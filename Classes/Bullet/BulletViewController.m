//
//  MobileLooksViewController.m
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BulletViewController.h"
#import "MobileLooksAppDelegate.h"
#import "ScrollViewEnhancer.h"
#import "TipView.h"
#import "TimeView.h"
#import "ComposeProgressView.h"
#import "HomeViewController.h"
#import "ShareViewController.h"
#import "YoutubeActivity.h"
#import <sys/time.h>

#import "DeviceDetect.h"

#define Audio_Decode
#define IS_WITHOUT_AUDIO YES

static NSString* const AVPlayerRateObservationContextBullet = @"AVPlayerRateObservationContextBullet";


@implementation BulletViewController
//@synthesize outputUrl_;
@synthesize videoMode;
@synthesize fBrightnessValue;
@synthesize fStrengthValue;
@synthesize renderer;
@synthesize renderStartTime;
@synthesize estimateFrameProcessTime;
@synthesize estimateClipProcessTime;
@synthesize estimateTotalRenderTime;
@synthesize measuredTotalRenderTime;
@synthesize mThumbImage;


- (id)init
{
	if(self = [super init])
	{
		fBrightnessValue = 0.5;
		fStrengthValue = 1.0;
		
		_curInputFrameIdx = 0;
		_completedFrames = 0;
		_totalFrames = 0;
		isAppActive = YES;
		needCheckPoint = YES;
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
	isAlertViewShown = NO;
	return self;
}

- (void) setRendererType:(RendererType)type withFullFramerate:(BOOL)fullFramerate andLookParam:(NSDictionary*)lookDic
{
	timeRemaining = 0;
	renderType = type;
	renderFullFramerate = fullFramerate;
	[renderer loadLookParam:lookDic withMode:videoMode];
	[renderer freeRenderBuffer];
}
-(NSUInteger)estimateProcessingTimebyFrame:(NSUInteger)numFramesRemainingToProcess;
{
	float fps = 30.0f;
	NSUInteger timeLeft = 0;
	// BOOL quickRender = renderer.doQuickRender;
	timeLeft = estimateFrameProcessTime*numFramesRemainingToProcess+ceil(numFramesRemainingToProcess/fps)*estimateClipProcessTime;
	if(numFramesRemainingToProcess==1)
		NSLog(@"========Last Frame!=======");
	return timeLeft;
}

- (void) exportAction:(id)sender{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	float frameFPS = 30.0f;		// NOTE: joe- I'm assuming the fps is hardcoded to 30
	
	_curInputFrameIdx = 0;
	_completedFrames = 0;
	framePastedFromPause = 0;
	renderer.looksStrengthValue = fStrengthValue;
	renderer.looksBrightnessValue = fBrightnessValue;
	
	if([movieProcessor checkFor720P:&_totalFrames])
		renderType = RendererTypeFull;
	else
		[movieProcessor startRenderMovie];


	timeRemaining = estimateFrameProcessTime*_totalFrames + ceil(_totalFrames/frameFPS)*estimateClipProcessTime;
	//timeScale = timeRemaining;
    timeScale = _totalFrames;
    //[timeView setTimeRemaining:timeRemaining isInit:YES];
	[pool release];
}


- (void)updateTime:(id)sender
{
	//	NSLog(@"Last time:%d, last frame:%d, complete frame:%d!",timeRemaining,(NSUInteger)(_totalFrames-_completedFrames),_completedFrames);
	timeRemaining = [self estimateProcessingTimebyFrame:(NSUInteger)(_totalFrames-_completedFrames)];
	if(timeRemaining<0)
        timeRemaining=0;
	//[timeView setTimeRemaining:timeRemaining isInit:NO];
}

- (void)updateCompose:(id)sender
{
	//[composeProgressView setTitleText:@"Composing%.2f%%" withProgress:[movieProcessor getComposeProgress]*100];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[renderer unloadKeyFrame];
    [self layoutOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) viewDidAppear:(BOOL)animated{
	
	[self.navigationItem setHidesBackButton:YES animated:NO];
	[super viewDidAppear:animated];
	//[self.navigationItem setHidesBackButton:YES animated:NO];
	
	if(_completedFrames==0)
	{
		[self performSelectorInBackground:@selector(exportAction:) withObject:nil]; //bret this starts rendering
		
		if( gettimeofday( &lastUpdate, NULL) != 0 )
		{
			NSAssert(0, @"ERROR: gettimeofday()");
		}
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES] retain];
	}

    [self layoutOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillDisappear:(BOOL)animated
{
#if 0
    if (mPlayer != Nil)
    {
        [self clearPlayer];
        //	NSLog(@"%d",[mPlayer count]);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskPause" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskResume" object:nil];
    }
#endif
	[super viewWillDisappear:animated];
}


- (void) layoutOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
		//iphone
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if (mThumbView.hidden == NO)
            {
            mOpaqueViewPortrait.hidden = YES;
            mOpaqueViewLandscape.hidden = NO;
            }
            if (IS_IPHONE_5)
            {
                mThumbView.frame = CGRectMake(0, 0, 568, 320);
                mOpaqueViewLandscape.frame = CGRectMake(timeElapsedLandscape, 0, 568, 320);
            }else
            {
                mThumbView.frame = CGRectMake(0, 0, 480, 320);
                mOpaqueViewLandscape.frame = CGRectMake(timeElapsedLandscape, 0, 480, 320);
            }
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            }

            //CGRect readyR = CGRectMake(280, 220, 125, 40);
            CGRect cancelR = CGRectMake(12, 320-44-44+((44-33)/2), 106, 33);
            //CGRect timeR = CGRectMake(80, 224, 160, 25);
            //readyButton.frame = readyR;
            cancelButton.frame = cancelR;
            //timeView.frame = timeR;
            int width = 480;
            if (IS_IPHONE_5)
                width = 568;
            CGRect message1Rect = CGRectMake((width-318)/2, 14, 318, 25);
            CGRect message2Rect = CGRectMake((width-288)/2, 320/3, 288, 31);
            //CGRect message3Rect = CGRectMake((width-312)/2, 14, 315, 20);
            mMessage1.frame = message1Rect;
            mMessage2.frame = message2Rect;
            //mMessage3.frame = message3Rect;
            CGRect backR;
            if (IS_IPHONE_5)
            {
                backR = CGRectMake(568-106-12, 320-44-44+((44-33)/2), 106, 33);
                goBackButton.frame = backR;
                mPlaybackView.frame = CGRectMake(0, 0, 568, 320);
                //mPlayButton.frame = CGRectMake((568/2)-30, 160-30, 60, 60);
                mPlayButton.frame = CGRectMake((568/2)-(116/2), 160-(116/2), 116, 116);
            
            }else
            {
                backR = CGRectMake(480-106-12, 320-44-44+((44-33)/2), 106, 33);
                goBackButton.frame = backR;
                mPlaybackView.frame = CGRectMake(0, 0, 480, 320);
                mPlayButton.frame = CGRectMake((480/2)-(116/2), 160-(116/2), 116, 116);
                //mPlayButton.frame = CGRectMake((480/2)-30, 160-30, 60, 60);
            }
            [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_218x33"] forState:UIControlStateNormal];
            UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            UIImage *maxImage = [[UIImage imageNamed:@"slider_background_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];

            if ( movieAdvanceSlider.hidden != YES && mPlayerState == AVPlayerPaused)
            {
                Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
                movieAdvanceSlider.value = factor;
                if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
                if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
            }
            if (IS_IPHONE_5)
            {
                CGFloat StartY = 239.0f-2;
                CGFloat StartX = 568/2;  //width of back button + offet
                StartX = StartX - ((232+35)/2);
                goPlayButton.frame = CGRectMake(StartX, StartY, 35, 33);
                goPauseButton.frame = CGRectMake(StartX, StartY,35, 33);
                movieAdvanceSliderBackground.frame = CGRectMake(StartX+34, StartY, 232, 33);
                //ios 7 test
                //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                    movieAdvanceSlider.frame = CGRectMake(StartX+35+5, StartY+11, 218, 12);
                //else
                //    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY, 208, 10);
            }else
            {
                CGFloat StartY = 239.0f-2;
                CGFloat StartX = 480/2;  //width of back button + offet
                StartX = StartX - ((218+35)/2);
                StartX = StartX - 34;
                goPlayButton.frame = CGRectMake(StartX, StartY, 35, 33);
                goPauseButton.frame = CGRectMake(StartX, StartY,35, 33);
                movieAdvanceSliderBackground.frame = CGRectMake(StartX+34, StartY, 232, 33);
                //ios 7 test
                //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                movieAdvanceSlider.frame = CGRectMake(StartX+35+5, StartY+11, 218, 12);
                //else
                //    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY, 208, 10);
            }
            
            int numberofbuttons;
            int buttonwidth = 50;
            int buttonoffset = 8;
            float startx = 141; //185 for 568 screen
            float starty = 20; //
            //int buttonindex;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 3;
                //else
                //    numberofbuttons = 4;
                numberofbuttons = 4;
            }else
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 2;
                //else
                //numberofbuttons = 3;
                numberofbuttons = 3;
                numberofbuttons = 2; //bret**
            }
            
            if (IS_IPHONE_5)
                startx = (568 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            else
                startx = (480 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                goChangeButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                goShareButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 58, 58);
                    //activityIndicator.center = CGPointMake(startx+(58/2), starty+(58/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goFacebookButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                goYoutubeButton.frame = CGRectMake(startx, starty, 50, 50);
            }else
            {
                goChangeButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 58, 58);
                    //activityIndicator.center = CGPointMake(startx+(58/2), starty+(58/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goShareButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                //bret** goYoutubeButton.frame = CGRectMake(startx, starty, 50, 50);
            }
        }else
        {
            if (mThumbView.hidden == NO)
            {
            mOpaqueViewLandscape.hidden = YES;
            mOpaqueViewPortrait.hidden = NO;
            }
			if (IS_IPHONE_5)
            {
                mThumbView.frame = CGRectMake(0, 0, 320, 568);
                mOpaqueViewPortrait.frame = CGRectMake(timeElapsedPortrait, 0, 320, 568);
            }else
            {
                mThumbView.frame = CGRectMake(0, 0, 320, 480);
                mOpaqueViewPortrait.frame = CGRectMake(timeElapsedPortrait, 0, 320, 480);
            }
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            }

            //CGRect readyR = CGRectMake(20, 320, 125, 40);
            CGRect cancelR;
            if (IS_IPHONE_5)
                cancelR = CGRectMake(12, 568-44-44+((44-33)/2), 106, 33);
            else
                cancelR = CGRectMake(12, 480-44-44+((44-33)/2), 106, 33);
            //CGRect timeR = CGRectMake(20, 360, 160, 25);
            //readyButton.frame = readyR;
            cancelButton.frame = cancelR;
            //timeView.frame = timeR;
            int height = 480;
            if (IS_IPHONE_5)
                height = 568;
            CGRect message1Rect = CGRectMake((320-318)/2, 14, 318, 25);
            CGRect message2Rect = CGRectMake((320-288)/2, height/3, 288, 31);
            //CGRect message3Rect = CGRectMake((320-312)/2, 14, 315, 20);
            mMessage1.frame = message1Rect;
            mMessage2.frame = message2Rect;
            //mMessage3.frame = message3Rect;
            CGRect backR;
            if (IS_IPHONE_5)
            {
                backR = CGRectMake(320-106-4, 569-44-44+((44-33)/2), 106, 33);
                goBackButton.frame = backR;
                mPlaybackView.frame = CGRectMake(0, 0, 320, 568);
                //mPlayButton.frame = CGRectMake(160-30, (568/2)-30, 60, 60);
                mPlayButton.frame = CGRectMake(160-(116/2), (568/2)-(116/2), 116, 116);
            }else
            {
                backR = CGRectMake(320-106-4, 480-44-44+((44-33)/2), 106, 33);
                goBackButton.frame = backR;
                mPlaybackView.frame = CGRectMake(0, 0, 320, 480);
                //mPlayButton.frame = CGRectMake(160-30, (480/2)-30, 60, 60);
                mPlayButton.frame = CGRectMake(160-(116/2), (480/2)-(116/2), 116, 116);
            }
            [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_197x33"] forState:UIControlStateNormal];
            UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_iphone_189x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            UIImage *maxImage = [[UIImage imageNamed:@"slider_background_iphone_189x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];

            if ( movieAdvanceSlider.hidden != YES && mPlayerState == AVPlayerPaused)
            {
                Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
                movieAdvanceSlider.value = factor;
                if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
                if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
            }
            
            if (IS_IPHONE_5)
            {
                CGFloat StartY = 397.0f + 88.0;
                CGFloat StartX = (320 - (106 + 4)) /2;  //width of back button + offet
                StartX = StartX - ((158+32)/2);
                goPlayButton.frame = CGRectMake(StartX, StartY, 32, 33);
                goPauseButton.frame = CGRectMake(StartX, StartY,32, 33);
                movieAdvanceSliderBackground.frame = CGRectMake(StartX+32, StartY, 158, 33);
                //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY+12, 151, 10);
                //else
                //    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY, 151, 10);
                
            }else
            {
                CGFloat StartY = 397.0f;
                CGFloat StartX = (320 - (106 + 4)) /2;  //width of back button + offet
                StartX = StartX - ((158+32)/2);
                goPlayButton.frame = CGRectMake(StartX, StartY, 32, 33);
                goPauseButton.frame = CGRectMake(StartX, StartY,32, 33);
                movieAdvanceSliderBackground.frame = CGRectMake(StartX+32, StartY, 158, 33);
                //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY+12, 151, 10);
                //else
                //    movieAdvanceSlider.frame = CGRectMake(StartX+32+5, StartY, 151, 10);
            }
#if 0
            float startx = 61;
            float starty = 20; //46;
            //if (IS_IPHONE_5)
            //{
            //    startx = 185;
            //}
            goChangeButton.frame = CGRectMake(startx, starty, 58, 58);
            goFacebookButton.frame = CGRectMake(startx+58+8, starty, 58, 58);
            goYoutubeButton.frame = CGRectMake(startx+58+8+58+8, starty, 58, 58);
#endif
            int numberofbuttons;
            int buttonwidth = 50;
            int buttonoffset = 8;
            float startx = 141; //185 for 568 screen
            float starty = 20; //
            //int buttonindex;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 3;
                //else
                //    numberofbuttons = 4;
                numberofbuttons = 4;
            }else
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 2;
                //else
                //numberofbuttons = 3;
                //numberofbuttons = 3;
                numberofbuttons = 2; //bret**
            }
            
            if (IS_IPHONE_5)
                startx = (320 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            else
                startx = (320 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                goChangeButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                goShareButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 58, 58);
                    //activityIndicator.center = CGPointMake(startx+(58/2), starty+(58/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goFacebookButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                goYoutubeButton.frame = CGRectMake(startx, starty, 50, 50);
            }else
            {
                goChangeButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 58, 58);
                    //activityIndicator.center = CGPointMake(startx+(58/2), starty+(58/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goShareButton.frame = CGRectMake(startx, starty, 50, 50);
                startx = startx + buttonwidth+buttonoffset;
                //bret **goYoutubeButton.frame = CGRectMake(startx, starty, 50, 50);
            }
        }
	}else //ipad
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if (mThumbView.hidden == NO)
            {
            mOpaqueViewPortrait.hidden = YES;
            mOpaqueViewLandscape.hidden = NO;
            }
			mThumbView.frame = CGRectMake(0, 0, 1024, 768);
            mOpaqueViewLandscape.frame = CGRectMake(timeElapsedLandscape, 0, 1024, 768);
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            }

            //CGRect timeR = CGRectMake(207, 578, 284, 46);
            //CGRect readyR = CGRectMake(575, 578, 242, 68);
            CGRect cancelR = CGRectMake(12, 768-44-94+((94-71)/2), 227, 71);
            //readyButton.frame = readyR;
            cancelButton.frame = cancelR;
            //timeView.frame = timeR;
            CGRect message1Rect = CGRectMake((1024-740)/2, 14, 740, 59);
            CGRect message2Rect = CGRectMake((1024-669)/2, 768/3, 669, 72);
            //CGRect message3Rect = CGRectMake((1024-726)/2, 14, 726, 46);
            mMessage1.frame = message1Rect;
            mMessage2.frame = message2Rect;
            //mMessage3.frame = message3Rect;
            mPlaybackView.frame = CGRectMake(0, 0, 1024, 768);
            mPlayButton.frame = CGRectMake(512-60, 384-60, 120, 120);
        
            [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_ipad_463x71"] forState:UIControlStateNormal];
            UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            UIImage *maxImage = [[UIImage imageNamed:@"slider_background_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];

            if ( movieAdvanceSlider.hidden != YES && mPlayerState == AVPlayerPaused)
            {
                Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
                movieAdvanceSlider.value = factor;
                if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
                if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
            }
            
            //mPlayButton.frame = CGRectMake(512-60, 384-60, 120, 120);
            mPlayButton.frame = CGRectMake(512-(253/2), 384-(253/2), 253, 253);
            mPlaybackView.frame = CGRectMake(0, 0, 1024, 768);
            
            //nextButton.frame = CGRectMake(768-225-12, 1024-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);

            goPlayButton.frame = CGRectMake(245, 631+10, 69, 66);
            goPauseButton.frame = CGRectMake(245, 631+10, 69, 66);
            movieAdvanceSliderBackground.frame = CGRectMake(245+69, 631+10, 463, 66);
            movieAdvanceSlider.frame = CGRectMake(245+69+12, 631+26-1, 436, 23);
            CGRect backR = CGRectMake(1024-227-12, (768-44-94+((94-71)/2))-3, 227, 71);
            goBackButton.frame = backR;

#if 0
            float starty = 685+2;
            goBackButton.frame = CGRectMake(8, starty-50, 226, 71);
            goPlayButton.frame = CGRectMake(245, starty-50+2, 69, 66); //69x66
            goPauseButton.frame = CGRectMake(245, starty-50+2, 69, 66);//69x66
            movieAdvanceSliderBackground.frame = CGRectMake(245+69, starty-50+2, 463, 66); //463x66
            movieAdvanceSlider.frame = CGRectMake(245+69+12, starty-50+2+22-7, 436, 23); //436x23
            nextButton.frame = CGRectMake(788, starty-50, 228, 72);
#endif
            //
#if 0
            //float iconwidth = 58;
            //float iconoffset = 24;
            float startx = 300;
            float starty = 40 ;//120;
            goChangeButton.frame = CGRectMake(startx, starty, 99, 99);
            goFacebookButton.frame = CGRectMake(startx+99+16, starty, 99, 99);
            goYoutubeButton.frame = CGRectMake(startx+99+16+99+16, starty, 99, 99);
#endif
            int numberofbuttons;
            int buttonwidth = 99;
            int buttonoffset = 16;
            float startx;
            float starty = 40; //
            //int buttonindex;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 3;
                //else
                //    numberofbuttons = 4;
                numberofbuttons = 4;
            }else
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 2;
                //else
                //numberofbuttons = 3;
                //numberofbuttons = 3;
                numberofbuttons = 2; //bret**
            }
            startx = (1024 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                goChangeButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                goShareButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 127, 126);
                    //activityIndicator.center = CGPointMake(startx+(127/2), starty+(126/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goFacebookButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                goYoutubeButton.frame = CGRectMake(startx, starty, 99, 99);
            }else
            {
                goChangeButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 127, 126);
                    //activityIndicator.center = CGPointMake(startx+(127/2), starty+(126/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goShareButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                //goYoutubeButton.frame = CGRectMake(startx, starty, 99, 99); //bret**
            }
        }
        else
        {
            if (mThumbView.hidden == NO)
            {
            mOpaqueViewLandscape.hidden = YES;
            mOpaqueViewPortrait.hidden = NO;
            }
			mThumbView.frame = CGRectMake(0, 0, 768, 1024);
            mOpaqueViewPortrait.frame = CGRectMake(timeElapsedPortrait, 0, 768, 1024);
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            }
            
            //CGRect timeR = CGRectMake(79, 830, 284, 46);
            //CGRect readyR = CGRectMake(689-242, 830, 242, 68);
            CGRect cancelR = CGRectMake(12, 1024-44-94+((94-71)/2), 227, 71);
            //readyButton.frame = readyR;
            cancelButton.frame = cancelR;
            //timeView.frame = timeR;
            CGRect message1Rect = CGRectMake((768-740)/2, 14, 740, 59);
            CGRect message2Rect = CGRectMake((768-669)/2, 1024/3, 669, 72);
            //CGRect message3Rect = CGRectMake((768-726)/2, 14, 726, 46);
            mMessage1.frame = message1Rect;
            mMessage2.frame = message2Rect;
            //mMessage3.frame = message3Rect;
            mPlaybackView.frame = CGRectMake(0, 0, 768, 1024);
            mPlayButton.frame = CGRectMake(384-60, 512-60, 120, 120);
        
            [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_ipad_420x71"] forState:UIControlStateNormal];
            UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_ipad_403x21"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            UIImage *maxImage = [[UIImage imageNamed:@"slider_background_ipad_403x21"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];

            if ( movieAdvanceSlider.hidden != YES && mPlayerState == AVPlayerPaused)
            {
                Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
                movieAdvanceSlider.value = factor;
                if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
                if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
                    movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
            }
            
            //mPlayButton.frame = CGRectMake(384-60, 512-60, 120, 120);
            mPlayButton.frame = CGRectMake(384-(253/2), 512-(253/2), 253, 253);
            mPlaybackView.frame = CGRectMake(0, 0, 768, 1024);
            
            CGFloat StartY = 885.0f+11;
            goPlayButton.frame = CGRectMake(22, StartY, 69, 66);
            goPauseButton.frame = CGRectMake(22, StartY, 69, 66);
            movieAdvanceSliderBackground.frame = CGRectMake(22+69, StartY-2, 420, 71);
            movieAdvanceSlider.frame = CGRectMake(22+68+14, StartY+22-7+3-2, 394, 23);
            CGRect backR = CGRectMake(768-227-12, (1024-44-94+((94-71)/2))-3, 227, 71);
            goBackButton.frame = backR;
        
#if 0
            CGFloat StartY = 885.0f;
            goBackButton.frame = CGRectMake(6, StartY-2, 158, 71);
            goPlayButton.frame = CGRectMake(171, StartY, 69, 66);
            goPauseButton.frame = CGRectMake(171, StartY, 69, 66);
            movieAdvanceSliderBackground.frame = CGRectMake(171+69, StartY-2, 420, 71);
            movieAdvanceSlider.frame = CGRectMake(248+3, StartY+22-7+3-2, 394, 23);
            nextButton.frame = CGRectMake(663, StartY-2, 100, 72);
#endif

            int numberofbuttons;
            int buttonwidth = 99;
            int buttonoffset = 16;
            float startx;
            float starty = 40; //
            //int buttonindex;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 3;
                //else
                //    numberofbuttons = 4;
                numberofbuttons = 4;
            }else
            {
                //if (isVideoSavedorShared)
                //    numberofbuttons = 2;
                //else
                //numberofbuttons = 3;
                //numberofbuttons = 3;
                numberofbuttons = 2; //bret**
            }
            startx = (768 - (numberofbuttons*(buttonwidth+buttonoffset)))/2;
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                goChangeButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                goShareButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 127, 126);
                    //activityIndicator.center = CGPointMake(startx+(127/2), starty+(126/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goFacebookButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                goYoutubeButton.frame = CGRectMake(startx, starty, 99, 99);
            }else
            {
                goChangeButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                if (!isVideoSavedorShared)
                {
                    //goCameraRollButton.frame = CGRectMake(startx, starty, 127, 126);
                    //activityIndicator.center = CGPointMake(startx+(127/2), starty+(126/2));
                    //startx = startx + buttonwidth+buttonoffset;
                }
                goShareButton.frame = CGRectMake(startx, starty, 99, 99);
                startx = startx + buttonwidth+buttonoffset;
                //goYoutubeButton.frame = CGRectMake(startx, starty, 99, 99); //**bret
            }
        }
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//[self.navigationItem setHidesBackButton:YES animated:NO];
	
	UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = backButton;
    
    //storyboard self.title = NSLocalizedString(@"Developing Your Movie", nil);
	mAlertView = nil;
