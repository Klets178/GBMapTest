//
//  LoginViewModel.swift
//  GbMapTest
//
//  Created by KKK on 23.03.2022.
//

import UIKit

class LoginViewModel {
    var appCoordinator: AppCoordinator?
    
    func gotoTrackController() {
        appCoordinator?.navigationController.navigationBar.isHidden = true
        appCoordinator?.goToTackView()
    }
    
    func gotoRegistrationController() {
        appCoordinator?.goToRegistrationView()
    }
    
}
