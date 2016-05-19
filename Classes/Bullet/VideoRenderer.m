//
//  VideoRenderer
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



// EXAMPLE OF LOADING
//        BulletViewController *bulletViewController = (BulletViewController *)segue.destinationViewController;
//		bulletViewController.renderer = renderer;
//		bulletViewController.fStrengthValue = fStrengthValue;
//		bulletViewController.fBrightnessValue = fBrightnessValue;
//		bulletViewController.estimateFrameProcessTime = estimateFrameProcessTime;
//		bulletViewController.estimateClipProcessTime = estimateClipProcessTime;
//		bulletViewController.estimateTotalRenderTime = estimateTotalRenderTime;
//		bulletViewController.videoMode = videoMode;
//        bulletViewController.mThumbImage = mThumbImageView.image;
//		
//		// grab the current time interval for measuring total duration later
//		bulletViewController.renderStartTime = [NSDate timeIntervalSinceReferenceDate];
//        
//        
//		RendererType type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeHalf:RendererTypeFull;
//        bool modeSwitcherHD;
//        if (modeSwitcher.on)
//        {
//            modeSwitcherHD = true;
//        } else
//        {
//            modeSwitcherHD = false;
//		}
//        
//
//        if (modeSwitcherHD) {
//            type = RendererTypeFull;
//        } else {
//            type = RendererTypeHalf;
//		}
//		
//        BOOL fullFramerate = YES;
//        if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf)
//        {
//            fullFramerate = NO;
//        }
//
//        [bulletViewController setRendererType:type withFullFramerate:fullFramerate andLookParam:mLookDic];

#import "VideoRenderer.h"
#import <sys/time.h>

#import "DeviceDetect.h"

#import "AVAssetUtilities.h"

#define Audio_Decode
#define IS_WITHOUT_AUDIO YES

static NSString* const AVPlayerRateObservationContextBullet = @"AVPlayerRateObservationContextBullet";


@implementation VideoRenderer
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
@synthesize delegate;


