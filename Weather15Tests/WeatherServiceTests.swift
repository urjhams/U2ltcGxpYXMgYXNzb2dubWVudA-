//
//  WeatherServiceTest.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 10.11.24.
//

import XCTest
@testable import Weather15

final class WeatherServiceTests: XCTestCase {
  
  var weatherService: WeatherService!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  override func setUp() {
    super.setUp()
    weatherService = WeatherService.generateInstance()
  }
  
  override func tearDown() {
    weatherService = nil
    super.tearDown()
  }
  
  func testSyncWeather() throws {
    weatherService.syncWeathers(<#T##weathers: [CityWeatherEntity]##[CityWeatherEntity]#>, completion: <#T##(Result<[CityWeatherEntity], any Error>) -> Void#>)
  }
  
}
