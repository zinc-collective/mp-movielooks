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
    
    var sourceVideoURL: URL!
    var renderedKeyFrame: UIImage!
    var lookStrength:Float!
    var lookBrightness:Float!
    var look:Look!
    
    var player = AVPlayer()
    var playerLayer : AVPlayerLayer!
    var isPlaying = false
    var isFinished = false
    var didShare = false
    
    var renderedVideoURL: URL?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
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
        playButton.isHidden = true
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
        playerView.layer.insertSublayer(playerLayer, at: 0)
        
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 150, height: 30)
        let newVideoButton = BButton(frame: buttonFrame)
        newVideoButton.setType(.primary)
        newVideoButton.setTitle(newVideoButtonItem.title, for: UIControlState())
        newVideoButton.addTarget(self, action: #selector(didTapNewVideo), for: .touchUpInside)
        newVideoButtonItem.customView = newVideoButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoRenderer.cancel()
    }
    
    @IBAction func sharePressed(){
        pause()
        displayShareSheet()
    }
    
    @IBAction func donePressed() {
        pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playPressed(_ sender: AnyObject) {
        play()
    }
    
    @IBAction func pausePressed(_ sender: AnyObject) {
        pause()
    }
    
    func play() {
        if isFinished {
            isFinished = false
            player.seek(to: kCMTimeZero)
        }
        
        isPlaying = true
        player.play()
        
        playButton.isHidden = true
        navigationItem.rightBarButtonItems = [pauseItem, actionItem]
    }
    
    func pause() {
        isPlaying = false
        player.pause()
        playButton.isHidden = false
        navigationItem.rightBarButtonItems = [playItem, actionItem]
    }
    
    func didFinishPlaying() {
        isFinished = true
        pause()
        self.animateBarsHidden(false)
    }
    
    func animateBarsHidden(_ hidden:Bool) {
        
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        
        let bottom : CGFloat = (self.navigationController?.isNavigationBarHidden == true) ? -toolbar.frame.size.height : 0
        self.toolbarBottom.constant = bottom
        self.view.setNeedsUpdateConstraints()
        
        // animate with the same duration...
        UIView.animate(withDuration: 0.200, animations: {
            self.view.layoutIfNeeded()
        })
    }
    

    func displayShareSheet(){
        if let url = renderedVideoURL {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
            activityViewController.modalPresentationStyle = .popover
            activityViewController.popoverPresentationController?.barButtonItem = self.actionItem
            activityViewController.completionWithItemsHandler = { activity, completed, _, _ in
                if completed {
                    self.didShare = true
                }
                
                if activity == UIActivityType.saveToCameraRoll && completed {
                    self.savePhotoFeedback()
                }
            }
            self.navigationController?.present(activityViewController, animated: true, completion: {})
        }
    }
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        let isHidden = (self.navigationController?.isNavigationBarHidden == true)
        self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    func rendererFinished(_ videoURL: URL) {
        self.renderedVideoURL = videoURL
        
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        UIView.animate(withDuration: 0.300, animations: {
            self.processingView.alpha = 0.0
            self.toolbarBottom.constant = 0
        }, completion: {_ in
            self.processingView.isHidden = true
        })
    
        self.navigationItem.rightBarButtonItems = [playItem, actionItem]
        self.navigationItem.title = "Share Your Movie"
        playButton.isHidden = false
    }
    
    func videoFinishedProcessing(_ url: URL!) {
        self.rendererFinished(url)
    }
    
    func videoCompletedFrames(_ completed: Int32, ofTotal total: Int32) {
        let percent = Float(completed) / Float(total)
        DispatchQueue.main.async {
            self.progressView.progress = CGFloat(percent)
        }
    }
    
    func videoDebugImage(_ image: UIImage!) {
        DispatchQueue.main.async {
            print("SET IMAGE")
            self.imageView.image = image
        }
    }
    
    func videoError(_ description: String!) {
        print("VIDEO ERROR!", description)
    }
    
    func didTapNewVideo() {
        print("didShare", didShare)
        if (didShare) {
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        
        else {
            let alert = UIAlertController(title: "Not Saved", message: "Your processed video is not saved, are you sure you want a new video?", preferredStyle: .alert)
            let saveFirstAction = UIAlertAction(title: "Save Video", style: .cancel, handler: { _ in
                // dismiss the alert
                alert.dismiss(animated: true, completion: nil)
                self.displayShareSheet()
            })
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
                _ = self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(continueAction)
            alert.addAction(saveFirstAction)
            self.navigationController?.present(alert, animated: true, completion: {})
        }
    }
    
    func savePhotoFeedback() {
        let alert = UIAlertController(title: "Saved in your Photos library", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: { _ in
            delay(0.8) {
                self.dismiss(animated: true, completion: nil)
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
