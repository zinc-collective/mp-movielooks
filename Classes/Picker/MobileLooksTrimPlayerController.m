//
//  MobileLooksTrimPlayerController.m
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "MobileLooksTrimPlayerController.h"
#import "MobileLooksAppDelegate.h"

#import "DeviceDetect.h"

#define PLAYBACK_UPDATE_INTERVAL 0.5


static NSString* const AVPlayerRateObservationContext = @"AVPlayerRateObservationContext";

@implementation MobileLooksTrimPlayerController

@synthesize delegate = _delegate;

//storyboard
- (void)setUrl:(NSURL *)sourceUrl withAssetMode:(AssetMode)mode
{
    mURL = [sourceUrl copyWithZone:[self zone]];
    mExportURL = nil;
    mAVTrimSession = nil;
    mTrimProgressTimer = nil;
    mAssetMode = mode;
}

#if 0
- (id)initWithUrl:(NSURL *)sourceUrl withAssetMode:(AssetMode)mode
{
    self = [super initWithNibName:@"MobileLooksTrimPlayerController" bundle:nil];
    if (self) {
        mURL = [sourceUrl copyWithZone:[self zone]];
		mExportURL = nil;
		
		mAVTrimSession = nil;
		mTrimProgressTimer = nil;
		mAssetMode = mode;
    }
    return self;
}
#endif

- (NSURL*)outputUrl
{
	return mURL;
}

- (void)dealloc
{
	[mURL release];

	//bret [doneButton removeFromSuperview];
	[trimButton removeFromSuperview];
	//bret [doneButton release];
	[trimButton release];

	//[backButton release];
	[cancelButton release];

    //[goBackButton release];
    [goPlayButton release];
    [goPauseButton release];
    [movieAdvanceSliderBackground release];
    [movieAdvanceSlider release];
    [nextButton release];

	[mCustomTrimView release];
	[mPlaybackView release];
	[mProgressView release];
	[mPlayButton release];
    
    [super dealloc];
}

