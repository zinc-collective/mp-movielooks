//
//  MovieProcessor.m
//  MobileLooks
//
//  Created by Chen Mike on 1/19/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "MovieProcessor.h"
#import "Utilities.h"
#import "AVAssetUtilities.h"

@implementation MovieProcessor
@synthesize delegate=_delegate;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

-(BOOL)checkFor720P:(float*)frameCount
{
	return NO;
}

- (id)initWithReadURL:(NSURL*)readURL
{
    if (!(self = [super init])) return nil;
		
	tempWriteMoviePath = nil;	
	//bret movielooks update
	prevWriteMoviePath = nil;

    readMovieURL = readURL;
    //bret
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
	readMovieAsset = [[AVURLAsset alloc] initWithURL:readMovieURL options:options];
	//readMovieAsset = [[AVURLAsset alloc] initWithURL:readMovieURL options:nil];
	//
    sizeAVMediaInput =	[AVAssetUtilities naturalSize:readMovieAsset];
	durationAVAsset = [readMovieAsset duration];
	
	avMovieCondition = [[NSCondition alloc] init];
	
	subMovieIndex = 1;
    subMovieStarts[0] = kCMTimeZero;
	movieRenderState = MovieStateReady;
	return self;
}


#pragma mark -
#pragma mark MovieProcess

-(void)waitCompleteThreadWithoutAudio
{
	@autoreleasepool {
	
		[avMovieCondition lock];
		while(!(avVideoProcessCompleted||avVideoProcessPaused|| avVideoProcessStoped || avVideoProcessCheckPoint))
			[avMovieCondition wait];
        if(avVideoProcessCompleted) {
			[self finishRenderMovie];
        }
        else if (avVideoProcessCheckPoint) {
            [self stopMovieSessionWithoutAudioWithCompletionHandler:^{
    			[self resumeRenderMovie];
    			[self.delegate checkPointRenderMovieEvent];
            }];
        }
        else {
            [self stopMovieSessionWithoutAudioWithCompletionHandler:^{}];
        }
        
		if(movieRenderState==MovieStateSamplerError)
		{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate errorSamplerMovieEvent];
            });
		}
        
		if(avVideoProcessStoped)
		{	
			//[self cancelMovieSessionWithoutAudio];
			[self.delegate cancelRenderMovieEvent]; 		
		}
        
		[avMovieCondition unlock];	
	
	}
}

-(BOOL)checkVideoTrack:(AVAsset*)movieAsset
{
	if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]<=0)
        return NO;
	if(subMovieStarts[subMovieIndex].value-subMovieStarts[subMovieIndex-1].value<=0)
        return NO;
//	if([[movieAsset tracksWithMediaType:AVMediaTypeAudio] count]<=0) return NO;
	return YES;
}

- (BOOL)movieStateIsStopped {
    enum MovieProcessState state = movieRenderState;
    return (state == MovieStatePause || state == MovieStateCheckPoint || state == MovieStateSamplerError || state == MovieStateStop || avMovieReader.status == AVAssetReaderStatusCompleted);
}

