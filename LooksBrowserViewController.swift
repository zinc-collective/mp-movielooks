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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // HACK: remove when we update the UI
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            // find the smaller of the two
            let size = self.view.frame.size
            let scale = min(size.width, size.height) / CGFloat(320)
            self.view.transform = CGAffineTransformMakeScale(scale, scale)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // needs to be called BEFORE loading
    func loadVideo(videoURL:NSURL) throws {
        let keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: kCMTimeZero)
        
        // save the key frame
        if let imageData = UIImagePNGRepresentation(keyFrame) {
            let imagePath = Utilities.savedKeyFrameImagePath()
            imageData.writeToFile(imagePath, atomically: false)
        }
        
        // stupid global state
        let videoDestURL = NSURL(fileURLWithPath: Utilities.savedVideoPath())
        let files = NSFileManager.defaultManager()
        
        if files.fileExistsAtPath(videoDestURL.path!) {
            try files.removeItemAtURL(videoDestURL)
        }
        
        try NSFileManager.defaultManager().copyItemAtURL(videoURL, toURL: videoDestURL)
        
        Utilities.selectedVideoPathWithURL(videoDestURL)
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
