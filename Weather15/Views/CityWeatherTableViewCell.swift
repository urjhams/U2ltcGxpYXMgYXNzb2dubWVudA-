//
//  WeatherRow.swift
//  Weather15
//
//  Created by Quân Đinh on 09.11.24.
//

import UIKit

final class CityWeatherTableViewCell: UITableViewCell {
  var city: CityWeather? {
    didSet {
      // update the cell's information
      nameLabel.text = city?.name
            
      temperatureLabel.text = if let temp = city?.temp {
        "\(Int(temp.fromKevinToCelsius()))" + "ºC"
      } else {
        nil
      }
      
      humidityLabel.text = if let humidity = city?.humidity {
        "humidity: \(humidity)" + "%"
      } else {
        nil
      }
      
      conditionLabel.text = city?.condition
    }
  }
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    label.text = "City Name"
    return label
  }()
  
  private let temperatureLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
    label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
    label.text = "_ºC"
    return label
  }()
  
  private let conditionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
    label.font = UIFont.systemFont(ofSize: 18)
    return label
  }()
  
  private let humidityLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
    label.font = UIFont.systemFont(ofSize: 18)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .gray
    setupLayout()
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CityWeatherTableViewCell {
  private func setupLayout() {
    contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
  
  private func setupViews() {
    let aligment: CGFloat = 24
    let verticalAligment: CGFloat = 12
    let maxTempWidth = (UIScreen.main.bounds.width - aligment * 2) / 4
    let maxNameWidth: CGFloat = maxTempWidth * 3
    
    contentView.addSubview(temperatureLabel)
    temperatureLabel
      .trailingAnchor
      .constraint(equalTo: contentView.trailingAnchor, constant: -aligment)
      .isActive = true
    temperatureLabel
      .topAnchor
      .constraint(equalTo: contentView.topAnchor, constant: verticalAligment)
      .isActive = true
    temperatureLabel
      .widthAnchor
      .constraint(lessThanOrEqualToConstant: maxTempWidth)
      .isActive = true
    
    contentView.addSubview(nameLabel)
    nameLabel
      .leadingAnchor
      .constraint(equalTo: contentView.leadingAnchor, constant: aligment)
      .isActive = true
    nameLabel
      .widthAnchor
      .constraint(lessThanOrEqualToConstant: maxNameWidth)
      .isActive = true
    nameLabel
      .centerYAnchor
      .constraint(equalTo: temperatureLabel.centerYAnchor)
      .isActive = true
    
    contentView.addSubview(humidityLabel)
    humidityLabel
      .trailingAnchor
      .constraint(equalTo: temperatureLabel.trailingAnchor)
      .isActive = true
    humidityLabel
      .bottomAnchor
      .constraint(equalTo: contentView.bottomAnchor, constant: -verticalAligment)
      .isActive = true
    humidityLabel
      .topAnchor
      .constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20)
      .isActive = true
    humidityLabel
      .widthAnchor
      .constraint(lessThanOrEqualToConstant: maxNameWidth)
      .isActive = true
    
    contentView.addSubview(conditionLabel)
    conditionLabel
      .leadingAnchor
      .constraint(equalTo: nameLabel.leadingAnchor)
      .isActive = true
    conditionLabel
      .centerYAnchor
      .constraint(equalTo: humidityLabel.centerYAnchor)
      .isActive = true
    conditionLabel
      .widthAnchor
      .constraint(lessThanOrEqualToConstant: maxNameWidth)
      .isActive = true
  }
}