-(void)layoutIPhoneLandscape
{
	//[goBackButton setImage:[UIImage imageNamed:@"slider_back_iphone_106x33.png"] forState:UIControlStateNormal];
	[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_iphone_107x34"] forState:UIControlStateNormal];
	[movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_218x33"] forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_background_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;

	if (IS_IPHONE_5)
    {
        CGFloat StartY = 244.0f;
        CGFloat StartX = 44-16-6;
        //mPlayButton.frame = CGRectMake((568/2)-30, 160-30, 60, 60);
        mPlayButton.frame = CGRectMake((568/2)-(116/2), 160-(116/2), 116, 116);
        mProgressView.frame = CGRectMake(10, 50, 586-20, 20);
        mPlaybackView.frame = CGRectMake(0, 0, 568, 320);
        [mCustomTrimView resize:CGRectMake(0, 0, 568, 50)];
        
        //goBackButton.frame = CGRectMake(StartX+3-8, StartY-1, 106, 33);
        goPlayButton.frame = CGRectMake(StartX+115+10, StartY, 35, 33);
        goPauseButton.frame = CGRectMake(StartX+115+10, StartY,35, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(StartX+115+10+35-1, StartY, 232, 33);
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            movieAdvanceSlider.frame = CGRectMake(StartX+115+10+35+5, StartY+11, 218, 12);
        //else
        //    movieAdvanceSlider.frame = CGRectMake(StartX+152, StartY, 208, 10);
        
        nextButton.frame = CGRectMake(StartX+370+12+16+12, StartY, 107, 34);
    }else
    {
        CGFloat StartY = 244.0f;
        //mPlayButton.frame = CGRectMake(240-30, 160-30, 60, 60);
        mPlayButton.frame = CGRectMake(240-(116/2), 160-(116/2), 116, 116);
        mProgressView.frame = CGRectMake(10, 50, 460, 20);
        mPlaybackView.frame = CGRectMake(0, 0, 480, 320);
        [mCustomTrimView resize:CGRectMake(0, 0, 480, 50)];
    
        //goBackButton.frame = CGRectMake(3, StartY, 106, 33);
        goPlayButton.frame = CGRectMake(115-6, StartY, 32, 33);
        goPauseButton.frame = CGRectMake(115-6, StartY,32, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(147-6, StartY, 218, 33);
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            movieAdvanceSlider.frame = CGRectMake(152-6, StartY+12, 208, 10);
        //else
        //    movieAdvanceSlider.frame = CGRectMake(152, StartY, 208, 10);
        
        nextButton.frame = CGRectMake(370, StartY, 107, 34);
    }
	
}

-(void)layoutIPhonePortrait
{
	//[goBackButton setImage:[UIImage imageNamed:@"slider_back_iphone_74x33.png"] forState:UIControlStateNormal];
	//**small button[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_iphone_47x34"] forState:UIControlStateNormal];
	[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_iphone_107x34"] forState:UIControlStateNormal];
    [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_197x33"] forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_iphone_189x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_background_iphone_189x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;

	if (IS_IPHONE_5)
    {
        CGFloat StartY = 394.0f + 88;
        CGFloat StartX = 0;

        //mPlayButton.frame = CGRectMake(160-30, (568/2)-30, 60, 60);
        mPlayButton.frame = CGRectMake(160-(116/2), (568/2)-(116/2), 116, 116);
        mProgressView.frame = CGRectMake(10, 50, 320-20, 20);
        mPlaybackView.frame = CGRectMake(0, 0, 320, 568);

        //goBackButton.frame = CGRectMake(StartX+1, StartY, 74, 33);
        goPlayButton.frame = CGRectMake(StartX+6, StartY, 35, 33);
        goPauseButton.frame = CGRectMake(StartX+6, StartY,35, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(StartX+6+34, StartY, 158 /*210*/, 33); //158
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        movieAdvanceSlider.frame = CGRectMake(StartX+6+35+4 /*5*/, StartY+11, 151 /*197*/, 12); //151
        //else
        //    movieAdvanceSlider.frame = CGRectMake(StartX+113, StartY, 151, 10);
#if 0
        goBackButton.frame = CGRectMake(StartX+3-8, StartY-1, 106, 33);
        goPlayButton.frame = CGRectMake(StartX+115+10, StartY, 35, 33);
        goPauseButton.frame = CGRectMake(StartX+115+10, StartY,35, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(StartX+115+10+35-1, StartY, 232, 33);
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        movieAdvanceSlider.frame = CGRectMake(StartX+115+10+35+5, StartY+11, 218, 12);
#endif
        //**small button nextButton.frame = CGRectMake(StartX+272-10, StartY, 47, 34);
        nextButton.frame = CGRectMake(320-107-6, StartY, 107, 34);
    }else
    {
        CGFloat StartY = 394.0f;
        CGFloat StartX = 0;

        //mPlayButton.frame = CGRectMake(160-30, (480/2)-30, 60, 60);
        mPlayButton.frame = CGRectMake(160-(116/2), (480/2)-(116/2), 116, 116);
        mProgressView.frame = CGRectMake(10, 50, 460, 20);
        mPlaybackView.frame = CGRectMake(0, 0, 320, 480);

        //goBackButton.frame = CGRectMake(StartX+1, StartY, 74, 33);
        goPlayButton.frame = CGRectMake(StartX+6, StartY, 35, 33);
        goPauseButton.frame = CGRectMake(StartX+6, StartY,35, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(StartX+6+34, StartY, 158 /*210*/, 33); //158
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        movieAdvanceSlider.frame = CGRectMake(StartX+6+35+4 /*5*/, StartY+11, 151 /*197*/, 12); //151
        //else
        //    movieAdvanceSlider.frame = CGRectMake(StartX+113, StartY, 151, 10);

#if 0
        goBackButton.frame = CGRectMake(StartX+1, StartY, 74, 33);
        goPlayButton.frame = CGRectMake(StartX+77, StartY, 32, 33);
        goPauseButton.frame = CGRectMake(StartX+77, StartY,32, 33);
        movieAdvanceSliderBackground.frame = CGRectMake(StartX+109, StartY, 158, 33);
        //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            movieAdvanceSlider.frame = CGRectMake(StartX+113, StartY+12, 151, 10);
        //else
        //    movieAdvanceSlider.frame = CGRectMake(StartX+113, StartY, 151, 10);
#endif
        //**small button nextButton.frame = CGRectMake(StartX+272-10, StartY, 47, 34);
        nextButton.frame = CGRectMake(320-107-6, StartY, 107, 34);
    }
	[mCustomTrimView resize:CGRectMake(0, 0, 320, 50)];
}

-(void)layoutIPadForPortrait
{
	//[goBackButton setImage:[UIImage imageNamed:@"slider_back_ipad_158x71.png"] forState:UIControlStateNormal];
	//**small button[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_ipad_100x72"] forState:UIControlStateNormal];
	[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_ipad_228x72"] forState:UIControlStateNormal];
	[movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_ipad_420x71"] forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_ipad_403x21"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_background_ipad_403x21"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;

    //mPlayButton.frame = CGRectMake(384-60, 512-60, 120, 120);
    mPlayButton.frame = CGRectMake(384-(253/2), 512-(253/2), 253, 253);
	mProgressView.frame = CGRectMake(20, 80, 728, 30);
	mPlaybackView.frame = CGRectMake(0, 0, 768, 1024);
	[mCustomTrimView resize:CGRectMake(0, 0, 768, 80)];

	CGFloat StartY = 885.0f;
    //goBackButton.frame = CGRectMake(6, StartY-2, 158, 71);
    goPlayButton.frame = CGRectMake(0+12, StartY, 69, 66);
    goPauseButton.frame = CGRectMake(0+12, StartY, 69, 66);
    movieAdvanceSliderBackground.frame = CGRectMake(69+12, StartY-2, 420, 71);
    movieAdvanceSlider.frame = CGRectMake(69+12+12, StartY+22-7+3-2, 394, 23);
    //**small button nextButton.frame = CGRectMake(663, StartY-2, 100, 72);
    nextButton.frame = CGRectMake(768-228-12, StartY-2, 228, 72);
}

-(void)layoutIPadForLandscape
{
	//[goBackButton setImage:[UIImage imageNamed:@"slider_back_ipad_226x71.png"] forState:UIControlStateNormal];
	[nextButton setImage:[UIImage imageNamed:@"slider_next_blue_ipad_228x72"] forState:UIControlStateNormal];
	[movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_ipad_463x71"] forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"slider_background_light_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_background_ipad_463x71"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [movieAdvanceSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [movieAdvanceSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
	
    //mPlayButton.frame = CGRectMake(512-60, 384-60, 120, 120);
    mPlayButton.frame = CGRectMake(512-(253/2), 384-(253/2), 253, 253);
	mProgressView.frame = CGRectMake(20, 80, 984, 30);
	mPlaybackView.frame = CGRectMake(0, 0, 1024, 768);
	[mCustomTrimView resize:CGRectMake(0, 0, 1024, 80)];
    
    float starty = 685+2;
    //goBackButton.frame = CGRectMake(8, starty-50, 226, 71);
    goPlayButton.frame = CGRectMake(245, starty-50+2, 69, 66); //69x66
    goPauseButton.frame = CGRectMake(245, starty-50+2, 69, 66);//69x66
    movieAdvanceSliderBackground.frame = CGRectMake(245+69, starty-50+2, 463, 66); //463x66
    movieAdvanceSlider.frame = CGRectMake(245+69+12, starty-50+2+22-7, 436, 23); //436x23
    nextButton.frame = CGRectMake(788, starty-50, 228, 72);
	//goPlayButton.alpha = 1.0f;
	//goPauseButton.alpha = 1.0f;
	//movieAdvanceSliderBackground.alpha = 1.0f;
	self.navigationItem.titleView = nil;
}

-(void)resetPlayer
{
	CGFloat leftFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CMTime leftTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*leftFactor,600);
	[mPlayer seekToTime:leftTime];
	[mPlayer pause];
    movieAdvanceSlider.value = leftFactor;
	//movieAdvanceSlider.minimumValue = lFactor;
	//movieAdvanceSlider.maximumValue = rFactor;
    
	mPlayerState = AVPlayerReady;
}

-(void)pausePlayer
{
	if(mPlayerState == AVPlayerPlaying) //bret **if(mPlayerState = AVPlayerPlaying)
	{
		[mPlayer pause];
		mPlayerState = AVPlayerPaused;
        goPauseButton.hidden = YES;
        goPlayButton.hidden = NO;
	}
//	Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
//	[mCustomTrimView.quartzTrimView setPickerPos:factor displayPicker:NO];
}

-(void)playPlayer
{	
	[mPlayer play];
	mPlayerState = AVPlayerPlaying;
    goPauseButton.hidden = NO;
    goPlayButton.hidden = YES;

	NSLog(@"Player Time(%lld,%d)",[mPlayer currentTime].value,[mPlayer currentTime].timescale);
}

#pragma mark - Player controll
- (void)displayPlayerButton
{	
	if (mPlayButton.alpha<0.5) {
		[mPlayButton setAlpha:0.0];
		[UIView animateWithDuration:0.5 animations:^{
			[mPlayButton setAlpha:1.0];
		}];		
	}
}

- (void)hiddenPlayerButton
{
	if (mPlayButton.alpha>0.5) {
		[mPlayButton setAlpha:1.0];
		[UIView animateWithDuration:0.5 animations:^{
			[mPlayButton setAlpha:0.0];
		}];
	}
}

-(void)clearPlayer
{
	if(mPlayerState==AVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
		
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

-(void)pauseToMultiTask
{
		NSLog(@"pauseToMultiTask");
	if(mPlayer)
	{
		[self pausePlayer];
		[self displayPlayerButton];
	}
	
	if(mAVTrimSession)
	{			
//		[mExportURL release];
//		mExportURL = nil;
		mExportCancel = YES;
		[mAVTrimSession cancelExport];		
		[self.navigationController popViewControllerAnimated:NO];		
	}
}

-(void)resumeFromMultiTask
{
	NSLog(@"resumeFromMultiTask");	
	NSLog(@"Player error:%@(%ld)",[mPlayer.error localizedDescription],(long)mPlayer.status);
	[mPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:mURL]];
/*
	if(mPlayer)
	{
		[self pausePlayer];
		[self displayPlayerButton];
	}
	
	if(mAVTrimSession)
	{			
		//		[mExportURL release];
		//		mExportURL = nil;
		mExportCancel = YES;
		[mAVTrimSession cancelExport];		
		[self.navigationController popViewControllerAnimated:NO];		
	}
*/  
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
#if 0
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
#endif
	
	mPlayer = [[AVPlayer allocWithZone:[self zone]] initWithURL:mURL];
	[mPlayer addObserver:self forKeyPath:@"rate" options:0 context:AVPlayerRateObservationContext];
	[mPlaybackView setPlayer:mPlayer];

	mPlayTimeObserver = [[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, 600) queue:dispatch_get_main_queue() usingBlock:
						  ^(CMTime time) {
							  if (mPlayer.rate==0.0) return;
							  
							  Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
							  NSLog(@"Player factor:%f, Time(%lld,%d)",factor,[mPlayer currentTime].value,[mPlayer currentTime].timescale);
							  if([mCustomTrimView.quartzTrimView isOverRange])
							  {
//								  factor = [mCustomTrimView.quartzTrimView getLeftPos];
//								  CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
//								  [mPlayer seekToTime:videoPosTime];
								  [mPlayer pause];
                                  movieAdvanceSlider.value = 0.0;
                                  goPauseButton.hidden = YES;
                                  goPlayButton.hidden = NO;
//								  mPlayerState = AVPlayerReady;
//								  [self displayPlayerButton];	
							  }
							[mCustomTrimView.quartzTrimView setPickerPos:factor displayPicker:YES];
                            movieAdvanceSlider.value = factor;
						  }] retain];
	
	mPlayerState = AVPlayerReady;
	[self displayPlayerButton];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToMultiTask) name:@"MultiTaskPause" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeFromMultiTask) name:@"MultiTaskResume" object:nil];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self clearPlayer];
//	NSLog(@"%d",[mPlayer count]);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskPause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskResume" object:nil];
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidAppear:(BOOL)animated{
	
	[super viewDidAppear:animated];

    //set back button arrow color
    //[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
    //[self.navigationItem setHidesBackButton:YES];
	//backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Camera Roll",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        //self.navigationController.navigationBar.translucent = YES;
        //self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.topItem.title = @"";
        //self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[UIColor whiteColor]];
    }
    backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	
	//bret doneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//bret [doneButton setImage:[UIImage imageNamed:@"done_button.png"] forState:UIControlStateNormal];
	//bret [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
	
	trimButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[trimButton setImage:[UIImage imageNamed:@"trim_button.png"] forState:UIControlStateNormal];
	[trimButton addTarget:self action:@selector(trimAction:) forControlEvents:UIControlEventTouchUpInside];
	
    UIImage *minImage;
    UIImage *maxImage;
    UIImage *thumbImage;
    if (IS_IPAD)
    {
        //goBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //[goBackButton setImage:[UIImage imageNamed:@"slider_back_ipad_226x71.png"] forState:UIControlStateNormal];
        //[goBackButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        nextButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [nextButton setImage:[UIImage imageNamed:@"slider_next_blue_ipad_228x72"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        
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
    }else
    {
        //goBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //[goBackButton setImage:[UIImage imageNamed:@"slider_back_iphone_106x33.png"] forState:UIControlStateNormal];
        //[goBackButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        nextButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [nextButton setImage:[UIImage imageNamed:@"slider_next_blue_iphone_107x34"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        
        goPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPlayButton setImage:[UIImage imageNamed:@"slider_play_iphone_32x33"] forState:UIControlStateNormal];
        [goPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
        goPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [goPauseButton setImage:[UIImage imageNamed:@"slider_pause_iphone_32x33"] forState:UIControlStateNormal];
        [goPauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        
        movieAdvanceSliderBackground = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [movieAdvanceSliderBackground setImage:[UIImage imageNamed:@"slider_frame_iphone_218x33"] forState:UIControlStateNormal];
        [movieAdvanceSliderBackground setEnabled:NO];
        
        minImage = [[UIImage imageNamed:@"slider_background_light_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        maxImage = [[UIImage imageNamed:@"slider_background_iphone_208x10"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        thumbImage = [UIImage imageNamed:@"slider_button_iphone_13x14"];
        
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
    
    //bret UIView* rightButtonGroupView = nil;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{	
		//bret doneButton.frame = CGRectMake(76, 6, 64, 32);
		trimButton.frame = CGRectMake(0, 6, 64, 32);
#if 0 //called in layout
        goBackButton.frame = CGRectMake(8, 685, 226, 71);
		goPlayButton.frame = CGRectMake(245, 685, 68, 71);
		goPauseButton.frame = CGRectMake(245, 685, 68, 71);
		movieAdvanceSliderBackground.frame = CGRectMake(314, 685, 463, 71);
		movieAdvanceSlider.frame = CGRectMake(323, 712-28, 443, 21);
		nextButton.frame = CGRectMake(788, 685, 228, 72);
#endif
        //bret rightButtonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 44)];
	}
	else
	{	
		//bret doneButton.frame = CGRectMake(56, 4, 48, 24);
		trimButton.frame = CGRectMake(0, 4, 48, 24);		
		//bret rightButtonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 106, 32)];
	}	
	//bret [rightButtonGroupView addSubview:doneButton];
//	[rightButtonGroupView addSubview:trimButton];
	
	//bret UIBarButtonItem* rightButtonGroupItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonGroupView];
	self.title = NSLocalizedString(@"Trim Your Movie", nil);
	//**self.navigationItem.leftBarButtonItem = backButton;
	//bret self.navigationItem.rightBarButtonItem = rightButtonGroupItem;
	//bret [rightButtonGroupView release];
	//bret [rightButtonGroupItem release];
    // Do any additional setup after loading the view from its nib.

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{	
		mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
		mCustomTrimView = [[CustomTrimView alloc] initWithFrame:CGRectMake(0, 0, 1024, 80)];
		[mCustomTrimView resize:CGRectMake(0, 0, 1024, 80)];
		mProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 80, 1024, 30)];
		mProgressView.alpha = 0.f;
	}
	else
    {
        if (IS_IPHONE_5)
        {
            mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
            mCustomTrimView = [[CustomTrimView alloc] initWithFrame:CGRectMake(0, 0, 568, 50)];
            [mCustomTrimView resize:CGRectMake(0, 0, 568, 50)];
            mProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 50, 568-20, 20)];
		}else
        {
            mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
            mCustomTrimView = [[CustomTrimView alloc] initWithFrame:CGRectMake(0, 0, 480, 50)];
            [mCustomTrimView resize:CGRectMake(0, 0, 480, 50)];
            mProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 50, 460, 20)];
        }
        
        mProgressView.alpha = 0.f;
	}
	
	mPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//[mPlayButton setImage:[UIImage imageNamed:@"trimButtonPlay.png"] forState:UIControlStateNormal];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [mPlayButton setImage:[UIImage imageNamed:@"play_button253x253.png"] forState:UIControlStateNormal];
    else
        [mPlayButton setImage:[UIImage imageNamed:@"play_button116x116_iphone.png"] forState:UIControlStateNormal];
    
	[mPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
	/*	
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	mVideoDuration = avAsset.duration;
	CGSize naturalSize = avAsset.naturalSize;

	CGFloat width = naturalSize.width/naturalSize.height;
	CGFloat totalWidth = mCustomTrimView.quartzTrimView.maskWidth/mCustomTrimView.quartzTrimView.maskHeight;

	mPlaybackView.backgroundColor = [UIColor blackColor];
	[mCustomTrimView.quartzTrimView resetTrimEditor];
	mCustomTrimView.quartzTrimView.delegate = self;
	[mCustomTrimView updateThumbnailLayer:avAsset withLayerNum:ceil(totalWidth/width)];
 	[avAsset release];
	*/
	mPlaybackView.backgroundColor = [UIColor blackColor];
	[mCustomTrimView.quartzTrimView resetTrimEditor];
	mCustomTrimView.quartzTrimView.delegate = self;
	
	//	[NSTimer scheduledTimerWithTimeInterval:0.2  target:self selector:@selector(loadAsset) userInfo:nil repeats:NO];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		if(orientation ==UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown)
			[self layoutIPadForPortrait];
		else 
			[self layoutIPadForLandscape];
	}
	else
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		if(orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
            [self layoutIPhonePortrait];
        else
            [self layoutIPhoneLandscape];
    }
	
	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[mPlaybackView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	mIsTrimming = NO;
	
	[self.view addSubview:mPlaybackView];
	[self.view addSubview:mCustomTrimView];
	[self.view addSubview:mProgressView];
	[self.view addSubview:mPlayButton];

	//[self.view addSubview:goBackButton];
	[self.view addSubview:goPlayButton];
	[self.view addSubview:goPauseButton];
	[self.view addSubview:nextButton];
    [self.view addSubview:movieAdvanceSliderBackground];
    [self.view addSubview:movieAdvanceSlider];
    
    goPauseButton.hidden = YES;
	
	[self performSelectorInBackground:@selector(loadAsset) withObject:nil];
}

-(void)loadAsset
{
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	mVideoDuration = avAsset.duration;
	CGSize naturalSize = avAsset.naturalSize;
	
	CGFloat width = naturalSize.width/naturalSize.height;
	CGFloat totalWidth = mCustomTrimView.quartzTrimView.maskWidth/mCustomTrimView.quartzTrimView.maskHeight;
	
	[mCustomTrimView updateThumbnailLayer:avAsset withLayerNum:ceil(totalWidth/width)];
 	[avAsset release];
}

 
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
	appDelegate.videoSize = avAsset.naturalSize;
	appDelegate.videoDuration = CMTimeGetSeconds([avAsset duration]);
	NSLog(@"Video Time:%f",CMTimeGetSeconds([avAsset duration]));
	
	NSError* err = nil;
	CMTime currentTime = [mPlayer currentTime];
	CGImageRef keyFrameRef =  [avImageGenerator copyCGImageAtTime:currentTime actualTime:NULL error:&err];
	[avAsset release];
	
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
	appDelegate.videoSize = avAsset.naturalSize;
	appDelegate.videoDuration = CMTimeGetSeconds([avAsset duration]);
	NSLog(@"Video Time:%f",CMTimeGetSeconds([avAsset duration]));
	
	NSError* err = nil;
	CMTime currentTime = [mPlayer currentTime];
	CGImageRef keyFrameRef =  [avImageGenerator copyCGImageAtTime:currentTime actualTime:NULL error:&err];
	[avAsset release];

	if(err)
		NSLog(@"%@",[err localizedDescription]);
	
	UIImage* keyFrame = [UIImage imageWithCGImage:keyFrameRef];
	NSData *imageData = UIImagePNGRepresentation(keyFrame);
	NSString *imagePath = [Utilities savedKeyFrameImagePath];
	[imageData writeToFile:imagePath atomically:NO];
	CGImageRelease(keyFrameRef);
}

- (void)playAction:(id)sender
{	
	if(mPlayerState == AVPlayerReady || mPlayerState == AVPlayerPaused)
	{
		[self playPlayer];
		[self hiddenPlayerButton];
	}
}

- (void)sliderAction:(id)sender
{
	if(mPlayerState==AVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
	}
    CGFloat factor = movieAdvanceSlider.value;
    CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
	[mPlayer seekToTime:videoPosTime];
    [mCustomTrimView.quartzTrimView setPickerPos:factor displayPicker:YES];
}

- (void)pauseAction:(id)sender
{
	if(mPlayerState==AVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
	}
}

-(void)handleTap:(UISwipeGestureRecognizer*)gestureRecognizer
{
	if(mPlayerState==AVPlayerPlaying)
	{
		[self pausePlayer];
		[self displayPlayerButton];
	}
}


-(void)backAction:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)doneAction:(id)sender
{
//	[mPlayer pause];
//#if 0 //joe rendering issue
	if(mIsTrimming)
	{			
		//fix for new UX logic
		[self saveKeyFrame];
		
		[self pausePlayer];
		[self hiddenPlayerButton];
		
#if 0
		//bret new movielooks update get dimensions of video
        //NSURL *mediaURL; // Your video's URL
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = [tracks objectAtIndex:0];
        CGSize movieSize = track.naturalSize;
        //
#endif
        //progress view apear animation
		[mProgressView setAlpha:0.0];
		[UIView animateWithDuration:0.5 animations:^{
			[mProgressView setAlpha:1.0];
		}];
		
		self.navigationItem.leftBarButtonItem.enabled = NO;
		mTrimProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTrimProgress:) userInfo:nil repeats:YES] retain];
		mCustomTrimView.userInteractionEnabled = NO;
		//bret doneButton.enabled = NO;
		nextButton.enabled = NO; //bug fix
        //goBackButton.enabled = NO; //bug fix
		//new trim path	
		NSString* moviePath = [Utilities trimedVideoPath:[mURL path]];
		NSFileManager *manager = [NSFileManager defaultManager];
		if([manager fileExistsAtPath:moviePath])
			[manager removeItemAtPath:moviePath error:nil];
		
		CMTime startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getLeftPos],600);
		CMTime endTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getRightPos],600);
		
        //test
        //startTime.value = 6884;
        //NSLog(@"bret start time == %d",(int)startTime.value);
        //NSLog(@"bret end time == %d",(int)endTime.value);
        //**printf("bret start time == %d\n",(int)startTime.value);
        //**printf("bret end time == %d\n",(int)endTime.value);
        //printf("loadLookupTable: %s\n", lut3dPath);
		AVAsset* avAsset = [AVURLAsset URLAssetWithURL:mURL options:nil];
		
		//bret new movielooks update
