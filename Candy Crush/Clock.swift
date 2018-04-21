//
//  Clock.swift
//  Candy Crush
//
//  Created by amir lahav on 11.9.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation


enum ClockType: Int, CustomStringConvertible {
    
    case Unknown = 0, Timer, Stoper
    
    var clockName: String {
        let clockName =
        ["Timer", "Stoper"]
    
        return clockName[rawValue-1]
    
    }
    
    var description: String
        {
        return clockName
    }
    
}


class Clock {
    
    var startTime: TimeInterval! = TimeInterval()
    var seconeds: Double! = 0
    var timer = Timer()
    var timerEndedCallback: ((Bool) -> Void)!
    var succes = false
    init(time: Double){
        self.seconeds = time
    }
    
    func startTimer(timerEnded: @escaping (Bool) -> Void) {
        if !timer.isValid {
            
            let aSelector : Selector = #selector(Clock.updateTime)
            timer = Timer.scheduledTimer(timeInterval: self.seconeds, target: self, selector: aSelector, userInfo: nil, repeats: true)
            
            timerEndedCallback = timerEnded
        }
    }
    
    @objc func updateTime() {
        
        succes = true
        timer.invalidate()
        timerEndedCallback(succes)
       
    }
    }



