//
//  WeatherMain.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct WeatherMain: Codable {
  var temp: Double
  var feels_like: Double
  var temp_min: Double
  var temp_max: Double
  var pressure: Int
  var humidity: Int
}