#if 0
    mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    mThumbImageView = [[UIImageView alloc] init];
    [mThumbView addSubview:mThumbImageView];
    mThumbView.backgroundColor = [UIColor blackColor];
    mThumbImageView.image = mThumbImage;
    [self.view addSubview:mThumbView];

	mOpaqueViewLandscape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
	mOpaqueViewPortrait = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    mOpaqueViewLandscape.backgroundColor = [UIColor blackColor];
    mOpaqueViewPortrait.backgroundColor = [UIColor blackColor];
    mOpaqueViewLandscape.alpha = 0.5f;
    mOpaqueViewPortrait.alpha = 0.5f;
    [self.view addSubview:mOpaqueViewLandscape];
    [self.view addSubview:mOpaqueViewPortrait];
    
    CGRect cancelR = CGRectMake(12, 320-44-44+((44-33)/2), 106, 33);
	//CGRect timeR = CGRectMake(80, 224, 160, 25);
	
	//NSString *ready_btn = @"bullet_ready_button.png";
	//NSString *ready_btn_sel = @"bullet_ready_button_h.png";
	NSString *cancel_btn = @"develop_cancel_button106x33_iphone.png";
	NSString *cancel_btn_sel = @"develop_cancel_button106x33_iphone.png";
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
		//timeR = CGRectMake(207, 578, 284, 46);
		//readyR = CGRectMake(575, 578, 242, 68);
		cancelR = CGRectMake(12, 768-44-94+((94-71)/2), 227, 71);
		
		//ready_btn = @"Processing02_view_movie_nol.png";
		//ready_btn_sel = @"Processing02_view_movie_pressl.png";
		cancel_btn = @"develop_cancel_button227x71.png";
		cancel_btn_sel = @"develop_cancel_button227x71.png";
	}
	
	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = cancelR;
	[cancelButton setImage:[UIImage imageNamed:cancel_btn] forState:UIControlStateNormal];
	[cancelButton setImage:[UIImage imageNamed:cancel_btn_sel] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
	
	NSString *message1 = @"develop_label1_318x25_iphone.png";
	NSString *message2 = @"develop_label2_288x31_iphone.png";
	NSString *message3 = @"develop_label3_312x20_iphone.png";
    CGRect message1Rect = CGRectMake((480-315)/2, 14, 315, 25);
    //CGRect message2Rect = CGRectMake((480-288)/2, 320/3, 288, 31);
    CGRect message2Rect = CGRectMake((480-320)/2, 320/3, 320, 42);
    //CGRect message3Rect = CGRectMake((480-312)/2, 14, 315, 20);

 	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        message1 = @"develop_label1_740x59.png";
        message2 = @"develop_label2_669x72.png";
        message3 = @"develop_label3_726x46.png";
        message1Rect = CGRectMake((1024-740)/2, 14, 740, 59);
        message2Rect = CGRectMake((1024-669)/2, 768/3, 669, 72);
        //message3Rect = CGRectMake((1024-726)/2, 14, 726, 46);
    }
    
    mMessage1 = [[UIImageView alloc] initWithFrame:message1Rect];
	mMessage1.image = [UIImage imageNamed:message1];
    [self.view addSubview:mMessage1];

    mMessage2 = [[UIImageView alloc] initWithFrame:message2Rect];
	mMessage2.image = [UIImage imageNamed:message2];
    [self.view addSubview:mMessage2];
    
