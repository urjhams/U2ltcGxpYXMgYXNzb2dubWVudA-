//
//  ViewController.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit

class ViewController: UITableViewController {
  
  var viewModel: CitesWeatherViewModel!
  
  private let refresher = UIRefreshControl()
  
  private var sortButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = CitesWeatherViewModel { [weak self] in
      // make sure to refresh the UI in the main thread
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    } sortingChangeHandler: { [weak self] sortType in
      self?.sortButton.title = switch sortType {
      case .alphabet:
        "Sort by Name"
      case .temperature:
        "Sort by Temp"
      }
    } errorHandler: { [weak self] error in
      self?.showError(
        title: "Error",
        message: error.localizedDescription,
        actions: [.init(title: "Ok", style: .default)]
      )
    }
    
    setupTableView()
    setupRefresher()
    navigationBarSetup()
    
    // load the local data at first
    loadLocalData()
    
    // initialy, try to fetch new data every time the view is loaded
    reloadListCities()
  }

  private func setupTableView() {
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.register(
      CityWeatherTableViewCell.self,
      forCellReuseIdentifier: CityWeatherTableViewCell.className
    )
  }
  
  private func setupRefresher() {
    refresher.tintColor = .systemGray
    refresher.addTarget(self, action: #selector(reloadListCities), for: .valueChanged)
    tableView.refreshControl = refresher
  }
  
  @objc private func reloadListCities() {
    
    guard isConnectedToNetwork() else {
      return refresher.endRefreshing()
    }
    
    let names = [
      "London",
      "Berlin",
      "Stockholm",
      "Barcelona",
      "Amsterdam",
      "Doha",
      "New York",
      "Hanoi",
      "Tokyo"
    ]
    
    viewModel.fetchCitiesWeather(service: WeatherService.shared, from: names) { [weak self] data, errors in
      guard errors.isEmpty else {
        self?.showError(
          title: "Error",
          message: ServiceError.fetchingError.localizedDescription,
          actions: [.init(title: "Ok", style: .default)]
        )
        return
      }
      
      self?.viewModel.applyNewData(data, service: WeatherService.shared)
      self?.refresher.endRefreshing()
    }
  }
  
  private func navigationBarSetup() {
    let sortTitle = switch viewModel.sorting {
      case .alphabet:
        "Sort by Name"
      case .temperature:
        "Sort by Temp"
    }
    sortButton = UIBarButtonItem(
      title: sortTitle,
      style: .plain,
      target: self,
      action: #selector(clickSortButton)
    )
    
    navigationItem.setRightBarButtonItems([sortButton], animated: true)
    
    extendedLayoutIncludesOpaqueBars = true
  }
  
  @objc private func clickSortButton(_ sender: Any) {
    viewModel.toggleSorting()
  }
  
  func loadLocalData() {
    viewModel.getWeathers(service: WeatherService.shared)
  }
}

// MARK: - TableView Delegate & Data source
extension ViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.sortedCities.count
  }
  
  override func tableView(
    _ tableView: UITableView, 
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(of: CityWeatherTableViewCell.self, for: indexPath)
    cell.city = viewModel.sortedCities[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    UITableView.automaticDimension
  }
}
