//
//  CityWeatherEntity+CoreDataProperties.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//
//

import Foundation
import CoreData


extension CityWeatherEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityWeatherEntity> {
        return NSFetchRequest<CityWeatherEntity>(entityName: "CityWeatherEntity")
    }

    @NSManaged public var icon: String?
    @NSManaged public var humidity: Int64
    @NSManaged public var temp: Int64
    @NSManaged public var condition: String?
    @NSManaged public var name: String?

}
