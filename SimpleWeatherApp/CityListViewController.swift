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
        cell.temperatureLabel.text = "\(cityWeather.temperatureCelsius)°C" // Or use cityWeather.temperatureFahrenheit if
        loadImageFromURL("https:\(cityWeather.image)", cell)

        return cell
    }
    
    func loadImageFromURL(_ imageUrlString: String, _ cell: CityTableViewCell) {

            guard let imageUrl = URL(string: imageUrlString) else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Set the image to the UIImageView
                        cell.weatherIconImageView.image = image
                    }
                }
            }.resume()
        }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
