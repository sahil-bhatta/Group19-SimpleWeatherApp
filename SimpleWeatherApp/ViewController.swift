//
//  ViewController.swift
//  SimpleWeatherApp
//
//  Created by Sahil Bhatta on 2023-07-27.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func onFahrenheitButtonClicked(_ sender: UIButton) {
        if isCelciusSelected {
            isCelciusSelected = false
            getWeather()
        }
    }
    
    @IBAction func onCelciusButtonClicked(_ sender: UIButton) {
        if !isCelciusSelected {
           isCelciusSelected = true
            getWeather()
        }
    }
    
    
    @IBOutlet weak var tvCity: UILabel!
    
    @IBOutlet weak var tvWeatherStatus: UILabel!
    
    @IBOutlet weak var ivWeather: UIImageView!
    
    @IBOutlet weak var tvTemperatue: UILabel!
    
    @IBOutlet weak var btnFahrenheit: UIButton!
    
    @IBOutlet weak var btnCelcius: UIButton!
    
    private var isCelciusSelected = true
    
    private var enabledColor = UIColor.blue
    private var disabledColor = UIColor.tintColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView(){
        self.btnFahrenheit.tintColor = disabledColor
        getWeather()
    }
    
    func getWeather(){
        setButtonView()
    }
    
    func setButtonView(){
        self.btnCelcius.tintColor = isCelciusSelected ? enabledColor: disabledColor
        self.btnFahrenheit.tintColor = !isCelciusSelected ? enabledColor: disabledColor
        
    }


}

