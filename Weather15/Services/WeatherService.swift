//
//  WeatherService.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import CoreData

class WeatherService {
  
  static let shared = WeatherService()
  
  lazy var container: NSPersistentContainer = {
    // persistentContainer
    let container = NSPersistentContainer(name: "Weather15")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.undoManager = nil
    container.viewContext.shouldDeleteInaccessibleFaults = true
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
}

// MARK: Fetch API
extension WeatherService {
  func fetchWeather(of city: String, result: @escaping (Result<Data, NetworkError>)->Void) {
    /// this is a sample app with a free and public weather service so I put the API key here, in the real use case, the secrect key
    /// must not be stored in the source code
    let key = "5ffcd8f8e469ee48581072a95ff9360f"
    let domain = "https://api.openweathermap.org"
    let weatherByCityName = "\(domain)/data/2.5/weather"
    let url = weatherByCityName + "?q=\(city)&appid=\(key)"
    
    Networking.shared.sendPostRequest(to: url) {
      result($0)
    }
  }
}


// MARK: CoreData
extension WeatherService {
  /// Creates and configures a private queue context.
  private func newTaskContext() -> NSManagedObjectContext {
    // Create a private queue context.
    let taskContext = container.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    taskContext.undoManager = nil
    return taskContext
  }
  
  /// From the full sets of weather that we want to sync, apply the batch inserts for new records
  ///  and batch update for existed records
  ///  This function runs synchronisely in the background context
  func syncWeathers(
    _ weathers: [CityWeatherEntity],
    completion: @escaping (Result<[CityWeatherEntity], Error>) -> Void
  ) {
    let backgroundContext = newTaskContext()
    
    backgroundContext.performAndWait {
      // fetch all the weather records
      
      // compare the result with `weathers` and split to the new records and needUpdated records
      
      // apply the batch update in a task context (if the array is not empty)
      
      // apply the batch insert in a task context (if the array is not empty)
      
      // save the context and merge change to the main context
      
      // do the fetch in the main context
      fetchWeathers(completion: completion)
    }
  }
  
  func fetchWeathers(completion: @escaping (Result<[CityWeatherEntity], Error>) -> Void) {
    container.viewContext.perform {
      // make the fetch request to fetch all the weather records
      
      // use the fetched record in the completion block
      
      // use the completion block for handle the reload in the view model
      
    }
  }
}
