//
//  BulletViewController.h
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieProcessor.h"
// #import "FacebookConnect.h"
#import "MProgressView.h"
#import "CustomPopView.h"
#import "WebSiteCtrlor.h"
#import "ES2Renderer.h"

#import "PlaybackView.h" //bret


typedef enum
{
	bAVPlayerReady,
	bAVPlayerPlaying,
	bAVPlayerPaused,
} bAVPlayerState;


typedef enum VIDEO_WRITING_STATUS{
	
	Video_Ready_Writing = 0,
	Video_Writing,
	Video_Writing_End
	
} VideoWritingStatus;

typedef enum AUDIO_WRITING_STATUS{
	
	Audio_Ready_Writing = 0,
	Audio_Writing,
	Audio_Writing_End
	
} AudioWritingStatus;

typedef enum
{
	RendererTypeHalf,
	RendererTypeFull
} RendererType;

@class TimeView;
@class ComposeProgressView;
@class ScrollViewEnhancer;

@interface BulletViewController : UIViewController <UIAlertViewDelegate,
	MovieProcessorDelegate, MProgressViewDelegate, CustomPopViewDelegate, WebSiteCtrlorDelegate>{
	
	RendererType renderType;
	BOOL		 renderFullFramerate;
	
	CGSize				videoSize_;
	CGSize				outputSize;
	ES2Renderer			*renderer;
	MovieProcessor*		movieProcessor;
	NSString*			processedMoviePath;
	int 				_curInputFrameIdx;		// input frame idx from reader (may not match _completed frames if we are only rendering at half frame rate)
	int					_completedFrames;
	float				_totalFrames;			// total frames to be processed
    int					timeRemaining;
    int					lastTimeRemaining;
    float               timeElapsedLandscape;
    float               timeElapsedPortrait;
    float               timeScale;
	int					framePastedFromPause;
	
	//UIImageView			*framesView;
	UIButton			*cancelButton;
	//UIButton			*readyButton;
	
	struct timeval		lastUpdate;
	//TimeView			*timeView;
	//ComposeProgressView *composeProgressView;
	NSTimer				*timer;
	
	float				fStrengthValue;
	float				fBrightnessValue;
	BOOL				isAppActive;
	BOOL				needCheckPoint;
	BOOL				isAlertViewShown;
    BOOL                isVideoSavedorShared;
    BOOL                blockCameraRollSave;
    BOOL                useYouTube;
	UIAlertView*		mAlertView;
	
	
	//UIScrollView *scrollView;
	//ScrollViewEnhancer *scrollEnhancer;
	//int tipsCount;
	
	NSTimeInterval 			renderStartTime;
	NSTimeInterval			estimateFrameProcessTime;		// amount of time a single frame is expected to endure
	NSTimeInterval			estimateClipProcessTime;		// adjustment factor applied to estimates for a single frame
	NSTimeInterval			estimateTotalRenderTime;		// initial estimate of total render time
	NSTimeInterval 			measuredTotalRenderTime;		// the actual render time once  calculated 
    UIImageView				*mThumbImageView;
    UIView					*mThumbView;
    UIView					*mOpaqueViewLandscape;
    UIView					*mOpaqueViewPortrait;
    UIImage                 *mThumbImage;
    UIImageView             *mMessage1;
    UIImageView             *mMessage2;
    //UIImageView             *mMessage3;
    //bret video section
    UIButton* mPlayButton;
    AVPlayer*       mPlayer;
    PlaybackView*   mPlaybackView;
    id				mPlayTimeObserver;
    bAVPlayerState	mPlayerState;
    CMTime			mVideoDuration;
    UIButton* goBackButton;
    UIButton* goPlayButton;
    UIButton* goPauseButton;
    UIButton*    goChangeButton;
    UIButton*    goFacebookButton;
    UIButton*    goYoutubeButton;
    UIButton*    goShareButton;     //ios 7
    UIButton*    goCameraRollButton;
    
    UIButton* movieAdvanceSliderBackground;
    UISlider* movieAdvanceSlider;
    UIActivityIndicatorView *activityIndicator;
        
    //end video section
	VideoMode				videoMode;
}

@property (nonatomic) VideoMode videoMode;
@property (nonatomic, assign) ES2Renderer *renderer;
@property (nonatomic) float fStrengthValue;
@property (nonatomic) float fBrightnessValue;
@property (nonatomic) NSTimeInterval renderStartTime;
@property (nonatomic) NSTimeInterval estimateFrameProcessTime;
@property (nonatomic) NSTimeInterval estimateClipProcessTime;
@property (nonatomic) NSTimeInterval estimateTotalRenderTime;
@property (nonatomic) NSTimeInterval measuredTotalRenderTime;
@property (nonatomic, retain) UIImage *mThumbImage;

-(void)setRendererType:(RendererType)type withFullFramerate:(BOOL)fullFramerate andLookParam:(NSDictionary*)lookDic;

@end