- (id)init
{
	if(self = [super init])
	{
		_curInputFrameIdx = 0;
		_completedFrames = 0;
		_totalFrames = 0;
		needCheckPoint = YES;
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
	return self;
}

- (void)load:(NSURL*)sourceVideoURL renderer:(ES2RendererOld*)rend videoMode:(VideoMode)mode brightness:(float)brightness strength:(float)strength rendererType:(RendererType)type fullFramerate:(BOOL)fullFramerate lookParam:(NSDictionary*)lookDic {
    self.renderer = rend;
    self.videoMode = mode;
    fBrightnessValue = brightness;
    fStrengthValue = strength;
    estimateTotalRenderTime = [self estimateProcessingTime:[Utilities selectedVideoPathWithURL:nil] withType:renderType withFullFramerate:renderFullFramerate];
    
    [self setRendererType:type withFullFramerate:fullFramerate andLookParam:lookDic];
    [self loadURL:sourceVideoURL];
}

- (void) setRendererType:(RendererType)type withFullFramerate:(BOOL)fullFramerate andLookParam:(NSDictionary*)lookDic
{
	timeRemaining = 0;
	renderType = type;
	renderFullFramerate = fullFramerate;
	[renderer loadLookParam:lookDic withMode:videoMode];
	[renderer freeRenderBuffer];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)loadURL:(NSURL*)videoURL {
    
	movieProcessor = [[MovieProcessor alloc] initWithReadURL:videoURL];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorMusicPlayer:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:[MPMusicPlayerController systemMusicPlayer]];
	[[MPMusicPlayerController systemMusicPlayer] beginGeneratingPlaybackNotifications];
    
    timeElapsedLandscape = 0.0f;
    timeElapsedPortrait = 0.0f;
    lastTimeRemaining = 0;
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

-(NSTimeInterval)estimateProcessingTime:(NSURL*)processURL withType:(RendererType)renderType_ withFullFramerate:(BOOL)renderFullFrames
{
	// TODO: joe- this fps should come from the video itself.
	// Or better yet, just grab a total count of all frames in the video if possible.
	// it is assumed that videos recorded from the iPhone are usually very close to 30fps.
	float fps = 30.0f;
	
	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:processURL options:nil];
	NSUInteger movieFrames = CMTimeGetSeconds(movieAsset.duration)*fps;
	
	if (!renderFullFrames) {
		movieFrames = ceil((float)movieFrames / 2.0);
	}
	
    CGSize movieOriginSize = [AVAssetUtilities naturalSize:movieAsset];
	CGSize movieOutputSize = movieOriginSize;
	
	CGFloat smallestSupportHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?120:100;
	CGFloat smallestSupportWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?240:200;
	if (renderType_ == RendererTypeHalf && movieOriginSize.height>smallestSupportHeight && movieOriginSize.width>smallestSupportWidth)
		movieOutputSize = CGSizeMake(movieOriginSize.width/2.0, movieOriginSize.height/2.0);
	[renderer resetFrameSize:movieOriginSize outputFrameSize:movieOutputSize];
	estimateOutputSize = movieOutputSize;
	
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:movieAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];
	[avImageGenerator setMaximumSize:movieOriginSize];
	
	//render buffer
	CGImageRef estimateFrameRef =  [avImageGenerator copyCGImageAtTime:CMTimeMake(0, 600) actualTime:NULL error:NULL];
	unsigned char* estimateFrameData = malloc(movieOriginSize.width*movieOriginSize.height * glPixelSize);
	CGContextRef estimateFrameContext = CGBitmapContextCreate(estimateFrameData, movieOriginSize.width, movieOriginSize.height, 8, movieOriginSize.width * glPixelSize, CGImageGetColorSpace(estimateFrameRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(estimateFrameContext, kCGBlendModeCopy);
	CGContextDrawImage(estimateFrameContext, CGRectMake(0.0, 0.0, movieOriginSize.width, movieOriginSize.height), estimateFrameRef);
	CGImageRelease(estimateFrameRef);
	CGContextRelease(estimateFrameContext);

	//rendering
	NSTimeInterval singleFrameRenderStartTime = [NSDate timeIntervalSinceReferenceDate];
	[renderer frameProcessing:estimateFrameData toDest:estimateFrameData flipPixel:YES];
	estimateFrameProcessTime = [NSDate timeIntervalSinceReferenceDate]-singleFrameRenderStartTime;
	
	// NOTE: joe- this appears to be a scale factor that is applied to the eestimate.  Not sure where this is coming from ??
	// This could be a factor of how much time is spend doing other things during the process loop.
	// When the profiling the app, the frame rendering is approximately 66% of the time.
	estimateClipProcessTime = 0.37;		


	NSTimeInterval estimateRenderTimeRemaining = estimateFrameProcessTime*movieFrames+ceil(movieFrames/fps)*estimateClipProcessTime;
	NSLog(@"Estimated Render Time: %f seconds", estimateRenderTimeRemaining);
	
	free(estimateFrameData);
	
	return estimateRenderTimeRemaining;
}

- (void) exportAction:(id)sender{
	@autoreleasepool {
        
		self.renderStartTime = [NSDate timeIntervalSinceReferenceDate];
	
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
        [self.delegate videoTimeRemaining:timeRemaining];
	}
}


- (void)updateTime:(id)sender
{
	//	NSLog(@"Last time:%d, last frame:%d, complete frame:%d!",timeRemaining,(NSUInteger)(_totalFrames-_completedFrames),_completedFrames);
	timeRemaining = (int)[self estimateProcessingTimebyFrame:(NSUInteger)(_totalFrames-_completedFrames)];
	if(timeRemaining<0)
        timeRemaining=0;
    
    [self.delegate videoTimeRemaining:timeRemaining];
	//[timeView setTimeRemaining:timeRemaining isInit:NO];
}

- (void)updateCompose:(id)sender
{
	//[composeProgressView setTitleText:@"Composing%.2f%%" withProgress:[movieProcessor getComposeProgress]*100];
}

- (void)reset
{
	[renderer unloadKeyFrame];
}

- (void)startRenderInBackground {
	
	if(_completedFrames==0)
	{
		[self performSelectorInBackground:@selector(exportAction:) withObject:nil]; //bret this starts rendering
		
		if( gettimeofday( &lastUpdate, NULL) != 0 )
		{
			NSAssert(0, @"ERROR: gettimeofday()");
		}
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
	}
}

-(void)cleanController
{
	if(timer)
	{
		[timer invalidate];
		timer = nil;
	}
	if(movieProcessor)
	{
		movieProcessor = nil;
	}
	self.renderer = nil;
}

- (void)dealloc
{
    [self cleanController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	//**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskResume" object:nil];
	//**[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultiTaskPause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BecomeActiveResume" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResignActivePause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoWasShared" object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:[MPMusicPlayerController systemMusicPlayer]];
	[[MPMusicPlayerController systemMusicPlayer] endGeneratingPlaybackNotifications];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


#pragma mark -
#pragma mark MovieProcessorDelegate 
-(CVPixelBufferRef)processVideoFrame:(CMSampleBufferRef)sampleBuffer atTime:(CMTime)sampleTime
{
	@autoreleasepool { //bret
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
                
                [self.delegate videoTimeElapsed:timeElapsedPortrait landscape:timeElapsedLandscape];
            }
        });
	return pixelBuffer;
	}
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
		timer = nil;
	}
	
	NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
	measuredTotalRenderTime = curTime - renderStartTime;
	
	processedMoviePath = [[NSString alloc] initWithString:processFilePath];
    
    NSURL* processedURL = [NSURL fileURLWithPath:processedMoviePath];