#if 0
        if (movieSize.width == 1920.0 || movieSize.height == 1920.0)
            mAVTrimSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset1280x720];
        else
            mAVTrimSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        //
#endif
        mAVTrimSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        
        mAVTrimSession.timeRange = CMTimeRangeFromTimeToTime(startTime,endTime);
		mAVTrimSession.outputURL = [NSURL fileURLWithPath:moviePath];
		mAVTrimSession.outputFileType = AVFileTypeQuickTimeMovie;
		//update trim URL
		mExportCancel = NO;
		mExportURL = [[NSURL alloc] initFileURLWithPath:moviePath];
		
		[mAVTrimSession exportAsynchronouslyWithCompletionHandler:^{
			NSLog(@"%@",[mAVTrimSession.error localizedDescription]);
			[self performSelectorOnMainThread:@selector(trimCompleteEvent:) withObject:moviePath waitUntilDone:YES];
		}];
	}
	else
	{
		[self saveKeyFrameAndVideo];
		[self clearPlayer];
		[self.delegate videoPickerDone:self];
	}
//#endif

#if 0 //bret hack
//    //fix for new UX logic
    [self saveKeyFrame];
    
    [self pausePlayer];
    [self hiddenPlayerButton];
    
    //progress view apear animation
    [mProgressView setAlpha:0.0];
    [UIView animateWithDuration:0.5 animations:^{
        [mProgressView setAlpha:1.0];
    }];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    mTrimProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTrimProgress:) userInfo:nil repeats:YES] retain];
    mCustomTrimView.userInteractionEnabled = NO;
    //bret doneButton.enabled = NO;
    nextButton.enabled = NO; //bug fix
    //goBackButton.enabled = NO; //bug fix
    
    //new trim path
    NSString* moviePath = [Utilities trimedVideoPath:[mURL path]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:moviePath])
        [manager removeItemAtPath:moviePath error:nil];
    
    CMTime startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getLeftPos],600);
    CMTime endTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getRightPos],600);
    
    //NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    //AVAsset* avAsset = [AVURLAsset URLAssetWithURL:mURL options:options];
    AVAsset* avAsset = [AVURLAsset URLAssetWithURL:mURL options:nil];
    
    mAVTrimSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
    //mAVTrimSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset1280x720];
    //AVAssetExportPreset1920x1080
    //bret
    if(!mIsTrimming)
    {
        //startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*.0250,600); //didn't work for 31 second clip
        startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*.0275,600); //magic number!
        //startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*.02625,600); //didn't work for 31 second clip
    }
    //
    mAVTrimSession.timeRange = CMTimeRangeFromTimeToTime(startTime,endTime);
    mAVTrimSession.outputURL = [NSURL fileURLWithPath:moviePath];
    mAVTrimSession.outputFileType = AVFileTypeQuickTimeMovie;
    //update trim URL
    mExportCancel = NO;
    mExportURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    
    
    [mAVTrimSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[mAVTrimSession.error localizedDescription]);
        [self performSelectorOnMainThread:@selector(trimCompleteEvent:) withObject:moviePath waitUntilDone:YES];
    }];
