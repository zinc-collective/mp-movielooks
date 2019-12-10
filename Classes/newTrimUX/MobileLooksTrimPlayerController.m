//
//  MobileLooksTrimPlayerController.m
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "MobileLooksTrimPlayerController.h"
#import "MobileLooksAppDelegate.h"

#define PLAYBACK_UPDATE_INTERVAL 0.5

static NSString* const AVPlayerRateObservationContext = @"AVPlayerRateObservationContext";

@implementation MobileLooksTrimPlayerController

@synthesize delegate = _delegate;

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

- (NSURL*)outputUrl
{
	return mURL;
}

- (void)dealloc
{
	[mURL release];

	[doneButton removeFromSuperview];
	[trimButton removeFromSuperview];
	[doneButton release];
	[trimButton release];

	[backButton release];
	[cancelButton release];
	[mCustomTrimView release];
	[mPlaybackView release];
	[mProgressView release];
	[mPlayButton release];
    [super dealloc];
}

-(void)layoutIPhone
{
	mPlayButton.frame = CGRectMake(240-30, 160-30, 60, 60);
	mProgressView.frame = CGRectMake(10, 50, 460, 20);
	mPlaybackView.frame = CGRectMake(0, 0, 480, 320);
	[mCustomTrimView resize:CGRectMake(0, 0, 480, 50)];
}

-(void)layoutIPadForPortrait
{
	mPlayButton.frame = CGRectMake(384-60, 512-60, 120, 120);
	mProgressView.frame = CGRectMake(20, 80, 728, 30);
	mPlaybackView.frame = CGRectMake(0, 0, 768, 1024);
	[mCustomTrimView resize:CGRectMake(0, 0, 768, 80)];
}

-(void)layoutIPadForLandscape
{
	mPlayButton.frame = CGRectMake(512-60, 384-60, 120, 120);
	mProgressView.frame = CGRectMake(20, 80, 984, 30);
	mPlaybackView.frame = CGRectMake(0, 0, 1024, 768);
	[mCustomTrimView resize:CGRectMake(0, 0, 1024, 80)];

	self.navigationItem.titleView = nil;
}

-(void)resetPlayer
{
	CGFloat leftFactor = [mCustomTrimView.quartzTrimView getLeftPos];
	CMTime leftTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*leftFactor,600);
	[mPlayer seekToTime:leftTime];
	[mPlayer pause];
	mPlayerState = AVPlayerReady;
}

-(void)pausePlayer
{
	if(mPlayerState = AVPlayerPlaying)
	{
		[mPlayer pause];
		mPlayerState = AVPlayerPaused;
	}
//	Float64 factor = CMTimeGetSeconds([mPlayer currentTime])/CMTimeGetSeconds(mVideoDuration);
//	[mCustomTrimView.quartzTrimView setPickerPos:factor displayPicker:NO];
}

-(void)playPlayer
{
	[mPlayer play];
	mPlayerState = AVPlayerPlaying;

	NSLog(@"Player Time(%d,%d)",[mPlayer currentTime].value,[mPlayer currentTime].timescale);
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
	NSLog(@"Player error:%@(%d)",[mPlayer.error localizedDescription],mPlayer.status);
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
							  NSLog(@"Player factor:%f, Time(%d,%d)",factor,[mPlayer currentTime].value,[mPlayer currentTime].timescale);
							  if([mCustomTrimView.quartzTrimView isOverRange])
							  {
//								  factor = [mCustomTrimView.quartzTrimView getLeftPos];
//								  CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
//								  [mPlayer seekToTime:videoPosTime];
								  [mPlayer pause];
//								  mPlayerState = AVPlayerReady;
//								  [self displayPlayerButton];
							  }
							[mCustomTrimView.quartzTrimView setPickerPos:factor displayPicker:YES];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

	backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Camera Roll",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];

	doneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[doneButton setImage:[UIImage imageNamed:@"done_button.png"] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];

	trimButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[trimButton setImage:[UIImage imageNamed:@"trim_button.png"] forState:UIControlStateNormal];
	[trimButton addTarget:self action:@selector(trimAction:) forControlEvents:UIControlEventTouchUpInside];

	UIView* rightButtonGroupView = nil;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		doneButton.frame = CGRectMake(76, 6, 64, 32);
		trimButton.frame = CGRectMake(0, 6, 64, 32);
		rightButtonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 44)];
	}
	else
	{
		doneButton.frame = CGRectMake(56, 4, 48, 24);
		trimButton.frame = CGRectMake(0, 4, 48, 24);
		rightButtonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 106, 32)];
	}
	[rightButtonGroupView addSubview:doneButton];
	[rightButtonGroupView addSubview:trimButton];

	UIBarButtonItem* rightButtonGroupItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonGroupView];
	self.title = NSLocalizedString(@"Select Frame", nil);
	self.navigationItem.leftBarButtonItem = backButton;
	self.navigationItem.rightBarButtonItem = rightButtonGroupItem;
	[rightButtonGroupView release];
	[rightButtonGroupItem release];
    // Do any additional setup after loading the view from its nib.

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
		mCustomTrimView = [[CustomTrimView alloc] initWithFrame:CGRectMake(0, 0, 1024, 80)];
		[mCustomTrimView resize:CGRectMake(0, 0, 1024, 80)];
		mProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 80, 1024, 30)];
		mProgressView.alpha = 0.f;
	}
	else {
		mPlaybackView = [[PlaybackView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
		mCustomTrimView = [[CustomTrimView alloc] initWithFrame:CGRectMake(0, 0, 480, 50)];
		[mCustomTrimView resize:CGRectMake(0, 0, 480, 50)];
		mProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 50, 460, 20)];
		mProgressView.alpha = 0.f;
	}

	mPlayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[mPlayButton setImage:[UIImage imageNamed:@"trimButtonPlay.png"] forState:UIControlStateNormal];
	[mPlayButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];

	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	mVideoDuration = avAsset.duration;
	CGSize naturalSize = avAsset.naturalSize;

	CGFloat width = naturalSize.width/naturalSize.height;
	CGFloat totalWidth = mCustomTrimView.quartzTrimView.maskWidth/mCustomTrimView.quartzTrimView.maskHeight;

	mPlaybackView.backgroundColor = [UIColor blackColor];
	[mCustomTrimView.quartzTrimView resetTrimEditor];
	mCustomTrimView.quartzTrimView.delegate = self;
	[mCustomTrimView updateThumbnailLayer:avAsset withLayerNum:ceil(totalWidth/width)];

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
			[self layoutIPadForPortrait];
		else
			[self layoutIPadForLandscape];
	}
	else
		[self layoutIPhone];

	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[mPlaybackView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	mIsTrimming = NO;

	[self.view addSubview:mPlaybackView];
	[self.view addSubview:mCustomTrimView];
	[self.view addSubview:mProgressView];
	[self.view addSubview:mPlayButton];

	[avAsset release];
}

