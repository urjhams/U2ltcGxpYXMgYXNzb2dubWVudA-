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
        "􀅏"
      case .temperature:
        "􂬮"
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
  }

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
    
    viewModel.fetchCitiesWeather { [weak self] result in
      if case .failure(let error) = result {
        self?.showError(
          title: "Error",
          message: error.localizedDescription,
          actions: [.init(title: "Ok", style: .default)]
        )
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
    viewModel.toggleSorting()
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