#endif
}

-(void)trimCompleteEvent:(id)sender
{
	NSLog(@"trimCompleteEvent Begin");
	[mAVTrimSession release];
	mAVTrimSession = nil;

	//pause export
	if(mExportCancel) 
	{	
		NSLog(@"Bad operation!");
		return;
	}
	
	if(mURL)
	{
		[mURL release];
		mURL = nil;
	}
	mURL = [mExportURL copy];
	[mExportURL release];
	mExportURL = nil;
	
	//fix for new UX logic
	if(!mExportCancel) 
	{
		[self saveVideo];
		
		[mPlayer replaceCurrentItemWithPlayerItem:nil];
		[mTrimProgressTimer invalidate];
		[mTrimProgressTimer release];
		mTrimProgressTimer = nil;
		
		[self clearPlayer];
		[self.delegate videoPickerDone:self];
        return;
	}
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.leftBarButtonItem = backButton;
	trimButton.hidden = NO;
	//bret doneButton.enabled = YES;
	
	mCustomTrimView.userInteractionEnabled = YES;
	self.title = NSLocalizedString(@"Select Frame", nil);
	
	//progress view disapear animation
	[mProgressView setAlpha:1.0];
	[UIView animateWithDuration:0.5 animations:^{
        [mProgressView setAlpha:0.0];
    }];
	[self displayPlayerButton];
	
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];	
	[mCustomTrimView.quartzTrimView resetHolder];
	[mCustomTrimView.quartzTrimView resetTrimEditor];
	[mCustomTrimView updateThumbnailLayer:avAsset withLayerNum:11];

	[mPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:avAsset]];
	[mTrimProgressTimer invalidate];
	[mTrimProgressTimer release];
	mTrimProgressTimer = nil;
		
	mVideoDuration = avAsset.duration;
	[avAsset release];
	
	mIsTrimming = NO;
	NSLog(@"Time(%d,%lld)",mVideoDuration.timescale,mVideoDuration.value);
	NSLog(@"trimCompleteEvent End");	
}

