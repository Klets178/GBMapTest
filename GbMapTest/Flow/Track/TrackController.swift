//
//  ViewController.swift
//  GbMapTest
//
//  Created by KKK on 08.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import RxSwift
import RxCocoa

class TrackController: UIViewController {
    
    var trackviewModel: TrackViewModel?
    
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
   
    let locationManager = LocationManager.instance
    
    let disposeBag = DisposeBag()
    
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
        
//    var locationManager: CLLocationManager?
    
//    var geoCoder: CLGeocoder?
    
    var route = GMSPolyline()
    var routePath = GMSMutablePath()
    
    let distantionRealy = BehaviorSubject<Double>(value: 0.0)
//    var distantion = 0.0
    
    let isTracking  = BehaviorRelay<Bool>(value: false)

    
    @IBOutlet weak var ledTrack: UIImageView!
    
    @IBOutlet weak var distantionLabek: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func didTapEndTrackButton(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        if routePath.count() > 0 {
            ViewModel.instance.deleteAllRealm()
            ViewModel.instance.saveAllRealm(routePath: routePath)
            initTrack()
            isTracking.accept( false )
        }

    }
    
    @IBAction func didTapNewTrackButton(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        ViewModel.instance.deleteAllRealm()
        initTrack()
        isTracking.accept( true )
    }
    
    @IBAction func didTapViewTrackButton(_ sender: UIButton) {
        if isTracking.value {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "Остановлена запись трека!")
            locationManager.stopUpdatingLocation()
            isTracking.accept( false )
        }
        viewTrack()
        viewAllTrack(routePath: ViewModel.instance.readAllRealm())
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
//        configureBackround()
        
//        print("􀘰􀘰 realm = \n", Realm.Configuration.defaultConfiguration.fileURL!, "\n 􀘰􀘰")
        
        ViewModel.instance.deleteAllRealm()
        
        configureMap()
        configureLocationManager()
        
        subscriptionLocationManager()

        isTrackingObservable()
        
        setDistantionRelay()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.settings.zoomGestures = true
//        addMarker()
//        locationManager.requestLocation()
    }
    
    
    
    func initTrack() {
        // Отвязываем от карты старую линию
        route.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
//        route.map = mapView
        distantionRealy.onNext(-1)
    }
    

    
    func addMarker(newCoordinate: CLLocationCoordinate2D) {
        marker = GMSMarker(position: newCoordinate)
        
        marker?.icon = UIImage.init(systemName: "figure.wave")
//        marker?.icon = UIImage.init(systemName: "car.fill")
//        marker?.icon = GMSMarker.markerImage(with: .red)
        marker?.map = mapView

    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func viewAllTrack(routePath: GMSMutablePath) {
        var bounds = GMSCoordinateBounds()
        for i in 0..<routePath.count() {
            self.routePath.add(routePath.coordinate(at: i))
            self.route.path = routePath
            bounds = bounds.includingCoordinate(routePath.coordinate(at: i))
            viewTrack()
        }

        mapView.moveCamera(GMSCameraUpdate.fit(bounds))
    }
    
    func viewTrack() {
        route.strokeColor = .red
        route.strokeWidth = 3.0
        route.geodesic = true
        route.map = mapView
        
        let pathLen = GMSGeometryLength(routePath)
//        distantion = distantion + round(pathLen)
        
//        distantionLabek.text = "Растояние: \(distantion) м"
        
//        distantionRealy.accept(round(pathLen))
        distantionRealy
            .asObserver()
            .onNext(round(pathLen))
 
    }
    
    func configureMap() {
//        let camera = GMSCameraPosition(target: coordinate, zoom: 15)
//        mapView.camera = camera
        
//        mapView.isMyLocationEnabled = true
        
//        mapView.settings.myLocationButton = true
        
        mapView.delegate = self
    }
    
    
    
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] (location) in
                guard let location = location else { return }
                self?.routePath.add(location.coordinate)
                self?.route.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
                self?.removeMarker()
                self?.addMarker(newCoordinate: location.coordinate)
                self?.viewTrack()
            }
            .disposed(by: disposeBag)
    }
    
    
    func subscriptionLocationManager() {
        locationManager
            .location
            .subscribe { (event) in print("location=", event) }
            .disposed(by: disposeBag)
    }
    
}

extension TrackController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("coordinate=",coordinate)
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let manualMarker  = GMSMarker(position: coordinate)
            manualMarker.map = mapView
        }
//        myAdd(newCoordinate: coordinate)
    }
}

extension TrackController {
    func isTrackingObservable() {
        isTracking
            .asObservable()
            .bind { [weak self] (bool) in
                guard let self = self else { return }
                if bool {
                    self.ledTrack.image = UIImage(systemName: "xmark.circle.fill")
                    self.ledTrack.tintColor = .red
                } else {
                    self.ledTrack.image = UIImage(systemName: "checkmark.circle.fill")
                    self.ledTrack.tintColor = .blue
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setDistantionRelay() {
        distantionRealy
            .asObservable()
        
            .scan(0.0) { val1, val2 in
                if val2 == -1 { return 0 }
                else {return val1 + val2}
            }
//            .compactMap{ $0.flatMap(String.init) }
            .bind(onNext: { self.distantionLabek.text = "Растояние: \($0) м"})
            .disposed(by: disposeBag)
    }
    
}
