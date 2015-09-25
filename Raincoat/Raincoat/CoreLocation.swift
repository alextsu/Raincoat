//
//  CoreLocation.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/20/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

//Referenced the following tutorial: http://dev.iachieved.it/iachievedit/corelocation-on-ios-8-with-swift/

import Foundation
import UIKit
import CoreLocation

@objc protocol LoadWeatherDataDelegate{
    optional func loadData()
}

class CoreLocation: NSObject, CLLocationManagerDelegate {
    
    var delegate: LoadWeatherDataDelegate?
    var locationManager:CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.distanceFilter  = 10000
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .AuthorizedAlways:
            println(".AuthorizedAlways")
            self.locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            let alert = UIAlertView()
            alert.title = "Location Error"
            alert.message = "Raincoat cannot determine your location. Please check that your Location Services are turned on and that you've given Raincoat permission to use your location."
            alert.addButtonWithTitle("OK")
            alert.show()
            println(".Denied")
            break
            
        default:
            println("Unhandled authorization status")
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        
        println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, e) -> Void in
            if let error = e {
                println("Error:  \(e.localizedDescription)")
            } else {
                let placemark = placemarks.last as! CLPlacemark
                
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(placemark.locality, forKey: "city")
                defaults.setObject(placemark.administrativeArea, forKey: "state")
                
                let userInfo = [
                    "city":     placemark.locality,
                    "state":    placemark.administrativeArea,
                    "country":  placemark.country
                ]
                
                println("Location:  \(userInfo)")
                
                self.delegate?.loadData!()
                
            }
        })
    }
}
