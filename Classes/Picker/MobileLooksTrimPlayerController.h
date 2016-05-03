//
//  MobileLooksTrimPlayerController.h
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTrimView.h"
#import "PlaybackView.h"

@class MobileLooksTrimPlayerController;

@protocol MobileLooksTrimPlayerControllerDelegate
@optional
-(void)videoPickerDone:(MobileLooksTrimPlayerController*)trimPlayerController;
@end

typedef enum 
{
	AVPlayerReady,	
	AVPlayerPlaying,
	AVPlayerPaused,	
} AVPlayerState;

typedef enum 
{
	VideoModePortrait,
	VideoModeLandscape,
}AssetMode;

@interface MobileLooksTrimPlayerController : UIViewController<QuartzTrimViewDelegate> {
    NSURL* mURL;
	NSURL* mExportURL;
	BOOL	mExportCancel;
	BOOL	mIsTrimming;
	
	UIBarButtonItem* backButton;
	UIBarButtonItem* cancelButton;
	//bret UIButton* doneButton;
	UIButton* trimButton;
    UIButton* goBackButton;
    UIButton* nextButton;
    UIButton* goPlayButton;
    UIButton* goPauseButton;
    UIButton* movieAdvanceSliderBackground;
    UISlider* movieAdvanceSlider;
	
	UIButton* mPlayButton;
	UIProgressView* mProgressView;
	AVAssetExportSession* mAVTrimSession;
	NSTimer				*mTrimProgressTimer;
	
	PlaybackView*   mPlaybackView;
	id				mPlayTimeObserver;
	AVPlayerState	mPlayerState;
	CMTime			mVideoDuration;	
	AssetMode       mAssetMode;
	id<MobileLooksTrimPlayerControllerDelegate> __weak _delegate;
}

@property(nonatomic,weak) id<MobileLooksTrimPlayerControllerDelegate> delegate;
@property (nonatomic, strong) CustomTrimView* mCustomTrimView;
@property (nonatomic, strong) AVPlayer*       mPlayer;

//- (id)initWithUrl:(NSURL *)sourceUrl withAssetMode:(AssetMode)mode;
- (void)setUrl:(NSURL *)sourceUrl withAssetMode:(AssetMode)mode; //storyboard
- (NSURL*)outputUrl;
@end
