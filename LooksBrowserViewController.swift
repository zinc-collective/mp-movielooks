//
//  LooksBrowserViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit
import BButton
import Crashlytics

let LookCellIdentifier = "LookCell"
let LookGroupHeaderIdentifier = "LookGroupHeader"

class LooksBrowserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextButton: BButton!
    @IBOutlet weak var looksView: UICollectionView!
    
    var keyFrame : UIImage!
    var renderer : ES2Renderer!
    var cellSize : CGSize = CGSize(width: 170, height: 170)
    var selectedLook : Look?
    var videoURL: NSURL?
    
    var videoMode = VideoModeWideSceenLandscape
    
    let lookGroups = PurchaseManager.sharedManager.looks
    var lookStates : [Look : LookCellState] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setType(.Primary)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        
        if (videoURL == nil) {
            CLSLogv("loadVideo not called before load", getVaList([]))
            Crashlytics.sharedInstance().crash()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
//        lookStates = [:]
        super.didReceiveMemoryWarning()
    }
    
    // needs to be called BEFORE loading
    func loadVideo(videoURL:NSURL) throws {
        self.videoURL = videoURL
        keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: kCMTimeZero)
        cellSize = cellSize(keyFrame)
        lookStates = lookStates(lookGroups)
        
        let scale = UIScreen.mainScreen().scale
        let outputSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        renderer = ES2Renderer(frameSize: outputSize, outputFrameSize: outputSize)
        startRender(keyFrame)
    }
    
    func startRender(keyFrame:UIImage) {
        // no matter what you put in for the size, the renderer will create a square image and fill the space
        // that you give it. So make sure this is square
        let scale = UIScreen.mainScreen().scale
        let outputSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        renderer.resetFrameSize(outputSize, outputFrameSize: outputSize)
        renderer.resetRenderBuffer()
        renderer.loadKeyFrame(keyFrame)
    }
    
    func lookStates(lookGroups: [LookGroup]) -> [Look : LookCellState] {
        var states : [Look : LookCellState] = [:]
        lookGroups
            .flatMap({group in
                return group.items.map({look in
                    return LookCellState(look: look)
                })
            })
            .forEach({(state : LookCellState) in
                states[state.look] = state
            })
       
        return states
    }
    
    func queueRender(state:LookCellState) {
        state.rendering = true
        NSOperationQueue.currentQueue()?.addOperationWithBlock({
            print("")
            print("****************** RENDER!")
            let look = state.look
            self.renderer.loadLookParam(look.data, withMode: self.videoMode)
    		self.renderer.looksStrengthValue = 1.0
    		self.renderer.looksBrightnessValue = 0.5
            
			let processedCGImageRef = self.renderer.frameProcessingAndReturnImage(nil, flipPixel:false)
            
            let processedImage = UIImage(CGImage: processedCGImageRef.takeUnretainedValue())
            print(" - got image", look.name)
            
            state.image = processedImage
            state.rendering = false
            state.onRender(processedImage)
        })
    }
    
    func cellSize(keyFrame:UIImage) -> CGSize {
        // these should always be square
        return CGSize(width: 170, height: 170)
    }
    
    @IBAction func tappedNext() {
        print("NEXT")
        
        self.performSegueWithIdentifier("LookPreviewController", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let preview = segue.destinationViewController as? LookPreviewController {
            preview.videoURL = videoURL
            preview.look = selectedLook
            preview.keyFrame = keyFrame
            preview.videoMode = self.videoMode
            preview.renderer = self.renderer
        }
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
        let group = lookGroups[indexPath.section]
        selectedLook = group.items[indexPath.item]
        nextButton.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LookCellIdentifier, forIndexPath: indexPath) as! LookCell
        
        let group = lookGroups[indexPath.section]
        let look = group.items[indexPath.item]
        
        cell.label.text = look.name
        
        if let state = lookStates[look] {
            print("Got cell", look.name)
            cell.update(state)
            
            if state.image == nil && state.rendering == false {
                queueRender(state)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: LookGroupHeaderIdentifier, forIndexPath: indexPath) as! LookGroupHeader
        let group = lookGroups[indexPath.section]
        header.label.text = group.name
        return header
    }

}
