//
//  Extensions.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit

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
