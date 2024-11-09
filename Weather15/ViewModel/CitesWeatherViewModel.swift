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
  
  var sorting: SortingType = .alphabet
  
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
  
  init(
    sorting: SortingType = .alphabet,
    dataChangeHandler: @escaping () -> Void
  ) {
    self.sorting = sorting
    self.dataChangeHandler = dataChangeHandler
  }
  
}

extension CitesWeatherViewModel {
  func fetchCitiesWeather(completion: @escaping (Error?) -> Void) {
    // create the dispatch group
    
    // for each city, add the request into dispach group
    
    // notify when all response
    
    // convert the response data to CityWeatherEntity
    
    // update the core data
    
    // if fail, completion with error
  }
  
  private func applyNewData(_ data: [CityWeatherEntity]) {
    // fetch the core data and split to new records and existed record using background context
    
    // batch insert the data of records that not existed in the core data
    
    // batch update the data of records that already existed in the core data
    
    // when done, fetch all the data from core data and apply it into cities
    
  }
}
