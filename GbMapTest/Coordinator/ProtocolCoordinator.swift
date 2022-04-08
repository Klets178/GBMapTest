//
//  ProtocolCoordinator.swift
//  GbMapTest
//
//  Created by KKK on 24.03.2022.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start()
}
