//
//  EnvironmentMock.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 4/9/24.
//

import Foundation
import ReactiveSwift

@testable import SwiftUIIntergrationProject

extension Environment {
  static var mock = {
    Environment(
      scheduler: TestScheduler(),
      backgroundScheduler: TestScheduler(),
      runLoop: .init(),
      weatherServiceReactive: WeatherServiceMock(), 
      addressService: AddressServiceMock()
    )
  }()
}
