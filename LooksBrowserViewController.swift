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
let LookGroupHeaderIdentifier = "LookGroupHeader"

class LooksBrowserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextButton: BButton!
    @IBOutlet weak var looksView: UICollectionView!
    
    var keyFrame : UIImage?
    
    let lookGroups = PurchaseManager.sharedManager.looks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setType(.Primary)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    //// Collection View //////////////////////////////////////////////////////
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return lookGroups.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = lookGroups[section]
        return group.items.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("SELECT", indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LookCellIdentifier, forIndexPath: indexPath) as! LookCell
        
        let group = lookGroups[indexPath.section]
        let look = group.items[indexPath.item]
        // configure it here!
        cell.imageView.image = self.keyFrame
        cell.label.text = look.name
        
        return cell
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: LookGroupHeaderIdentifier, forIndexPath: indexPath) as! LookGroupHeader
        let group = lookGroups[indexPath.section]
        header.label.text = group.name
        return header
    }

}
