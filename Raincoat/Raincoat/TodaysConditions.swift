//
//  TodaysConditions.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/17/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

class TodaysConditions: NSObject {
    var high: Int
    var low: Int
    var forecastText: String!
    
    init(high: Int, low: Int, forecastText: String) {
        self.high = high
        self.low = low
        self.forecastText = forecastText
    }
}
