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
                                print("Code is \(condition.code)")
                                
                                
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
            print("muji \(error)")
        }
        return wrapper
    }
    
    func parseLocationJson(data: Data) -> [CityData?] {
        let decoder = JSONDecoder()
        var wrapper: [CityData?] = []
        
        do {
            wrapper = try decoder.decode([CityData].self, from: data)
        } catch {
            print("muji \(error)")
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

}
