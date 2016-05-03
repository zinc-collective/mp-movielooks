//
//  HomeViewController.h
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MobileLooksVideoPickerController.h"
#import "MobileLooksTrimPlayerController.h"

@interface HomeViewController : UIViewController <CLLocationManagerDelegate,MobileLooksVideoPickerControllerDelegate,MobileLooksTrimPlayerControllerDelegate, UINavigationControllerDelegate>
{
@private
	//storyboard UIButton *infoButton;
	UIButton *chooseVideoButton;
	
	UINavigationController  *navigationVideoPicker;
	UINavigationController  *navigationVideoProcessor;
	BOOL	isSelectingVideo;
	BOOL    isSharingVideo;
	UIButton *_newsBtn;
	UIButton *_shareBtn;
    //UIView *mOpaqueView;
	
	CLLocationManager *locationManager;
    
    NSURL *selectedURL; //for storyboard seque
    int assetMode;
}
//storyboard
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
//- (IBAction)infoButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *chooseVideoButton;
//- (IBAction)chooseVideoButtonAction:(id)sender;


//- (void)chooseVideoAction:(id)sender;
//- (void)showChooseVideoView;
- (void)layoutForCurrentOrientation;
- (void)dismissNavigationPicker;
- (void)dismissNavigationProcessor;
- (void)presentShareView; 
- (void)showShareButton;
- (void)shareAction:(id)sender;
- (void)showNewsButton;
- (void)newsAction:(id)sender;

@end
