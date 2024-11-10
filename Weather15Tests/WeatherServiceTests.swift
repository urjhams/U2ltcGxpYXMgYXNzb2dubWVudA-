//
//  WeatherServiceTest.swift
//  Weather15Tests
//
//  Created by Quân Đinh on 10.11.24.
//

import XCTest
@testable import Weather15
import CoreData

final class WeatherServiceTests: XCTestCase {
  
  var weatherService: WeatherService!
  var testPersistentContainer: NSPersistentContainer!
  
  override func setUp() {
    super.setUp()
    
    // Initialize in-memory persistent container
    testPersistentContainer = NSPersistentContainer(name: "Weather15")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    testPersistentContainer.persistentStoreDescriptions = [description]
    
    let expectation = self.expectation(description: "Persistent container load")
    testPersistentContainer.loadPersistentStores { (description, error) in
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
        
    weatherService = WeatherService(container: testPersistentContainer)
  }
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    // Initialize in-memory persistent container
    testPersistentContainer = NSPersistentContainer(name: "Weather15")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    testPersistentContainer.persistentStoreDescriptions = [description]
    
    let expectation = self.expectation(description: "Persistent container load")
    testPersistentContainer.loadPersistentStores { (description, error) in
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
        
    weatherService = WeatherService(container: testPersistentContainer)
  }
  
  override func tearDown() {
    weatherService = nil
    MockURLProtocol.response = nil
    testPersistentContainer = nil
    super.tearDown()
  }
  
  override func tearDownWithError() throws {
    weatherService = nil
    MockURLProtocol.response = nil
    testPersistentContainer = nil
    try super.tearDownWithError()
  }
  
  func testSyncWeathersInsertsNewWeathers() {
    let expectation = self.expectation(description: "Sync weathers inserts new data")
    
    // Prepare test data
    let weathers = [
      CityWeather(humidity: 50, temp: 25, condition: "Sunny", name: "City1"),
      CityWeather(humidity: 80, temp: 18, condition: "Rainy", name: "City2")
    ]
    
    weatherService.syncWeathers(weathers) { result in
      switch result {
      case .success(let syncedWeathers):
        XCTAssertEqual(syncedWeathers.count, weathers.count, "Synced weathers count should match input")
        self.weatherService.fetchWeathersFromCoreData { fetchResult in
          switch fetchResult {
          case .success(let fetchedWeathers):
            XCTAssertEqual(fetchedWeathers.count, weathers.count, "Fetched weathers count should match input")
            expectation.fulfill()
          case .failure(let error):
            XCTFail("Failed to fetch weathers: \(error)")
          }
        }
      case .failure(let error):
        XCTFail("Failed to sync weathers: \(error)")
      }
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testSyncWeathersUpdatesExistingWeathers() {
    let expectation = self.expectation(description: "Sync weathers updates existing data")
    
    // Initial data
    let initialWeathers = [
      CityWeather(humidity: 50, temp: 25, condition: "Sunny", name: "City1"),
      CityWeather(humidity: 80, temp: 18, condition: "Rainy", name: "City2")
    ]
    
    // Sync initial data
    weatherService.syncWeathers(initialWeathers) { result in
      switch result {
      case .success:
        // Updated data
        let updatedWeathers = [
          CityWeather(humidity: 60, temp: 22, condition: "Cloudy", name: "City1"),
          CityWeather(humidity: 90, temp: 16, condition: "Stormy", name: "City2")
        ]
        
        self.weatherService.syncWeathers(updatedWeathers) { updateResult in
          switch updateResult {
          case .success(let syncedWeathers):
            XCTAssertEqual(syncedWeathers.count, updatedWeathers.count, "Synced weathers count should match updated input")
            for weather in syncedWeathers {
              if let updatedWeather = updatedWeathers.first(where: { $0.name == weather.name }) {
                XCTAssertEqual(weather.condition, updatedWeather.condition, "Weather condition should be updated")
                XCTAssertEqual(weather.humidity, updatedWeather.humidity, "Weather humidity should be updated")
                XCTAssertEqual(weather.temp, updatedWeather.temp, "Weather temperature should be updated")
              } else {
                XCTFail("Unexpected city name: \(weather.name)")
              }
            }
            expectation.fulfill()
          case .failure(let error):
            XCTFail("Failed to sync updated weathers: \(error)")
          }
        }
      case .failure(let error):
        XCTFail("Failed to sync initial weathers: \(error)")
      }
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testFetchWeathersFromCoreDataReturnsCorrectWeathers() {
    let expectation = self.expectation(description: "Fetch weathers from Core Data")
    
    // Insert test data directly into Core Data
    let context = testPersistentContainer.viewContext
    let entity1 = CityWeatherEntity(context: context)
    entity1.name = "City1"
    entity1.condition = "Sunny"
    entity1.humidity = 50
    entity1.temp = 25
    
    let entity2 = CityWeatherEntity(context: context)
    entity2.name = "City2"
    entity2.condition = "Rainy"
    entity2.humidity = 80
    entity2.temp = 18
    
    do {
      try context.save()
    } catch {
      XCTFail("Failed to save context: \(error)")
    }
    
    weatherService.fetchWeathersFromCoreData { result in
      switch result {
      case .success(let weathers):
        XCTAssertEqual(weathers.count, 2, "Fetched weathers count should be 2")
        for weather in weathers {
          if weather.name == "City1" {
            XCTAssertEqual(weather.condition, "Sunny")
            XCTAssertEqual(weather.humidity, 50)
            XCTAssertEqual(weather.temp, 25)
          } else if weather.name == "City2" {
            XCTAssertEqual(weather.condition, "Rainy")
            XCTAssertEqual(weather.humidity, 80)
            XCTAssertEqual(weather.temp, 18)
          } else {
            XCTFail("Unexpected city name: \(weather.name)")
          }
        }
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Failed to fetch weathers: \(error)")
      }
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
}