-(void)renderNextVideoFrame
{
//	@try{
    
    if (self.movieStateIsStopped) {
    	[avVideoWriterInput markAsFinished];
     	if(movieRenderState==MovieStatePause)
		{
            [self setCondition:^{
                avVideoProcessPaused = YES;
            }];
		}
		else if(movieRenderState==MovieStateCheckPoint)
		{
            [self setCondition:^{
                avVideoProcessCheckPoint = YES;
            }];
		}
		else if(movieRenderState==MovieStateSamplerError)
		{
            [self setCondition:^{
                avVideoProcessStoped = YES;
            }];
		}
		else if(movieRenderState==MovieStateStop)
		{
            [self setCondition:^{
                avVideoProcessStoped = YES;
            }];
		}
		
		else if(avMovieReader.status == AVAssetReaderStatusCompleted)
		{
            [self setCondition:^{
                avVideoProcessCompleted = YES;
            }];
		}
        
        return;
    }
    
	
		
		
		CMSampleBufferRef avVideoSampleBufferRef = [avVideoReaderOutput copyNextSampleBuffer];
		
		if(avVideoSampleBufferRef)
		{
			
			CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(avVideoSampleBufferRef);
			lastSampleTimeRange = CMTimeRangeFromTimeToTime(lastSampleTime, CMTimeRangeGetEnd(lastSampleTimeRange));
			 NSLog(@"Video Rendering at Time(%lld,%d)!",lastSampleTime.value,lastSampleTime.timescale);

			CVPixelBufferRef avVideoPixelBufferRef = [self.delegate processVideoFrame:avVideoSampleBufferRef atTime:lastSampleTime];
			if(avVideoPixelBufferRef)
			{	
				[avMoviePixelBufferAdaptor appendPixelBuffer:avVideoPixelBufferRef withPresentationTime:lastSampleTime];
				CFRelease(avVideoPixelBufferRef);
			}
			else 
			{
				// this frame should be skipped, don't include it.
				
				// we weren't able to process or modify this frame, just pass it through
				// [avVideoWriterInput appendSampleBuffer:avVideoSampleBufferRef];
			}
			
			CFRelease(avVideoSampleBufferRef);
		}
		else if(lastSampleTimeRange.duration.value<20)
        {
			NSLog(@"Video Rendering last Time(%lld,%d)!",lastSampleTimeRange.duration.value, lastSampleTimeRange.duration.timescale);
            
            [avVideoWriterInput markAsFinished];

            [avMovieCondition lock];
            avVideoProcessCompleted = YES;
            [avMovieCondition signal];
            [avMovieCondition unlock];
        }
}

-(void)setCondition:(void (^)(void))setBlock
{
	[avMovieCondition lock];
    setBlock();
	[avMovieCondition signal];
	[avMovieCondition unlock];
}

