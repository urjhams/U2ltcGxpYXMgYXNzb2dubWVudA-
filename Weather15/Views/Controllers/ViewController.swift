//
//  ViewController.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit

class ViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    view.backgroundColor = .cyan
  }
  
  // TODO: turn this into UITableView
  // TODO: need a list of cities, a refresh to fetch and re-fetch cities
  // TODO: need a button to sort by temperature or city name


}

// MARK: - TableView Delegate & Data source
extension ViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    0
  }
  
  override func tableView(
    _ tableView: UITableView, 
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(of: CityWeatherTableViewCell.self, for: indexPath)
//    cell.city = cities[indexPath.row]
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
