//
//  ListCityWeather.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import Foundation

struct ListCityWeather: Codable {
  var cnt: Int
  var list: [CityWeather]?
}