-(void)renderNextAudioFrame
{
	@try{
		if(movieRenderState==MovieStatePause) 
		{
			[avAudioWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avAudioProcessPaused = YES;
			[avMovieCondition	signal];
			[avMovieCondition unlock];
			
			return;
		}
		if(movieRenderState==MovieStateCheckPoint)
		{
			[avAudioWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avAudioProcessCheckPoint = YES;
			[avMovieCondition	signal];
			[avMovieCondition unlock];
			
			return;
		}
		if(movieRenderState==MovieStateSamplerError)
		{
			[avAudioWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avAudioProcessStoped = YES;
			[avMovieCondition	signal];
			[avMovieCondition unlock];
			
			return;
		}		
		if(movieRenderState==MovieStateStop)
		{
			[avAudioWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avAudioProcessStoped = YES;
			[avMovieCondition	signal];
			[avMovieCondition unlock];
			
			return;
		}
		
		CMSampleBufferRef avAudioSampleBufferRef = [avAudioReaderOutput copyNextSampleBuffer];
		if(avAudioSampleBufferRef)
		{
			[avAudioWriterInput appendSampleBuffer:avAudioSampleBufferRef];
			CFRelease(avAudioSampleBufferRef);
		}
		else
		{
			[avAudioWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avAudioProcessCompleted = YES;
			[avMovieCondition	signal];
			[avMovieCondition unlock];
		}
	}
	@catch (NSException* exc) {
		NSLog(@"%@",exc.reason);
	}
	
}


-(BOOL)startMovieSessionWithoutAudio
{
//	NSTimeInterval renderTime = [NSDate timeIntervalSinceReferenceDate];
//	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:readMovieURL options:nil];
//	@try{

//	if([[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)return NO;
//	sizeAVMediaInput =	[readMovieAsset naturalSize];
    if(self.delegate) {
		AVAssetTrack *clipVideoTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
		sizeAVMediaOutput = [self.delegate knownVideoInfoEvent:sizeAVMediaInput withDuration:durationAVAsset transform:clipVideoTrack.preferredTransform];
	}
//	@catch (NSException *exc) {
//		NSLog(@"22222");
//	}
	NSError* error=nil;	
	NSString* stringAVMediaTypeVideo =	AVFileTypeQuickTimeMovie;//[[[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] mediaType];	
	
    NSLog(@"Start Movie Session Without Audio: %@", tempWriteMoviePath);
	avMovieWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:tempWriteMoviePath] fileType:stringAVMediaTypeVideo error:&error];
	if(error)
	{	NSLog(@"AVAssetWriter setup error:%@",[error localizedFailureReason]);
	}		
	
	avMovieReader = [AVAssetReader assetReaderWithAsset:readMovieAsset error:&error];
	if(error)
	{	NSLog(@"AVAssetReader setup error:%@",[error localizedFailureReason]);
	}
	
	AVAssetTrack *clipVideoTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	
	if(movieRenderState==MovieStateRendering)
		lastSampleTimeRange = clipVideoTrack.timeRange;
    
    //bret movielooks update
    if (subMovieIndex == 1)
        totalDurationTime.value = clipVideoTrack.timeRange.duration.value;
    //end
    
//	[movieAsset release];
	
	NSLog(@"Start Render CMTime(%lld,%d)---CMTimeDuration(%lld,%d)",lastSampleTimeRange.start.value,lastSampleTimeRange.start.timescale,lastSampleTimeRange.duration.value,lastSampleTimeRange.duration.timescale);
	
    //bret movielooks update
    if (subMovieIndex > 1)
    {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:prevWriteMoviePath] options:nil];
        //NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        //AVAssetTrack *track = [tracks objectAtIndex:0];
        CMTime currentduration = asset.duration;
        if (!backfromPause)
            currentStartTime.value += currentduration.value;
        lastSampleTimeRange = CMTimeRangeMake(CMTimeMake(currentStartTime.value, 600),CMTimeMake(totalDurationTime.value - currentStartTime.value, 600));
    }
    backfromPause = NO;
    //end
	avMovieReader.timeRange = lastSampleTimeRange;
	
	// add the avMovieReader => avVideoReaderOutput hook
	{
		NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,nil];
		avVideoReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:clipVideoTrack outputSettings:videoReaderSettings];
		if([avMovieReader canAddOutput:avVideoReaderOutput]) {
			[avMovieReader addOutput:avVideoReaderOutput];
		}
	}
	
	// add the avVideoWriterInput => avMovieWriter hook
	{	
		NSDictionary* videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,	AVVideoCodecKey,
											 [NSNumber numberWithInt:sizeAVMediaOutput.width],				AVVideoWidthKey,
											 [NSNumber numberWithInt:sizeAVMediaOutput.height],				AVVideoHeightKey,nil];
		avVideoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoWriterSettings];
		avVideoWriterInput.expectsMediaDataInRealTime = NO;
		if([avMovieWriter canAddInput:avVideoWriterInput]) {
			[avMovieWriter addInput:avVideoWriterInput];
		}
	}
	
	
	avMoviePixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:avVideoWriterInput sourcePixelBufferAttributes:NULL];
	
	dispatch_queue_t avMovieSerialQueue = dispatch_queue_create("AVAssetWriterMovieQueue", 0);	
	[avMovieReader startReading];	
	if([avMovieWriter startWriting]){
		[avMovieWriter startSessionAtSourceTime:lastSampleTimeRange.start];
		
		[avVideoWriterInput requestMediaDataWhenReadyOnQueue:avMovieSerialQueue usingBlock:^{			
			while ([avVideoWriterInput isReadyForMoreMediaData])
				[self renderNextVideoFrame];
		}];
		[NSThread detachNewThreadSelector:@selector(waitCompleteThreadWithoutAudio) toTarget:self withObject:nil];
//		renderTime = [NSDate timeIntervalSinceReferenceDate]-renderTime;
//		NSLog(@"Start Time:%f",renderTime);
		return YES;
	}
	else
	{
		if(avMovieReader.status == AVAssetReaderStatusFailed)
			NSLog(@"Reader Error:%@", [avMovieReader.error description]);
		if(avMovieWriter.status == AVAssetWriterStatusFailed)
			NSLog(@"Writter Error:%@", [avMovieWriter.error description]);
		return NO;
	}
}

