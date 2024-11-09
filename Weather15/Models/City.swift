//
//  City.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct ListCityWeather: Codable {
  var cnt: Int
  var list: [CityWeather]?
}

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

struct Coordinate: Codable {
  var lon: Double
  var lat: Double
}

struct Weather: Codable {
  var id: Int
  var main: String
  var description: String
  var icon: String
}

struct WeatherMain: Codable {
  var temp: Double
  var feels_like: Double
  var temp_min: Double
  var temp_max: Double
  var pressure: Int
  var humidity: Int
}

struct WeatherWind: Codable {
  var speed: Double
  var deg: Int
}

struct WeatherCloud: Codable {
  var all: Int
}

struct WeatherSys: Codable {
  var type: Int?
  var id: Int?
  var country: String
  var sunrise: TimeInterval
  var sunset: TimeInterval
  var timezone: Int?
}