//#if 0
//    mMessage3 = [[UIImageView alloc] initWithFrame:message3Rect];
//	mMessage3.image = [UIImage imageNamed:message3];
//    //[self.view addSubview:mMessage3];
//    mMessage3.hidden = YES;
//#endif
#endif
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
	}
	else
    {
        if (IS_IPHONE_5)
        {
            mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
		}else
        {
            mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
        }
	}
    [self.view addSubview:mPlaybackView];
    mPlaybackView.backgroundColor = [UIColor blackColor];
	mPlaybackView.hidden = YES;
    
    mPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//[mPlayButton setImage:[UIImage imageNamed:@"trimButtonPlay.png"] forState:UIControlStateNormal];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [mPlayButton setImage:[UIImage imageNamed:@"play_button253x253.png"] forState:UIControlStateNormal];
    else
        [mPlayButton setImage:[UIImage imageNamed:@"play_button116x116_iphone.png"] forState:UIControlStateNormal];
	[mPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    //mPlayButton.frame = CGRectMake(240-30, 160-30, 60, 60);
    mPlayButton.hidden = YES;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[mPlaybackView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
    [self.view addSubview:mPlayButton];
    //[self.view addSubview:mMessage3]; //comes after mPlaybackView in view

    UIImage *minImage;
    UIImage *maxImage;
    UIImage *thumbImage;
    if (IS_IPAD)
    {
        goBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goBackButton setImage:[UIImage imageNamed:@"develop_done_button227x71.png"] forState:UIControlStateNormal];
        [goBackButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
 
        goPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPlayButton setImage:[UIImage imageNamed:@"slider_play_ipad_68x71"] forState:UIControlStateNormal];
        [goPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
        goPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPauseButton setImage:[UIImage imageNamed:@"slider_pause_ipad_68x71"] forState:UIControlStateNormal];
        [goPauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        
        movieAdvanceSliderBackground = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_ipad_463x71"] forState:UIControlStateNormal];
        [movieAdvanceSliderBackground setEnabled:NO];
        
        minImage = [[UIImage imageNamed:@"slider_background_light_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        maxImage = [[UIImage imageNamed:@"slider_background_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        thumbImage = [UIImage imageNamed:@"slider_button_ipad_28x30"];

        goChangeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goChangeButton setImage:[UIImage imageNamed:@"develop_change_button127x126.png"] forState:UIControlStateNormal];
        [goChangeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];

        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        //{
            goFacebookButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goFacebookButton setImage:[UIImage imageNamed:@"develop_facebook_button127x126.png"] forState:UIControlStateNormal];
            [goFacebookButton addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
            
            goYoutubeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goYoutubeButton setImage:[UIImage imageNamed:@"develop_youtube_button127x126.png"] forState:UIControlStateNormal];
            [goYoutubeButton addTarget:self action:@selector(youtubeAction:) forControlEvents:UIControlEventTouchUpInside];
        //}else
        //{
            goShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goShareButton setImage:[UIImage imageNamed:@"develop_share_button127x126.png"] forState:UIControlStateNormal];
            [goShareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        //}
        
        goCameraRollButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goCameraRollButton setImage:[UIImage imageNamed:@"develop_cameraroll_button127x126.png"] forState:UIControlStateNormal];
        [goCameraRollButton addTarget:self action:@selector(cameraRollAction:) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        goBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goBackButton setImage:[UIImage imageNamed:@"develop_done_button105x33_iphone.png"] forState:UIControlStateNormal];
        [goBackButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];

        goPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPlayButton setImage:[UIImage imageNamed:@"slider_play_iphone_32x33"] forState:UIControlStateNormal];
        [goPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
        goPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPauseButton setImage:[UIImage imageNamed:@"slider_pause_iphone_32x33"] forState:UIControlStateNormal];
        [goPauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        
        movieAdvanceSliderBackground = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_218x33"] forState:UIControlStateNormal];
        [movieAdvanceSliderBackground setEnabled:NO];
        
        minImage = [[UIImage imageNamed:@"slider_background_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        maxImage = [[UIImage imageNamed:@"slider_background_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        thumbImage = [UIImage imageNamed:@"slider_button_iphone_13x14"];
        
        goChangeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goChangeButton setImage:[UIImage imageNamed:@"develop_change_button58x58_iphone.png"] forState:UIControlStateNormal];
        [goChangeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        //{
            goFacebookButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goFacebookButton setImage:[UIImage imageNamed:@"develop_facebook_button58x58_iphone.png"] forState:UIControlStateNormal];
            [goFacebookButton addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
            
            goYoutubeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goYoutubeButton setImage:[UIImage imageNamed:@"develop_youtube_button58x58_iphone.png"] forState:UIControlStateNormal];
            [goYoutubeButton addTarget:self action:@selector(youtubeAction:) forControlEvents:UIControlEventTouchUpInside];
        //}else
        //{
            goShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [goShareButton setImage:[UIImage imageNamed:@"develop_share_button58x58_iphone.png"] forState:UIControlStateNormal];
            [goShareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        //}
        goCameraRollButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goCameraRollButton setImage:[UIImage imageNamed:@"develop_cameraroll_button58x58_iphone.png"] forState:UIControlStateNormal];
        [goCameraRollButton addTarget:self action:@selector(cameraRollAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    movieAdvanceSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    movieAdvanceSlider.value = 0.0f;
    [movieAdvanceSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
    [movieAdvanceSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpOutside];
    [movieAdvanceSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [movieAdvanceSlider setThumbImage:thumbImage forState:UIControlStateSelected];
    [movieAdvanceSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //activityIndicator.center = CGPointMake(165, 90);
    activityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:goPlayButton];
    [self.view addSubview:goPauseButton];
    [self.view addSubview:goBackButton];
    [self.view addSubview:movieAdvanceSliderBackground];
    [self.view addSubview:movieAdvanceSlider];
    [self.view addSubview:goChangeButton];
    //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    //{
        [self.view addSubview:goFacebookButton];
        [self.view addSubview:goYoutubeButton];
    //}else
    //{
        [self.view addSubview:goShareButton];
    //}
    
    [self.view addSubview:goCameraRollButton];
    [self.view addSubview:activityIndicator];
    
    goPlayButton.hidden = YES;
    goPauseButton.hidden = YES;
    movieAdvanceSlider.hidden = YES;
    movieAdvanceSliderBackground.hidden = YES;
    goBackButton.hidden = YES;
    goChangeButton.hidden = YES;
    //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    //{
        goFacebookButton.hidden = YES;
        goYoutubeButton.hidden = YES;
    //}else
    //{
        goShareButton.hidden = YES;
        
    //}
    goCameraRollButton.hidden = YES;
    // NSLog(@"timeRemaining=%.2f", timeRemaining);

	if (IS_IPAD)
    {
        mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    }else
    {
        if (IS_IPHONE_5)
        {
            mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
        }else
        {
            mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
        }
    }
    mThumbImageView = [[UIImageView alloc] init];
    [mThumbView addSubview:mThumbImageView];
    mThumbView.backgroundColor = [UIColor blackColor];
    mThumbImageView.image = mThumbImage;
    [self.view addSubview:mThumbView];
    
	if (IS_IPAD)
    {
        mOpaqueViewLandscape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        //[[mOpaqueViewLandscape layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_1024x768.png"] CGImage]];
        mOpaqueViewPortrait = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
        //[[mOpaqueViewPortrait layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_768x1024.png"] CGImage]];
    }else
    {
        if (IS_IPHONE_5)
        {
            mOpaqueViewLandscape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
            //[[mOpaqueViewLandscape layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_568x320.png"] CGImage]];
            mOpaqueViewPortrait = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
            [[mOpaqueViewPortrait layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_320x568.png"] CGImage]];
        }else
        {
            mOpaqueViewLandscape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
            //[[mOpaqueViewLandscape layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_480x320.png"] CGImage]];
            mOpaqueViewPortrait = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            [[mOpaqueViewPortrait layer] setContents:(id)[[UIImage imageNamed:@"develop_grad_ipad_320x480.png"] CGImage]];
        }
    }
    mOpaqueViewLandscape.backgroundColor = [UIColor blackColor];
    mOpaqueViewPortrait.backgroundColor = [UIColor blackColor];
    mOpaqueViewLandscape.alpha = 0.5f;
    mOpaqueViewPortrait.alpha = 0.5f;
    [self.view addSubview:mOpaqueViewLandscape];
    [self.view addSubview:mOpaqueViewPortrait];
    
    CGRect cancelR = CGRectMake(12, 320-44-44+((44-33)/2), 106, 33);
	//CGRect timeR = CGRectMake(80, 224, 160, 25);
	
	//NSString *ready_btn = @"bullet_ready_button.png";
	//NSString *ready_btn_sel = @"bullet_ready_button_h.png";
	NSString *cancel_btn = @"develop_cancel_button106x33_iphone.png";
	NSString *cancel_btn_sel = @"develop_cancel_button106x33_iphone.png";
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
		//timeR = CGRectMake(207, 578, 284, 46);
		//readyR = CGRectMake(575, 578, 242, 68);
		cancelR = CGRectMake(12, 768-44-94+((94-71)/2), 227, 71);
		
		//ready_btn = @"Processing02_view_movie_nol.png";
		//ready_btn_sel = @"Processing02_view_movie_pressl.png";
		cancel_btn = @"develop_cancel_button227x71.png";
		cancel_btn_sel = @"develop_cancel_button227x71.png";
	}
	
	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = cancelR;
	[cancelButton setImage:[UIImage imageNamed:cancel_btn] forState:UIControlStateNormal];
	[cancelButton setImage:[UIImage imageNamed:cancel_btn_sel] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = YES;
    [self.view addSubview:cancelButton];
	
	NSString *message1 = @"develop_label1_318x25_iphone.png";
	NSString *message2 = @"develop_label2_288x31_iphone.png";
	NSString *message3 = @"develop_label3_312x20_iphone.png";
    CGRect message1Rect = CGRectMake((480-318)/2, 14, 318, 25);
    CGRect message2Rect = CGRectMake((480-288)/2, 320/3, 288, 31);
    //CGRect message3Rect = CGRectMake((480-312)/2, 14, 315, 20);
    
 	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        message1 = @"develop_label1_740x59.png";
        message2 = @"develop_label2_669x72.png";
        message3 = @"develop_label3_726x46.png";
        message1Rect = CGRectMake((1024-740)/2, 14, 740, 59);
        message2Rect = CGRectMake((1024-669)/2, 768/3, 669, 72);
        //message3Rect = CGRectMake((1024-726)/2, 14, 726, 46);
    }
    
    mMessage1 = [[UIImageView alloc] initWithFrame:message1Rect];
	mMessage1.image = [UIImage imageNamed:message1];
    [self.view addSubview:mMessage1];
    
    mMessage2 = [[UIImageView alloc] initWithFrame:message2Rect];
	mMessage2.image = [UIImage imageNamed:message2];
    [self.view addSubview:mMessage2];
    
    //#if 0
    //    mMessage3 = [[UIImageView alloc] initWithFrame:message3Rect];
    //	mMessage3.image = [UIImage imageNamed:message3];
    //    //[self.view addSubview:mMessage3];
    //    mMessage3.hidden = YES;
    //#endif


#if 0
	timeView = [[TimeView alloc] initWithFrame:timeR];
	[self.view addSubview:timeView];
	[timeView release];
	
	composeProgressView = [[ComposeProgressView alloc] initWithFrame:timeR];
	composeProgressView.hidden = YES;
	[self.view addSubview:composeProgressView];
	[composeProgressView release];
#endif
	[self layoutOrientation:self.interfaceOrientation];
	
	movieProcessor = [[MovieProcessor alloc] initWithReadURL:[Utilities selectedVideoPathWithURL:nil]];
	movieProcessor.delegate = self;
	
	// if we don't have a video title set, then use the look name
	NSString *existingTitle = [Utilities selectedVideoTitle:nil];
	if (!existingTitle) {
		existingTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kLookName];
		[Utilities selectedVideoTitle:existingTitle];
	}
	
//**	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeFromMultiTask) name:@"MultiTaskResume" object:nil];
//**	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToMultiTask) name:@"MultiTaskPause" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeToActive) name:@"BecomeActiveResume" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToDisactive) name:@"ResignActivePause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoWasShared) name:@"VideoWasShared" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorMusicPlayer:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:[MPMusicPlayerController iPodMusicPlayer]];
	[[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
    
    timeElapsedLandscape = 0.0f;
    timeElapsedPortrait = 0.0f;
    lastTimeRemaining = 0;
    isVideoSavedorShared = NO;
    blockCameraRollSave = NO;
    
}

// Override to allow orientations other than the default portrait orientation.
#if 0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return YES;
	}
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
#endif
- (BOOL)shouldAutorotate
{
	return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self layoutOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)cleanController
{
	if(timer)
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	if(mAlertView)
	{	
		[mAlertView release];
		mAlertView = nil;
	}
	if(movieProcessor)
	{
		[movieProcessor release];
		movieProcessor = nil;
	}
	self.renderer = nil;
}

- (void)dealloc
{
	[mThumbImage release];
    [mThumbImageView release];
	[mThumbView release];
	
    [self cleanController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	//**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskResume" object:nil];
	//**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskPause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BecomeActiveResume" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResignActivePause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoWasShared" object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:[MPMusicPlayerController iPodMusicPlayer]];
	[[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];	
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [super dealloc];
}

//movie playback handlers
-(void)resetPlayer
{
	CMTime leftTime = CMTimeMakeWithSeconds(0,600);
	[mPlayer seekToTime:leftTime];
	[mPlayer pause];
    movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
	//movieAdvanceSlider.minimumValue = lFactor;
	//movieAdvanceSlider.maximumValue = rFactor;
    
	mPlayerState = bAVPlayerReady;
    [self shareButtonsAnimateToShow];
}

-(void)pausePlayer
{
	if(mPlayerState == bAVPlayerPlaying) //bret **if(mPlayerState == AVPlayerPlaying)
	{
		[mPlayer pause];
		mPlayerState = bAVPlayerPaused;
        goPauseButton.hidden = YES;
        goPlayButton.hidden = NO;
        [self shareButtonsAnimateToShow];
    }
}

-(void)playPlayer
{
	[mPlayer play];
	mPlayerState = bAVPlayerPlaying;
    goPauseButton.hidden = NO;
    goPlayButton.hidden = YES;
    [self shareButtonsAnimateToHide];
	//NSLog(@"Player Time(%d,%d)",[mPlayer currentTime].value,[mPlayer currentTime].timescale);
}

#pragma mark - Player controll
- (void)displayPlayerButton
{
	if (mPlayButton.alpha<0.5)
    {
		[mPlayButton setAlpha:0.0];
		[UIView animateWithDuration:0.5 animations:^{
			[mPlayButton setAlpha:1.0];
		}];
	}
}

- (void)hiddenPlayerButton
{
	if (mPlayButton.alpha>0.5)
    {
		[mPlayButton setAlpha:1.0];
		[UIView animateWithDuration:0.5 animations:^{
			[mPlayButton setAlpha:0.0];
		}];
	}
}

-(void)clearPlayer
{
	if(mPlayerState==bAVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
        [self shareButtonsAnimateToShow];
	}
	if(mPlayer)
	{
		[mPlayer removeObserver:self forKeyPath:@"rate"];
		[mPlayer removeTimeObserver:mPlayTimeObserver];
		[mPlayer release];
		mPlayer = nil;
	}
    //	[mPlaybackView setPlayer:nil];
	[mPlayTimeObserver release];
}

- (void)playAction:(id)sender
{
	if(mPlayerState == bAVPlayerReady || mPlayerState == bAVPlayerPaused)
	{
		[self playPlayer];
		[self hiddenPlayerButton];
        [self shareButtonsAnimateToHide];
    }
}

- (void)sliderAction:(id)sender
{
	if(mPlayerState==bAVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
        [self shareButtonsAnimateToShow];
    }
    CGFloat factor = movieAdvanceSlider.value;
    CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
	[mPlayer seekToTime:videoPosTime];
}

- (void)pauseAction:(id)sender
{
	if(mPlayerState==bAVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
        [self shareButtonsAnimateToShow];
	}
}

-(void)handleTap:(UISwipeGestureRecognizer*)gestureRecognizer
{
	if(mPlayerState==bAVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
        [self shareButtonsAnimateToShow];
	}
}


#pragma mark -
#pragma mark MovieProcessorDelegate 
-(CVPixelBufferRef)processVideoFrame:(CMSampleBufferRef)sampleBuffer atTime:(CMTime)sampleTime
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; //bret
    CVPixelBufferRef pixelBuffer = NULL;
		
	// check if we are only rendering even frames.
	if (renderFullFramerate || (_curInputFrameIdx % 2) == 0) {
	
		CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		// CGSize bufferSize = CVImageBufferGetEncodedSize(imageBuffer);
		// NSLog(@"Buffer Size(%f,%f)",bufferSize.width,bufferSize.height);
	
		// Lock the base address of the pixel buffer
		CVPixelBufferLockBaseAddress(imageBuffer,0);
		void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
		// size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);

		[renderer frameProcessing:baseAddress toDest:baseAddress flipPixel:YES];
	
		CVPixelBufferCreateWithBytes(NULL,outputSize.width,outputSize.height,
								 kCVPixelFormatType_32BGRA,baseAddress,
								 outputSize.width*glPixelSize,
								 NULL,0,NULL,&pixelBuffer);
		CVPixelBufferUnlockBaseAddress(imageBuffer,0);
		_completedFrames++;
		framePastedFromPause++;
	
		// with higher resolution, we want to hold fewer frames in the checkpoint buffer.
		NSInteger CheckPointFrameCount = (renderType==RendererTypeFull)?30:60;
		if(framePastedFromPause>CheckPointFrameCount && (sampleTime.value%300<20) && needCheckPoint)
		{
			framePastedFromPause = 0;
			[movieProcessor checkPointRenderMovie];
		}
	}
	
	_curInputFrameIdx++;
    
	dispatch_async(dispatch_get_main_queue(),
    ^{
        if ( _completedFrames != lastTimeRemaining)
        {
            lastTimeRemaining = _completedFrames;
            int screenwidthl, screenwidthp;
            if (IS_IPAD)
            {
                screenwidthl = 1024;
                screenwidthp = 768;
            }else
            {
                if (IS_IPHONE_5)
                {
                    screenwidthl = 568;
                    screenwidthp = 320;
                }else
                {
                    screenwidthl = 480;
                    screenwidthp = 320;
                }
            }
            
            //timeScale is totalframes
            //_completedFrames is the current frame index
#if 0
            //curve method 1
            float timeoffsetcos = cos(_completedFrames/(timeScale/2));
            timeoffsetcos = fabs(timeoffsetcos);
            
            float timeoffsetl = screenwidthl * (_completedFrames/timeScale);
            float timeoffsetp = screenwidthp * (_completedFrames/timeScale);
            
            float timestepl = (screenwidthl/timeScale)*timeoffsetcos;
            float timestepp = (screenwidthp/timeScale)*timeoffsetcos;

            timeoffsetl = timeoffsetl+timestepl; //comment out for linear
            timeoffsetp = timeoffsetp+timestepp; //comment out for linear
            
            NSLog(@"bret timestepl == %f",timestepl);
            
            timeElapsedLandscape = timeoffsetl; //these are for rotation during render
            timeElapsedPortrait = timeoffsetp;

            CGRect frame;
            frame = mOpaqueViewLandscape.frame;
            frame.origin.x = timeoffsetl;
            mOpaqueViewLandscape.frame = frame;
            frame = mOpaqueViewPortrait.frame;
            frame.origin.x = timeoffsetp;
            mOpaqueViewPortrait.frame = frame;
            //end curve method 1
#endif
            //curve method 2
            float timeoffsetl = screenwidthl/timeScale;
            float timeoffsetp = screenwidthp/timeScale;
            float timezone = timeScale/8;
            if (_completedFrames < (timezone*1) )
            {
                timeoffsetl = timeoffsetl * 1.50;
                timeoffsetp = timeoffsetp * 1.50;
            }else if ( _completedFrames < (timezone*2) )
            {
                timeoffsetl = timeoffsetl * 1.25;
                timeoffsetp = timeoffsetp * 1.25;
            }else if ( _completedFrames < (timezone*3) )
            {
                timeoffsetl = timeoffsetl * 0.75;
                timeoffsetp = timeoffsetp * 0.75;
            }else if ( _completedFrames < (timezone*4) )
            {
                timeoffsetl = timeoffsetl * 0.50;
                timeoffsetp = timeoffsetp * 0.50;
            }else if ( _completedFrames < (timezone*5) )
            {
                timeoffsetl = timeoffsetl * 0.50;
                timeoffsetp = timeoffsetp * 0.50;
            }else if ( _completedFrames < (timezone*6) )
            {
                timeoffsetl = timeoffsetl * 0.75;
                timeoffsetp = timeoffsetp * 0.75;
            }else if ( _completedFrames < (timezone*7) )
            {
                timeoffsetl = timeoffsetl * 1.25;
                timeoffsetp = timeoffsetp * 1.25;
            }else
            {
                timeoffsetl = timeoffsetl * 1.50;
                timeoffsetp = timeoffsetp * 1.50;
            }
            
            timeElapsedLandscape = timeElapsedLandscape + timeoffsetl; //these are for rotation during render
            timeElapsedPortrait = timeElapsedLandscape + timeoffsetp;
            
            CGRect frame;
            frame = mOpaqueViewLandscape.frame;
            frame.origin.x = frame.origin.x + timeoffsetl;
            mOpaqueViewLandscape.frame = frame;
            frame = mOpaqueViewPortrait.frame;
            frame.origin.x = frame.origin.x + timeoffsetp;
            mOpaqueViewPortrait.frame = frame;
            //end curve method 2
        }
    });
    [pool release];
	return pixelBuffer;
}

-(CGSize)knownVideoInfoEvent:(CGSize)videoSize withDuration:(CMTime)duration;
{
	float fps = 30;
	videoSize_ = videoSize;
	outputSize = videoSize_;
    bool sizecorrected = NO;
    
	Float64 seconds =  CMTimeGetSeconds(duration);
	needCheckPoint = (seconds>2.0);
	
    
	//prevent reproccessing reduced sizes beyond certain sizes
    if (IS_IPHONE)
    {
        if (!IS_RETINA)
        {
            //3gs
            CGFloat smallestSupportHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?120:100;
            if (renderType == RendererTypeHalf && videoSize_.height>smallestSupportHeight)
                outputSize = CGSizeMake(videoSize_.width/2.0, videoSize_.height/2.0);
            sizecorrected = YES;
        }
            
    }
    if (!sizecorrected)
    {
        if (videoSize_.width == 480 || videoSize_.height == 480)
        {
            //1920>>960>>480
            if (renderType == RendererTypeHalf )
            {
                renderType = RendererTypeFull;
                sizecorrected = YES;
            }
        }else if (videoSize_.width == 640 || videoSize_.height == 640)
        {
            //1280>>640
            if (renderType == RendererTypeHalf )
            {
                renderType = RendererTypeFull;
                sizecorrected = YES;
            }
        }
    }
    
    if (!sizecorrected)
    {
        if (renderType == RendererTypeHalf)
            outputSize = CGSizeMake(videoSize_.width/2.0, videoSize_.height/2.0);
    }else
    {
        outputSize = CGSizeMake(videoSize_.width, videoSize_.height);
    }
    
    //final kludge: if 960 video and full is selected force it to half
    if (videoSize_.width == 960 || videoSize_.height == 960)
    {
        renderType = RendererTypeHalf;
    }
    
#if 0
    //fix for small video just like 160*90, because 80*45 can not be processed
	CGFloat smallestSupportHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?120:100;
	if (renderType == RendererTypeHalf && videoSize_.height>smallestSupportHeight)
		outputSize = CGSizeMake(videoSize_.width/2.0, videoSize_.height/2.0);
    
    
    // check for video sizes that exceed max supported resolutions and reduce as needed
	if (IS_IPAD && IS_RETINA)
	{
		if (videoSize_.width > 1920.0 || videoSize_.height > 1920.0)
		{
			if (videoSize_.width > 1920.0)
			{
				outputSize = CGSizeMake(1920.0, 1080.0);
			}
			if (videoSize_.height > 1920.0)
			{
				outputSize = CGSizeMake(1080.0, 1920.0);
			}
		}
	}
	else if (IS_RETINA)
	{
		if (videoSize_.width > 1280.0 || videoSize_.height > 1280.0)
		{
			if (videoSize_.width > 1280.0)
			{
				outputSize = CGSizeMake(1280.0, 720.0);
			}
			if (videoSize_.height > 1280.0)
			{
				outputSize = CGSizeMake(720.0, 1280.0);
			}
		}
    }
	else
	{
		if (videoSize_.width > 560.0 || videoSize_.height > 560.0)
		{
			if (videoSize_.width > 560.0)
			{
				outputSize = CGSizeMake(560.0, 360.0);
			}
			if (videoSize_.height > 560.0)
			{
				outputSize = CGSizeMake(560.0, 360.0);
			}
		}
	}
#endif
    //
    [renderer resetFrameSize:videoSize_ outputFrameSize:outputSize];
	
	_totalFrames = seconds*fps;
	
	if (!renderFullFramerate) {
		// if we are only rendering half of the frames, then adjust the total
		_totalFrames = ceil(_totalFrames/2.0);
	}
	
	return outputSize;
}

-(void)finishRenderMovieEvent
{
	timeRemaining = 0;
	if(timer)
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	/*
	 timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCompose:) userInfo:nil repeats:YES] retain];
	 
	 timeView.hidden = YES;
	 composeProgressView.hidden = NO;
	 [composeProgressView setTitleText:@"Composing%.2f%%" withProgress:0.0];
	 */
	//[timeView setTimeSaving];
	[movieProcessor startComposeMovie];
}

-(void)finishProcessMovieEvent:(NSString*)processFilePath
{
	
	if(timer)
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	if(isAlertViewShown)
	{
		[mAlertView dismissWithClickedButtonIndex:0 animated:NO];
		isAlertViewShown = NO;
	}
	
	NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
	measuredTotalRenderTime = curTime - renderStartTime;
	
	processedMoviePath = [[NSString alloc] initWithString:processFilePath];
	//[movieProcessor writeMovieToAlbum:processedMoviePath];
	//readyButton.hidden = NO;
    CGFloat dur = 1.0;
    [UIView transitionWithView:cancelButton
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:mMessage1
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:mMessage2
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:mThumbView
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:mThumbImageView
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];

	cancelButton.hidden = YES;
    mMessage1.hidden = YES;
    mMessage2.hidden = YES;
    mOpaqueViewPortrait.hidden = YES;
    mOpaqueViewLandscape.hidden = YES;
    mThumbView.hidden = YES;
    mThumbImageView.hidden = YES;
    
    //mMessage3.hidden = NO;
    mPlaybackView.hidden = NO;
    mPlayButton.hidden = NO;

    goPlayButton.hidden = NO;
    goPauseButton.hidden = YES;
    movieAdvanceSliderBackground.hidden = NO;
    movieAdvanceSlider.hidden = NO;
    goBackButton.hidden = NO;
    
    //[self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]]];
    //goChangeButton.hidden = NO;
    //goFacebookButton.hidden = NO;
    //goYoutubeButton.hidden = NO;
    [self shareButtonsAnimateToShow];
    self.title = NSLocalizedString(@"Share this movie with your friends", nil);
    //#if 0
    AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:processedMoviePath] options:nil];
    mVideoDuration = avAsset.duration;
    [avAsset release];
    
    //	[composeProgressView setTitleText:@"Done" withProgress:1.0];
	//[timeView setTimeDone];
	mPlayer = [[AVPlayer allocWithZone:[self zone]] initWithURL:[NSURL fileURLWithPath:processedMoviePath]];
	//mPlayer = [[AVPlayer allocWithZone:[self zone]] initWithURL:processedMoviePath];
	[mPlayer addObserver:self forKeyPath:@"rate" options:0 context:AVPlayerRateObservationContextBullet];
	[mPlaybackView setPlayer:mPlayer];
    
	mPlayTimeObserver = [[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, 600) queue:dispatch_get_main_queue() usingBlock:
						  ^(CMTime time) {
							  if (mPlayer.rate==0.0) return;
							  
							  Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
							  //NSLog(@"Player factor:%f, Time(%d,%d)",factor,[mPlayer currentTime].value,[mPlayer currentTime].timescale);
                              movieAdvanceSlider.value = factor;
						  }] retain];
	mPlayerState = bAVPlayerReady;
	[self displayPlayerButton];
	//**[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToMultiTask) name:@"MultiTaskPause" object:nil];
	//**[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeFromMultiTask) name:@"MultiTaskResume" object:nil];
//#endif
#if 0
	@try{
		MPMoviePlayerViewController *mpViewCtrlor = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:processedMoviePath]];
		mpViewCtrlor.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
		mpViewCtrlor.moviePlayer.repeatMode = MPMovieRepeatModeOne;
		mpViewCtrlor.moviePlayer.useApplicationAudioSession = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector: @selector(playbackDidFinish:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		
		[self presentMoviePlayerViewControllerAnimated:mpViewCtrlor];
		[mpViewCtrlor.moviePlayer play];
		[mpViewCtrlor release];
	}
	@catch (NSException* exc) {
		NSLog(@"%@",[exc reason]);
	}
#endif
    BOOL printReport = YES;
	if (printReport) {
		NSLog(@"Render Completed");
		NSLog(@"Render Type: %@ Resolution", (renderType == RendererTypeFull)? @"Full": @"Half");
		NSLog(@"Render Framerate: %@", (renderFullFramerate)? @"Full": @"Half");
		NSLog(@"Frames Read: %d", _curInputFrameIdx);
		NSLog(@"Frames Rendered: %d / %d", _completedFrames, (int)_totalFrames);
		NSLog(@"Org Estimate: %f", estimateTotalRenderTime);
		NSLog(@"Tot Duration: %f", measuredTotalRenderTime);
	}
}

-(void)finishSaveToCameraRollEventAfterDelay:(id)sender
{
    [self layoutOrientation:self.interfaceOrientation];
}

//bret
-(void)finishSaveToCameraRollEvent
{
    isVideoSavedorShared = YES;
    [activityIndicator stopAnimating];
    [UIView transitionWithView:goCameraRollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    goCameraRollButton.hidden = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finishSaveToCameraRollEventAfterDelay:) userInfo:nil repeats:NO];
    //[self layoutOrientation:self.interfaceOrientation];
}

-(void)checkPointRenderMovieEvent
{
	NSLog(@"Video Clip Check Point!");
	CMTimeRange processRange = [movieProcessor getProcessRange];
	_completedFrames = (NSUInteger)(processRange.start.value/20);	
}

-(void)cancelRenderMovieEvent
{
	NSLog(@"Video Stop!");
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark MultiTaskHandle 
-(void)pauseToMultiTask
{
	//if(!isAppActive) return;
	
	if(isAlertViewShown)
	{	
		[mAlertView dismissWithClickedButtonIndex:0 animated:NO];
		isAlertViewShown = NO;
	}
	
	if([movieProcessor getProcessState]==MovieStateRendering || [movieProcessor getProcessState]==MovieStateResume)
	{	
		framePastedFromPause = 0;
		[movieProcessor pauseRenderMovie];
	}
	else if([movieProcessor getProcessState]==MovieStateCompose)
		[movieProcessor pauseComposeMovie];
}

-(void)resumeFromMultiTask
{
#if 0
	if(!isAppActive)
    {
        NSLog(@"bret resumeFromMultiTask not active app");
        return;
    }else
        NSLog(@"bret is resumeFromMultiTask active app");
#endif
	NSLog(@"bret in resumeFromMultiTask");
    if([movieProcessor getProcessState]==MovieStatePause || [movieProcessor getProcessState]==MovieStateRenderEnd)
	{
		 NSLog(@"bret in alert");
        framePastedFromPause = 0;
		
		
		isAlertViewShown = YES;
		if(mAlertView)
		{
			[mAlertView release];
			mAlertView = nil;
		}
		mAlertView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Resume Process!",nil)
															 message:NSLocalizedString(@"Welcome Back! Movie Looks will resume rendering where it left off when you last quit the app.",nil)
															delegate:self
												   cancelButtonTitle:NSLocalizedString(@"OK",nil)
												   otherButtonTitles:nil];
		mAlertView.tag = 100;
		[mAlertView show];
	}
	//	else if([movieProcessor getProcessState]==MovieStateRenderEnd)
	//		[self finishRenderMovieEvent];
}

-(void)pauseToDisactive
{	
	[self pauseToMultiTask];
	isAppActive = NO;
    NSLog(@"bret isAppActive = NO");
}

-(void)resumeToActive
{
	isAppActive = YES;
    NSLog(@"bret isAppActive = YES");
	[self resumeFromMultiTask];
}

-(void)pauseToMusicPlayer
{
	if([movieProcessor getProcessState]==MovieStateRendering || [movieProcessor getProcessState]==MovieStateResume)
	{	
		framePastedFromPause = 0;
		[movieProcessor pauseRenderMovie];
	}
	else if([movieProcessor getProcessState]==MovieStateCompose)
		[movieProcessor pauseComposeMovie];
	
	isAlertViewShown = YES;
	if(mAlertView)
	{
		[mAlertView release];
		mAlertView = nil;
	}
	mAlertView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Resume Process!",nil)
														   message:NSLocalizedString(@"The render process is interrupted by your iPod player. Do you want to resume rendering and stop the media playing?",nil)
														  delegate:self
												 cancelButtonTitle:NSLocalizedString(@"YES",nil)
												 otherButtonTitles:nil];
	mAlertView.tag = 50;
	[mAlertView show];
}

-(void)monitorMusicPlayer:(id)sender
{
	// NSLog(@"ddddd");
	MPMusicPlayerController* iPodPlayer =[MPMusicPlayerController iPodMusicPlayer];
	switch(iPodPlayer.playbackState)
	{
		case MPMoviePlaybackStatePlaying:
			// NSLog(@"%d",iPodPlayer.playbackState);
			[self pauseToMusicPlayer];
			break;
			/*			
			 case MPMoviePlaybackStatePaused:
			 NSLog(@"%d",iPodPlayer.playbackState);
			 
			 [self resumeFromMultiTask];
			 break;
			 */
		default:
			// NSLog(@"%d",iPodPlayer.playbackState);
			break;	
	}
}

#pragma mark -
#pragma mark ActionHandle 
- (void) cancelAction:(id)sender
{
	isAlertViewShown = YES;
	if(mAlertView)
	{
		[mAlertView release];
		mAlertView = nil;
	}
	mAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Terminate the Develop",nil)
														message:NSLocalizedString(@"Are you sure you want to terminate the processing? You can't undo this action.",nil) 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"NO",nil) 
											  otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
	mAlertView.tag = 300;
	[mAlertView show];
}

- (void) homeAction:(id)sender
{
    if (isVideoSavedorShared)
    {
        if (mPlayer != Nil)
        {
            [self clearPlayer];
            //	NSLog(@"%d",[mPlayer count]);
            //**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskPause" object:nil];
            //**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskResume" object:nil];
        }
        //code is duplicated in alert handler
        [self cleanController];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToVideo" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil];
    }else
    {
        isAlertViewShown = YES;
        if(mAlertView)
        {
            [mAlertView release];
            mAlertView = nil;
        }
        mAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera Roll",nil)
                                                message:NSLocalizedString(@"Your movie isn't saved to the camera roll. Are you sure you want to exit?",nil)
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"NO",nil)
                                      otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
        mAlertView.tag = 500;
        [mAlertView show];
        
    }
    
}

