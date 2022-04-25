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

class TrackController: UIViewController {
    
    var trackviewModel: TrackViewModel?
    
    var coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var geoCoder: CLGeocoder?
    
    var route = GMSPolyline()
    var routePath = GMSMutablePath()
    
//    var timer: Timer?
//    var backgroundTask: UIBackgroundTaskIdentifier?
    
    var distantion = 0.0
    
    var isTracking = false {
        willSet {
            if newValue {
                ledTrack.image = UIImage(systemName: "xmark.circle.fill")
                ledTrack.tintColor = .red
            } else {
                ledTrack.image = UIImage(systemName: "checkmark.circle.fill")
                ledTrack.tintColor = .blue

            }
        }
    }
    
    @IBOutlet weak var ledTrack: UIImageView!
    
    @IBOutlet weak var distantionLabek: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func didTapEndTrackButton(_ sender: Any) {
        locationManager?.stopUpdatingLocation()
        if routePath.count() > 0 {
            ViewModel.instance.deleteAllRealm()
            ViewModel.instance.saveAllRealm(routePath: routePath)
            initTrack()
            isTracking = false
        }

    }
    
    @IBAction func didTapNewTrackButton(_ sender: UIButton) {
        locationManager?.startUpdatingLocation()
        ViewModel.instance.deleteAllRealm()
        initTrack()
        isTracking = true
    }
    
    @IBAction func didTapViewTrackButton(_ sender: UIButton) {
        if isTracking {
            MesssageView.instance.alertMain(view: self, title: "Attention", message: "Остановлена запись трека!")
            locationManager?.stopUpdatingLocation()
            isTracking = false
        }
        viewAllTrack(routePath: ViewModel.instance.readAllRealm())
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
//        configureBackround()
        
//        print("􀘰􀘰 realm = \n", Realm.Configuration.defaultConfiguration.fileURL!, "\n 􀘰􀘰")
        ViewModel.instance.deleteAllRealm()
        
        configureLacationManager()
        configureMap()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.settings.zoomGestures = true
//        addMarker()
    }
    
//    func configureBackround() {
//        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            guard let strongSelf = self else { return }
//
//            UIApplication.shared.endBackgroundTask(strongSelf.backgroundTask!)
//            strongSelf.backgroundTask = UIBackgroundTaskIdentifier.invalid
//        }
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
//            print(Date())
//        })
//
//    }
    
    
    func initTrack() {
        // Отвязываем от карты старую линию
        route.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
//        route.map = mapView
    }
    
    func configureLacationManager(){
        locationManager = CLLocationManager()
        locationManager?.activityType = .automotiveNavigation
        locationManager?.delegate = self
        
//        locationManager?.distanceFilter = 20
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
//        locationManager?.requestWhenInUseAuthorization()
        
        locationManager?.requestLocation()
        
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
        distantion = distantion + round(pathLen)
        
        distantionLabek.text = "Растояние: \(distantion) м"
    }
    
    func configureMap() {
//        let camera = GMSCameraPosition(target: coordinate, zoom: 15)
//        mapView.camera = camera
        
//        mapView.isMyLocationEnabled = true
        
//        mapView.settings.myLocationButton = true
        
        mapView.delegate = self
    }
    
    func myAdd(newCoordinate: CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        path.add(coordinate)
        path.add(newCoordinate)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .red
        polyline.strokeWidth = 3.0
        polyline.geodesic = true
        polyline.map = mapView
        
        let pathLen = GMSGeometryLength(path)
        distantion = distantion + round(pathLen)
        
        distantionLabek.text = "Растояние: \(distantion) м"

        print("distantion = \(distantion)км")
        
//        coordinate = newCoordinate
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

extension TrackController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Берём последнюю точку из полученного набора
        guard let location = locations.last else { return } // Добавляем её в путь маршрута

        routePath.add(location.coordinate)
        // Обновляем путь у линии маршрута путём повторного присвоения
        route.path = routePath
        // Чтобы наблюдать за движением, установим камеру на только что добавленную точку
        
        print("routePath =", routePath.count())
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        mapView.animate(to: position)
        
        viewTrack()
        removeMarker()
        addMarker(newCoordinate: location.coordinate)
        
        coordinate = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
