//
//  Extensions.swift
//  Candy Crush
//
//  Created by amir lahav on 3.9.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation




extension Dictionary {
    
    
    static func loadJSONFromBundle(filename: String) -> Dictionary <String, AnyObject>? {
        var dataOK: NSData
        var dictionaryOK: NSDictionary = NSDictionary()
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            let _: NSError?
            do {
                let data = try NSData(contentsOfFile: path, options: NSData.ReadingOptions()) as NSData!
                dataOK = data!
                
            }
            catch {
                print("Could not load level file: \(filename), error: \(error)")
                return nil
            }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: dataOK as Data, options: JSONSerialization.ReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as! NSDictionary as? Dictionary <String, AnyObject>)! as NSDictionary
            }
            catch {
                print("Level file '\(filename)' is not valid JSON: \(error)")
                return nil
            }
        }
        return dictionaryOK as? Dictionary <String, AnyObject>
    }
}
