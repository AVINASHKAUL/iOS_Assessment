//
//  Environment.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 4/8/24.
//

import Foundation
import ReactiveSwift

public struct Environment {
  var scheduler: ReactiveSwift.Scheduler = QueueScheduler(qos: .userInitiated, name: "userInitiated")
  var backgroundScheduler: DateScheduler = QueueScheduler(qos: .background, name: "background")
  var runLoop: RunLoop = .main
    
// AVINASH_TODO: Should replace this with a DI Container
  var weatherServiceReactive: WeatherService = WeatherServiceImpl()
  var addressService: AddressService = AddressServiceImpl()
}

public extension Environment {
  static var current = Environment()
}
