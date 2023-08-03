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
    let long: Double
    let url: String
}
