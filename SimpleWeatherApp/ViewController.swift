//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Sahil Bhatta on 2023-07-27.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBAction func onFahrenheitButtonClicked(_ sender: UIButton) {
        if isCelciusSelected {
            isCelciusSelected = false
            toggleWeather()
        }
    }
    
    @IBAction func onCelciusButtonClicked(_ sender: UIButton) {
        if !isCelciusSelected {
           isCelciusSelected = true
            toggleWeather()
        }
    }
    
    @IBOutlet weak var tvWeatherStatus: UILabel!
    
    @IBOutlet weak var ivWeather: UIImageView!
    
    @IBOutlet weak var tvTemperatue: UILabel!
    
    @IBOutlet weak var btnFahrenheit: UIButton!
    
    @IBOutlet weak var btnCelcius: UIButton!
    
    @IBOutlet weak var textFieldLocation: UITextField!
    
    @IBOutlet weak var ivSearchWeather: UIImageView!
    
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet weak var tvCity: UILabel!
    
    @IBOutlet weak var currentCity: UILabel!
    
    private var isCelciusSelected = true
    
    private let enabledColor = UIColor.blue
    private let disabledColor = UIColor.tintColor
    private var tempInCelcius = 0.0
    private var tempInFahrenheit = 0.0
    
    private let API_KEY = "c86f09b7dada4f678fa34849230308"
    
    var citiesWeatherData: [CityWeather] = []
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textFieldLocation.delegate = self
        setupLocationManager()
        initView()
    }
    
    func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest

            // You may also consider requesting background location updates if your app needs it
            // locationManager.requestAlwaysAuthorization()
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
                    case .authorizedWhenInUse, .authorizedAlways:
                        // Location permission granted, you can now start updating location when needed
                        break
                    case .denied, .restricted:
                        // Location permission denied or restricted, show an alert or inform the user
                        print("Location permission denied or restricted.")
                    case .notDetermined:
                        // Location permission not yet determined, do nothing here
                        break
                    @unknown default:
                        break
                    }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                // Use the user's current location here
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                print("Latitude: \(latitude), Longitude: \(longitude)")
                
                self.searchWeather(query: "\(latitude),\(longitude)")

                // Stop updating location once you have the user's location
                locationManager.stopUpdatingLocation()
            }
        }

    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get user's location: \(error.message)")

            // Stop updating location in case of an error
            locationManager.stopUpdatingLocation()
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        searchCity(textField.text)
        return true
    }
    
    func initView(){
        self.btnFahrenheit.tintColor = disabledColor
        toggleWeather()
        tvTemperatue.text = isCelciusSelected ? String(tempInCelcius) : String(tempInFahrenheit)
        
        ivSearchWeather.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchClicked))
              tapGesture.numberOfTapsRequired = 1
        
        ivSearchWeather.addGestureRecognizer(tapGesture)
        
        tvCity.isUserInteractionEnabled = true // This is important to enable user interaction on the label

        // Add a tap gesture recognizer to the label
        let cityTapGesture = UITapGestureRecognizer(target: self, action: #selector(cityLabelTapped))
        tvCity.addGestureRecognizer(cityTapGesture)
        
        //for location image tap
        locationImage.isUserInteractionEnabled = true
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
        locationImage.addGestureRecognizer(locationTap)
        
//        Sets config colors for SF symbols
        let config = UIImage.SymbolConfiguration(paletteColors: [.blue,.yellow])
        self.ivWeather.preferredSymbolConfiguration = config

    }
    
    @objc func locationTapped(_ gesture: UIGestureRecognizer) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func handleSearchClicked(_ gesture : UITapGestureRecognizer){
//        TODO Verify triggering on action
        print("Search Triggered")
        if let _ = gesture.view as? UIImageView {
            
//        searchWeather(query: textFieldLocation.text)
        searchCity(textFieldLocation.text)
        }
    }
    
    @objc func cityLabelTapped() {
        // This method will be called when the label is tapped
        print("Label was tapped!")
        performSegue(withIdentifier: "showList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showList" {
            if let destinationViewController = segue.destination as? CityListViewController {
                destinationViewController.citiesWeatherData = self.citiesWeatherData
            }
        }
    }
    
    func toggleWeather(){
        setButtonView()
    }
    
    //function to search location based on the query
    func searchCity(_ query: String?) {
        
        if let location = query {
            print(location)
            
            let urlString = "https://api.weatherapi.com/v1/search.json?key=\(API_KEY)&q=\(location)"
            let url = URL(string: urlString)
            //            TODO Add header with apiKey
            let urlSession = URLSession(configuration: .default)
            if let url = url {
                let dataTask = urlSession.dataTask(with: url){
                    data,response,error in
                    guard error == nil else{
                        print(error)
                        return
                    }
                    guard let data = data else{
                        print("No data received")
                        return
                    }
                    let cityWrapper = self.parseLocationJson(data: data)
                    print(cityWrapper)
                    
                    //once the location data is received, I used its lat lon to find the current weather
                    for city in cityWrapper {
                        if let city = city {
                            self.searchWeather(query: "\(city.lat),\(city.lon)")
                        }
                    }
                    
                }
                dataTask.resume()
            }
        }
    }
    
    //function to search weather based on location or lat lon
    func searchWeather(query : String?){
        print("Searching ...")
        
        if let query = query {
            print(query)
            
            let urlString = "https://api.weatherapi.com/v1/current.json?key=\(API_KEY)&q=\(query)"
            let url = URL(string: urlString)
            
            let urlSession = URLSession(configuration: .default)
            if let url = url {
                let dataTask = urlSession.dataTask(with: url) {
                    data,response,error in
                    guard error == nil else{
                        print(error)
                        return
                    }
                    guard let data = data else{
                        print("No data received")
                        return
                    }
                    if let weatherWrapper = self.parseWeatherJson(data: data) {
                        
                        print(weatherWrapper)
                        var cityWeather = CityWeather(cityName: "", weatherCondition: "", temperatureCelsius: 0.0, temperatureFahrenheit: 0.0, image: "")
                        
                        if let location = weatherWrapper.location {
                            cityWeather.cityName = location.name
                            DispatchQueue.main.async {
                                self.currentCity.text = location.name
                            }
                        }
                        //                        TODO Use handler to store data
                        if let currentWeather = weatherWrapper.current{
                            self.tempInCelcius = currentWeather.temp_c
                            self.tempInFahrenheit = currentWeather.temp_f
                            
                            DispatchQueue.main.async {
                                self.tvTemperatue.text = self.isCelciusSelected ? String(self.tempInCelcius) : String(self.tempInFahrenheit)
                            }
                            
                            cityWeather.temperatureCelsius = self.tempInCelcius
                            cityWeather.temperatureFahrenheit = self.tempInFahrenheit
                            
                            if let condition = currentWeather.condition {
                                if let conditionCode = condition.code{
                                    self.showSymbolImage(conditionCode: conditionCode)
                                }
                                
                                cityWeather.weatherCondition = condition.text
                                cityWeather.image = condition.icon
                            }
                            
                        }
                        if !self.citiesWeatherData.contains(cityWeather) {
                            self.citiesWeatherData.append(cityWeather)
                        } else {
                            print("Location \(cityWeather.cityName) is already in the list")
                        }
                            
                        print(self.citiesWeatherData.count)
                    }
                }
                dataTask.resume()
            }
        }
        
    }
    
    func parseWeatherJson(data: Data) -> WeatherData? {
        let decoder = JSONDecoder()
        var wrapper : WeatherData?
        
        do{
        wrapper = try decoder.decode(WeatherData.self, from: data)
        } catch {
            print("Error in weather decoding \(error)")
        }
        return wrapper
    }
    
    func parseLocationJson(data: Data) -> [CityData?] {
        let decoder = JSONDecoder()
        var wrapper: [CityData?] = []
        
        do {
            wrapper = try decoder.decode([CityData].self, from: data)
        } catch {
            print("Error in location decoding \(error)")
        }
        
        return wrapper
    }
    
    func setButtonView(){
        self.btnCelcius.tintColor = isCelciusSelected ? enabledColor: disabledColor
        self.btnFahrenheit.tintColor = !isCelciusSelected ? enabledColor: disabledColor
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func showSymbolImage(conditionCode : Int){
        let systemNameOfSymbol : String
        switch conditionCode {
//                                        Sunny
        case 1000:
            systemNameOfSymbol = "sun.max.fill"
//                                        Partly Cloudy
        case 1003:
            systemNameOfSymbol = "cloud.sun"
//                                        Cloudy
        case 1006:
            systemNameOfSymbol = "cloud"
//                                        Overcast
        case 1009:
            systemNameOfSymbol = "cloud.fill"
//                                        Mist
        case 1030:
            systemNameOfSymbol = "water.waves"
//                                        Patchy rain
        case 1063:
            systemNameOfSymbol = "cloud.sun.rain"
//                                        Patchy snow
        case 1066:
            systemNameOfSymbol = "cloud.snow"
//                                        Patchy sleet
        case 1069:
            systemNameOfSymbol = "cloud.sleet"
//                                        Freezing drizzle
        case 1072:
            systemNameOfSymbol = "cloud.drizzle.fill"
//                                        Thundery outbreaks possible
        case 1087:
            systemNameOfSymbol = "cloud.sun.bolt"
//                                        Blowing snow
        case 1114:
            systemNameOfSymbol = "wind.snow.circle.fill"
//                                        Blizzard
        case 1117:
            systemNameOfSymbol = "wind.snow.circle"
//                                        Fog
        case 1135:
            systemNameOfSymbol = "cloud.fog"
//                                        Freezing Fog
        case 1147:
            systemNameOfSymbol = "cloud.fog.fill"
//                                       Patchy Light drizzle
        case 1150:
            systemNameOfSymbol = "cloud.sun.rain"
//                                        Light drizzle
        case 1153:
            systemNameOfSymbol = "cloud.sun.rain"
//                                        Freezing drizzle
        case 1168:
            systemNameOfSymbol = "cloud.rain"
        case 1171:
            systemNameOfSymbol = "cloud.rain.fill"
//                                        Patchy Light rain
        case 1180:
            systemNameOfSymbol = "cloud.sun.rain"
//                                        Light rain
        case 1183:
            systemNameOfSymbol = "cloud.sun.rain.fill"
//                                        Moderate rain at times
        case 1186:
            systemNameOfSymbol = "cloud.bolt.rain"
//                                        Moderate rain
        case 1189:
            systemNameOfSymbol = "cloud.bolt.rain"
//                                        Heavy rain at times
        case 1192:
            systemNameOfSymbol = "cloud.heavyrain"
//                                        Heavy rain
        case 1195:
            systemNameOfSymbol = "cloud.heavyrain.fill"
//                                        Light freezing rain
        case 1198:
            systemNameOfSymbol = "cloud.moon.rain"
//                                        Moderate or heavy freezing rain
        case 1201:
            systemNameOfSymbol = "cloud.moon.rain.fill"
//                                        Light sleet
        case 1204:
            systemNameOfSymbol = "cloud.sleet"
//                                        Moderate or heavy sleet
        case 1207:
            systemNameOfSymbol = "cloud.sleet.fill"
//                                        Patchy light snow
        case 1210:
            systemNameOfSymbol = "cloud.snow"
//                                        Light snow
        case 1213:
            systemNameOfSymbol = "cloud.snow.fill"
//                                        Patchy moderate snow
        case 1216:
            systemNameOfSymbol = "cloud.snow.circle"
//                                        Moderate snow
        case 1219:
            systemNameOfSymbol = "cloud.snow.circle.fill"
//                                        Patchy heavy snow
        case 1222:
            systemNameOfSymbol = "wind.snow"
//                                        Heavy snow
        case 1225:
            systemNameOfSymbol = "wind.snow.circle.fill"
//                                        Ice Palette
        case 1237:
            systemNameOfSymbol = "snowflake"
//                                        Light rain shower
        case 1240:
            systemNameOfSymbol = "cloud.rain"
//                                        Moderate or heavy rain shower
        case 1243:
            systemNameOfSymbol = "cloud.bolt.rain"
//                                        Torrential rain shower
        case 1246:
            systemNameOfSymbol = "cloud.bolt.rain.fill"
//                                        Light sleet showers
        case 1249:
            systemNameOfSymbol = "cloud.sleet"
//                                        Moderate or heavy sleet showers
        case 1252:
            systemNameOfSymbol = "cloud.sleet.fill"
//                                        Light snow showers
        case 1255:
            systemNameOfSymbol = "cloud.snow"
//                                       Moderate or heavy snow showers
        case 1258:
            systemNameOfSymbol = "wind.snow.fill"
//                                        Light showers of ice pellets
        case 1261:
            systemNameOfSymbol = "cloud.snow"
//                                        Moderate or heavy showers of ice pellets
        case 1264:
            systemNameOfSymbol = "cloud.snow.fill"
//                                        Patchy light rain with thunder
        case 1273:
            systemNameOfSymbol = "cloud.bolt.rain"
//                                        Moderate or heavy rain with thunder
        case 1276:
            systemNameOfSymbol = "cloud.bolt.rain.fill"
        case 1279:
            systemNameOfSymbol = "cloud.bolt.rain.fill"
        default:
            systemNameOfSymbol = "sun.min"
        }
        self.ivWeather.image = UIImage(systemName: systemNameOfSymbol)
    }

}
