//
//  ViewController.swift
//  Asdf
//
//  Created by Sean Hess on 5/5/16.
//  Copyright © 2016 Orbital Labs. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedInfo() {
        print("tapped info")
        if let info = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InfoViewController") as? InfoViewController {
            
            print("info!")
            self.navigationController?.pushViewController(info, animated: true)
        }
        
    }
    
    @IBAction func tappedFind() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        picker.modalPresentationStyle = .Popover
        picker.popoverPresentationController?.sourceView = self.view
        picker.popoverPresentationController?.sourceRect = self.findButton.frame
        picker.mediaTypes = [kUTTypeMovie as String]
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)
    }
}
