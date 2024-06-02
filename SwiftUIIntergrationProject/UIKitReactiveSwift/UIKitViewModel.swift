//
//  UIKitViewModel.swift
//  SwiftUIIntergrationProject
//
//  Created by Avinash Kaul on 02/06/24.
//

import Foundation
import Combine
import CoreLocation

class UIKitViewModel {
    
    @Published
    private (set) var viewData: ViewData = ViewData(addresses: ["201012", "180013", "180001"], selectedAddress: (name: "Address 1", secondary: "Cloudy weather", currentTemperature: "Current Temprature: 72F"), weathers: [])
    
    // MARK: All the services consumed by viewModel
    private let weatherSerivce: WeatherService
    private let addressService: AddressService
    private var cancelBag = Set<AnyCancellable>()
    
    @Published
    private var currentLocation: CLLocation?
    
    init(weatherService: WeatherService, addressService: AddressService) {
        self.weatherSerivce = weatherService
        self.addressService = addressService
        currentLocationObserver()
    }
    
    struct ViewData {
        var addresses: [String]
        var selectedAddress: (name: String, secondary:String, currentTemperature: String)
        var weathers: [WeatherListItemViewdata]?
    }
    
    // TODO_AVINASH: We need to make this equatable so in viewController we don't do tableView.reload everytime rest of the viewController changes
    struct WeatherListItemViewdata {
        var date: String
        var time: String
        var secondary: String
        var temprature: String
    }
    
    // AVINASH_TODO: Change the following logic to better
    public func onSelectAddress(name: String) {
        viewData.selectedAddress.name = name
        self.onAddressSelect(address: name)
    }
    
    // AVINASH_TODO: need to replace the location with something else e.g CLLocation
    private func onAddressSelect(address: String) {
        AddressService.coordinatePub(from: address).sink { completion in
            switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("Error: \(error)")
            }
        } receiveValue: { location in
            if let location = location {
                self.currentLocation = location
                print("Received location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            } else {
                print("Received nil location")
            }
        }.store(in: &cancelBag)

    }
    
    private func currentLocationObserver(){
        $currentLocation.sink { [weak self] location in
            guard let location, let self else { return }
            fetchCurrentWeatherData(location: location)
            fetchForecastWeatherData(location: location)
        }.store(in: &cancelBag)
    }
    
    private func fetchCurrentWeatherData(location: CLLocation){
        weatherSerivce.retrieveCurrentWeather(location: location).sink { completion in
            switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("Error: \(error)")
            }
        } receiveValue: { [weak self] currentWeatherData in
            guard let self else { return }
            updateCurrentWeatherViewData(data: currentWeatherData)
        }.store(in: &cancelBag)

    }
    
    private func fetchForecastWeatherData(location: CLLocation) {
        weatherSerivce.retrieveWeatherForecast(location: location).sink { completion in
            switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("Error: \(error)")
            }
        } receiveValue: { [weak self] forecastJSONData in
            guard let self else { return }
            updateForeCastWeatherViewData(data: forecastJSONData)
        }.store(in: &cancelBag)
    }
    
    
    // AVINASH_TODO: For performance we might want to following operations together, we should handle emppty state
    
    func updateCurrentWeatherViewData(data: CurrentWeatherJSONData?){
        guard let data = data else { return }
        viewData.selectedAddress.name = data.name
        // viewData.selectedAddress.secondary = data.main.
        viewData.selectedAddress.currentTemperature = "Current Temprature: \(data.main.temp)"
        
    }
    
    func updateForeCastWeatherViewData(data: ForecastJSONData?) {
        guard let data = data else { return }
        var weatherList = [WeatherListItemViewdata]()
        for item in data.list {
            var weatherListItem = WeatherListItemViewdata(date: item.displayDate, time: "", secondary: item.rain != nil ? "Light Rain" : "No Rain"  , temprature: "Temprature: \(item.temperatures.temp)F")
            weatherList.append(weatherListItem)
        }
        self.viewData.weathers = weatherList
    }
}

