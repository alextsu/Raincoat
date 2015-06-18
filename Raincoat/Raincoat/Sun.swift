//
//  Sun.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

class Sun: NSObject {
    var sunrise: Int
    var sunset: Int
    
    init (sunrise: Int, sunset:Int) {
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
