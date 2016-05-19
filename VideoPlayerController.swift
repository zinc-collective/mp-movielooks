//
//  VideoPlayerController.swift
//  Home Movies
//
//  Created by Sean Hess on 3/2/16.
//  Copyright © 2016 HomeMoviesDev. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import DAProgressOverlayLayeredView

class VideoPlayerController : UIViewController, VideoRenderDelegate {
    
    var sourceVideoURL: NSURL!
    var renderedKeyFrame: UIImage!
    var lookStrength:Float!
    var lookBrightness:Float!
    var look:Look!
    
    var player = AVPlayer()
    var playerLayer : AVPlayerLayer!
    var isPlaying = false
    var isFinished = false
    
    var renderedVideoURL: NSURL?
    
    var renderer: ES2Renderer!
    var videoRenderer: VideoRenderer!
    var videoMode:VideoMode = VideoModeTraditionalLandscape
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var playItem: UIBarButtonItem!
    @IBOutlet var pauseItem: UIBarButtonItem!
    @IBOutlet var actionItem: UIBarButtonItem!
    
    @IBOutlet weak var processingView: UIView!
    @IBOutlet weak var progressView: DAProgressOverlayView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isPlaying = false
        self.navigationItem.rightBarButtonItems = [actionItem]
        self.videoRenderer.reset()
//        navigationBar.topItem?.rightBarButtonItems = [playItem, actionItem]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playerLayer.frame = playerView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = renderedKeyFrame
        playButton.hidden = true
        self.navigationItem.rightBarButtonItems = []
        self.progressView.displayOperationWillTriggerAnimation()

        self.progressView.progress = 0.5
        
        self.videoRenderer = VideoRenderer()
        self.videoRenderer.delegate = self
        self.videoRenderer.load(self.sourceVideoURL, renderer: self.renderer, videoMode: videoMode, brightness: lookBrightness, strength: lookStrength, rendererType: RendererTypeFull, fullFramerate: true, lookParam: look.data)
        self.videoRenderer.startRenderInBackground()

        playerLayer = AVPlayerLayer(player: player)
        playerView.layer.insertSublayer(playerLayer, atIndex: 0)
    }
    
    @IBAction func sharePressed(){
        pause()
        displayShareSheet()
    }
    
    @IBAction func donePressed() {
        pause()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playPressed(sender: AnyObject) {
        play()
    }
    
    @IBAction func pausePressed(sender: AnyObject) {
        pause()
    }
    
    func play() {
        
        hideNavbar()
        
        if isFinished {
            isFinished = false
            player.seekToTime(kCMTimeZero)
        }
        
        isPlaying = true
        player.play()
        
        playButton.hidden = true
//        navigationBar.topItem?.rightBarButtonItems = [pauseItem, actionItem]
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        playButton.hidden = false
//        navigationBar.topItem?.rightBarButtonItems = [playItem, actionItem]
    }
    
    func didFinishPlaying() {
        isFinished = true
        pause()
        showNavbar()
    }
    

    func displayShareSheet(){
        if let url = renderedVideoURL {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: {})
        }
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
//        if navigationBar.alpha == 1.0 {
//            hideNavbar()
//        }
//        else {
//            showNavbar()
//        }
    }
    
    func showNavbar() {
//        UIView.animateWithDuration(0.300, animations: {
//            self.navigationBar.alpha = 1.0
//        })
    }
    
    func hideNavbar() {
//        UIView.animateWithDuration(0.300, animations: {
//            self.navigationBar.alpha = 0.0
//        })
    }
    
    func rendererFinished(videoURL: NSURL) {
        self.renderedVideoURL = videoURL
        
        let playerItem = AVPlayerItem(URL: videoURL)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        player.play()
        
        self.processingView.hidden = true
    }
    
    func videoFinishedProcessing(url: NSURL!) {
        self.rendererFinished(url)
    }
    
    func videoTimeRemaining(time: Int32) {
//        print("Time remaining", time)
    }
    
    func videoTimeElapsed(portrait: Float, landscape: Float) {
        print("Time elapsed", portrait, landscape, videoRenderer.estimateTotalRenderTime)
        let percent = portrait / Float(videoRenderer.estimateTotalRenderTime)
        print("UMMM", percent)
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = CGFloat(percent)
        }
    }
    
}