- (void) changeAction:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    NSInteger noOfViewControllers = [self.navigationController.viewControllers count];
    [self.navigationController
     popToViewController:[self.navigationController.viewControllers
                          objectAtIndex:(noOfViewControllers-3)] animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"seque id == %@",segue.identifier);
    if ([[segue identifier] isEqualToString:@"ShareViewController"])
    {
        ShareViewController *shareViewController = (ShareViewController *)segue.destinationViewController;
		shareViewController.useYouTube = useYouTube;
        shareViewController.mThumbImage = mThumbImageView.image;
        shareViewController.processedMoviePath = processedMoviePath;
    }
    
}

- (void) videoWasShared
{
    isVideoSavedorShared = YES;
}

- (void) facebookAction:(id)sender
{
    useYouTube = NO;
    [self performSegueWithIdentifier:@"ShareViewController" sender:self];
}

- (void) youtubeAction:(id)sender
{
    useYouTube = YES;
    [self performSegueWithIdentifier:@"ShareViewController" sender:self];
	//ShareViewController *shareViewController = [[ShareViewController alloc] init];
    //shareViewController.useYouTube = useYouTube;
    //shareViewController.mThumbImage = mThumbImageView.image;
	//[self.navigationController pushViewController:shareViewController animated:YES];

}

