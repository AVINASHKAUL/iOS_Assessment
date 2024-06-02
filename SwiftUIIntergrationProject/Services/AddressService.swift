//
//  AddressService.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 4/5/24.
//

import Foundation
import MapKit
import ReactiveSwift
import Combine

/*
 Examples of services that will return a CLLocation object using frameworks like RXSwift, ReactiveSwift, Combine, or just a completion
For example, if you wanted to use the publisher version to get the address from a string, use:
    let publisher = Environment.current.addressService.coordinatePublisher("address")
 
 TODO: use one of these services to convert an address string to CLLocation
 */
struct AddressService {
  var coordinates: (String) -> SignalProducer<CLLocation?, SimpleError> = coordinates
  var asyncCoordinate: (String) async throws -> CLLocation? = asyncCoordinate
  var coordinatePublisher: (String) -> AnyPublisher<CLLocation?, SimpleError> = coordinatePub
  // var coordinateRX: (String) -> Observable<CLLocation?> = coordinateObservable
  var coordinatesCompletion: (String, ((CLLocation?, SimpleError?) -> Void)?) -> () = coordinatesComp
}

extension AddressService {
  static var live = AddressService()
}

/*
 This service returns addresses in its various permutations.
 Returns SimpleError.address when address is not found
*/
extension AddressService {
  static func coordinatesComp(from address: String, completion: ((CLLocation?, SimpleError?) -> Void)?) {
    let geoCoder = CLGeocoder()
    geoCoder.geocodeAddressString(address) { (placemarks, error) in
      guard let placemarks = placemarks,
            let location = placemarks.first?.location else {
        completion?(nil, SimpleError.address)
        return
      }
      completion?(location, nil)
    }
  }
  
//  static func coordinateObservable(from address: String) -> Observable<CLLocation?> {
//    return Observable.create { observer in
//      let geoCoder = CLGeocoder()
//      geoCoder.geocodeAddressString(address) { (placemarks, error) in
//        guard let placemarks = placemarks,
//              let location = placemarks.first?.location else {
//          observer.onError(SimpleError.address)
//          return
//        }
//        observer.onNext(location)
//      }
//      return Disposables.create()
//    }
//  }
  
  static func asyncCoordinate(from address: String) async throws -> CLLocation? {
    let geocoder = CLGeocoder()
    
    guard let location = try? await geocoder.geocodeAddressString(address)
      .compactMap( { $0.location } )
      .first(where: { $0.horizontalAccuracy >= 0 } )
    else { throw SimpleError.address }
    return location
  }
  
  static func coordinatePub(from address: String) -> AnyPublisher<CLLocation?, SimpleError> {
    return Future<CLLocation?, SimpleError> { promise in
      let geoCoder = CLGeocoder()
      geoCoder.geocodeAddressString(address) { (placemarks, error) in
        guard let placemarks = placemarks,
              let location = placemarks.first?.location else {
          promise(.failure(.address))
          return
        }
        promise(.success(location))
      }
    }.eraseToAnyPublisher()
  }
  
  static func coordinates(from address: String) -> SignalProducer<CLLocation?, SimpleError>{
    return SignalProducer<CLLocation?, SimpleError> { observer, _ in
      let geoCoder = CLGeocoder()
      geoCoder.geocodeAddressString(address) { (placemarks, error) in
        guard let placemarks = placemarks,
              let location = placemarks.first?.location else {
          observer.send(error: .address)
          return
        }
        observer.send(value: location)
      }
    }
  }
}
