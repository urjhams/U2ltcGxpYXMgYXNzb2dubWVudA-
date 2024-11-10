//
//  CitesWeatherViewModel.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation
import CoreData

class CitesWeatherViewModel {
  
  enum SortingType {
    case alphabet
    case temperature
  }
  
  var sorting: SortingType = .alphabet {
    didSet {
      switch sorting {
      case .alphabet:
        sortedCities.sort { $0.name <= $1.name }
      case .temperature:
        sortedCities.sort { $0.temp <= $1.temp }
      }
      sortingChangeHandler(sorting)
    }
  }
  
  var cities = [CityWeather]() {
    didSet {
      sortedCities = switch sorting {
      case .alphabet:
        cities.sorted { $0.name <= $1.name }
      case .temperature:
        cities.sorted { $0.temp <= $1.temp }
      }
    }
  }
  
  var sortedCities = [CityWeather]() {
    didSet {
      dataChangeHandler()
    }
  }
  
  private let dataChangeHandler: () -> Void
  
  private let sortingChangeHandler: (SortingType) -> Void
  
  private let errorHandler: (Error) -> Void
  
  init(
    sorting: SortingType = .alphabet,
    dataChangeHandler: @escaping () -> Void,
    sortingChangeHandler: @escaping (SortingType) -> Void,
    errorHandler: @escaping (Error) -> Void
  ) {
    self.sorting = sorting
    self.dataChangeHandler = dataChangeHandler
    self.sortingChangeHandler = sortingChangeHandler
    self.errorHandler = errorHandler
  }
  
}

extension CitesWeatherViewModel {
  
  func fetchCitiesWeather(
    from names: [String],
    completion: @escaping ([CityWeather], [Error]) -> Void
  ) {
    // create the dispatch group
    var weatherDataArray: [CityWeather] = []
    var errors: [Error] = []
    let dispatchGroup = DispatchGroup()
    let dataQueue = DispatchQueue(label: "com.yourapp.weatherdataqueue")
    
    for name in names {
      // for each city, add the request into dispach group
      dispatchGroup.enter()
      WeatherService.shared.fetchWeather(of: name) { result in
        dataQueue.async {
          switch result {
          case .success(let response):
            // convert the response data to CityWeatherEntity
            weatherDataArray.append(response.toCityWeatherModel())
            dispatchGroup.leave()
          case .failure(let error):
            errors.append(error)
            dispatchGroup.leave()
          }
        }
      }
    }
    
    // notify when all response
    dispatchGroup.notify(queue: .main) {
      // All network requests have completed
      completion(weatherDataArray, errors)
    }
  }
  
  func getWeathers() {
    WeatherService.shared.fetchWeathersFromCoreData { result in
      DispatchQueue.main.async { [weak self] in
        guard let self else {
          return
        }
        switch result {
        case .success(let newVersion):
          cities = newVersion
        case .failure(let error):
          errorHandler(error)
        }
      }
    }
  }
  
  func applyNewData(_ data: [CityWeather]) {
    WeatherService.shared.syncWeathers(data) { result in
      DispatchQueue.main.async { [weak self] in
        switch result {
        case .success(let newVersion):
          self?.cities = newVersion
        case .failure(let error):
          self?.errorHandler(error)
        }
      }
    }
  }
  
  func toggleSorting() {
    sorting = switch sorting {
    case .alphabet:
        .temperature
    case .temperature:
        .alphabet
    }
  }
}
