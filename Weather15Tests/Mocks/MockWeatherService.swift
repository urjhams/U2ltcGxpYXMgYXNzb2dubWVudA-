//
//  MockWeatherService.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 11.11.24.
//

import XCTest
@testable import Weather15

class MockWeatherService: WeatherServiceProtocol {
  var fetchWeatherResult: Result<CityWeatherResponse, NetworkError>?
  var fetchWeathersFromCoreDataResult: Result<[CityWeather], Error>?
  var syncWeathersResult: Result<[CityWeather], Error>?
  
  func fetchWeather(of city: String, session: URLSession?, result: @escaping (Result<CityWeatherResponse, NetworkError>) -> Void) {
    if let rs = fetchWeatherResult {
      result(rs)
    } else {
      result(.failure(NetworkError.transportError))
    }
  }
  
  func fetchWeathersFromCoreData(completion: @escaping (Result<[CityWeather], Error>) -> Void) {
    if let result = fetchWeathersFromCoreDataResult {
      completion(result)
    } else {
      completion(.failure(MockError.noData))
    }
  }
  
  func syncWeathers(_ data: [CityWeather], completion: @escaping (Result<[CityWeather], Error>) -> Void) {
    if let result = syncWeathersResult {
      completion(result)
    } else {
      completion(.failure(MockError.noData))
    }
  }
  
  enum MockError: Error {
    case noData
  }
}
