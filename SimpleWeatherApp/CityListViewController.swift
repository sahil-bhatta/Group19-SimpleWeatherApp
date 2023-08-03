//
//  CityListViewController.swift
//  SimpleWeatherApp
//
//  Created by Binay on 2023-08-02.
//

import UIKit

class CityListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    //    var citiesWeatherData: [CityWeather] = []

    struct CityWeather {
        let cityName: String
        let weatherCondition: String
        let temperatureCelsius: Double
        let temperatureFahrenheit: Double
    }
    
    //sample data
    let citiesWeatherData: [CityWeather] = [
        CityWeather(cityName: "New York", weatherCondition: "cloudy", temperatureCelsius: 25.0, temperatureFahrenheit: 77.0),
        CityWeather(cityName: "Los Angeles", weatherCondition: "sunny", temperatureCelsius: 32.5, temperatureFahrenheit: 90.5),
        CityWeather(cityName: "London", weatherCondition: "rainy", temperatureCelsius: 18.5, temperatureFahrenheit: 65.3),
        CityWeather(cityName: "Tokyo", weatherCondition: "clear", temperatureCelsius: 29.0, temperatureFahrenheit: 84.2),
        CityWeather(cityName: "Sydney", weatherCondition: "partly_cloudy", temperatureCelsius: 21.7, temperatureFahrenheit: 71.1),
        // Add more cities and their weather data as needed
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
//        tableView.register(CityTableViewCell.nib, forCellReuseIdentifier: CityTableViewCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesWeatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell

        let cityWeather = citiesWeatherData[indexPath.row]

        // Configure the cell with the data
        cell.cityNameLabel.text = cityWeather.cityName
//        cell.weatherIconImageView.image = UIImage(named: cityWeather.weatherCondition) // Assuming you have appropriate image assets for each weather condition
        cell.temperatureLabel.text = "\(cityWeather.temperatureCelsius)°C" // Or use cityWeather.temperatureFahrenheit if user selected Fahrenheit

        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
