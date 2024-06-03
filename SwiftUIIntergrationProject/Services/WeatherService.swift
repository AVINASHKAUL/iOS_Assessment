import Foundation
import Combine
import MapKit

  // TODO: Fill in this to retrieve current weather, and 5 day forecast by passing in a CLLocation
  ///ForecastJSONData and CurrentWeatherJSONData are the data types returned from Open Weather Service
 // AVINASH_TODO: let's make a DI Container for this
protocol WeatherService {
    func retrieveWeatherForecast(location: CLLocation) -> DataPublisher<ForecastJSONData?>
    func retrieveCurrentWeather(location: CLLocation) -> DataPublisher<CurrentWeatherJSONData?>
}

struct WeatherServiceImpl: WeatherService {
  /// Example function signatures. Takes in location and returns publishers that contain
//  var retrieveWeatherForecast: (CLLocation) -> DataPublisher<ForecastJSONData?>
//  var retrieveCurrentWeather: (CLLocation) -> DataPublisher<CurrentWeatherJSONData?>
    
    func retrieveWeatherForecast(location: CLLocation) -> DataPublisher<ForecastJSONData?> {
        guard let url = forecastURL(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) else {
            return Fail(error: SimpleError.invalidUrl).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { _ in SimpleError.requestFailed }
            .tryMap{ data, response -> ForecastJSONData? in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw SimpleError.invalidResponse
                }
                return try? JSONDecoder().decode(ForecastJSONData.self, from: data)
            }
            .mapError { error -> SimpleError in
                if let simpleError = error as? SimpleError {
                    return simpleError
                } else {
                    return SimpleError.decodingFailed
                }
            }
            .eraseToAnyPublisher()
    }
    
    func retrieveCurrentWeather(location: CLLocation) -> DataPublisher<CurrentWeatherJSONData?> {
        guard let url = currentWeatherURL(location: location) else {
            return Fail(error: SimpleError.invalidUrl).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { _ in SimpleError.requestFailed }
            .tryMap{ data, response -> CurrentWeatherJSONData? in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw SimpleError.invalidResponse
                }
                return try? JSONDecoder().decode(CurrentWeatherJSONData.self, from: data)
            }
            .mapError { error -> SimpleError in
                if let simpleError = error as? SimpleError {
                    return simpleError
                } else {
                    return SimpleError.decodingFailed
                }
            }
            .eraseToAnyPublisher()
    }
    
}

