//
//  Utils.swift
//  NoirPhoto
//
//  Created by Sean Hess on 5/24/16.
//  Copyright © 2016 Moment Park. All rights reserved.
//

import Foundation

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