//    AVAsset* avAsset = [[AVURLAsset alloc] initWithURL: options:nil];
//    mVideoDuration = avAsset.duration;
    
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
    
    [self.delegate videoFinishedProcessing:processedURL];
}

-(void)finishSaveToCameraRollEventAfterDelay:(id)sender
{
    
}

-(void)finishSaveToCameraRollEvent
{
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finishSaveToCameraRollEventAfterDelay:) userInfo:nil repeats:NO];
}

-(void)checkPointRenderMovieEvent
{
	NSLog(@"Video Clip Check Point!");
	CMTimeRange processRange = [movieProcessor getProcessRange];
	_completedFrames = (int)(processRange.start.value/20);
}

-(void)cancelRenderMovieEvent
{
	NSLog(@"Video Stop!");
}

#pragma mark -
#pragma mark MultiTaskHandle 
-(void)pauseToMultiTask
{
	//if(!isAppActive) return;
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
    if([movieProcessor getProcessState]==MovieStatePause || [movieProcessor getProcessState]==MovieStateRenderEnd)
	{
        framePastedFromPause = 0;
        
        // HISTORICAL: they displayed an alert saying "
        // Welcome Back! Movie Looks will resume rendering where it left off when you last quit the app.
	}
}

-(void)pauseToDisactive
{	
	[self pauseToMultiTask];
	isAppActive = NO;
}

-(void)resumeToActive
{
	isAppActive = YES;
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
    
    // HISTORICAL: another alert asking if they want to resume
}

