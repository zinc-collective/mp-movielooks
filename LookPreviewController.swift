//
//  LookPreviewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit
import BButton

let kLookName = "name"

class LookPreviewController: UIViewController {
    
    // to be set before loading
    var videoURL:NSURL!
    var keyFrame:UIImage!
    var look:Look!
    var lookStrength:Float = 1.0
    var lookBrightness:Float = 0.5
    var videoMode = VideoModeWideSceenLandscape
    
    var renderer : ES2Renderer!
    
    @IBOutlet weak var strengthSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var hdSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var developButton: BButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        
        developButton.setType(.Primary)
        strengthSlider.value = lookStrength
        brightnessSlider.value = lookBrightness
        
        let outputSize = imageOutputSize()
        self.renderer = ES2Renderer(frameSize: outputSize, outputFrameSize: outputSize)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let outputSize = imageOutputSize()
        self.renderer.resetRenderBuffer()
        self.renderer.resetFrameSize(outputSize, outputFrameSize: outputSize)
        self.renderer.loadKeyFrame(self.keyFrame)
        self.loadImageWithSpinner()
    }
    
    func loadImageWithSpinner() {
        spinner.hidden = false
        spinner.startAnimating()
        let image = self.renderImage(self.look, strength: self.lookStrength, brightness: self.lookBrightness)
        self.imageView.image = image
        self.spinner.stopAnimating()
        self.spinner.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        renderer.unloadKeyFrame()
//        renderer.resetRenderBuffer()
    }
    
    func imageOutputSize() -> CGSize {
//        let displaySize = imageView.frame.size
//        let minAxis = min(displaySize.width, displaySize.height)
        let scale = UIScreen.mainScreen().scale
        let iPhone6PlusMinAxis:CGFloat = 414.0
//        return CGSize(width: minAxis * scale, height: minAxis * scale)
        return CGSize(width: iPhone6PlusMinAxis * scale, height: iPhone6PlusMinAxis * scale)
    }
    
    func renderImage(look:Look, strength: Float, brightness: Float) -> UIImage {
        renderer.loadLookParam(look.data, withMode: self.videoMode)
		renderer.looksStrengthValue = strength
		renderer.looksBrightnessValue = brightness
        
		let processedCGImageRef = renderer.frameProcessingAndReturnImage(nil, flipPixel:false)
        
//			if(videoMode==VideoModeWideSceenPortrait || videoMode==VideoModeTraditionalPortrait) {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef  scale:1.0 orientation:UIImageOrientationRight];
//			}
//			else {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef];
//			}
        
        let processedImage = UIImage(CGImage: processedCGImageRef.takeUnretainedValue(), scale: 1.0, orientation: keyFrame.imageOrientation)
        
//            CGImage: processedCGImageRef.takeUnretainedValue(), scale: 0.5)
        
        return processedImage
    }
    
    func render() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = self.renderImage(self.look, strength: self.lookStrength, brightness: self.lookBrightness)
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = image
            }
        }
    }
    
    // the size: depends on the orientation
    // but for now, just use the image size
    // but it should be initialized once the size is actually all aligned
    // can I just render the image at half res?
    
//    func hackSaveGlobalVideo() throws {
//        // HACK: stupid global state, required by LookPreviewController and beyond
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
//    }
//    
//    
//    func hackSetupGlobalLook() {
////    	let lookDic = look.data
//        NSUserDefaults.standardUserDefaults().setObject(look.name, forKey: kLookName)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStrength(sender: AnyObject) {
        lookStrength = strengthSlider.value
    }
        
    @IBAction func onBrightness(sender: AnyObject) {
        lookBrightness = brightnessSlider.value
    }
    
    @IBAction func onSlideEnd(sender: AnyObject) {
        self.render()
    }
    
    @IBAction func onHD(sender: AnyObject) {
        
    }
    
    @IBAction func onDevelop(sender: AnyObject) {
        print("DEVELOP")
        self.performSegueWithIdentifier("VideoPlayerController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let player = segue.destinationViewController as? VideoPlayerController {
            player.renderedKeyFrame = imageView.image
            player.sourceVideoURL = videoURL
            player.look = look
            player.lookBrightness = lookBrightness
            player.lookStrength = lookStrength
            player.renderer = self.renderer
        }
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        
//        // HACK: remove when we update the UI
//        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
//            // find the smaller of the two
//            let size = self.view.frame.size
//            let scale = min(size.width, size.height) / CGFloat(320)
//            self.view.transform = CGAffineTransformMakeScale(scale, scale)
//        }
//    }

}
