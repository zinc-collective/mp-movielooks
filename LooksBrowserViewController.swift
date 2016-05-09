//
//  LooksBrowserViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit
import BButton

let LookCellIdentifier = "LookCell"

class LooksBrowserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextButton: BButton!
    @IBOutlet weak var looksView: UICollectionView!
    
    var keyFrame : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        looksView.registerClass(LookCell.self, forCellWithReuseIdentifier: LookCellIdentifier)
        
        nextButton.setType(.Primary)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
//        // HACK: remove when we update the UI
//        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
//            // find the smaller of the two
//            let size = self.view.frame.size
//            let scale = min(size.width, size.height) / CGFloat(320)
//            self.view.transform = CGAffineTransformMakeScale(scale, scale)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // needs to be called BEFORE loading
    func loadVideo(videoURL:NSURL) throws {
        keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: kCMTimeZero)

//        // save the key frame
//        if let imageData = UIImagePNGRepresentation(keyFrame) {
//            let imagePath = Utilities.savedKeyFrameImagePath()
//            imageData.writeToFile(imagePath, atomically: false)
//        }
//        
//        // stupid global state
//        let videoDestURL = NSURL(fileURLWithPath: Utilities.savedVideoPath())
//        let files = NSFileManager.defaultManager()
//        
//        if files.fileExistsAtPath(videoDestURL.path!) {
//            try files.removeItemAtURL(videoDestURL)
//        }
//        
//        try NSFileManager.defaultManager().copyItemAtURL(videoURL, toURL: videoDestURL)
//        
//        Utilities.selectedVideoPathWithURL(videoDestURL)
    }
    
    @IBAction func tappedNext() {
        print("NEXT")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("SELECT", indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LookCellIdentifier, forIndexPath: indexPath) as? LookCell
        
        // configure it here!
        cell?.imageView.image = self.keyFrame
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width:CGFloat = 170
        if let keyFrame = self.keyFrame {
            let ratio = keyFrame.size.height / keyFrame.size.width
            let height = width * ratio
            return CGSize(width: width, height: height)
        }
        
        return CGSizeZero
    }

}
