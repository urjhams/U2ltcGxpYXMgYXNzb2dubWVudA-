//
//  CityWeather.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct CityWeatherResponse: Codable {
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

extension CityWeatherResponse {
  func toCityWeatherModel() -> CityWeather {
    CityWeather(
      humidity: Int64(self.main.humidity),
      temp: self.main.temp,
      condition: self.weather.first?.description,
      name: self.name
    )
  }
}
