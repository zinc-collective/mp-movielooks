//
//  PlaybackViewController.m
//  MobileLooks
//
//  Created by jack on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlaybackViewController.h"
#import "PlaybackView.h"
#import "VideoFrameTrack.h"
#import "ThumbView.h"
#import "FileCache.h"
#import "LooksBrowserViewController.h"
#import "AVAssetUtilities.h"

@interface PlaybackViewController()
- (void)syncButtons;
- (void)syncScrubber;
@end

static NSString* const PlayerPlaybackViewControllerRateObservationContext = @"PlayerPlaybackViewControllerRateObservationContext";
static NSString* const PlayerPlaybackViewControllerDurationObservationContext = @"PlayerPlaybackViewControllerDurationObservationContext";

@implementation PlaybackViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		mPlayer = [[AVPlayer alloc] init];
		[mPlayer addObserver:self forKeyPath:@"rate" options:0 context:(__bridge void * _Nullable)(PlayerPlaybackViewControllerRateObservationContext)];
		[mPlayer addObserver:self forKeyPath:@"currentItem.asset.duration" options:0 context:(__bridge void * _Nullable)(PlayerPlaybackViewControllerDurationObservationContext)];
		
		mThumbView = [[ThumbView alloc] initWithFrame:mPlaybackView.frame];
		mThumbView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			mThumbView.mCropSize = CGSizeMake(1024, 768);
		}
		else {
			mThumbView.mCropSize = CGSizeMake(320, 180);
		}
	}
	
	return self;
}

- (id)init
{
	return [self initWithNibName:@"PlaybackViewController" bundle:nil];
}

- (void)dealloc
{
	
	
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
	}
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:AVFrameTrackedDidFinishNotification object:self];
	
	[mPlayer removeObserver:self forKeyPath:@"rate"];
	[mPlayer removeObserver:self forKeyPath:@"currentItem.asset.duration"];
	[mPlayer pause];
	
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (NSURL*)URL
{
	return mURL;
}

- (void)setURL:(NSURL*) URL
{
	if (mURL != URL)
	{       
//		MobileLooksAppDelegate *appDelegate = (MobileLooksAppDelegate*)[[UIApplication sharedApplication] delegate];
//
		mURL = [URL copyWithZone:nil];
		
		[mPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:URL]];
		
		
		[[mThumbView layer] setContents:nil];
		
		AVAsset* aasset = [[mPlayer currentItem] asset];
		if(aasset){
//            appDelegate.videoDuration = CMTimeGetSeconds([aasset duration]);
			[mThumbView setAsset:aasset];
		}
		else {
			
			mAvAsset = [[AVURLAsset allocWithZone:NULL] initWithURL:mURL options:nil];
			[mThumbView setAsset:mAvAsset];
			
			if (mAvAsset)
			{
//                appDelegate.videoSize = [AVAssetUtilities naturalSize:mAvAsset];
//				appDelegate.videoDuration = CMTimeGetSeconds([mAvAsset duration]);
			}
		}
		
		mVideoFrameTrack = [[VideoFrameTrack alloc] initWithURL:mURL];
	}
}

- (AVPlayer*)player
{
	return mPlayer;
}

