# U2ltcGxpYXMgYXNzb2dubWVudA-
Weather Application using core data

> ### Requirements
> - API Integration: Fetch weather data for at least 5 predefined cities in parallel using multithreading (DispatchGroup, OperationQueue, etc.).
> - Core Data Integration: Use main and private contexts for UI fetches and background insertion, ensuring thread-safe operations.
> - User Interface: Display a list of cities with weather data and include a refresh control to update data.
> - Synchronization: Use DispatchGroup or similar to synchronize API requests before saving to Core Data.

> ### Bonus Points
> - Implement error handling, sorting by temperature or city name.

> ### Submission
> Please provide the source code in a public repository with a README describing your multithreading and Core Data context approach.

> ### Evaluation Criteria
> - Effective multithreading and synchronization.
> - Correct usage of Core Data contexts.
> - Clean code and well-documented design choices.

## Aproach
MVVM is the chosen the UI pattern for the application. Besides of the View, Model, View Model; the Service Layer contains the Weather Service that handle the fetching Data from API and CoreData, also store the new data to the Core Data.
The flow of data transmission is as follows: 
- Fetching new data from the API using `DispatchGroup`.
- Synchronize to the CoreData via a background context to prevent blocking the main thread.
- Then the main context - which runs in the main thread, is used to fetch from the CoreData and make the update to the UI. 

Since the application deployment target is from iOS 12, there are some features couldn't be used such as Swift Concurrency, NSBatchUpdate, etc...
