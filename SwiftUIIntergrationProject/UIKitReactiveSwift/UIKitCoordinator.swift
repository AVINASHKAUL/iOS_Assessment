//
//  UIKitCoordinator.swift
//  SwiftUIIntergrationProject
//
//  Created by Avinash Kaul on 02/06/24.
//

import Foundation
import UIKit



class UIKitCoordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let viewModel = UIKitViewModel(weatherService: Environment.current.weatherServiceReactive, addressService: Environment.current.addressService)
        
        let viewController = UIKitController(viewModel: viewModel)
        
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
