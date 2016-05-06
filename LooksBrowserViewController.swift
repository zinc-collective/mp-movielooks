//
//  LooksBrowserViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit

class LooksBrowserViewController: LooksBrowserViewControllerOld {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // needs to be called BEFORE loading
    func loadVideo(videoURL:NSURL) {
        do {
            let keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: kCMTimeZero)
            
            // save the key frame
            if let imageData = UIImagePNGRepresentation(keyFrame) {
                let imagePath = Utilities.savedKeyFrameImagePath()
                imageData.writeToFile(imagePath, atomically: false)
            }
            
            let videoDestURL = NSURL(fileURLWithPath: Utilities.savedVideoPath())
            try NSFileManager.defaultManager().copyItemAtURL(videoURL, toURL: videoDestURL)
        }
        catch let err as NSError {
            print("Video Load Error", err.localizedDescription)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
