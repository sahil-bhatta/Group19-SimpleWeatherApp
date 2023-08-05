//
//  CityListViewController.swift
//  SimpleWeatherApp
//
//  Created by Binay on 2023-08-02.
//

import UIKit

class CityListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var citiesWeatherData: [CityWeather] = []
    var isCelciusSelected = true
    
    let config = UIImage.SymbolConfiguration(paletteColors: [.blue,.yellow])
    
    //sample data
    /*let citiesWeatherData: [CityWeather] = [
        CityWeather(cityName: "New York", weatherCondition: "cloudy", temperatureCelsius: 25.0, temperatureFahrenheit: 77.0),
        CityWeather(cityName: "Los Angeles", weatherCondition: "sunny", temperatureCelsius: 32.5, temperatureFahrenheit: 90.5),
        CityWeather(cityName: "London", weatherCondition: "rainy", temperatureCelsius: 18.5, temperatureFahrenheit: 65.3),
        CityWeather(cityName: "Tokyo", weatherCondition: "clear", temperatureCelsius: 29.0, temperatureFahrenheit: 84.2),
        CityWeather(cityName: "Sydney", weatherCondition: "partly_cloudy", temperatureCelsius: 21.7, temperatureFahrenheit: 71.1),
        // Add more cities and their weather data as needed
    ] */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        print(citiesWeatherData)
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
        cell.weatherCondition.text = cityWeather.weatherCondition
        cell.temperatureLabel.text = self.isCelciusSelected ? "\(cityWeather.temperatureCelsius)°C" : "\(cityWeather.temperatureFahrenheit)°F"
    
        cell.weatherIconImageView.preferredSymbolConfiguration = self.config
        cell.weatherIconImageView.image = UIImage(systemName: cityWeather.image)

        return cell
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
