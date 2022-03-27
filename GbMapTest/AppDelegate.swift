//
//  AppDelegate.swift
//  GbMapTest
//
//  Created by KKK on 08.03.2022.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? {
      didSet {
        window?.overrideUserInterfaceStyle = .light
      }
    }
    var appCoordinate: AppCoordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        GMSServices.provideAPIKey("AIzaSyAuW-cBcK81Fq22yEn92y_fdBeGL8n6qq0")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        appCoordinate = AppCoordinator(navigationController: navigationController)
        appCoordinate?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    



}