- (void)viewWillDisappear:(BOOL)animated
{
	//self.navigationController.navigationBar.hidden = YES;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	
	[mPlayer pause];
	
	[mThumbView _clearThumbnailLayers];
	
	[super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated{
	
	self.navigationController.navigationBar.hidden = NO;
	#if 0
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
#endif
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
	
	[super viewWillAppear:animated];
}

- (NSString*) timeToString:(NSTimeInterval)time{
	
	int iTime = time*10;
	int m = iTime/600;
	int modm = iTime%600;
	
	NSString *s = @"";
	
	s = [NSString stringWithFormat:@"%d:%02d", m,modm/10];
	
	return s;
}


- (void)viewDidLoad
{
	//UIView* view  = [self view];
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Pick a Frame",nil);
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",nil) style:UIBarButtonItemStylePlain target:self
																		  action:@selector(didPickFrame:)];
	
	self.navigationItem.rightBarButtonItem = done;
	
	UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home",nil) style:UIBarButtonItemStylePlain target:self
																		  action:@selector(homeAction:)];
	
	self.navigationItem.leftBarButtonItem = home;
	
	mPlaybackView.backgroundColor = [UIColor blackColor];
	[mPlaybackView setPlayer:mPlayer];
	
	mThumbView.frame = mPlaybackView.frame;
	[self.view insertSubview:mThumbView aboveSubview:mPlaybackView];
	
	CGRect rc = CGRectMake(0, 0, 480, 50);
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		rc = CGRectMake(0, 0, 1024, 50);
	}
	
	UIView *grayBlack = [[UIView alloc] initWithFrame:rc];
	grayBlack.backgroundColor = [UIColor blackColor];
	grayBlack.alpha = 0.5;
	[mLowerUI insertSubview:grayBlack atIndex:0];
	
	currentTime = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 50, 30)];
	currentTime.text  = @"0:00";
	currentTime.textColor = [UIColor whiteColor];
	currentTime.textAlignment = NSTextAlignmentCenter;
	currentTime.backgroundColor = [UIColor clearColor];
	[mLowerUI addSubview:currentTime];
	
	rc = CGRectMake(270, 10, 50, 30);
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		rc = CGRectMake(1024-305, 10, 50, 30);
	}

	leftTime = [[UILabel alloc] initWithFrame:rc];
	leftTime.text  = @"-0:00";
	leftTime.textColor = [UIColor whiteColor];
	leftTime.textAlignment = NSTextAlignmentCenter;
	leftTime.backgroundColor = [UIColor clearColor];
	[mLowerUI addSubview:leftTime];
	leftTime.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameTraked:) name:AVFrameTrackedDidFinishNotification object:mVideoFrameTrack];
	
	double interval = .1f;
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (asset)
	{
		//mVideoSize = asset.naturalSize;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			interval = 0.5f * duration / width;
		}
		
		NSString *tx = [self timeToString:duration];
		leftTime.text = [NSString stringWithFormat:@"-%@",tx];
	}
	
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
	}
	
    __weak PlaybackViewController* weakSelf = self;
	mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
					  ^(CMTime time) {
						  [weakSelf syncScrubber];
					  }];
	

	[mThumbView layer].contentsGravity = kCAGravityResizeAspect;
	
	NSDate *date = [NSDate date];
	mTimeInterval = (long)[date timeIntervalSince1970];
	
	[mScrubber addTarget:self action:@selector(endTrackSlider:) forControlEvents:UIControlEventTouchUpInside];
	
	[mScrubber setThumbImage:[UIImage imageNamed:@"gray_progress_thumb.png"] forState:UIControlStateNormal];
	[mScrubber setThumbImage:[UIImage imageNamed:@"gray_progress_thumb.png"] forState:UIControlStateSelected];
	[mScrubber setThumbImage:[UIImage imageNamed:@"gray_progress_thumb.png"] forState:UIControlStateHighlighted];
	[mScrubber setMinimumTrackImage:[UIImage imageNamed:@"blue_progress_bk.png"] forState:UIControlStateNormal];
	[mScrubber setMaximumTrackImage:[UIImage imageNamed:@"gray_progress_bk.png"] forState:UIControlStateNormal];
	
	[self syncButtons];
	[self syncScrubber];
	
}

- (void)didReceiveMemoryWarning{
	
	[mThumbView _collectThumbnailLayersForTime:CMTimeGetSeconds([mPlayer currentTime])];
	
}

