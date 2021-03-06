//
//  ViewController.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LoadWeatherDataDelegate {
    
    @IBOutlet weak var sunback: UIImageView!
    @IBOutlet weak var sunfront: UIImageView!
    @IBOutlet weak var cloudFront: UIImageView!
    @IBOutlet weak var cloudBack: UIImageView!
    @IBOutlet weak var raincoatLogo: UIImageView!
    
    @IBOutlet weak var shouldWearLabel: UILabel!
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
    
    //Chance of precipitation, above which the app will consider it raining
    var currentWeather : String!
    
    var settingsView:UIView!
    var tempBackgroundScreen : UIView!
    var alarmSetting : UISegmentedControl!
    var timePicker : UIDatePicker!
    
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
        
        //loadData()
        self.navigationItem.rightBarButtonItem!.enabled = false
        self.view.bringSubviewToFront(raincoatLogo)
        self.navigationItem.rightBarButtonItem?.tintColor = raincoatYellow
        self.navigationItem.leftBarButtonItem?.tintColor = raincoatYellow
        
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.loadData()
    }
    
    @IBAction func settings(sender: AnyObject) {
        
        
        //self.currentlyInSettingsMenu = true
        
        //set background dark
        
        self.tempBackgroundScreen.backgroundColor = raincoatNavy
        UIView.animateWithDuration(1, animations: {self.tempBackgroundScreen.alpha = 0.95}, completion: { finished in })
        self.view.bringSubviewToFront(tempBackgroundScreen)
        
        //hide navigation bar
        self.navigationController?.navigationBar.alpha = 0.0001
        
        //let centerPoint:CGPoint = self.view.center
        
        //Create the white settings box
        settingsView = UIView(frame: CGRect(x: (self.view.frame.width - 280)/2 , y: -500, width: 280, height: 400))
        settingsView.backgroundColor = UIColor.clearColor()
        settingsView.clipsToBounds = true
        settingsView.alpha = 0.1
        
        //add cancel button to white settings box
        let cancelButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        cancelButton.setImage(UIImage(named: "delete.png"), forState: .Normal)
        cancelButton.tintColor = UIColor.whiteColor()
        cancelButton.frame = CGRect(x: settingsView.frame.width - 30, y: 5, width: 25, height: 25)
        cancelButton.addTarget(self, action: "cancelOut:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsView.addSubview(cancelButton)
        
        //add segmented control
        let alarmSettingText = ["Alarm On", "Alarm Off"]
        alarmSetting = UISegmentedControl(items: alarmSettingText)
        alarmSetting.center = CGPoint(x: settingsView.frame.width / 2, y: 80)
        alarmSetting.tintColor = UIColor.whiteColor()
        if (NSUserDefaults.standardUserDefaults().objectForKey("AlarmSetting") == nil) {
            alarmSetting.selectedSegmentIndex = 1
        }
        else {
            alarmSetting.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("AlarmSetting")
        }
        settingsView.addSubview(alarmSetting)
        
        //add save button
        let saveButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.tintColor = UIColor.whiteColor()
        saveButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 22)
        saveButton.frame = CGRect(x: 0, y: settingsView.frame.height - 72, width: settingsView.frame.width, height: 30)
        //saveButton.backgroundColor = UIColor.whiteColor()
        saveButton.addTarget(self, action: "saveSettings:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsView.addSubview(saveButton)
        
        //add time picker
        timePicker = UIDatePicker(frame: CGRect(x:0, y: 100, width: settingsView.frame.width, height: settingsView.frame.height - 50))
        timePicker.center.x = settingsView.frame.width/2
        timePicker.datePickerMode = UIDatePickerMode.Time
        timePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        timePicker.locale = NSLocale(localeIdentifier: "en_GB")
        if (NSUserDefaults.standardUserDefaults().objectForKey("AlarmTime") != nil) {
            timePicker.setDate(NSUserDefaults.standardUserDefaults().objectForKey("AlarmTime") as! NSDate, animated: true)
        }
        settingsView.addSubview(timePicker)
        
        //put the subviews together
        self.view.addSubview(settingsView)
        self.view.bringSubviewToFront(settingsView)
        
        //animate
        UIView.animateWithDuration(1.5, animations: {
            self.settingsView.center.y += (500 + self.view.frame.height/2 - self.settingsView.frame.height/2)
            self.settingsView.alpha = 1.0
            }, completion: { finished in
                println("Moved!")
        })
        
    }
    
    func cancelOut(sender:UIButton!) {
        
        UIView.animateWithDuration(0.7, animations: {
            self.settingsView.center.y -= (500 + self.view.frame.height/2 - self.settingsView.frame.height/2)
            self.settingsView.alpha = 0.0
            }, completion: { finished in
                println("Moved!")
                UIView.animateWithDuration(1, animations: {self.tempBackgroundScreen.alpha = 0.0}, completion: { finished in })
                self.navigationController?.navigationBar.alpha = 1
        })
    }
    
    func saveSettings(sender: UIButton!) {
        NSUserDefaults.standardUserDefaults().setInteger(self.alarmSetting.selectedSegmentIndex, forKey: "AlarmSetting")
        
        NSUserDefaults.standardUserDefaults().setObject(timePicker.date, forKey: "AlarmTime")
        //NSLog("Time is: %@", timePicker.date.description)
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        self.triggerAlarm(timePicker.date, alarmSetting: self.alarmSetting.selectedSegmentIndex)
        
        
        UIView.animateWithDuration(0.7, animations: {
            self.settingsView.center.y -= (500 + self.view.frame.height/2 - self.settingsView.frame.height/2)
            self.settingsView.alpha = 0.0
            }, completion: { finished in
                println("Moved!")
                UIView.animateWithDuration(1, animations: {self.tempBackgroundScreen.alpha = 0.0}, completion: { finished in
                    
                    if self.alarmSetting.selectedSegmentIndex == 0 {
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                            
                            let alert = UIAlertView()
                            alert.title = "Alarm Saved"
                            alert.message = "Please keep Raincoat running in the background if you wish to receive subsequent rain alarms."
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        
                    }
                    
                })
                self.navigationController?.navigationBar.alpha = 1
        })
        
        
    }
    
    func triggerAlarm(alarmTime: NSDate, alarmSetting: Int) {
        var notificationText : String!
        var city : String = NSUserDefaults.standardUserDefaults().objectForKey("city") as! String
        
        NSLog("Alarm Time: %@, Alarm Setting: %d", alarmTime.description, alarmSetting)
        
        if (alarmSetting == 0) {
            
            let calendar = NSCalendar.currentCalendar()
            let comp = calendar.components((.CalendarUnitHour | .CalendarUnitMinute), fromDate: alarmTime)
            let hour = comp.hour
            let minute = comp.minute
            
            var currentDate = NSDate()
            NSLog("Current Date %@", currentDate.description)
            NSLog("Alarm hour: %d, Alarm minute: %d", hour, minute)
            
            let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            var newDate: NSDate = cal.dateBySettingHour(hour, minute: minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
            
            if(currentDate.compare(newDate) == NSComparisonResult.OrderedDescending) {
                newDate = newDate.dateByAddingTimeInterval(60*60*24)
            }
            
            NSLog("New Alarm Date: %@", newDate.description)
            
            
            if(willRainToday(self.hourlyConditions!) == true) {
                notificationText = "Yes. It's going to rain today in " + city + "."
            }
            else {
                notificationText = "Nope. No rain today in " + city + "."
            }
            
            var notification = UILocalNotification()
            notification.alertBody = notificationText
            notification.alertAction = "open"
            notification.fireDate = newDate
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        }
        
    }
    
    
    func sunRotateOnce() {
        self.currentWeather = "sunny"
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
        self.currentWeather = "rainy"
        UIView.animateWithDuration(3.0,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {cloud.center.x += 20},
            completion: {finished in
                if finished {
                    self.cloudMoveRight(cloud)
                }
        })
    }
    
    func cloudMoveRight(cloud: UIView) {
        UIView.animateWithDuration(3.0,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {cloud.center.x -=  20},
            completion: {finished in
                if finished {
                    self.cloudMoveLeft(cloud)
                }
        })
    }
    
    func willRainToday(conditions: [HourlyCondition]) -> Bool {
        for hour in conditions {
            if hour.pop > popThreshold {
                return true
            }
        }
        
        return false
    }
    
    func loadData() {
        
        
        self.currentTemp = weatherJSONRequester.getCurrentTemp()!
        self.todaysConditions = weatherJSONRequester.getTodaysConditions()
        self.hourlyConditions = weatherJSONRequester.getHourlyConditions()
        
        //Should wear label
        var city = NSUserDefaults.standardUserDefaults().objectForKey("city") as! String
        shouldWearLabel.text = "Will it rain in\n\(city) today?"
        
        //Set high low
        highTempLabel.text = String(todaysConditions.high) + "\u{00B0}"
        lowTempLabel.text = String(todaysConditions.low) + "\u{00B0}"
        
        //Details label
        weatherDetailsLabel.text = "Currently " + String(self.currentTemp) + "F. " + self.todaysConditions.forecastText
        
        //Bring it label
        if willRainToday(self.hourlyConditions!) == true {
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
            self.view.bringSubviewToFront(tempBackgroundScreen)
            self.view.bringSubviewToFront(raincoatLogo)
            
            //check if the clouds are already moving. If not, begin animation
            if(currentWeather != "rainy") {
                //cloudMoveLeft(cloudFront)
                //cloudMoveRight(cloudBack)
            }
        }
        else {
            bringItLabel.text = "Nope. We're rain-free!"
            
            self.cloudBack.alpha = 0.0
            self.cloudFront.alpha = 0.0
            
            self.navigationItem.rightBarButtonItem?.tintColor = raincoatNavy
            self.navigationItem.leftBarButtonItem?.tintColor = raincoatNavy
            
            //check if the sun is already moving. If not, begin animation
            if(currentWeather != "sunny") {
                sunRotateOnce()
            }
        }
        
        
        self.navigationItem.rightBarButtonItem!.enabled = true
        UIView.animateWithDuration(0.9, animations: {
            self.raincoatLogo.alpha = 0.0
            }, completion: { finished in
                UIView.animateWithDuration(0.9, animations: {
                    self.tempBackgroundScreen.alpha = 0.0
                    
                    }, completion: { finished in })
        })
        
        
        //Welcome Message
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("first") == nil) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                
                defaults.setObject("x", forKey: "first")
                NSLog("First Time")
                let alert = UIAlertView()
                alert.title = "Welcome to Raincoat"
                alert.message = "To get started, click the Settings button to set your Raincoat alarm. Please note, in order for you to receive daily alarms, Raincoat must be running in the background of your device."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
        
    }
}

