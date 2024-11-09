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
      self?.tableView.reloadData()
    }
    
    setupTableView()
    setupRefresher()
  }
  
  // TODO: need a list of cities, a refresh to fetch and re-fetch cities
  // TODO: need a button to sort by temperature or city name

  private func setupTableView() {
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .singleLine
    
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
    
    viewModel.fetchCitiesWeather { [weak self] error in
      if let error {
        let alert = UIAlertController(
          title: "Error",
          message: error.localizedDescription,
          preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "Ok", style: .default))
        self?.present(alert, animated: true)
      }
    }
  }
  
  private func navigationBarSetup() {
    let sortTitle = switch viewModel.sorting {
      case .alphabet:
        "􀅏"
      case .temperature:
        "􂬮"
    }
    sortButton = UIBarButtonItem(
      title: sortTitle,
      style: .plain,
      target: self,
      action: #selector(clickSortButton)
    )
    navigationItem.setRightBarButton(sortButton, animated: true)
    extendedLayoutIncludesOpaqueBars = true
  }
  
  @objc private func clickSortButton(_ sender: Any) {
    
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
