//
//  Look.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/9/16.
//
//

import UIKit

class Look: NSObject {
    var name: String = ""
    var desc: String = ""
    var desc1: String = ""
    var file: String = ""
    var quick: Bool = false
    
    var data: [String : AnyObject] = [:]
    
    static func parse(data:[String: AnyObject]) -> Look {
        let look = Look()
        
        look.name = data["name"] as? String ?? ""
        look.desc = data["desc"] as? String ?? ""
        look.desc1 = data["desc1"] as? String ?? ""
        look.file = data["file"] as? String ?? ""
        look.quick = (data["quick"] as? NSNumber)?.boolValue ?? false
        look.data = data
        
        return look
    }
}

class LookGroup: NSObject {
    var identifier: String = ""
    var name: String = ""
    var locked: Bool = false
    var items: [Look] = []
    
    var data: [String : AnyObject] = [:]
    
    static func parse(dictionary:[String : AnyObject]) -> LookGroup? {
        
        if let id = dictionary["identifier"] as? String, name = dictionary["name"] as? String, locked = dictionary["locked"] as? NSNumber, items = dictionary["items"] as? [[String: AnyObject]] {
            
            let group = LookGroup()
            group.identifier = id
            group.name = name
            group.locked = locked.boolValue
            group.items = items.map(Look.parse)
            group.data = dictionary
            return group
        }
        return nil
    }
}
