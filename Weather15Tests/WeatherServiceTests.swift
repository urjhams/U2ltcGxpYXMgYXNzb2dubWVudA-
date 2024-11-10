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
  var network: Networking!
  var session: URLSession!
  
  override func setUp() {
    super.setUp()
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    
    network = Networking()
    
    weatherService = WeatherService(network)
  }
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    
    network = Networking()
    
    weatherService = WeatherService(network)
  }
  
  override func tearDown() {
    weatherService = nil
    network = nil
    session = nil
    MockURLProtocol.response = nil
    super.tearDown()
  }
  
  override func tearDownWithError() throws {
    weatherService = nil
    network = nil
    session = nil
    MockURLProtocol.response = nil
    try super.tearDownWithError()
  }
  
  func testFetchWeather() {
    let expect = expectation(description: "Fetch expected data")
    
    let testName = "non_real_city_name"
    let testCondition = "Test condition"
    
    let mockWeatherData = try! [
      CityWeatherResponse(
        coord: .init(lon: 0, lat: 0),
        weather: [
          .init(id: -1, main: "", description: testCondition, icon: "")
        ],
        main: .init(
          temp: 1, 
          feels_like: 1,
          temp_min: 1,
          temp_max: 1,
          pressure: 1,
          humidity: 1
        ),
        visibility: 0,
        wind: .init(speed: 1, deg: 1),
        clouds: .init(all: 1),
        dt: 1.0,
        sys: .init(country: "", sunrise: 1.0, sunset: 2.0),
        id: -1,
        name: testName
      )
    ].toJSON()
    
    let responseData = mockWeatherData.data(using: .utf8)
        
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=non_real_city_name&appid=5ffcd8f8e469ee48581072a95ff9360f"
    
    let response = HTTPURLResponse(
      url: URL(string: urlString)!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    
    MockURLProtocol.response = (data: responseData, urlResponse: response, error: nil)
    
    weatherService.fetchWeather(of: testName, session: session) { result in
      switch result {
      case .success(let response):
        XCTAssertEqual(response.name, testName)
      case .failure:
        XCTFail("Expected success, but got failure.")
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 0.5)
  }
  
  func testSyncWeathers() {
//    weatherService.syncWeathers(<#T##weathers: [CityWeatherEntity]##[CityWeatherEntity]#>, completion: <#T##(Result<[CityWeatherEntity], any Error>) -> Void#>)
  }
  
  func testFetchWeathersFromCoreData() {
    
  }
  
}