+(BOOL)checkMovieSession:(NSURL*)movieURL
{
	BOOL hasPadding = NO;
	AVAsset* movieAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];

	NSError* error=nil;	
	AVAssetReader* movieReader = [AVAssetReader assetReaderWithAsset:movieAsset error:&error];
	AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	
	movieReader.timeRange = clipVideoTrack.timeRange;

		NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,nil];		
		AVAssetReaderTrackOutput* videoReaderOutput  = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:clipVideoTrack outputSettings:videoOutputSettings];
		if([movieReader canAddOutput:videoReaderOutput])
			[movieReader addOutput:videoReaderOutput];

	[movieReader startReading];	
	CMSampleBufferRef videoSampleBufferRef = [videoReaderOutput copyNextSampleBuffer];
	CVImageBufferRef videoImageBufferRef = CMSampleBufferGetImageBuffer(videoSampleBufferRef);
	{
		CVPixelBufferLockBaseAddress(videoImageBufferRef,0);
		CGSize bufferSize = CVImageBufferGetEncodedSize(videoImageBufferRef);
		size_t bytesPerRow = CVPixelBufferGetBytesPerRow(videoImageBufferRef);
		NSLog(@"Buffer Size(%f,%f) BytesPerRow:%zu",bufferSize.width,bufferSize.height,bytesPerRow);
		CVPixelBufferUnlockBaseAddress(videoImageBufferRef,0);
		CFRelease(videoSampleBufferRef);
		if(bytesPerRow>bufferSize.width*4)
			hasPadding = YES;
	}
	[movieReader cancelReading];	
	
	return !hasPadding;
}


