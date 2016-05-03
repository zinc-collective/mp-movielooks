//
//  ShareViewController.h
//  MobileLooks
//
//  Created by Joseph Snow / Snow Software Services on 8/1/2013.
//  Copyright 2013 Red Giant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileLooksVideoPickerController.h"
#import "MobileLooksTrimPlayerController.h"
#import "FacebookConnect.h"
#import "YoutubeConnect.h"
#import "MProgressView.h"
#import "WebSiteCtrlor.h"


@interface ShareViewController : UIViewController<UIAlertViewDelegate,FacebookConnectDelegate, YoutubeConnectDelegate, MProgressViewDelegate, UITextFieldDelegate, WebSiteCtrlorDelegate>
{
	UIView *contentView;
	UIColor *viewBorderColor;

	UITextField *titleInput;
	MProgressView		*progressView;
	UIView 			    *buttonsView;
	
	UIView				*facebookSettingsView;
	UIView				*youtubeSettingsView;
	//bret
    UIImage             *mThumbImage;
    UIImageView			*mThumbImageView;
    UILabel             *titleLabel;
    UISegmentedControl *facebookPrivacyControl;
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
	FacebookConnect		*_facebook;
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
-(void)sendingVideoDataToFacebook:(NSInteger)bytesSend bytesNeedSend:(NSInteger)bytesNeedSend;
-(void)didNeedAskJoinGroup:(NSString*)joinUrl;

// youtube specific handlers
-(void)sendingVideoDataToYoutube:(unsigned long long)bytesRead dataLength:(unsigned long long)dataLength;
-(void)backAction:(id)sender; //bret
@property (nonatomic) BOOL useYouTube;
@property (nonatomic, retain) UIImage *mThumbImage;
@property (nonatomic, retain) NSString *processedMoviePath;
@end
