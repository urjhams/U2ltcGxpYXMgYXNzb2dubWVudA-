//
//  Extensions.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit
import CoreData

extension NSObject {
  class var className : String {
    return String(describing: self)
  }
}

extension UITableView {
  /// Dequeues reusable UITableViewCell using class name for indexPath.
  /// - Parameters:
  ///   - type: UITableViewCell type.
  ///   - indexPath: Cell location in collectionView.
  /// - Returns: UITableViewCell object with associated class name.
  public func dequeueReusableCell<Cell>(
    of type: Cell.Type,
    for indexPath: IndexPath
  ) -> Cell where Cell: UITableViewCell {
    guard 
      let cell = dequeueReusableCell(withIdentifier: type.className, for: indexPath) as? Cell
    else {
      fatalError("Couldn't find UITableViewCell of class \(type.className)")
    }
    return cell
  }
}

extension NSManagedObjectContext {
  func saveIfChanged() throws {
    guard hasChanges else {
      return
    }
    try save()
  }
}

extension Double {
  
  func fromKevinToCelsius() -> Double {
    let result = self - 273.5
    return Double(Int(result * 10.0)) / 10.0
  }
}
