//
//  CityData.swift
//  SimpleWeatherApp
//
//  Created by Binay on 2023-08-03.
//

import Foundation
struct CityData: Decodable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}

struct CityWeather: Equatable {
    var cityName: String
    var weatherCondition: String
    var temperatureCelsius: Double
    var temperatureFahrenheit: Double
    var image: String
}