-(void)monitorMusicPlayer:(id)sender
{
	// NSLog(@"ddddd");
	MPMusicPlayerController* iPodPlayer =[MPMusicPlayerController systemMusicPlayer];
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

- (void) homeAction:(id)sender
{
    // when they hit home
//        [self cleanController];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil];
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToVideo" object:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil];
    
    // otherwise say "Are you sure?" to tell them it isn't saved
}

// Example of using share controller with custom youtube sharing
//- (void) shareAction:(id)sender
//{
//    NSURL *url = [NSURL fileURLWithPath:processedMoviePath];
//    NSArray* dataToShare = [NSArray arrayWithObjects:url,nil];
//    
//    YoutubeActivity *youtubeactivity = [[YoutubeActivity alloc]init];
//    youtubeactivity.mThumbImage = mThumbImageView.image;
//    youtubeactivity.processedMoviePath = processedMoviePath;
//    
//    NSArray* customactivities = [NSArray arrayWithObjects:youtubeactivity,nil];
//
//    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
//                                                                                         applicationActivities:customactivities];
//
//
//    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray * returnedItems, NSError * error)
//    {
//        bool activityTypeFound = false;
//        NSString *notificationString;
//        if (completed)
//        {
//            isVideoSavedorShared  = YES;
//            
//            if ([activityType rangeOfString:@"cameraroll" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                activityTypeFound = true;
//                notificationString = @"Your movie was saved to the Camera Roll.";
//                //if (!isVideoSavedorShared)
//                //    [self finishSaveToCameraRollEvent];
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"facebook" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Facebook.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"youtube" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Youtube.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"vimeo" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Vimeo.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"flickr" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Flickr.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if ([activityType rangeOfString:@"weibo" options:NSCaseInsensitiveSearch].location != NSNotFound)
//            {
//                notificationString = @"Your movie was uploaded to Weibo.";
//                activityTypeFound = true;
//                NSLog(@"bret Camera Roll");
//            }
//            if (!activityTypeFound)
//            {
//                notificationString = @"Your movie was sucessfully uploaded.";
//            }
//        }
//    }];
//    
//    [self presentViewController:activityViewController animated:TRUE completion:nil];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the iPod pause stuff
//	if(alertView.tag == 50)
//	{
//		isAlertViewShown = NO;
//		if (buttonIndex == 0)
//		{
//			//pause the ipod
//			NSLog(@"Pause Music");
//			MPMusicPlayerController* iPodPlayer =[MPMusicPlayerController systemMusicPlayer];
//			if(iPodPlayer.playbackState == MPMoviePlaybackStatePlaying)
//				[iPodPlayer pause];
//			
//			if([movieProcessor getProcessState]==MovieStatePause)
//			{	
//				[movieProcessor resumeRenderMovie];
//				CMTimeRange processRange = [movieProcessor getProcessRange];
//				_completedFrames = (int)(processRange.start.value/20);
//			}
//			else if([movieProcessor getProcessState]==MovieStateRenderEnd)
//				[self finishRenderMovieEvent];
//		}
//	}
    
    
    // The resume from background stuff?
//	else if(alertView.tag == 100)
//	{
//		isAlertViewShown = NO;
//		if (buttonIndex == 0)
//		{
//			isAlertViewShown = NO;
//			if([movieProcessor getProcessState]==MovieStatePause)
//			{	
//				[movieProcessor resumeRenderMovie];
//				CMTimeRange processRange = [movieProcessor getProcessRange];
//				_completedFrames = (int)(processRange.start.value/20);
//			}
//			else if([movieProcessor getProcessState]==MovieStateRenderEnd)
//				[self finishRenderMovieEvent];
//		}
//	}
    
    
    // not sure what this is
//	else if(alertView.tag == 300)
//	{
//		isAlertViewShown = NO;
//		if (buttonIndex == 1)
//		{
//			//stop the timer
//			if(timer)
//			{
//				[timer invalidate];
//				timer = nil;
//			}
//			if ([movieProcessor getProcessState]==MovieStateRendering  || [movieProcessor getProcessState]==MovieStateResume)
//				[movieProcessor stopRenderMovie];
//			else if([movieProcessor getProcessState]==MovieStateCompose)
//				[movieProcessor stopComposeMovie];
//		}
//	}
    
//    //bret safe tags start at 500
//    else if (alertView.tag == 500)
//    {
//		isAlertViewShown = NO;
//		if(buttonIndex == 1)
//        {
//            if (mPlayer != Nil)
//            {
//                [self clearPlayer];
//            }
//            [self cleanController];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseRender" object:nil];
//            //[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToVideo" object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil];
//        }
//    }
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

- (void)errorSamplerMovieEvent {
    // don't know what this means
    NSLog(@"ERROR: sampler movie event");
}

@end
