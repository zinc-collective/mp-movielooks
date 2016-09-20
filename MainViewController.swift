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
        
        findButton.setType(.primary)
        findButton.color = UIColor(red: 0.204, green: 0.451, blue: 0.690, alpha: 0.8) // #3473B0
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        #if DEBUG
            Debug.addDefaultVideoIfEmpty()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedInfo() {
        print("tapped info")
        self.performSegue(withIdentifier: "InfoViewController", sender: self)
//        if let info = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InfoViewController") as? InfoViewController {
//            
//            print("info!")
//            self.navigationController?.pushViewController(info, animated: true)
//        }
        
    }
    
//    func isFullResolution() -> Bool {
//        return NSUserDefaults.standardUserDefaults().boolForKey(FullResolutionKey)
//    }
    
    @IBAction func tappedFind() {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.videoQuality = .typeHigh
        
        // NOTE: disabling this feature to see if it fixes not finishing errors
        // to get 1080p video, we need to use the Reference URL, which ignores edits
        // is there a way to use the MediaURL but get 1080p video?
        // For now: only allow editing and use media url if not full resolution
//        picker.allowsEditing = !isFullResolution()
        picker.allowsEditing = true
        
        picker.delegate = self
        picker.modalPresentationStyle = .popover
        picker.popoverPresentationController?.sourceView = self.view
        picker.popoverPresentationController?.sourceRect = self.findButton.frame
        picker.mediaTypes = [kUTTypeMovie as String]
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenURL = info[UIImagePickerControllerMediaURL]
        
//        if isFullResolution() {
//            // if full resolution we need to use the original URL, not the 
//            // url of the edited / compressed video
//            chosenURL = info[UIImagePickerControllerReferenceURL]
//        }
        
        // I would rather crash than have this missing. I need it to operate
        if chosenURL == nil {
            CLSLogv("Media URL Undefined: %@", getVaList([info]))
            
            // TEST: does this fix the crash?
            // dismiss first
            self.navigationController?.dismiss(animated: true, completion: {
                CLSLogv("Inside dismiss: %@", getVaList([info]))
                if let chosenURL = info[UIImagePickerControllerMediaURL] {
                    self.performSegue(withIdentifier: "LooksBrowserViewController", sender: chosenURL)
                }
                else {
                    let alert = UIAlertController(title: "Please help!", message: "You found a bug and we need your help. Will you contact support and tell us what kind of video you were picking? Our code can't locate it.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        UIApplication.shared.openURL(URL(string: "http://www.momentpark.com/contact-us/")!)
                        alert.dismiss(animated: true, completion: {
                            Crashlytics.sharedInstance().crash()
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            return
        }
        
        // this order is required to get the animation right
        self.performSegue(withIdentifier: "LooksBrowserViewController", sender: chosenURL)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LooksBrowserViewController" {
            if let looksViewController = segue.destination as? LooksBrowserViewController {
                let movieURL = sender as! URL
                
                // crash if this doesn't work
                try! looksViewController.loadVideo(movieURL)
            }
        }
    }
    
    @IBAction func unwindHome(_ segue:UIStoryboardSegue) {
        
    }
}



/*
 
 
 

 */
