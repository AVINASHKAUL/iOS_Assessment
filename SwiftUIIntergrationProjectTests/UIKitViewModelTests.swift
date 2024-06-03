//
//  UIKitViewModelTests.swift
//  SwiftUIIntergrationProjectTests
//
//  Created by Avinash Kaul on 03/06/24.
//

import XCTest
import Combine

@testable import SwiftUIIntergrationProject

final class UIKitViewModelTests: XCTestCase {

    var viewModel: UIKitViewModel!
    var cancelBag = Set<AnyCancellable>()
    
    override func setUp() {
        self.viewModel = UIKitViewModel(weatherService: Environment.mock.weatherServiceReactive, addressService: Environment.mock.addressService)
    }

    func testSelectedAddress() {
        let expectation = self.expectation(description: "current Weather address updated")
        viewModel.$viewData.sink { [weak self] viewData in
            guard let self else { return }
            if viewData.selectedAddress.name == "test" {
                expectation.fulfill()
                cancelBag.removeAll()
            }
        }.store(in: &cancelBag)
        viewModel.onSelectAddress(name: "test")
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCurrentTemprature() {
        let expectation = self.expectation(description: "current Weather address updated")
        viewModel.$viewData.sink { [weak self] viewData in
            guard let self else { return }
            if viewData.selectedAddress.currentTemperature == "Current Temprature: 59.65" {
                expectation.fulfill()
                cancelBag.removeAll()
            }
        }.store(in: &cancelBag)
        viewModel.onSelectAddress(name: "test")
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testForecastTemprature() {
        let expectation = self.expectation(description: "current Weather address updated")
        viewModel.$viewData.sink { [weak self] viewData in
            guard let self else { return }
            if viewData.weathers?.count == 9{
                expectation.fulfill()
                cancelBag.removeAll()
            }
        }.store(in: &cancelBag)
        viewModel.onSelectAddress(name: "test")
        wait(for: [expectation], timeout: 5.0)
    }
}