- (void) homeAction:(id)sender
{
	#if 0
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
#endif
	
	if (![[self presentedViewController] isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
	}
}


- (void) didPickFrame:(id)sender{
	
	UIImage *img = [mThumbView currentFrame];
	if(!img){
		NSLog(@"Error pick frame nil");
	}
	[self processImage:img];
	
	LooksBrowserViewController *looksBrowser = [[LooksBrowserViewController alloc] init];
	[self.navigationController pushViewController:looksBrowser animated:YES];
	
}

- (void) endTrackSlider:(id)sender{
	
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (!asset)
		return;
	
	if([self isPlaying])return;
	[self pickCurrentFrame:nil];
	
}


- (void)syncScrubber
{
	
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (!asset)
		return;
	
	double duration = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(duration))
	{
		float minValue = [mScrubber minimumValue];
		float maxValue = [mScrubber maximumValue];
		double time = CMTimeGetSeconds([mPlayer currentTime]);
		if (time/duration<0 || time/duration>1.0 || duration==0.0) 
			[mScrubber setValue:0];
		else
			 [mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
		
		if(time >= duration){
			[mPlayer seekToTime:kCMTimeZero];
			[mPlayer pause];
		}
		
		NSString *tx = [self timeToString:duration-time];
		leftTime.text = [NSString stringWithFormat:@"-%@",tx];
		
		tx = [self timeToString:time];
		currentTime.text = [NSString stringWithFormat:@"%@",tx];
		
		//NSLog(@"%f", time);
		[mThumbView update:time];
	}
}

- (void)syncButtons
{
	if ([self isPlaying])
	{
		[mPlayButton setImage:[UIImage imageNamed:@"picker_pause.png"] forState:UIControlStateNormal];
		[mPlayButton setImage:[UIImage imageNamed:@"picker_play.png"] forState:UIControlStateHighlighted];
	}
	else
	{
		[mPlayButton setImage:[UIImage imageNamed:@"picker_play.png"] forState:UIControlStateNormal];
		[mPlayButton setImage:[UIImage imageNamed:@"picker_pause.png"] forState:UIControlStateHighlighted];
	}
}

- (void)play:(id)sender
{
	if ([self isPlaying])
	{
		[mPlayer pause];
	}
	else
	{
		mThumbView.hidden = YES;
		[mPlayer play];
	}
}

- (BOOL)isPlaying
{
	return mRestoreAfterScrubbingRate != 0.f || [mPlayer rate] != 0.f;
}

- (void)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [mPlayer rate];
	[mPlayer setRate:0.f];
	
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		mTimeObserver = nil;
	}
}

- (void)scrub:(id)sender
{	
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		if(![self isPlaying]){
			mThumbView.hidden = NO;
		}
		
		AVAsset* asset = [[mPlayer currentItem] asset];
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			CGFloat width = CGRectGetWidth([slider bounds]);
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			double tolerance = 0.5f * duration / width;
			
			
			NSString *tx = [self timeToString:duration-time];
			leftTime.text = [NSString stringWithFormat:@"-%@",tx];
			
			tx = [self timeToString:time];
			currentTime.text = [NSString stringWithFormat:@"%@",tx];
			
			//NSLog(@"%f", time);
			[mThumbView update:time];
			
			[mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
			
			
		}
	}
}

- (void)endScrubbing:(id)sender
{
	if (!mTimeObserver)
	{
		AVAsset* asset = [[mPlayer currentItem] asset];
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			double tolerance = 0.5f * duration / width;
			
            __weak PlaybackViewController* weakSelf = self;
			mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
							  ^(CMTime time)
							  {
								  [weakSelf syncScrubber];
							  }];
		}
	}
	
	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}

- (void) showRenderedFrame:(UIImage*)img{
	
	mThumbView.hidden = NO;
	[[mThumbView layer] setContents:(id)[img CGImage]];
}


- (void) processImage:(UIImage*)img{
	NSData *imageData = UIImagePNGRepresentation(img);
	
	NSString *imagePath = [Utilities savedKeyFrameImagePath];
	[imageData writeToFile:imagePath atomically:NO];
}

- (void) frameTraked:(NSNotification*)notification
{	
	UIImage *img = [mVideoFrameTrack trackedKeyFrame];
	
	[self showRenderedFrame:img];
}

- (void)pickCurrentFrame:(id)sender
{
	UISlider* slider = mScrubber;
	
	AVAsset* asset = [[mPlayer currentItem] asset];
	
	if (!asset){
		return;
	}
	
	double duration = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(duration))
	{
		float minValue = [slider minimumValue];
		float maxValue = [slider maximumValue];
		float value = [slider value];
		
		double time = duration * (value - minValue) / (maxValue - minValue);
		
		if(mURL == nil){
			return;
		}
		
		
		UIImage *frameImg = [mThumbView currentFrame];
		if(frameImg){
			//[self processImage:frameImg];
			[self showRenderedFrame:frameImg];
		}
		else {
			[mVideoFrameTrack trackKeyFrame:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
		}
		
	}
	
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if (context == (__bridge void * _Nullable)(PlayerPlaybackViewControllerRateObservationContext))
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   [self syncButtons];
					   });
	}
	else if (context == (__bridge void * _Nullable)(PlayerPlaybackViewControllerDurationObservationContext))
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   [self syncScrubber];
					   });
	}
	else
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
}

@end
