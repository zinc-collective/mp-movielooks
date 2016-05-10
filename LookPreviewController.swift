//
//  LookPreviewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit

let kLookName = "name"

class LookPreviewController: LookPreviewControllerOld {
    
    // to be set before loading
    var videoURL:NSURL!
    var keyFrame:UIImage!
    var look:Look!
    
    override func viewDidLoad() {
        
        do {
            try self.hackSaveGlobalVideo()
            self.hackSetupGlobalLook()
        }
        catch let err as NSError {
            print("ERROR LOADING", err.description)
        }
        
		self.lookDic = look.data
        
        let outputSize = self.frameSize
        let originalOutputSize = self.frameSize
		//previewController.outputSize = outputSize;
		self.outputSizeCropped = outputSize
		self.outputSize = originalOutputSize
        
        let renderer = ES2Renderer(frameSize: outputSize, outputFrameSize: outputSize)
        renderer.resetFrameSize(outputSize, outputFrameSize: outputSize)
        renderer.resetRenderBuffer()
        renderer.loadKeyFrame(keyFrame)
        self.renderer = renderer
        
        super.viewDidLoad()
    }
    
    func hackSaveGlobalVideo() throws {
        // HACK: stupid global state, required by LookPreviewController and beyond
        let videoDestURL = NSURL(fileURLWithPath: Utilities.savedVideoPath())
        let files = NSFileManager.defaultManager()
        
        if files.fileExistsAtPath(videoDestURL.path!) {
            try files.removeItemAtURL(videoDestURL)
        }
        
        try NSFileManager.defaultManager().copyItemAtURL(videoURL, toURL: videoDestURL)
        
        Utilities.selectedVideoPathWithURL(videoDestURL)
    }
    
    
    func hackSetupGlobalLook() {
//    	let lookDic = look.data
        NSUserDefaults.standardUserDefaults().setObject(look.name, forKey: kLookName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