-(BOOL)composeMovieSessionWithoutAudio
{	
	AVMutableComposition* compositionMovieAsset = [AVMutableComposition composition];
	AVMutableCompositionTrack *compositionVideoTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *compositionAudioTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
	
    CMTime finalduration = kCMTimeZero;
    CMTime currentduration;
    
    int skipped = 0;
    for (int i=1; i <= subMovieIndex; ++i)
    {
        CMTimeRange clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(subMovieStarts[i].value-subMovieStarts[i-1].value, 600));
        
        // skip tiny ones at the end
        if(clipTimeRange.duration.value<20) {
            skipped++;
            continue;
        }
        
        NSString* subMovieName = [NSString stringWithFormat:@"Sub%i_%@",i,@"bullet_movie.mov"];
        //bret
        //AVMutableVideoComposition's frameDuration
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:options];
        
        NSLog(@"ASSETS %@ %@", subMovieName, movieAsset);
        
        //bret debug test
        //AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        currentduration = movieAsset.duration;
        finalduration.value += currentduration.value;
        clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(currentduration.value, 600));
        
        //overrideo
        //AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:nil];
        //end bret
        if(movieAsset==nil) NSLog(@"Sub clip %@ not exit!",subMovieName);
        NSLog(@"MOVIE ASSET %lu", (unsigned long)[[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]);
        
        // if the track is missing video clips, we have an issue
        if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]<=0) {
            NSLog(@"Sub clip%d video render error!",i);
            
            // unless it is the last track, which sometimes is tiny and created without anything in it
            if (i == subMovieIndex) {
                skipped++;
                continue;
            }
            else {
                return NO;
            }
        }
        
        AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTrack insertTimeRange:clipTimeRange ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        NSLog(@"Clip %d:CMTime(%lld,%d)---CMTimeDuration(%lld,%d)",i,nextClipStartTime.value,nextClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
        nextClipStartTime = CMTimeAdd(nextClipStartTime, clipTimeRange.duration);
    }
		
    CMTime audioClipStartTime = kCMTimeZero;
	CMTimeRange clipTimeRange = CMTimeRangeMake(audioClipStartTime,CMTimeMake(subMovieStarts[subMovieIndex-skipped].value-subMovieStarts[0].value, 600));

    //AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:readMovieURL options:nil];
	AVAssetTrack *clipVideoTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform;
    
    if([[readMovieAsset tracksWithMediaType:AVMediaTypeAudio] count]>0)
	{
		AVAssetTrack *clipAudioTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
		[compositionAudioTrack insertTimeRange:clipTimeRange ofTrack:clipAudioTrack atTime:CMTimeMake(0, 600) error:nil];
		NSLog(@"Clip audio:CMTime(%lld,%d)---CMTimeDuration(%lld,%d)",audioClipStartTime.value,audioClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
	}
    
    //bret render issue force recode
    //avComposeSession = [[AVAssetExportSession alloc] initWithAsset:compositionMovieAsset presetName:AVAssetExportPresetHighestQuality];
    //CGSize sizeAVMediaInput;
    //CGSize sizeAVMediaOutput;
    NSString *outputsizeOption;
    //NSLog(@"bret outputwidth == %f",sizeAVMediaOutput.width);

//joe rendering issue 1080p
//this line forces 1080p video to be recoded at 720p and fixes the frame rate issue (all devices)
//#if 0
    if (sizeAVMediaOutput.width == 1920.0 || sizeAVMediaOutput.height == 1920.0)
        outputsizeOption = AVAssetExportPreset1920x1080;
        //outputsizeOption = AVAssetExportPreset1280x720;
//#endif
        else if (sizeAVMediaOutput.width == 1280.0 || sizeAVMediaOutput.height == 1280.0)
            outputsizeOption = AVAssetExportPresetHighestQuality;
        else if (sizeAVMediaOutput.width == 960.0 || sizeAVMediaOutput.height == 960.0)
            outputsizeOption = AVAssetExportPresetHighestQuality;
        else if (sizeAVMediaOutput.width == 640.0 || sizeAVMediaOutput.height == 640.0)
            outputsizeOption = AVAssetExportPreset640x480;
        else
            outputsizeOption = AVAssetExportPresetHighestQuality;
    
        //bret new test,for the black video, this fixes it
        //outputsizeOption = AVAssetExportPresetPassthrough;
        //
        avComposeSession = [[AVAssetExportSession alloc] initWithAsset:compositionMovieAsset presetName:outputsizeOption];
        //avComposeSession = [[AVAssetExportSession alloc] initWithAsset:compositionMovieAsset presetName:AVAssetExportPreset1280x720];
		avComposeSession.outputURL = [NSURL fileURLWithPath:tempWriteMoviePath];
		avComposeSession.outputFileType = AVFileTypeQuickTimeMovie;
		[avComposeSession exportAsynchronouslyWithCompletionHandler:^{
			NSLog(@"export result: %ld %@", (long)avComposeSession.status, avComposeSession.error );
            
            if(avComposeSession.error) {
                [self.delegate exportError:avComposeSession.error status:avComposeSession.status];
            }
            
			else if(movieRenderState == MovieStateCompose)
			{
				movieRenderState = MovieStateComplete;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate finishProcessMovieEvent:tempWriteMoviePath];
                });
			}
		}];
	return YES;
}

-(BOOL)stopMovieSessionWithoutAudioWithCompletionHandler:(void (^)(void))complete
{
//	NSTimeInterval renderTime = [NSDate timeIntervalSinceReferenceDate];
	
//	@try{
		CMTime lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value, 600);
		if(movieRenderState == MovieStatePause || movieRenderState == MovieStateCheckPoint || movieRenderState == MovieStateStop || movieRenderState == MovieStateSamplerError)
			lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value-(lastSampleTimeRange.start.value%300), 600);
		lastSampleTimeRange = CMTimeRangeFromTimeToTime(lastSampleTime, CMTimeRangeGetEnd(lastSampleTimeRange));
		
		subMovieStarts[subMovieIndex] = lastSampleTimeRange.start;
		NSLog(@"Stop w/o audio %lu at（%lld,%d） video frame!",(unsigned long)subMovieIndex,subMovieStarts[subMovieIndex].value,subMovieStarts[subMovieIndex].timescale);
		
        [avMovieWriter finishWritingWithCompletionHandler:complete];
		[avMovieReader cancelReading];
