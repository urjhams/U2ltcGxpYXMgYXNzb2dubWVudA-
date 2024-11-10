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
  
  private let names = ["London", "Berlin", "Stockholm", "Barcelona", "Amsterdam", "Doha", "New York"]
  
  var sorting: SortingType = .alphabet {
    didSet {
      switch sorting {
      case .alphabet:
        sortedCities.sort { $0.name ?? "" <= $1.name ?? "" }
      case .temperature:
        sortedCities.sort { $0.temp <= $1.temp }
      }
    }
  }
  
  var cities = [CityWeatherEntity]() {
    didSet {
      sortedCities = switch sorting {
      case .alphabet:
        cities.sorted { $0.name ?? "" <= $1.name ?? "" }
      case .temperature:
        cities.sorted { $0.temp <= $1.temp }
      }
    }
  }
  
  var sortedCities = [CityWeatherEntity]() {
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
  func fetchCitiesWeather(completion: @escaping (Result<Void, Error>) -> Void) {
    // create the dispatch group
    
    // for each city, add the request into dispach group
    
    // notify when all response
    
    // convert the response data to CityWeatherEntity
    
    // update the core data
    
    // if fail, completion with error
  }
  
  func getWeathers(completion: @escaping (Result<Void, Error>) -> Void) {
    
  }
  
  private func applyNewData(_ data: [CityWeatherEntity]) {
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
