//
//  ViewController.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LoadWeatherDataDelegate {

    @IBOutlet weak var shouldWearLabel: UILabel!
    
    @IBOutlet weak var sunback: UIImageView!
    @IBOutlet weak var sunfront: UIImageView!
    
    @IBOutlet weak var bringItLabel: UILabel!
    
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    
    @IBOutlet weak var todaysForecastLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    var coreLocation : CoreLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //NSLog("%d", weatherJSONRequester.getSunData()!.sunrise)
        //weatherJSONRequester.getTodaysConditions()
        //weatherJSONRequester.getHourlyConditions()
        self.coreLocation = CoreLocation()
        
        self.coreLocation?.delegate = self
        

        //navigation bar
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.5, alpha: 0.0)
        bar.tintColor = raincoatNavy
        
        //background
        self.view.backgroundColor = raincoatYellow
        
        //should wear text
        shouldWearLabel.font = UIFont(name: "OpenSans", size: 12)
        shouldWearLabel.textColor = UIColor.whiteColor()
        
        //sun
        sunRotateOnce()
        
        //bring it text
        bringItLabel.font = UIFont(name: "OpenSans-Light", size: 28)
        bringItLabel.textColor = raincoatNavy
        
        //current temp
        /*currentTemp.alpha = 0.0
        currentTemp.font = UIFont(name: "OpenSans-Light", size: 17)
        currentTemp.textColor = raincoatNavy
        currentTemp.text = "It's 65\u{00B0} outside."*/
        
        //show more
        showMoreLabel.font = UIFont(name: "OpenSans-Light", size: 15)
        showMoreLabel.textColor = UIColor.whiteColor()
        
        //weather details
        weatherDetailsLabel.font = UIFont(name: "OpenSans-Light", size: 13)
        weatherDetailsLabel.textColor = raincoatNavy
        
        
        //temperatures
        highTempLabel.font = UIFont(name: "OpenSans-Light", size: 24)
        highTempLabel.textColor = raincoatNavy
        lowTempLabel.font = UIFont(name: "OpenSans-Light", size: 24)
        lowTempLabel.textColor = raincoatNavy
        
        //todays forecast
        todaysForecastLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        todaysForecastLabel.textColor = UIColor.whiteColor()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sunRotateOnce() {
        UIView.animateWithDuration(11.0,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.sunback.transform = CGAffineTransformRotate(self.sunback.transform, 3.1415926)},
            completion: {finished in self.sunRotateAgain()})
    }

    func sunRotateAgain() {
        UIView.animateWithDuration(11.0,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.sunback.transform = CGAffineTransformRotate(self.sunback.transform, 3.1415926)},
            completion: {finished in self.sunRotateOnce()})
    }
    
    func loadData() {
        weatherJSONRequester.getCurrentTemp()
    }
}