//	}
//	@catch (NSException* exc) {
//		NSLog(@"%@",[exc reason]); return NO;
//	}
	
    if(avMovieReader.status == AVAssetReaderStatusFailed) {
		NSLog(@"Reader Error:%@",[avMovieReader.error localizedDescription]);
    }
    
    if(avMovieWriter.status == AVAssetWriterStatusFailed) {
		NSLog(@"Writer Error:%@",[avMovieWriter.error localizedDescription]);
    }
	
	avVideoReaderOutput = nil;
	avVideoWriterInput = nil;
	avMovieReader = nil;
	avMovieWriter = nil;
//	renderTime = [NSDate timeIntervalSinceReferenceDate]-renderTime;
//	NSLog(@"Stop Time:%f",renderTime);
	return YES;
}

-(BOOL)cancelMovieSessionWithoutAudio
{
//	@try{		//	BOOL canwStopWriteSession = [avMovieWriter finishWriting];
		[avMovieWriter cancelWriting];
		[avMovieReader cancelReading];
//	}
//	@catch (NSException* exc) {
//		NSLog(@"%@",[exc reason]);
//	}
	
	avVideoReaderOutput = nil;
	avVideoWriterInput = nil;
	avMovieReader = nil;
	avMovieWriter = nil;
	return YES;
}

-(void)writeMovieToAlbum:(NSString*)writePath
{	
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	
	if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:[NSURL fileURLWithPath:writePath]]) {
		
		[assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:writePath] 
										  completionBlock:^(NSURL *assetURL, NSError *error){
											  dispatch_async(dispatch_get_main_queue(), ^{
												  if (error) {
													  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																										  message:[error localizedRecoverySuggestion]
																										 delegate:nil
																								cancelButtonTitle:@"OK"
																								otherButtonTitles:nil];
													  [alertView show];
												  }
                                                  [self.delegate finishSaveToCameraRollEvent];
											  });
											  
										  }];
	}
}

#pragma mark -
#pragma mark MovieOperator 
-(void)startRenderMovie//:(BOOL)withoutAudio
{
	subMovieIndex = 1;
    currentStartTime.value = 0; //bret movielooksupdate
	avVideoProcessCompleted = NO;
	avAudioProcessCompleted = NO;
	avVideoProcessPaused = NO;
	avAudioProcessPaused = NO;
	avVideoProcessStoped = NO;
	avAudioProcessStoped = NO;
	avVideoProcessCheckPoint = NO;
	avAudioProcessCheckPoint = NO;
	
	movieRenderState = MovieStateRendering;
	
	tempWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%i_%@", subMovieIndex,@"bullet_movie.mov"]];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSLog(@"Start render%@",tempWriteMoviePath);
	if([manager fileExistsAtPath:tempWriteMoviePath])
		[manager removeItemAtPath:tempWriteMoviePath error:nil];	
	
//	if(withoutAudio)
	[self startMovieSessionWithoutAudio];		
//	else		
//		[self startMovieSession];		
}

-(void)stopRenderMovie//:(BOOL)withoutAudio
{
	movieRenderState = MovieStateStop;
	
//	if(withoutAudio)
//	[self cancelMovieSessionWithoutAudio];
//	else
//		[self cancelMovieSession];
	
	tempWriteMoviePath = nil;
	 //bret movielooks update
	prevWriteMoviePath = nil;
}

-(void)pauseRenderMovie//:(BOOL)withoutAudio
{
	movieRenderState = MovieStatePause;
//	[self stopMovieSession];
//	[tempWriteMoviePath release];
//	tempWriteMoviePath = nil;
}

-(void)checkPointRenderMovie
{
    NSLog(@"Check Point Render Movie");
	movieRenderState = MovieStateCheckPoint;
}

