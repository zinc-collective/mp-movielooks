//
//  ViewController.swift
//  Asdf
//
//  Created by Sean Hess on 5/5/16.
//  Copyright © 2016 Orbital Labs. All rights reserved.
//

import UIKit
import MobileCoreServices
import BButton
import Crashlytics

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var findButton: BButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findButton.setType(.Primary)
        findButton.color = UIColor(red: 0.204, green: 0.451, blue: 0.690, alpha: 0.8) // #3473B0
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        #if DEBUG
            Debug.addDefaultVideoIfEmpty()
        #endif
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
        self.performSegueWithIdentifier("InfoViewController", sender: self)
//        if let info = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InfoViewController") as? InfoViewController {
//            
//            print("info!")
//            self.navigationController?.pushViewController(info, animated: true)
//        }
        
    }
    
    @IBAction func tappedFind() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.videoQuality = .TypeHigh
        picker.allowsEditing = true
        picker.delegate = self
        picker.modalPresentationStyle = .Popover
        picker.popoverPresentationController?.sourceView = self.view
        picker.popoverPresentationController?.sourceRect = self.findButton.frame
        picker.mediaTypes = [kUTTypeMovie as String]
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("cancel")
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        print("GOT image", image, )
//        
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // I would rather crash than have this missing. I need it to operate
        let chosenURL = info[UIImagePickerControllerMediaURL]
        
        if chosenURL == nil {
            CLSLogv("Media URL Undefined: %@", getVaList([info]))
            Crashlytics.sharedInstance().crash()
        }
        
        // this order is required to get the animation right
        self.performSegueWithIdentifier("LooksBrowserViewController", sender: chosenURL)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LooksBrowserViewController" {
            if let looksViewController = segue.destinationViewController as? LooksBrowserViewController {
                let movieURL = sender as! NSURL
                
                // crash if this doesn't work
                try! looksViewController.loadVideo(movieURL)
            }
        }
    }
    
    @IBAction func unwindHome(segue:UIStoryboardSegue) {
        
    }
}



/*
 
 
 

 */
