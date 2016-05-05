//
//  ViewController.swift
//  Asdf
//
//  Created by Sean Hess on 5/5/16.
//  Copyright © 2016 Orbital Labs. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            Debug.addDefaultVideoIfEmpty()
        #endif
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedInfo() {
        print("tapped info")
        self.performSegueWithIdentifier("InfoViewController", sender: self)
//        if let info = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InfoViewController") as? InfoViewController {
//            
//            print("info!")
//            self.navigationController?.pushViewController(info, animated: true)
//        }
        
    }
    
    @IBAction func tappedFind() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        picker.modalPresentationStyle = .Popover
        picker.popoverPresentationController?.sourceView = self.view
        picker.popoverPresentationController?.sourceRect = self.findButton.frame
        picker.mediaTypes = [kUTTypeMovie as String]
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("cancel")
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        print("GOT image", image, )
//        
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("GOT MEDIA")
//        let chosenURL = info[UIImagePickerControllerMediaURL]
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
        //    appDelegate.videoSize = [AVAssetUtilities naturalSize:avAsset];
        //	appDelegate.videoDuration = CMTimeGetSeconds([avAsset duration]);
    }
}



/*
 
 
 
 - (void)saveKeyFrame{
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];
	
	CGSize maximumSize;
	//bret check
 //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	//	maximumSize = CGSizeMake(800, 450);
	//else
	//	maximumSize = CGSizeMake(320, 180);
 
 if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
 maximumSize = CGSizeMake(800, 450);
	else
 maximumSize = CGSizeMake(640, 360);
	
	if(mAssetMode==VideoModePortrait)
 maximumSize = CGSizeMake(maximumSize.height, maximumSize.width);
	
	
	[avImageGenerator setMaximumSize:maximumSize];
	
	MobileLooksAppDelegate *appDelegate = (MobileLooksAppDelegate*)[[UIApplication sharedApplication] delegate];
 appDelegate.videoSize = [AVAssetUtilities naturalSize:avAsset];
	appDelegate.videoDuration = CMTimeGetSeconds([avAsset duration]);
	NSLog(@"Video Time:%f",CMTimeGetSeconds([avAsset duration]));
	
	NSError* err = nil;
	CMTime currentTime = [mPlayer currentTime];
	CGImageRef keyFrameRef =  [avImageGenerator copyCGImageAtTime:currentTime actualTime:NULL error:&err];
	
	if(err)
 NSLog(@"%@",[err localizedDescription]);
	
	UIImage* keyFrame = [UIImage imageWithCGImage:keyFrameRef];
	NSData *imageData = UIImagePNGRepresentation(keyFrame);
	NSString *imagePath = [Utilities savedKeyFrameImagePath];
	[imageData writeToFile:imagePath atomically:NO];
	CGImageRelease(keyFrameRef);
 }
 
 - (void)saveVideo{
	[Utilities selectedVideoPathWithURL:mURL];
 }
 
 - (void)saveKeyFrameAndVideo{
	[Utilities selectedVideoPathWithURL:mURL];
	
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];
	
	CGSize maximumSize;
	//bret check
 //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	//	maximumSize = CGSizeMake(800, 450);
	//else
	//	maximumSize = CGSizeMake(320, 180);
	
 if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
 maximumSize = CGSizeMake(800, 450);
	else
 maximumSize = CGSizeMake(640, 360);
 
	if(mAssetMode==VideoModePortrait)
 maximumSize = CGSizeMake(maximumSize.height, maximumSize.width);
 
 
	[avImageGenerator setMaximumSize:maximumSize];
 
	MobileLooksAppDelegate *appDelegate = (MobileLooksAppDelegate*)[[UIApplication sharedApplication] delegate];
 appDelegate.videoSize = [AVAssetUtilities naturalSize:avAsset];
	appDelegate.videoDuration = CMTimeGetSeconds([avAsset duration]);
	NSLog(@"Video Time:%f",CMTimeGetSeconds([avAsset duration]));
	
	NSError* err = nil;
	CMTime currentTime = [mPlayer currentTime];
	CGImageRef keyFrameRef =  [avImageGenerator copyCGImageAtTime:currentTime actualTime:NULL error:&err];
 
	if(err)
 NSLog(@"%@",[err localizedDescription]);
	
	UIImage* keyFrame = [UIImage imageWithCGImage:keyFrameRef];
	NSData *imageData = UIImagePNGRepresentation(keyFrame);
	NSString *imagePath = [Utilities savedKeyFrameImagePath];
	[imageData writeToFile:imagePath atomically:NO];
	CGImageRelease(keyFrameRef);
 }
 

 */