- (void) cameraRollAction:(id)sender
{
    if (!blockCameraRollSave)
    {
        blockCameraRollSave = YES;
        [activityIndicator startAnimating];
        [movieProcessor writeMovieToAlbum:processedMoviePath];
        //[activityIndicator stopAnimating];
    }
}

- (void) shareAction:(id)sender
{
    //NSString *videoToShare = @"myFirsScribble.mov";
    //NSURL *videoPath = [NSURL fileURLWithPath:videoToShare];
    //NSArray *objectsToShare = [NSArray arrayWithObjects:message, videoPath, nil];
    NSURL *url = [NSURL fileURLWithPath:processedMoviePath];
    NSArray* dataToShare = [NSArray arrayWithObjects:url,nil];
    
    YoutubeActivity *youtubeactivity = [[YoutubeActivity alloc]init];
    youtubeactivity.mThumbImage = mThumbImageView.image;
    youtubeactivity.processedMoviePath = processedMoviePath;
    
    NSArray* customactivities = [NSArray arrayWithObjects:youtubeactivity,nil];

    //UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
    //                                                                                     applicationActivities:nil];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                                         applicationActivities:customactivities];

    //activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    //activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact];
    //UILocalNotification
#if 0
    UIKIT_EXTERN NSString *const UIActivityTypePostToFacebook     NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypePostToTwitter      NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypePostToWeibo        NS_AVAILABLE_IOS(6_0);    // SinaWeibo
    UIKIT_EXTERN NSString *const UIActivityTypeMessage            NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypeMail               NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypePrint              NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypeCopyToPasteboard   NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypeAssignToContact    NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypeSaveToCameraRoll   NS_AVAILABLE_IOS(6_0);
    UIKIT_EXTERN NSString *const UIActivityTypeAddToReadingList   NS_AVAILABLE_IOS(7_0);
    UIKIT_EXTERN NSString *const UIActivityTypePostToFlickr       NS_AVAILABLE_IOS(7_0);
    UIKIT_EXTERN NSString *const UIActivityTypePostToVimeo        NS_AVAILABLE_IOS(7_0);
    UIKIT_EXTERN NSString *const UIActivityTypePostToTencentWeibo NS_AVAILABLE_IOS(7_0);
    UIKIT_EXTERN NSString *const UIActivityTypeAirDrop            NS_AVAILABLE_IOS(7_0);
#endif
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed)
    {
        bool activityTypeFound = false;
        NSString *notificationString;
        if (completed)
        {
            isVideoSavedorShared  = YES;
            
            if ([activityType rangeOfString:@"cameraroll" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                activityTypeFound = true;
                notificationString = @"Your movie was saved to the Camera Roll.";
                //if (!isVideoSavedorShared)
                //    [self finishSaveToCameraRollEvent];
                NSLog(@"bret Camera Roll");
            }
            if ([activityType rangeOfString:@"facebook" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                notificationString = @"Your movie was uploaded to Facebook.";
                activityTypeFound = true;
                NSLog(@"bret Camera Roll");
            }
            if ([activityType rangeOfString:@"youtube" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                notificationString = @"Your movie was uploaded to Youtube.";
                activityTypeFound = true;
                NSLog(@"bret Camera Roll");
            }
            if ([activityType rangeOfString:@"vimeo" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                notificationString = @"Your movie was uploaded to Vimeo.";
                activityTypeFound = true;
                NSLog(@"bret Camera Roll");
            }
            if ([activityType rangeOfString:@"flickr" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                notificationString = @"Your movie was uploaded to Flickr.";
                activityTypeFound = true;
                NSLog(@"bret Camera Roll");
            }
            if ([activityType rangeOfString:@"weibo" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                notificationString = @"Your movie was uploaded to Weibo.";
                activityTypeFound = true;
                NSLog(@"bret Camera Roll");
            }
            if (!activityTypeFound)
            {
                notificationString = @"Your movie was sucessfully uploaded.";
            }
        }
    }];
    
    [self presentViewController:activityViewController animated:TRUE completion:nil];
}

- (void)shareButtonsAnimateToShow
{
    if (goChangeButton.hidden == YES)
    {
        [UIView transitionWithView:goChangeButton
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    goChangeButton.hidden = NO;
    
    if ( !isVideoSavedorShared )
    {
        //if (goCameraRollButton.hidden == YES)
        //{
        //    [UIView transitionWithView:goCameraRollButton
        //                      duration:0.5
        //                       options:UIViewAnimationOptionTransitionCrossDissolve
        //                    animations:NULL
        //                    completion:NULL];
        //}
        //goCameraRollButton.hidden = NO;
    }

    if (goShareButton.hidden == YES)
    {
        [UIView transitionWithView:goShareButton
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    goShareButton.hidden = NO;

    //ios 7 test
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {

        if (goFacebookButton.hidden == YES)
        {
            [UIView transitionWithView:goFacebookButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goFacebookButton.hidden = NO;
        
        if (goYoutubeButton.hidden == YES)
        {
            [UIView transitionWithView:goYoutubeButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goYoutubeButton.hidden = NO;
    }
    else
    {
//bret**
#if 0
        if (goYoutubeButton.hidden == YES)
        {
            [UIView transitionWithView:goYoutubeButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goYoutubeButton.hidden = NO;
#endif
    }
}

- (void)shareButtonsAnimateToHide
{
    if (goChangeButton.hidden == NO)
    {
        [UIView transitionWithView:goChangeButton
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    goChangeButton.hidden = YES;
    
    if ( !isVideoSavedorShared )
    {
        //if (goCameraRollButton.hidden == NO)
        //{
        //    [UIView transitionWithView:goCameraRollButton
        //                      duration:0.5
        //                       options:UIViewAnimationOptionTransitionCrossDissolve
        //                    animations:NULL
        //                    completion:NULL];
        //}
        //goCameraRollButton.hidden = YES;
    }
    
    if (goShareButton.hidden == NO)
    {
        [UIView transitionWithView:goShareButton
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    goShareButton.hidden = YES;
    
    //ios 7 test
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        if (goFacebookButton.hidden == NO)
        {
            [UIView transitionWithView:goFacebookButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goFacebookButton.hidden = YES;
        
        if (goYoutubeButton.hidden == NO)
        {
            [UIView transitionWithView:goYoutubeButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goYoutubeButton.hidden = YES;
    }
    else
    {
//bret**
#if 0
        if (goYoutubeButton.hidden == NO)
        {
            [UIView transitionWithView:goYoutubeButton
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        goYoutubeButton.hidden = YES;
#endif
    }
}

- (void)playbackDidFinish:(NSNotification*)notification
{
	// NSLog(@"playbackDidFinish:");
	[self dismissMoviePlayerViewControllerAnimated];

	CGRect frameSize;
    if (IS_IPHONE_5)
        frameSize = CGRectMake(0, 0, 320, 568);
    else
        frameSize = CGRectMake(0, 0, 320, 480);
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		frameSize = CGRectMake(0, 0, 768, 1024);
	}

//#if 0
    UIView *v = [self.view viewWithTag:400];
	if(v && [v superview]){
		[v removeFromSuperview];
	}
//#endif
	CustomPopView *custom = [[CustomPopView alloc] initWithButtons:[NSArray arrayWithObjects:
		NSLocalizedString(@"Select another look",nil),
		NSLocalizedString(@"Select another video",nil),
		NSLocalizedString(@"Share Online",nil),nil]
		frame:frameSize];
		
	custom.tag  = 400;
	custom.delegate_ = self;
	[self.view addSubview:custom];
	[custom release];
}


#pragma mark -
#pragma mark AlertViewHandle 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 50)
	{
		isAlertViewShown = NO;
		if (buttonIndex == 0)
		{
			//pause the ipod
			NSLog(@"Pause Music");
			MPMusicPlayerController* iPodPlayer =[MPMusicPlayerController iPodMusicPlayer];
			if(iPodPlayer.playbackState == MPMoviePlaybackStatePlaying)
				[iPodPlayer pause];
			
			if([movieProcessor getProcessState]==MovieStatePause)
			{	
				[movieProcessor resumeRenderMovie];
				CMTimeRange processRange = [movieProcessor getProcessRange];
				_completedFrames = (NSUInteger)(processRange.start.value/20);
			}
			else if([movieProcessor getProcessState]==MovieStateRenderEnd)
				[self finishRenderMovieEvent];
		}
	}
	else if(alertView.tag == 100)
	{
		isAlertViewShown = NO;
		if (buttonIndex == 0)
		{
			isAlertViewShown = NO;
			if([movieProcessor getProcessState]==MovieStatePause)
			{	
				[movieProcessor resumeRenderMovie];
				CMTimeRange processRange = [movieProcessor getProcessRange];
				_completedFrames = (NSUInteger)(processRange.start.value/20);
			}
			else if([movieProcessor getProcessState]==MovieStateRenderEnd)
				[self finishRenderMovieEvent];
		}
	}	
	else if(alertView.tag == 300)
	{
		isAlertViewShown = NO;
		if (buttonIndex == 1)
		{
			//stop the timer
			if(timer)
			{
				[timer invalidate];
				[timer release];
				timer = nil;
			}
			if ([movieProcessor getProcessState]==MovieStateRendering  || [movieProcessor getProcessState]==MovieStateResume)
				[movieProcessor stopRenderMovie];
			else if([movieProcessor getProcessState]==MovieStateCompose)
				[movieProcessor stopComposeMovie];
		}
	}
	else if(alertView.tag == 1000)
    {
		isAlertViewShown = NO;
		if(buttonIndex == 1)
        {
		}
	}
    //bret safe tags start at 500
    else if (alertView.tag == 500)
    {
		isAlertViewShown = NO;
		if(buttonIndex == 1)
        {
            if (mPlayer != Nil)
            {
                [self clearPlayer];
            }
            [self cleanController];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToVideo" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil];
        }
    }
}

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if(actionSheet.tag == 400)
	{
		if (buttonIndex == 0) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		} else if(buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil]; 
		} else if(buttonIndex == 2) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHomeAndShare" object:nil];
		}
	}
}
*/


- (void) popView:(UIView*)sender clickedButtonAtIndex:(NSInteger)index{
	if(sender.tag == 400)
	{
		if (index == 0) {
			// select another look
			[self.navigationController popToRootViewControllerAnimated:YES];
		} else if(index == 1) {
			// select another movie
			[self cleanController];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil]; 
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToVideo" object:nil]; 
		} else if(index == 2) {
			// share
			[self cleanController];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHomeAndShare" object:nil];
		}
	}
}

- (void) didButtonClickedIndex:(int)index{
	
	mAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancel Upload",nil)
							   message:NSLocalizedString(@"Are you sure you want to cancel this upload?",nil)
							  delegate:self 
					 cancelButtonTitle:NSLocalizedString(@"NO",nil)
					 otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
	mAlertView.tag = 1000;
	[mAlertView show];
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if (context == AVPlayerRateObservationContextBullet)
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   if([mPlayer rate]==0.0 && mPlayerState==AVPlayerPlaying)
						   {
							   [self resetPlayer];
							   [self displayPlayerButton];
                               [self shareButtonsAnimateToShow];
                               goPauseButton.hidden = YES;
                               goPlayButton.hidden = NO;
						   }
					   });
	}
}


@end
