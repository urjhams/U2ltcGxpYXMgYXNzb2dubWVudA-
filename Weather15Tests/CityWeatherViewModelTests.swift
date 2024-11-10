//
//  CityWeatherViewModelTests.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 11.11.24.
//

import XCTest
@testable import Weather15

final class CityWeatherViewModelTests: XCTestCase {

  var viewModel: CitesWeatherViewModel!
  var mockWeatherService: MockWeatherService!
  var dataChangeHandlerCalled: Bool!
  var sortingChangeHandlerCalled: Bool!
  var errorHandlerCalled: Bool!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    dataChangeHandlerCalled = false
    sortingChangeHandlerCalled = false
    errorHandlerCalled = false
    
    viewModel = CitesWeatherViewModel(
      sorting: .alphabet,
      dataChangeHandler: { [weak self] in
        self?.dataChangeHandlerCalled = true
      },
      sortingChangeHandler: { [weak self] _ in
        self?.sortingChangeHandlerCalled = true
      },
      errorHandler: { [weak self] _ in
        self?.errorHandlerCalled = true
      }
    )
    
    mockWeatherService = MockWeatherService()
  }
  
  override func tearDownWithError() throws {
    viewModel = nil
    mockWeatherService = nil
   try  super.tearDownWithError()
  }
  
  func testFetchCitiesWeatherSuccess() {
    // Given
    let expectation = self.expectation(description: "FetchCitiesWeatherSuccess")
    let weatherResponse = CityWeatherResponse(
      coord: .init(lon: 0, lat: 0),
      weather: [
        .init(id: -1, main: "", description: "test condition", icon: "")
      ],
      main: .init(
        temp: 25,
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
      name: "TestCity"
    )
    mockWeatherService.fetchWeatherResult = .success(weatherResponse)
    
    // When
    viewModel.fetchCitiesWeather(service: mockWeatherService, from: ["TestCity"]) { cities, errors in
      // Then
      XCTAssertEqual(cities.count, 1)
      XCTAssertEqual(cities.first?.name, "TestCity")
      XCTAssertEqual(cities.first?.temp, 25)
      XCTAssertEqual(errors.count, 0)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testFetchCitiesWeatherFailure() {
    // Given
    let expectation = self.expectation(description: "FetchCitiesWeatherFailure")
    mockWeatherService.fetchWeatherResult = .failure(NetworkError.transportError)
    
    // When
    viewModel.fetchCitiesWeather(service: mockWeatherService, from: ["TestCity"]) { cities, errors in
      // Then
      XCTAssertEqual(cities.count, 0)
      XCTAssertEqual(errors.count, 1)
      XCTAssertTrue(errors.first is NetworkError)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testToggleSorting() {
    // Given
    viewModel.sorting = .alphabet
    sortingChangeHandlerCalled = false
    
    // When
    viewModel.toggleSorting()
    
    // Then
    XCTAssertEqual(viewModel.sorting, .temperature)
    XCTAssertTrue(sortingChangeHandlerCalled)
  }
  
  func testCitiesSortingAlphabetically() {
    // Given
    let city1 = CityWeather(humidity: 0, temp: 10, name: "Berlin")
    let city2 = CityWeather(humidity: 1, temp: 15, name: "Amsterdam")
    let city3 = CityWeather(humidity: 2, temp: 5, name: "Copenhagen")
    viewModel.sorting = .alphabet
    dataChangeHandlerCalled = false
    
    // When
    viewModel.cities = [city1, city2, city3]
    
    // Then
    XCTAssertEqual(viewModel.sortedCities.map { $0.name }, ["Amsterdam", "Berlin", "Copenhagen"])
    XCTAssertTrue(dataChangeHandlerCalled)
  }
  
  func testCitiesSortingByTemperature() {
    // Given
    let city1 = CityWeather(humidity: 10, temp: 10, name: "Berlin")
    let city2 = CityWeather(humidity: 20, temp: 15, name: "Amsterdam")
    let city3 = CityWeather(humidity: 30, temp: 5, name: "Copenhagen")
    viewModel.sorting = .temperature
    dataChangeHandlerCalled = false
    
    // When
    viewModel.cities = [city1, city2, city3]
    
    // Then
    XCTAssertEqual(viewModel.sortedCities.map { $0.temp }, [5, 10, 15])
    XCTAssertTrue(dataChangeHandlerCalled)
  }
}
