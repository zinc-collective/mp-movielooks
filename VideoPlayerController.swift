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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    func displayShareSheet(){
        if let url = renderedVideoURL {
//            let youtube = YoutubeActivity()
//            youtube.mThumbImage = renderedKeyFrame
//            youtube.processedMoviePath = url.path
//            let youtube = KMYoutubeActivity()
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: {})
        }
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        let isHidden = self.navigationController?.navigationBarHidden
        self.navigationController?.setNavigationBarHidden(isHidden != true, animated: true)
    }
    
    func rendererFinished(videoURL: NSURL) {
        self.renderedVideoURL = videoURL
        
        let playerItem = AVPlayerItem(URL: videoURL)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        UIView.animateWithDuration(0.300, animations: {
            self.processingView.alpha = 0.0
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
