//
//  WeatherSys.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct WeatherSys: Codable {
  var type: Int?
  var id: Int?
  var country: String
  var sunrise: TimeInterval
  var sunset: TimeInterval
  var timezone: Int?
}
