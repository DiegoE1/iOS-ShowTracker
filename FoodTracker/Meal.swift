//
//  Meal.swift
//  ShowTracker
//
//  Created by Diego Espinosa on 8/17/18.
//  Copyright © 2018 Diego Espinosa. All rights reserved.
//

import os.log
import UIKit

class Meal: NSObject, NSCoding{
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var episode: String
    var total: String
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let episode = "episode"
        static let total = "total"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, episode: String, total: String) {
        
        guard !name.isEmpty else {
            return nil
        }
        guard !episode.isEmpty else {
            return nil
        }
        guard !total.isEmpty else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.episode = episode
        self.total = total
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(episode, forKey: PropertyKey.episode)
        aCoder.encode(total, forKey: PropertyKey.total)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let episode = aDecoder.decodeObject(forKey: PropertyKey.episode) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let total = aDecoder.decodeObject(forKey: PropertyKey.total) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        self.init(name: name, photo: photo, episode: episode, total: total)
    }
}
