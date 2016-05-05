//
//  InfoViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/5/16.
//
//

import UIKit

class InfoViewController : UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}