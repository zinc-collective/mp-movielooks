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
import BButton

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
    var didShare = false
    
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
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarBottom: NSLayoutConstraint!
    @IBOutlet weak var newVideoButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var processingView: UIView!
    @IBOutlet weak var progressContainer: UIView!
    var progressView: DAProgressOverlayView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isPlaying = false
        self.videoRenderer.reset()
//        navigationItem.rightBarButtonItems = [playItem, actionItem]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playerLayer.frame = playerView.bounds
        progressView.frame = progressContainer.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide it
        toolbarBottom.constant = -toolbar.frame.size.height
        
        imageView.image = renderedKeyFrame
        playButton.hidden = true
        self.navigationItem.rightBarButtonItems = []
        
        let progressView = DAProgressOverlayView(frame: progressContainer.bounds)
        progressContainer.addSubview(progressView)
        progressView.displayOperationWillTriggerAnimation()
        self.progressView = progressView
        
        self.videoRenderer = VideoRenderer()
        self.videoRenderer.delegate = self
        self.videoRenderer.load(self.sourceVideoURL, renderer: self.renderer, videoMode: videoMode, brightness: lookBrightness, strength: lookStrength, rendererType: RendererTypeFull, fullFramerate: true, lookParam: look.data)
        self.videoRenderer.startRenderInBackground()

        playerLayer = AVPlayerLayer(player: player)
        playerView.layer.insertSublayer(playerLayer, atIndex: 0)
        
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 150, height: 30)
        let newVideoButton = BButton(frame: buttonFrame)
        newVideoButton.setType(.Primary)
        newVideoButton.setTitle(newVideoButtonItem.title, forState: .Normal)
        newVideoButton.addTarget(self, action: #selector(didTapNewVideo), forControlEvents: .TouchUpInside)
        newVideoButtonItem.customView = newVideoButton
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoRenderer.cancel()
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
        if isFinished {
            isFinished = false
            player.seekToTime(kCMTimeZero)
        }
        
        isPlaying = true
        player.play()
        
        playButton.hidden = true
        navigationItem.rightBarButtonItems = [pauseItem, actionItem]
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        playButton.hidden = false
        navigationItem.rightBarButtonItems = [playItem, actionItem]
    }
    
    func didFinishPlaying() {
        isFinished = true
        pause()
        self.animateBarsHidden(false)
    }
    
    func animateBarsHidden(hidden:Bool) {
        
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        
        let bottom : CGFloat = (self.navigationController?.navigationBarHidden == true) ? -toolbar.frame.size.height : 0
        self.toolbarBottom.constant = bottom
        self.view.setNeedsUpdateConstraints()
        
        // animate with the same duration...
        UIView.animateWithDuration(0.200, animations: {
            self.view.layoutIfNeeded()
        })
    }
    

    func displayShareSheet(){
        if let url = renderedVideoURL {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
            activityViewController.completionWithItemsHandler = { activity, completed, _, _ in
                if completed {
                    self.didShare = true
                }
                
                if activity == UIActivityTypeSaveToCameraRoll && completed {
                    self.savePhotoFeedback()
                }
            }
            self.navigationController?.presentViewController(activityViewController, animated: true, completion: {})
        }
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        let isHidden = self.navigationController?.navigationBarHidden
        self.animateBarsHidden(isHidden != true)
    }
    
    func rendererFinished(videoURL: NSURL) {
        self.renderedVideoURL = videoURL
        
        let playerItem = AVPlayerItem(URL: videoURL)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        UIView.animateWithDuration(0.300, animations: {
            self.processingView.alpha = 0.0
            self.toolbarBottom.constant = 0
        }, completion: {_ in
            self.processingView.hidden = true
        })
    
        self.navigationItem.rightBarButtonItems = [playItem, actionItem]
        self.navigationItem.title = "Share Your Movie"
        playButton.hidden = false
    }
    
    func videoFinishedProcessing(url: NSURL!) {
        self.rendererFinished(url)
    }
    
    func videoCompletedFrames(completed: Int32, ofTotal total: Int32) {
        let percent = Float(completed) / Float(total)
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = CGFloat(percent)
        }
    }
    
    func videoDebugImage(image: UIImage!) {
        dispatch_async(dispatch_get_main_queue()) {
            print("SET IMAGE")
            self.imageView.image = image
        }
    }
    
    func videoError(description: String!) {
        print("VIDEO ERROR!", description)
    }
    
    func didTapNewVideo() {
        print("didShare", didShare)
        if (didShare) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        else {
            let alert = UIAlertController(title: "Not Saved", message: "Your processed video is not saved, are you sure you want a new video?", preferredStyle: .Alert)
            let saveFirstAction = UIAlertAction(title: "Save Video", style: .Cancel, handler: { _ in
                // dismiss the alert
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.displayShareSheet()
            })
            let continueAction = UIAlertAction(title: "Continue", style: .Default, handler: { _ in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alert.addAction(continueAction)
            alert.addAction(saveFirstAction)
            self.navigationController?.presentViewController(alert, animated: true, completion: {})
        }
    }
    
    func savePhotoFeedback() {
        let alert = UIAlertController(title: "Saved in your Photos library", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: { _ in
            delay(0.8) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
    }
    
}
//    NSURL *url = [NSURL fileURLWithPath:processedMoviePath];
//    NSArray* dataToShare = [NSArray arrayWithObjects:url,nil];
//    
//    YoutubeActivity *youtubeactivity = [[YoutubeActivity alloc]init];
//    youtubeactivity.mThumbImage = mThumbImageView.image;
//    youtubeactivity.processedMoviePath = processedMoviePath;
//    
//    NSArray* customactivities = [NSArray arrayWithObjects:youtubeactivity,nil];
//
//    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
//                                                                                         applicationActivities:customactivities];
//
//
//    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray * returnedItems, NSError * error)
//    {
//        bool activityTypeFound = false;
//        NSString *notificationString;
//        if (completed)
//        {
//            isVideoSavedorShared  = YES;
//            
//            if ([activityType rangeOfString:@"cameraroll" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                activityTypeFound = true;
//                notificationString = @"Your movie was saved to the Camera Roll.";
//                //if (!isVideoSavedorShared)
//                //    [self finishSaveToCameraRollEvent];
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"facebook" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Facebook.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"youtube" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Youtube.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"vimeo" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Vimeo.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"flickr" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Flickr.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"weibo" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Weibo.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if (!activityTypeFound)
//            {
//                notificationString = @"Your movie was sucessfully uploaded.";
//            }
//        }
