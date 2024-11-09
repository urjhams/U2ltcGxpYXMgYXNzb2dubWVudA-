//
//  CityWeather.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct CityWeather: Codable {
  var coord: Coordinate
  var weather: [Weather]
  var base: String?
  var main: WeatherMain
  var visibility: Int
  var wind: WeatherWind
  var clouds: WeatherCloud
  var dt: TimeInterval
  var sys: WeatherSys
  var timezone: Int?
  var id: Int
  var name: String
  var cod: Int?
}
