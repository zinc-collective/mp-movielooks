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
    
    var keyFrame : UIImage!
    var renderer : ES2Renderer!
    var cellSize : CGSize!
    
    let lookGroups = PurchaseManager.sharedManager.looks
    var lookStates : [Look : LookCellState] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setType(.Primary)
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
        keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: kCMTimeZero)
        cellSize = cellSize(keyFrame)
        lookStates = lookStates(lookGroups)
        
        // save the key frame
        // the renderer requires this, because it is retarted
        // TODO fix ES2Renderer
        if let imageData = UIImagePNGRepresentation(keyFrame) {
            let imagePath = Utilities.savedKeyFrameImagePath()
            imageData.writeToFile(imagePath, atomically: false)
        }
        
        // I need to keep track of it
        renderer = ES2Renderer(frameSize: cellSize, outputFrameSize: cellSize)
        renderer.loadKeyFrameCrop()
        
        startRender()
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
    
    func startRender() {
        renderer.resetFrameSize(cellSize, outputFrameSize: cellSize)
        renderer.resetRenderBuffer()
        renderer.loadKeyFrameCrop()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.renderLoop()
        }
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
    
    func renderLoop() {
        // create all the look states
        
        var renderStates = Array(lookStates.values)
        
        // NOTE: the first one fails for some reason (this was there in the legacy code uncommented)
        // so render it twice
        renderStates = renderStates + [renderStates[0]]
        
        renderStates.forEach { (state) in
            
            let look = state.look
            self.renderer.loadLookParam(look.data, withMode: VideoModeTraditionalLandscape)
			renderer.looksStrengthValue = 1.0
			renderer.looksBrightnessValue = 0.5
            
			let processedCGImageRef = renderer.frameProcessingAndReturnImage(nil, flipPixel:false)
            
//			if(videoMode==VideoModeWideSceenPortrait || videoMode==VideoModeTraditionalPortrait) {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef  scale:1.0 orientation:UIImageOrientationRight];
//			}
//			else {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef];
//			}
            
            
            let processedImage = UIImage(CGImage: processedCGImageRef.takeUnretainedValue())
            print(" - got image", look.name)
			
            dispatch_async(dispatch_get_main_queue()) {
                print(" - set image", look.name)
                state.image = processedImage
                state.onRender(processedImage)
            }
        }
    }
    
    func cellSize(keyFrame:UIImage) -> CGSize {
        let width:CGFloat = 170
        let ratio = keyFrame.size.height / keyFrame.size.width
        let height = width * ratio
        return CGSize(width: width, height: height)
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
        
        cell.label.text = look.name
        
        if let state = lookStates[look] {
            print("Got cell", look.name)
            cell.update(state)
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
