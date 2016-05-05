//
//  ViewController.swift
//  Asdf
//
//  Created by Sean Hess on 5/5/16.
//  Copyright © 2016 Orbital Labs. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        print("GOT MEDIA")
//        let chosenURL = info[UIImagePickerControllerMediaURL]
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
