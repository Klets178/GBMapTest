//
//  ViewModel.swift
//  GbMapTest
//
//  Created by KKK on 22.03.2022.
//

import UIKit
import GoogleMaps

class ViewModel {
    
    static let instance = ViewModel()
    private init(){}
    

    func saveRealm(count: UInt, coordinate: CLLocationCoordinate2D) {
        let coordinateRealm =  CoordinateRealm()
        coordinateRealm.uid = Int(count)
        coordinateRealm.latitude = coordinate.latitude
        coordinateRealm.longitude = coordinate.longitude
        
        RealmWork.instance.saveItems(coordinates: coordinateRealm)
    }
    
    func saveAllRealm(routePath: GMSMutablePath) {
        for i in 0..<routePath.count() {
            saveRealm(count: i, coordinate: routePath.coordinate(at: i))
        }
        
    }
    
    func deleteAllRealm() {
        RealmWork.instance.deleteAllItems()
    }
    
    func readAllRealm() -> GMSMutablePath {
        let routePath = GMSMutablePath()
        let coord = RealmWork.instance.readItems()
        
            coord.forEach { coordinateRealm in
                routePath.add(CLLocationCoordinate2DMake(coordinateRealm.latitude, coordinateRealm.longitude))
            }
        return routePath
    }

    
    
}

