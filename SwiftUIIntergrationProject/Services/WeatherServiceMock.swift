//
//  WeatherServiceMock.swift
//  SwiftUIIntergrationProject
//
//  Created by Avinash Kaul on 03/06/24.
//

import Foundation
import CoreLocation
import Combine

struct WeatherServiceMock: WeatherService {
    func retrieveWeatherForecast(location: CLLocation) -> DataPublisher<ForecastJSONData?> {
       return  Just(ForecastJSONData.createMock())
            .setFailureType(to: SimpleError.self)
            .eraseToAnyPublisher()
    }
    
    func retrieveCurrentWeather(location: CLLocation) -> DataPublisher<CurrentWeatherJSONData?> {
        return  Just(CurrentWeatherJSONData.createMock())
             .setFailureType(to: SimpleError.self)
             .eraseToAnyPublisher()
    }
}
