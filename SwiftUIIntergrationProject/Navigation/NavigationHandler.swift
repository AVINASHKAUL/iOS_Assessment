//
//  NavigationHandler.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 4/4/24.
//

import Foundation
import UIKit

extension UIViewController {
  func handle(action: DemoType) {
    switch action {
    case .uiKit:
      navigateUIKitView()
    case .swiftUI:
      navigateSwiftUIView()
    }
  }
  
  private func navigateUIKitView() {
      if let navigationController = self.navigationController {
          let coordinator = UIKitCoordinator(navigationController: navigationController)
          coordinator.start()
      }
  }
  
  private func navigateSwiftUIView() {
    let controller = SwiftUIController()
    navigationController?.pushViewController(controller, animated: true)
  }
}
