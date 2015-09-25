//
//  AppDelegate.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        defaults.setObject("Cupertino", forKey: "city")
        defaults.setObject("CA", forKey: "state")
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Support for background fetch
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        NSLog("\nBackground")
        
        
        var alarmTime = NSUserDefaults.standardUserDefaults().objectForKey("AlarmTime") as! NSDate
        
        var alarmSetting : Int = NSUserDefaults.standardUserDefaults().integerForKey("AlarmSetting")
        var city : String = NSUserDefaults.standardUserDefaults().objectForKey("city") as! String
        
        var notificationText : String!
        
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
            
            NSLog("Alarm is %d Minutes Away", newDate.minutesFrom(currentDate)  )
            
            if(newDate.minutesFrom(currentDate) < 200) {
                
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                
                var hourly : [HourlyCondition] = weatherJSONRequester.getHourlyConditions()!
                var willRain : Bool
                
                willRain = false
                for hour in hourly {
                    if hour.pop > popThreshold {
                        willRain = true
                    }
                }
                
                NSLog("Background: Will it rain? %@", willRain.description)
                
                if(willRain == true) {
                    notificationText = "Yup. It's going to rain today in " + city + ". Grab a raincoat!"
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
        
        
        
        
    }
}

