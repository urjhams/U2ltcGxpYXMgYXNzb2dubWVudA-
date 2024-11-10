//
//  WeatherService.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import CoreData

protocol WeatherServiceProtocol {
  func fetchWeather(
    of city: String,
    session: URLSession?, 
    result: @escaping (Result<CityWeatherResponse, NetworkError>) -> Void
  )
  
  func fetchWeathersFromCoreData(completion: @escaping (Result<[CityWeather], Error>) -> Void)
  
  func syncWeathers(
    _ weathers: [CityWeather],
    completion: @escaping (Result<[CityWeather], Error>) -> Void
  )
}

enum ServiceError: Error {
  case unableToUpdate
  case fetchingError
}

class WeatherService: WeatherServiceProtocol {
  
  static let shared = WeatherService()
  
  private let networking: Networking
  
  let container: NSPersistentContainer
  
  init(_ network: Networking = .shared, container: NSPersistentContainer? = nil) {
    self.networking = network
    if let container {
      self.container = container
    } else {
      // persistentContainer
      let container = NSPersistentContainer(name: "Weather15")
      
      guard let _ = container.persistentStoreDescriptions.first else {
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
      self.container = container
    }
  }
  
}

// MARK: Fetch API
extension WeatherService {
  func fetchWeather(
    of city: String,
    session: URLSession? = nil,
    result: @escaping (Result<CityWeatherResponse, NetworkError>) -> Void
  ) {
    /// this is a sample app with a free and public weather service so I put the API key here,
    /// in the real use case, the secrect key `MUST NOT be stored in the source code`.
    let key = "5ffcd8f8e469ee48581072a95ff9360f"
    let domain = "https://api.openweathermap.org"
    let weatherByCityName = "\(domain)/data/2.5/weather"
    let url = weatherByCityName + "?q=\(city)&appid=\(key)"
    networking.sendPostRequest(CityWeatherResponse.self, session: session ?? .shared, to: url) {
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
    _ weathers: [CityWeather],
    completion: @escaping (Result<[CityWeather], Error>) -> Void
  ) {
    let backgroundContext = newTaskContext()
    
    backgroundContext.perform { [unowned self] in
      // fetch all the weather records
      let fetchRequest = CityWeatherEntity.fetchRequest()
      let existingEntities = try? backgroundContext.fetch(fetchRequest)
      
      /// Use a dictionary for O(1) time complexity when we want to check if the corresponding
      /// entity existed in the context already.
      var existingEntitiesLookUp = [String: CityWeatherEntity]()
      existingEntities?.forEach {
        existingEntitiesLookUp[$0.name] = $0
      }
      
      var updates = [CityWeather]()
      var inserts = [CityWeather]()
      
      weathers.forEach {
        if let _ = existingEntitiesLookUp[$0.name] {
          updates.append($0)
        } else {
          inserts.append($0)
        }
      }
      
      // batch insert is only available from iOS 13 so we don't use it here
      
      // perform insert
      for insert in inserts {
        let newEntity = CityWeatherEntity(context: backgroundContext)
        newEntity.name = insert.name
        newEntity.condition = insert.condition
        newEntity.humidity = insert.humidity
        newEntity.temp = insert.temp
      }
      
      /// The update just stores the CityWeatherEntity that we converted from API so we use them
      /// to update the corresponding entity in the context (existingEntitiesLookUp)
      for update in updates {
        let needToUpdate = existingEntitiesLookUp[update.name]
        needToUpdate?.name = update.name
        needToUpdate?.condition = update.condition
        needToUpdate?.humidity = update.humidity
        needToUpdate?.temp = update.temp
      }
      
      try? backgroundContext.saveIfChanged()
      
      // merge change to main context and update UI
      container.viewContext.perform { [weak self] in
        self?.container.viewContext.mergeChanges(
          fromContextDidSave: Notification(
            name: .NSManagedObjectContextDidSave,
            object: backgroundContext
          )
        )
        
        DispatchQueue.main.async { [weak self] in
          self?.fetchWeathersFromCoreData(completion: completion)
        }
      }

    }

  }
  
  func fetchWeathersFromCoreData(
    completion: @escaping (Result<[CityWeather], Error>) -> Void
  ) {
    /// in the case of the potential size and complexity of the data is high, 
    /// run the perform block in background thread instead
    let mainContext = container.viewContext
    mainContext.perform {
      do {
        // make the fetch request to fetch all the weather records
        let fetchRequest = CityWeatherEntity.fetchRequest()
        let entities = try mainContext.fetch(fetchRequest)
        // use the fetched record in the completion block
        completion(.success(entities.map { $0.toCityWeatherModel() }))
      } catch {
        completion(.failure(error))
      }
    }
  }
}
