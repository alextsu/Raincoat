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
    @IBOutlet weak var cloudFront: UIImageView!
    @IBOutlet weak var cloudBack: UIImageView!
    
    
    @IBOutlet weak var bringItLabel: UILabel!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    @IBOutlet weak var todaysForecastLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    var coreLocation : CoreLocation?
    var todaysConditions : TodaysConditions!
    var hourlyConditions : [HourlyCondition]?
    var currentTemp : Int = 0
    
    var popThreshold : Int = 19
    
    var tempBackgroundScreen : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //NSLog("%d", weatherJSONRequester.getSunData()!.sunrise)

        self.coreLocation = CoreLocation()
        self.coreLocation?.delegate = self
        
        hourlyConditions = [HourlyCondition]()

        //navigation bar
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.5, alpha: 0.0)
        bar.tintColor = raincoatNavy
        
        //background
        self.view.backgroundColor = raincoatYellow
        
        //should wear text
        shouldWearLabel.font = UIFont(name: "OpenSans", size: 14)
        shouldWearLabel.textColor = UIColor.whiteColor()
        
        
        //bring it text
        bringItLabel.font = UIFont(name: "OpenSans-Light", size: 28)
        bringItLabel.textColor = raincoatNavy
        
        
        //show more
        showMoreLabel.font = UIFont(name: "OpenSans-Light", size: 15)
        showMoreLabel.textColor = UIColor.whiteColor()
        
        //weather details
        weatherDetailsLabel.font = UIFont(name: "OpenSans-Light", size: 14)
        weatherDetailsLabel.textColor = raincoatNavy
        
        
        //temperatures
        highTempLabel.font = UIFont(name: "OpenSans-Light", size: 24)
        highTempLabel.textColor = raincoatNavy
        lowTempLabel.font = UIFont(name: "OpenSans-Light", size: 24)
        lowTempLabel.textColor = raincoatNavy
        
        //todays forecast
        todaysForecastLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        todaysForecastLabel.textColor = UIColor.whiteColor()
        
        tempBackgroundScreen = UIView(frame: self.view.frame)
        tempBackgroundScreen.backgroundColor = raincoatYellow
        self.view.addSubview(tempBackgroundScreen)
        
        loadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func refresh(sender: UIBarButtonItem) {
        self.loadData()
    }

    @IBAction func settings(sender: AnyObject) {
        self.tempBackgroundScreen.backgroundColor = UIColor.blackColor()
        self.tempBackgroundScreen.alpha = 0.8
        self.view.bringSubviewToFront(tempBackgroundScreen)
        
        let centerPoint:CGPoint = self.view.center
        var settingsView:UIView = UIView(frame: CGRect(x: 50, y: -500, width: self.view.frame.width - 100, height: self.view.frame.height - 400))
        settingsView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(settingsView)
        self.view.bringSubviewToFront(settingsView)
    

        UIView.animateWithDuration(2.0, animations: {settingsView.center.y += (550 + self.view.frame.height/4)}, completion: { finished in
            println("Moved!")
        })
        
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
    
    func cloudMoveLeft(cloud : UIView) {
        UIView.animateWithDuration(4.0,
            delay: 0.0,
            options: nil,
            animations: {cloud.center.x += 11},
            completion: {finished in self.cloudMoveRight(cloud)})
    }
    
    func cloudMoveRight(cloud: UIView) {
        UIView.animateWithDuration(4.0,
            delay: 0.0,
            options: nil,
            animations: {cloud.center.x -=  11},
            completion: {finished in self.cloudMoveLeft(cloud)})
    }
    
    func loadData() {
        
        
        self.currentTemp = weatherJSONRequester.getCurrentTemp()!
        self.todaysConditions = weatherJSONRequester.getTodaysConditions()
        self.hourlyConditions = weatherJSONRequester.getHourlyConditions()
        
        //Should wear label
        var city = NSUserDefaults.standardUserDefaults().objectForKey("city") as! String
        shouldWearLabel.text = "Should I expect rain \n in \(city) today?"
        
        //Set high low
        highTempLabel.text = String(todaysConditions.high) + "\u{00B0}"
        lowTempLabel.text = String(todaysConditions.low) + "\u{00B0}"
        
        //Details label
        weatherDetailsLabel.text = "Currently " + String(self.currentTemp) + "F. " + self.todaysConditions.forecastText
        
        //Bring it label
        if willRainToday(self.hourlyConditions!) == true  {
            bringItLabel.text = "Yup. Grab a raincoat!"
            
            self.view.backgroundColor = raincoatNavy
            self.navigationController?.navigationBar.tintColor = raincoatYellow
            self.highTempLabel.textColor = raincoatYellow
            self.lowTempLabel.textColor = raincoatYellow
            self.weatherDetailsLabel.textColor = raincoatYellow
            self.bringItLabel.textColor = raincoatYellow
            
            self.sunback.alpha = 0
            self.sunfront.alpha = 0
            
            self.view.bringSubviewToFront(cloudFront)
            cloudMoveLeft(cloudFront)
            cloudMoveRight(cloudBack)
        }
        else {
            bringItLabel.text = "Nope. We're rain-free!"
            
            self.cloudBack.alpha = 0.0
            self.cloudFront.alpha = 0.0
            
            //sun
            sunRotateOnce()
        }
        tempBackgroundScreen.alpha = 0.0
    }
    
    func willRainToday(conditions: [HourlyCondition]) -> Bool {
        for hour in conditions {
            if hour.pop > self.popThreshold {
                return true
            }
        }
        
        return false
    }
}

