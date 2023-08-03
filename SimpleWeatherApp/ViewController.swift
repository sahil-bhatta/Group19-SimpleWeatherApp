//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Sahil Bhatta on 2023-07-27.
//

import UIKit
import Foundation

class ViewController: UIViewController,UITextFieldDelegate {

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
    
    @IBOutlet weak var tvCity: UILabel!
    
    private var isCelciusSelected = true
    
    private let enabledColor = UIColor.blue
    private let disabledColor = UIColor.tintColor
    private var tempInCelcius = 0.0
    private var tempInFahrenheit = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textFieldLocation.delegate = self
        
        initView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        searchWeather(locationQuery: textField.text)
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

    }
    
    @objc func handleSearchClicked(_ gesture : UITapGestureRecognizer){
//        TODO Verify triggering on action
        print("Search Triggered")
        if let _ = gesture.view as? UIImageView {
            
        searchWeather(locationQuery: textFieldLocation.text)
        }
    }
    
    @objc func cityLabelTapped() {
        // This method will be called when the label is tapped
        print("Label was tapped!")
        performSegue(withIdentifier: "showList", sender: self)
    }
    
    func toggleWeather(){
        setButtonView()
    }
    
    func searchWeather(locationQuery : String?){
        print("Searching ...")
        let key = "c86f09b7dada4f678fa34849230308&"
        if let location = locationQuery{
            print(location)
            let urlString = "https://api.weatherapi.com/v1/search.json?key=\(key)&q=\(location)"
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
                        if let currentWeather = weatherwrapper.current{
                            self.tempInCelcius = currentWeather.temp_c
                            self.tempInFahrenheit = currentWeather.temp_f
                                print("Code is \(currentWeather.condition.code)")
                    }
                            }
            }
                dataTask.resume()
        }
        }
    }
    
    func parseJson(data: Data) -> WeatherData? {
        let decoder = JSONDecoder()
        var wrapper : WeatherData?
        print(data)
        do{
        wrapper = try decoder.decode(WeatherData.self, from: data)
        } catch {
            print("muji \(error)")
        }
        return wrapper
    }
    
    func weatherCompletionHandler(data : Data?,response:URLResponse?, error : Error?){
        
        guard error == nil else{
            print(error!)
            return
        }
        
        guard let data = data else{
            print("No data received")
            return
        }
        
        if let dataString = String(data: data, encoding: .utf8){
            print(dataString)
            print("---------")
        }
        
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
