//
//  AddressServiceMock.swift
//  SwiftUIIntergrationProjectTests
//
//  Created by Yuchen Nie on 4/10/24.
//

import Foundation
import MapKit
import ReactiveSwift
import Combine

@testable import SwiftUIIntergrationProject


struct AddressServiceMock: AddressService {
    func coordinatePub(from address: String) -> AnyPublisher<CLLocation?, SwiftUIIntergrationProject.SimpleError> {
        Just(CLLocation(latitude: 0, longitude: 0))
            .setFailureType(to: SimpleError.self) // Set the failure type to SimpleError.
            .eraseToAnyPublisher()
    }
}
