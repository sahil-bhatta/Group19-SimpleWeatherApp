//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Sahil Bhatta on 2023-07-27.
//

import UIKit
import Foundation

class ViewController: UIViewController {

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
    
    
    @IBOutlet weak var tvCity: UILabel!
    
    @IBOutlet weak var tvWeatherStatus: UILabel!
    
    @IBOutlet weak var ivWeather: UIImageView!
    
    @IBOutlet weak var tvTemperatue: UILabel!
    
    @IBOutlet weak var btnFahrenheit: UIButton!
    
    @IBOutlet weak var btnCelcius: UIButton!
    
    @IBOutlet weak var textFieldLocation: UITextField!
    
    @IBOutlet weak var ivSearchWeather: UIImageView!
    
    
    
    private var isCelciusSelected = true
    
    private let enabledColor = UIColor.blue
    private let disabledColor = UIColor.tintColor
    private var tempInCelcius = 0.0
    private var tempInFahrenheit = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView(){
        self.btnFahrenheit.tintColor = disabledColor
        toggleWeather()
        tvTemperatue.text = isCelciusSelected ? String(tempInCelcius) : String(tempInFahrenheit)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchClicked))
              tapGesture.numberOfTapsRequired = 1
        
        ivSearchWeather.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleSearchClicked(_ gesture : UITapGestureRecognizer){
        print("Search Triggered")
        if let _ = gesture.view as? UIImageView {
            
            searchWeather(locationQuery: textFieldLocation.text)
              }
    }
    
    func toggleWeather(){
        setButtonView()
    }
    
    func searchWeather(locationQuery : String?){
        print("Searching ...")
        if let location = locationQuery{
            print(location)
            let urlString = "https://api.weatherapi.com/v1/search.json?q=\(location)"
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
                    if let weatherwrapper = self.parseJson(data: data){
//                        TODO Use handler to store data
                        self.tempInCelcius = weatherwrapper.current.temp_c
                        self.tempInFahrenheit = weatherwrapper.current.temp_f
                                print("Code is \(weatherwrapper.current.condition.code)")
                            }
            }
                dataTask.resume()
        }
        }
    }
    
    struct WeatherWrapper : Decodable{
        let location : Location
        let current : CurrentLocation
    }
    
    struct Location : Decodable{
        let name : String
        let region : String
        let country : String
        let lat : Double
        let lon : Double
        let tz_id : String
        let localtime_epoch : Int
        let localtime : String
    }
    
    struct CurrentLocation : Decodable{
        let last_updated_epoch : Int
        let last_updated : String
        let temp_c : Double
        let temp_f : Double
        let is_day : Bool
        let condition : Condition
        let wind_mph : Double
        let wind_kph : Double
        let wind_degree : Int
        let wind_dir : String
        let pressure_mb : Int
        let pressure_in : Double
        let precip_mm : Int
        let precip_in : Int
        let humidity : Int
        let cloud : Int
        let feelslike_c : Int
        let feelslike_f : Int
        let vis_km : Int
        let vis_miles : Int
        let uv : Int
        let gust_mph : Double
        let gust_kph : Double
        let air_quality : AirQuality
        
    }
    
    struct Condition : Decodable{
        let text : String
        let icon : String
        let code : Int
    }
    
    struct AirQuality : Decodable{
        let co : Double
        let no2 : Double
        let o3 : Double
        let so2 : Int
        let pm2_5 : Double
        let pm10 : Int
//        let us-epa-index : Int
//        let gb-defra-index : Int
    }
    
    func parseJson(data: Data)->WeatherWrapper?{
        let decoder = JSONDecoder()
        var wrapper : WeatherWrapper?
        
        do{
        wrapper = try decoder.decode(WeatherWrapper.self, from: data)
        } catch {
            print(error)
        }
        return wrapper
    }
    
    func weatherCompletionHandler(data : Data?,response:URLResponse?, error : Error?){
        
        guard error == nil else{
            print(error)
            return
        }
        
        guard let data = data else{
            print("No data received")
            return
        }
        
        if let dataString = String(data: data, encoding: .utf8){
            print(dataString)
        }
        
    }
    
    func setButtonView(){
        self.btnCelcius.tintColor = isCelciusSelected ? enabledColor: disabledColor
        self.btnFahrenheit.tintColor = !isCelciusSelected ? enabledColor: disabledColor
        
    }


}