- (void)saveKeyFrame{
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];

	CGSize maximumSize;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		maximumSize = CGSizeMake(800, 450);
	else
		maximumSize = CGSizeMake(320, 180);

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
	[Utilities seletedVideoPathWithURL:mURL];
}

- (void)saveKeyFrameAndVideo{
	[Utilities seletedVideoPathWithURL:mURL];

	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];

	CGSize maximumSize;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		maximumSize = CGSizeMake(800, 450);
	else
		maximumSize = CGSizeMake(320, 180);

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
	if(mIsTrimming)
	{
		//fix for new UX logic
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
		doneButton.enabled = NO;

		//new trim path
		NSString* moviePath = [Utilities trimedVideoPath:[mURL path]];
		NSFileManager *manager = [NSFileManager defaultManager];
		if([manager fileExistsAtPath:moviePath])
			[manager removeItemAtPath:moviePath error:nil];

		CMTime startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getLeftPos],600);
		CMTime endTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*[mCustomTrimView.quartzTrimView getRightPos],600);

		AVAsset* avAsset = [AVURLAsset URLAssetWithURL:mURL options:nil];

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
	doneButton.enabled = YES;

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
	NSLog(@"Time(%d,%d)",mVideoDuration.timescale,mVideoDuration.value);
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
	trimButton.hidden = YES;
	[doneButton setImage:[UIImage imageNamed:@"trim_done_button.png"] forState:UIControlStateNormal];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		doneButton.frame = CGRectMake(30, 6, 110, 32);
	else
		doneButton.frame = CGRectMake(22, 4, 82, 24);

	self.title = NSLocalizedString(@"Trim Video", nil);
	[self pausePlayer];
	//	[self hiddenPlayerButton];
	[self displayPlayerButton];

	mIsTrimming = YES;
	[mCustomTrimView.quartzTrimView setEditing:YES];
}

-(void)extraTrimMode
{
	self.navigationItem.leftBarButtonItem = backButton;
	//	self.navigationItem.rightBarButtonItem = doneButton;
	trimButton.hidden = NO;
	[doneButton setImage:[UIImage imageNamed:@"done_button.png"] forState:UIControlStateNormal];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		doneButton.frame = CGRectMake(76, 6, 64, 32);
	else
		doneButton.frame = CGRectMake(56, 4, 48, 24);


	self.title = NSLocalizedString(@"Select Frame", nil);

	[mCustomTrimView.quartzTrimView resetTrimEditor];

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
	[self extraTrimMode];
}

#pragma mark - Trim View Delegate
-(void)trimBeginEdit:(QuartzTrimView*)trimView
{
	[self enterTrimMode];
};

-(void)trimCancelEdit:(QuartzTrimView*)trimView
{
	[self extraTrimMode];
}

-(void)changePicker:(QuartzTrimView*)trimView withPos:(CGFloat)factor
{
	CMTime videoPosTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(mVideoDuration)*factor,600);
	[mPlayer seekToTime:videoPosTime];
	[self pausePlayer];
	[self displayPlayerButton];
}

-(void)changeTrimRange:(QuartzTrimView*)trimView withLeftPos:(CGFloat)lFactor withRightPos:(CGFloat)rFactor
{
	[self pausePlayer];
	[self displayPlayerButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || interfaceOrientation==UIInterfaceOrientationLandscapeRight;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
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
							   [mCustomTrimView.quartzTrimView setPickerPos:[mCustomTrimView.quartzTrimView getLeftPos] displayPicker:YES];
						   }
					   });
	}
}
@end
