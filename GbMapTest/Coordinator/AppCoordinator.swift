//
//  AppCoordinator.swift
//  GbMapTest
//
//  Created by KKK on 24.03.2022.
//

import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        goToLoginView()
    }
    
    var stroryboard = UIStoryboard(name: "Main", bundle: .main)
    
    func goToTackView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "TrackController") as? TrackController else { return }

        let viewModel = TrackViewModel()
        viewModel.appCoordinator = self

        controller.trackviewModel = viewModel
        navigationController.pushViewController(controller, animated: true)
    }
    
    func goToLoginView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "LoginController") as? LoginController else { return }
        
       controller.onLogin = { [weak self] (login, password) in
            ViewModel.instance.loginUser(login: login, password: password)
        }
        
        let viewModel = LoginViewModel()
        viewModel.appCoordinator = self
        
        controller.loginViewModel = viewModel
        navigationController.pushViewController(controller, animated: true)

    }
   
    func goToRegistrationView() {
        guard let controller = stroryboard.instantiateViewController(withIdentifier: "RegistrationController") as? RegistrationController else { return }
        
        
        controller.onRegistration = { [weak self] (login, password) in
            ViewModel.instance.registrationUser(login: login, password: password)
        }
        
        
        let viewModel = RegistrationViewModel()
        viewModel.appCoordinator = self
        
        controller.registrationViewModel = viewModel
        navigationController.pushViewController(controller, animated: true)

    }
    
}