-(void)updateTrimProgress:(id)sender
{
	mProgressView.progress = mAVTrimSession.progress;
}

-(void)enterTrimMode
{
	self.navigationItem.leftBarButtonItem = cancelButton;
	//	self.navigationItem.rightBarButtonItem = doneButton;
//	trimButton.hidden = YES;
	//bret [doneButton setImage:[UIImage imageNamed:@"trim_done_button.png"] forState:UIControlStateNormal];
/*
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		doneButton.frame = CGRectMake(30, 6, 110, 32);
	else
		doneButton.frame = CGRectMake(22, 4, 82, 24);
		
	self.title = NSLocalizedString(@"Trim Video", nil);
*/ 
	[self pausePlayer];
	//	[self hiddenPlayerButton];
	[self displayPlayerButton];
	
	mIsTrimming = YES;
	[mCustomTrimView.quartzTrimView setEditing:YES];	
}

-(void)exitTrimMode
{
	//self.navigationItem.leftBarButtonItem = backButton;
	self.navigationItem.leftBarButtonItem = nil;
	//	self.navigationItem.rightBarButtonItem = doneButton;
	trimButton.hidden = NO;
	[mCustomTrimView.quartzTrimView resetTrimEditor];
	
	//
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
	//
    [self pausePlayer];
	[self displayPlayerButton];
	mIsTrimming = NO;
	[mCustomTrimView.quartzTrimView setEditing:NO];	
}

