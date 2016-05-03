//
//  YoutubeUIActivityShareViewController.h
//  MobileLooks
//
//  Created by Joseph Snow / Snow Software Services on 8/1/2013.
//
//  Copyright 2013 Red Giant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileLooksVideoPickerController.h"
#import "MobileLooksTrimPlayerController.h"
#import "YoutubeConnect.h"
#import "MProgressView.h"

@protocol YoutubeUIActivityShareViewControllerDelegate;

@interface YoutubeUIActivityShareViewController : UIViewController<UIAlertViewDelegate, YoutubeConnectDelegate, MProgressViewDelegate, UITextFieldDelegate>
{
	UIView *contentView;
	UIColor *viewBorderColor;

	UITextField *titleInput;
	UITextField *descInput;
	MProgressView		*progressView;
	UIView 			    *buttonsView;
	
	UIView				*youtubeSettingsView;
	//bret
    UIImage             *mThumbImage;
    UIImageView			*mThumbImageView;
    UILabel             *titleLabel;
    UILabel             *descLabel;
    UISegmentedControl *youtubePrivacyControl;
    UILabel *upLoadSettingsLabel;
    UILabel *userLabel; //user name
    CGSize userLabelSize;
    UIButton *btnLogout; //sign out of facebook/youtube
    UIButton *btnCancel;
    UIButton *btnUpload;
    UIImageView *iconView; //Facebook or Youtube Icon
    UILabel             *privacyLabel;
    UILabel             *uploadingLabel;
    CGSize uploadingLabelSize;
    BOOL useYouTube;  //YES == Youtube NO == FACEBOOK
    BOOL isUploading;
    BOOL iskeyboardUp;
    UIAlertView*		mAlertView;
    BOOL				isAlertViewShown;
    NSString    *processedMoviePath;
	// connector helpers
	YoutubeConnect		*_youtube;
}

-(UINavigationController*) getNavigationController; 
-(void)addShareSubview:(UIView *)view :(NSString*)title :(NSString*)imagepath :(NSInteger)tag :(NSInteger)yPos;
-(void)addHorizontalSeparator:(UIView*)view :(NSInteger)yPos;
-(void)setCurrentSubView:(UIView *)view;
-(void)shareButtonAction:(id)sender;
-(void)didButtonClickedIndex:(int)index;

-(void)didFinishShare:(BOOL)success :(NSString*)errorMsg;
-(void)beganSendVideoData;

// youtube specific handlers
-(void)sendingVideoDataToYoutube:(unsigned long long)bytesRead dataLength:(unsigned long long)dataLength;
-(void)backAction:(id)sender; //bret
@property (nonatomic) BOOL useYouTube;
@property (nonatomic, strong) UIImage *mThumbImage;
@property (nonatomic, strong) NSString *processedMoviePath;
@property (nonatomic, weak) id<YoutubeUIActivityShareViewControllerDelegate> delegate;
@end

@protocol YoutubeUIActivityShareViewControllerDelegate <NSObject>

- (void)youTubeUIActivityShareViewControllerDidUpload:(YoutubeUIActivityShareViewController*)viewController;
- (void)youTubeUIActivityShareViewControllerDidCancel:(YoutubeUIActivityShareViewController*)viewController;

@end
