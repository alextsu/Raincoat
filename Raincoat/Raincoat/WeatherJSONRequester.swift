//
//  WeatherJSONRequester.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

let weatherJSONRequester = WeatherJSONRequester()
let wundergroundAPIKey = "c67345f20e4bd1a5";


public class WeatherJSONRequester: NSObject {
    
    func getCurrentTemp () -> Int? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var endpoint : NSURL!
        var city : String!
        var state : String!
        
        if let city = defaults.stringForKey("city") {
            
            var nCity = city.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            NSLog("City is %@", nCity)
            
            if let state = defaults.stringForKey("state") {
                endpoint = NSURL(string: "http://api.wunderground.com/api/\(wundergroundAPIKey)/conditions/q/\(state)/\(nCity).json")
            }
        }
        
        
        var data = NSData(contentsOfURL: endpoint!)
        
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
        
            if let currentObservation = json["current_observation"] as? NSDictionary {
                
                let temp = (currentObservation["temp_f"] as! Int)
   
                NSLog("Temp is %d", temp)
                
                return temp
            }
            
        }
        
        return nil
    }
    
    func getHourlyConditions () -> [HourlyCondition]? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var endpoint : NSURL!
        var city : String!
        var state : String!
        
        if let city = defaults.stringForKey("city") {
            
            var nCity = city.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            NSLog("City is %@", nCity)
            
            if let state = defaults.stringForKey("state") {
                endpoint = NSURL(string: "http://api.wunderground.com/api/\(wundergroundAPIKey)/hourly/q/\(state)/\(nCity).json")
            }
        }

        
        var data = NSData(contentsOfURL: endpoint!)
        
        var output = [HourlyCondition]()
        
        
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            
            if let hourlyForecast = json["hourly_forecast"] as? NSArray {
                for var i = 0; i < 24; i++ {
                    let temp = hourlyForecast[i]["temp"] as! NSDictionary
                    let tempEnglish = (temp["english"] as! String).toInt()
                    let pop = (hourlyForecast[i]["pop"] as! String).toInt()
                    
                    let fctime = hourlyForecast[i]["FCTTIME"] as! NSDictionary
                    let hour = (fctime["hour"] as! String).toInt()
                    
                    NSLog("hour %d", hour!)
                    
                    let hourlyCondition = HourlyCondition(temp: tempEnglish!, pop: pop!, hour: hour!)
                    
                    output.append(hourlyCondition)
                }
            }
            
        }
        
        return output
    }
    
    func getTodaysConditions () -> TodaysConditions? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var endpoint : NSURL!
        var city : String!
        var state : String!
        
        if let city = defaults.stringForKey("city") {
            
            var nCity = city.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            NSLog("City is %@", nCity)
            
            if let state = defaults.stringForKey("state") {
                endpoint = NSURL(string: "http://api.wunderground.com/api/\(wundergroundAPIKey)/forecast/q/\(state)/\(nCity).json")
            }
        }

      var data = NSData(contentsOfURL: endpoint!)
        
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            
            var highTemp : Int
            var lowTemp : Int
            var text : String!
            
            //NSLog("%@", json)
            
            if let forecast = json["forecast"] as? NSDictionary {
                if let simpleForecast = forecast["simpleforecast"] as? NSDictionary {
                    if let forecastDay = simpleForecast["forecastday"] as? NSArray {
                        if let high = forecastDay[0]["high"] as? NSDictionary {
                            if let low = forecastDay[0]["low"] as? NSDictionary {
                                
                                highTemp = (high["fahrenheit"] as! String).toInt()!
                                lowTemp = (low["fahrenheit"] as! String).toInt()!
                                

                                if let txtforecast = forecast["txt_forecast"] as? NSDictionary {
                                    if let forecastDay = txtforecast["forecastday"] as? NSArray {
                                        let today = forecastDay[0] as! NSDictionary
                                        text = today["fcttext"] as! String
                                        
                                        let output = TodaysConditions(high: highTemp, low: lowTemp, forecastText: text)
                                        return output
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func getSunData () -> Sun? {
        var endpoint = NSURL(string: "http://api.wunderground.com/api/\(wundergroundAPIKey)/astronomy/q/CA/San_Francisco.json")
        var data = NSData(contentsOfURL: endpoint!)
        
        
        //Serialize JSON into NSDictionary Array and perform operations on it
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            
            if let sunPhase = json["sun_phase"] as? NSDictionary {
                
                if let sunrise = sunPhase["sunrise"] as? NSDictionary {
                    
                    if let sunset = sunPhase["sunset"] as? NSDictionary {
                        
                        NSLog("%@", sunPhase["sunrise"] as! NSDictionary)
                        NSLog("%@", sunPhase["sunset"] as! NSDictionary)
                        
                        
                        let sun = Sun(sunrise: (sunrise["hour"] as! String).toInt()!, sunset: (sunset["hour"] as! String).toInt()!)
                        
                        return sun
                        
                        //NSLog("Sunrise: %@", sun.sunrise);
                    }
                    
                }
                
            }
        }
        return nil
    }
    
    
    
}