-(void)trimAction:(id)sender
{
	[self enterTrimMode];
}

-(void)cancelAction:(id)sender
{
	[self exitTrimMode];
}

#pragma mark - Trim View Delegate
-(void)trimBeginEdit:(QuartzTrimView*)trimView
{
	[self enterTrimMode];
};

-(void)trimCancelEdit:(QuartzTrimView*)trimView
{
	[self exitTrimMode];
}

-(void)changePicker:(QuartzTrimView*)trimView withPos:(CGFloat)factor
{
	CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
	[mPlayer seekToTime:videoPosTime];
    movieAdvanceSlider.value = factor;
	//
    CGFloat lFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CGFloat rFactor = [mCustomTrimView.quartzTrimView getRightPos];
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
	//
    [self pausePlayer];
	[self displayPlayerButton];
}

-(void)changeTrimRange:(QuartzTrimView*)trimView withLeftPos:(CGFloat)lFactor withRightPos:(CGFloat)rFactor
{
	movieAdvanceSlider.minimumValue = lFactor;
	movieAdvanceSlider.maximumValue = rFactor;
    if (movieAdvanceSlider.value < movieAdvanceSlider.minimumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.minimumValue;
    if (movieAdvanceSlider.value > movieAdvanceSlider.maximumValue)
        movieAdvanceSlider.value = movieAdvanceSlider.maximumValue;
    [self pausePlayer];
	[self displayPlayerButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
	
- (BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait
            || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self layoutIPadForPortrait];
        }
        else
        {
            [self layoutIPadForLandscape];
            
        }
    }else
    {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait
            || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self layoutIPhonePortrait];
        }
        else
        {
            [self layoutIPhoneLandscape];
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if (context == AVPlayerRateObservationContext)
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   if([mPlayer rate]==0.0 && mPlayerState==AVPlayerPlaying)
						   {
							   [self resetPlayer];
							   [self displayPlayerButton];
                               goPauseButton.hidden = YES;
                               goPlayButton.hidden = NO;
							   [mCustomTrimView.quartzTrimView setPickerPos:[mCustomTrimView.quartzTrimView getLeftPos] displayPicker:YES];
						   }
					   });
	}
}
@end