-(void)errorSamplerRenderMovie
{
	movieRenderState = MovieStateSamplerError;
}

-(void)resumeRenderMovie//:(BOOL)withoutAudio
{
	backfromPause = NO;
    movieRenderState = MovieStateResume;
	{	
//		NSString* lastWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%i_%@",subMovieIndex,@"bullet_movie.mov"]];
//		AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:lastWriteMoviePath] options:nil];	
//		if(![self checkVideoTrack:movieAsset])
//        {
//			lastSampleTimeRange =  CMTimeRangeFromTimeToTime(subMovieStarts[subMovieIndex-1], CMTimeRangeGetEnd(lastSampleTimeRange));
//            backfromPause = YES;
//        }
//        else
			++subMovieIndex;
	}
	avVideoProcessPaused = NO;
	avAudioProcessPaused = NO;
	avVideoProcessCheckPoint = NO;
	avAudioProcessCheckPoint = NO;
	
	tempWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%i_%@", subMovieIndex, @"bullet_movie.mov"]];
	NSLog(@"Resume render %@",tempWriteMoviePath);
    //bret movielooks update
    if (subMovieIndex > 1 )
    {
        prevWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%i_%@",subMovieIndex-1,@"bullet_movie.mov"]];
    }
    
	NSFileManager *manager = [NSFileManager defaultManager];
	if([manager fileExistsAtPath:tempWriteMoviePath])
		[manager removeItemAtPath:tempWriteMoviePath error:nil];

//	if(withoutAudio)
	[self startMovieSessionWithoutAudio];		
//	else		
//		[self startMovieSession];
}

-(void)finishRenderMovie
{	
	movieRenderState = MovieStateRenderEnd;
	
    [self stopMovieSessionWithoutAudioWithCompletionHandler:^{
        NSLog(@"Finished writing");
        
    	tempWriteMoviePath = nil;

    	//bret movielooks update
    	prevWriteMoviePath = nil;
        
        //	if(subMovieIndex>1)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate finishRenderMovieEvent];
        });
        
    	//else
    	if(NO)
    	{	
    		movieRenderState = MovieStateComplete;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* path = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%i_%@",subMovieIndex,@"bullet_movie.mov"]];
                [self.delegate finishProcessMovieEvent:path];
            });
    	}
    }];
}

-(void)startComposeMovie//:(BOOL)withoutAudio
{
	movieRenderState = MovieStateCompose;

	
	
    //tempWriteMoviePath = [[Utilities documentsPath:@"bullet_movie_compose.mov"] retain];
	tempWriteMoviePath = [Utilities documentsPath:@"movie_looks.mov"];
	NSLog(@"Start compose %@",tempWriteMoviePath);

	NSFileManager *manager = [NSFileManager defaultManager];
	if([manager fileExistsAtPath:tempWriteMoviePath])
		[manager removeItemAtPath:tempWriteMoviePath error:nil];
	
	BOOL composeSucceed = NO;
//	if(withoutAudio)
		composeSucceed = [self composeMovieSessionWithoutAudio];
//	else
//		composeSucceed = [self composeMovieSession];
	if(!composeSucceed)
	{
		UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"Compose Error!"
															 message:@"These is some error in rendering movie, please retry!"
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
		[alertView show];
	}
}

-(void)pauseComposeMovie//:(BOOL)withoutAudio
{
	movieRenderState = MovieStateRenderEnd;	
	[avComposeSession cancelExport];
	avComposeSession = nil;
	
}

-(void)stopComposeMovie//:(BOOL)withoutAudio
{
	movieRenderState = MovieStateRenderEnd;	
	[avComposeSession cancelExport];
	avComposeSession = nil;
	[self.delegate cancelRenderMovieEvent];
}

-(NSUInteger)getProcessState
{
	return movieRenderState;
}

-(CGFloat)getComposeProgress
{
	return (movieRenderState==MovieStateCompose)?avComposeSession.progress:0.0;
}

-(CMTimeRange)getProcessRange
{
	return lastSampleTimeRange;
}

@end
