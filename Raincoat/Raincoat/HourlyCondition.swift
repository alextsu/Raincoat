//
//  HourlyCondition.swift
//  Raincoat
//
//  Created by Alexander Tsu on 6/18/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

import UIKit

class HourlyCondition: NSObject {
    var temp : Int
    var pop : Int
    
    init (temp : Int, pop : Int) {
        self.temp = temp
        self.pop = pop
    }
}
