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
#if 0
    if(TooHighForDevice(sizeAVMediaInput))
	{
		float fps = 30.0f;
		CMTime startTime = kCMTimeZero;
		CMTime endTime = readMovieAsset.duration;
		Float64 seconds =  CMTimeGetSeconds(endTime);
		*frameCount = floor(seconds*fps);
				
		//new trim path	
		NSString* tempTrimMoviePath = [[Utilities documentsPath:@"TempTrimMoviePath.mov"] retain];
		NSFileManager *manager = [NSFileManager defaultManager];
		if([manager fileExistsAtPath:tempTrimMoviePath])
			[manager removeItemAtPath:tempTrimMoviePath error:nil];
		
		AVAssetExportSession* avTrimSession = [AVAssetExportSession exportSessionWithAsset:readMovieAsset presetName:AVAssetExportPreset640x480];
		avTrimSession.timeRange = CMTimeRangeFromTimeToTime(startTime,endTime);
		avTrimSession.outputURL = [NSURL fileURLWithPath:tempTrimMoviePath];
		avTrimSession.outputFileType = AVFileTypeQuickTimeMovie;
		//update trim URL
		
		[avTrimSession exportAsynchronouslyWithCompletionHandler:^{
			NSLog(@"%@",[avTrimSession.error localizedDescription]);
			tempWriteMoviePath = nil;
			[readMovieURL release];
			[readMovieAsset release];

			readMovieURL = [[NSURL fileURLWithPath:tempTrimMoviePath] retain];
			readMovieAsset = [[AVURLAsset alloc] initWithURL:readMovieURL options:nil];
			sizeAVMediaInput =	[readMovieAsset naturalSize];
			durationAVAsset = [readMovieAsset duration];
			
			[self performSelectorOnMainThread:@selector(startRenderMovie) withObject:nil waitUntilDone:YES];
		}];
		return YES;
	}
#endif
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
	subMovieStarts[0] = CMTimeMake(0,600);
	movieRenderState = MovieStateReady;
	return self;
}


#pragma mark -
#pragma mark MovieProcess
/*
-(void)waitCompleteThread
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	[avMovieCondition lock];
	while(!((avVideoProcessCompleted||avVideoProcessPaused) && (avAudioProcessCompleted||avAudioProcessPaused)))
		[avMovieCondition wait];
	if(avVideoProcessCompleted&&avAudioProcessCompleted)
		[self finishRenderMovie:NO];
		//		[self performSelectorOnMainThread:@selector(finishRenderMovie) withObject:nil waitUntilDone:NO];
	else
		[self stopMovieSession];
//		[self performSelectorOnMainThread:@selector(stopMovieSession) withObject:nil waitUntilDone:NO];
	[avMovieCondition unlock];	
	
	[pool release];
}
*/
-(void)waitCompleteThreadWithoutAudio
{
	@autoreleasepool {
	
		[avMovieCondition lock];
		while(!(avVideoProcessCompleted||avVideoProcessPaused|| avVideoProcessStoped || avVideoProcessCheckPoint))
			[avMovieCondition wait];
		if(avVideoProcessCompleted)
			[self finishRenderMovie];
		//		[self performSelectorOnMainThread:@selector(finishRenderMovie) withObject:nil waitUntilDone:NO];
		else 
			[self stopMovieSessionWithoutAudio];	
		//		[self performSelectorOnMainThread:@selector(stopMovieSession) withObject:nil waitUntilDone:NO];
		if(movieRenderState==MovieStateSamplerError)
		{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate errorSamplerMovieEvent];
        });
		}
		if(avVideoProcessCheckPoint)
		{	
			[self resumeRenderMovie];
			[self.delegate checkPointRenderMovieEvent]; 
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


-(void)renderNextVideoFrame
{
//	@try{
		if(movieRenderState==MovieStatePause)
		{
			[avVideoWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avVideoProcessPaused = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
			return;
		}
		if(movieRenderState==MovieStateCheckPoint)
		{
			[avVideoWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avVideoProcessCheckPoint = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
			return;
		}
		if(movieRenderState==MovieStateSamplerError)
		{
			[avVideoWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avVideoProcessStoped = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
			return;
		}
		if(movieRenderState==MovieStateStop)
		{
			[avVideoWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avVideoProcessStoped = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
			return;
		}
		
		//NSLog(@"Movie Reader Status:%d",avMovieReader.status);
		
		if(avMovieReader.status == AVAssetReaderStatusCompleted)
		{
			[avVideoWriterInput markAsFinished];
			
			[avMovieCondition lock];
			avVideoProcessCompleted = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
			return;
		}
		
		
		
		CMSampleBufferRef avVideoSampleBufferRef = [avVideoReaderOutput copyNextSampleBuffer];
		
		if(avVideoSampleBufferRef)
		{
			
			CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(avVideoSampleBufferRef);
			lastSampleTimeRange = CMTimeRangeFromTimeToTime(lastSampleTime, CMTimeRangeGetEnd(lastSampleTimeRange));
			// NSLog(@"Video Rendering at Time(%d,%d)!",lastSampleTime.value,lastSampleTime.timescale);

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
			NSLog(@"Video Rendering last Time(%lld,%d)!",lastSampleTimeRange.duration.value,lastSampleTimeRange.duration.timescale);

			[avVideoWriterInput markAsFinished];
				
			[avMovieCondition lock];
			avVideoProcessCompleted = YES;
			[avMovieCondition signal];
			[avMovieCondition unlock];
		}

//	}
//	@catch (NSException* exc) {
//		NSLog(@"%@",exc.reason);
//	}	
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
/*
-(BOOL)startMovieSession
{
	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:readMoviePath] options:nil];	
	if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)return NO;
	sizeAVMediaInput =	[movieAsset naturalSize];
	sizeAVMediaOutput = [self.delegate knownVideoInfoEvent:sizeAVMediaInput withDuration:[movieAsset duration]];
	
	NSError* error=nil;	
	NSString* stringAVMediaTypeVideo =	AVFileTypeQuickTimeMovie;//[[[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] mediaType];	
	avMovieWriter = [[AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:tempWriteMoviePath] fileType:stringAVMediaTypeVideo error:&error] retain];
	if(error)
	{	NSLog(@"AVAssetWriter setup error:%@",[error localizedFailureReason]);
	}		
	avMovieReader = [[AVAssetReader assetReaderWithAsset:movieAsset error:&error] retain];
	if(error)
	{	NSLog(@"AVAssetReader setup error:%@",[error localizedFailureReason]);
	}

	AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVAssetTrack *clipAudioTrack = [[movieAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
	if(movieRenderState==MovieStateRendering)
		lastSampleTimeRange = clipVideoTrack.timeRange;
	[movieAsset release];
	
	NSLog(@"Start Render CMTime(%d,%d)---CMTimeDuration(%d,%d)",lastSampleTimeRange.start.value,lastSampleTimeRange.start.timescale,lastSampleTimeRange.duration.value,lastSampleTimeRange.duration.timescale);

	avMovieReader.timeRange = lastSampleTimeRange;
	{
	NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,nil];
	NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,nil];
		
	avVideoReaderOutput  = [[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:clipVideoTrack outputSettings:videoOutputSettings] retain];
	avAudioReaderOutput = [[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:clipAudioTrack outputSettings:audioOutputSettings] retain];
	if([avMovieReader canAddOutput:avVideoReaderOutput])
		[avMovieReader addOutput:avVideoReaderOutput];
	if([avMovieReader canAddOutput:avAudioReaderOutput])
		[avMovieReader addOutput:avAudioReaderOutput];
	}	
	AudioChannelLayout* al = (AudioChannelLayout *) calloc(0, sizeof(AudioChannelLayout));
	al->mChannelBitmap = 0;
	al->mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
	al->mNumberChannelDescriptions = 0;
	{	
	NSDictionary* videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,	AVVideoCodecKey,
										 [NSNumber numberWithInt:sizeAVMediaOutput.width],				AVVideoWidthKey,
										 [NSNumber numberWithInt:sizeAVMediaOutput.height],				AVVideoHeightKey,nil];
	NSDictionary* audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
										 [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
										 [NSNumber numberWithInt:44100.0],AVSampleRateKey,
										 [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,
										 //[NSNumber numberWithInt:96],AVEncoderBitRateKey,
										 //[NSNumber numberWithInt:16],AVEncoderBitDepthHintKey,
										 [NSData dataWithBytes:al length:sizeof(AudioChannelLayout)+1],AVChannelLayoutKey, 
										 //AVChannelLayoutKey,AVChannelLayoutKey,
										 [NSNumber numberWithInt:16],	AVLinearPCMBitDepthKey,
										 [NSNumber numberWithBool:NO],	AVLinearPCMIsBigEndianKey,
										 [NSNumber numberWithBool:NO],	AVLinearPCMIsFloatKey,
										 [NSNumber numberWithBool:NO],	AVLinearPCMIsNonInterleaved,nil];
		
		
		avVideoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings];
		avAudioWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
		avVideoWriterInput.expectsMediaDataInRealTime = NO;
		avAudioWriterInput.expectsMediaDataInRealTime = NO;
		if([avMovieWriter canAddInput:avVideoWriterInput])
			[avMovieWriter addInput:avVideoWriterInput];
		if([avMovieWriter canAddInput:avAudioWriterInput])
			[avMovieWriter addInput:avAudioWriterInput];
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
		[avAudioWriterInput requestMediaDataWhenReadyOnQueue:avMovieSerialQueue usingBlock:^{
			while ([avAudioWriterInput isReadyForMoreMediaData])
				[self renderNextAudioFrame];
		}];
		[NSThread detachNewThreadSelector:@selector(waitCompleteThread) toTarget:self withObject:nil];
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

-(BOOL)composeMovieSession
{	
	@try{
		AVMutableComposition* compositionMovieAsset = [AVMutableComposition composition];
		AVMutableCompositionTrack *compositionVideoTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
		AVMutableCompositionTrack *compositionAudioTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
		CMTime nextClipStartTime = CMTimeMake(0, 600);

		for (int i=1; i <= subMovieIndex; ++i) {
			CMTimeRange clipTimeRange = CMTimeRangeMake(CMTimeMake(0, 600),CMTimeMake(subMovieStarts[i].value-subMovieStarts[i-1].value, 600));

			NSString* subMovieName = [NSString stringWithFormat:@"Sub%d_%@",i,@"bullet_movie.mov"];
			AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:nil];

			if(movieAsset==nil) NSLog(@"Sub clip %@ not exit!",subMovieName);
			if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]<=0) {NSLog(@"Sub clip%d video render error!",i); return NO;}
			if([[movieAsset tracksWithMediaType:AVMediaTypeAudio] count]<=0) {NSLog(@"Sub clip%d audio render error!",i); return NO;}

			AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
			AVAssetTrack *clipAudioTrack = [[movieAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
			[compositionVideoTrack insertTimeRange:clipTimeRange ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
			[compositionAudioTrack insertTimeRange:clipTimeRange ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
			NSLog(@"Clip %d:CMTime(%d,%d)---CMTimeDuration(%d,%d)",i,nextClipStartTime.value,nextClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
			nextClipStartTime = CMTimeAdd(nextClipStartTime, clipTimeRange.duration);

		}
			
		avComposeSession = [[AVAssetExportSession alloc] initWithAsset:compositionMovieAsset presetName:AVAssetExportPresetHighestQuality];
		avComposeSession.outputURL = [NSURL fileURLWithPath:tempWriteMoviePath];
		avComposeSession.outputFileType = AVFileTypeQuickTimeMovie;
		[avComposeSession exportAsynchronouslyWithCompletionHandler:^{
			if(movieRenderState == MovieStateCompose)	
			{
				movieRenderState = MovieStateComplete;
				[self.delegate performSelectorOnMainThread:@selector(finishProcessMovieEvent:) withObject:tempWriteMoviePath waitUntilDone:NO];
			}
		}];
	}
	@catch(NSException* exc)
	{
		NSLog(@"%@",[exc reason]); return NO;
	}
	return YES;
}

-(BOOL)stopMovieSession
{
	
	@try{
		CMTime lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value, 600);
		if(movieRenderState == MovieStatePause)
			lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value-(lastSampleTimeRange.start.value%300), 600);
		lastSampleTimeRange = CMTimeRangeFromTimeToTime(lastSampleTime, CMTimeRangeGetEnd(lastSampleTimeRange));

		subMovieStarts[subMovieIndex] = lastSampleTimeRange.start;
		NSLog(@"Stop %d at（%d,%d） video frame!",subMovieIndex,subMovieStarts[subMovieIndex].value,subMovieStarts[subMovieIndex].timescale);
		if(movieRenderState == MovieStatePause)
			++subMovieIndex;
		
		[avMovieWriter finishWriting];
		[avMovieReader cancelReading];
	}
	@catch (NSException* exc) {
		NSLog(@"%@",[exc reason]); return NO;
	}

	if(avMovieReader.status == AVAssetReaderStatusFailed)
		NSLog(@"Reader Error:%@",[avMovieReader.error localizedDescription]);
	if(avMovieWriter.status == AVAssetWriterStatusFailed)
		NSLog(@"Writer Error:%@",[avMovieWriter.error localizedDescription]);
	
	[avVideoReaderOutput release];
	[avAudioReaderOutput release];
	[avVideoWriterInput release];
	[avAudioWriterInput release];
	[avMovieReader release];
	[avMovieWriter release];
	[avMoviePixelBufferAdaptor release];
	
	avVideoReaderOutput = nil;
	avAudioReaderOutput = nil;
	avVideoWriterInput = nil;
	avAudioWriterInput = nil;
	avMovieReader = nil;
	avMovieWriter = nil;


	return YES;
}

-(BOOL)cancelMovieSession
{
	@try{		//	BOOL canwStopWriteSession = [avMovieWriter finishWriting];
		[avMovieWriter cancelWriting];
		[avMovieReader cancelReading];
	}
	@catch (NSException* exc) {
		NSLog(@"%@",[exc reason]);
	}
	[avVideoReaderOutput release];
	[avAudioReaderOutput release];
	[avVideoWriterInput release];
	[avAudioWriterInput release];
	[avMovieReader release];
	[avMovieWriter release];
	[avMoviePixelBufferAdaptor release];
	
	avVideoReaderOutput = nil;
	avAudioReaderOutput = nil;
	avVideoWriterInput = nil;
	avAudioWriterInput = nil;
	avMovieReader = nil;
	avMovieWriter = nil;
	return YES;
}
*/

-(BOOL)startMovieSessionWithoutAudio
{
//	NSTimeInterval renderTime = [NSDate timeIntervalSinceReferenceDate];
//	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:readMovieURL options:nil];
//	@try{

//	if([[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)return NO;
//	sizeAVMediaInput =	[readMovieAsset naturalSize];
	if(self.delegate)
		sizeAVMediaOutput = [self.delegate knownVideoInfoEvent:sizeAVMediaInput withDuration:durationAVAsset];
//	}
//	@catch (NSException *exc) {
//		NSLog(@"22222");
//	}
	NSError* error=nil;	
	NSString* stringAVMediaTypeVideo =	AVFileTypeQuickTimeMovie;//[[[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] mediaType];	
	
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
//	@try{
		AVMutableComposition* compositionMovieAsset = [AVMutableComposition composition];
		AVMutableCompositionTrack *compositionVideoTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
		AVMutableCompositionTrack *compositionAudioTrack = [compositionMovieAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
		CMTime nextClipStartTime = CMTimeMake(0, 600);
		
        //
        CMTime finalduration;
        finalduration.value  = 0;
        finalduration.timescale  = 600;
        CMTime currentduration;
        //
#if 0
        for (int i=1; i <= subMovieIndex; ++i)
        {
			CMTimeRange clipTimeRange = CMTimeRangeMake(CMTimeMake(0, 600),CMTimeMake(subMovieStarts[i].value-subMovieStarts[i-1].value, 600));
            if(clipTimeRange.duration.value<20) continue;
			
			NSString* subMovieName = [NSString stringWithFormat:@"Sub%d_%@",i,@"bullet_movie.mov"];
			//bret
            //AVMutableVideoComposition's frameDuration
            NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
            AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:options];

			//bret debug test
            //AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
            currentduration = movieAsset.duration;
            finalduration.value += currentduration.value;
            //
            
            //
            //AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:nil];
            //end bret
			if(movieAsset==nil) NSLog(@"Sub clip %@ not exit!",subMovieName);
			if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]<=0) {NSLog(@"Sub clip%d video render error!",i); return NO;}
			
			AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
			[compositionVideoTrack insertTimeRange:clipTimeRange ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
			NSLog(@"Clip %d:CMTime(%d,%d)---CMTimeDuration(%d,%d)",i,nextClipStartTime.value,nextClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
			nextClipStartTime = CMTimeAdd(nextClipStartTime, clipTimeRange.duration);			
		}
#endif
    for (int i=1; i <= subMovieIndex; ++i)
    {
        CMTimeRange clipTimeRange = CMTimeRangeMake(CMTimeMake(0, 600),CMTimeMake(subMovieStarts[i].value-subMovieStarts[i-1].value, 600));
        if(clipTimeRange.duration.value<20) continue;
        
        NSString* subMovieName = [NSString stringWithFormat:@"Sub%d_%@",i,@"bullet_movie.mov"];
        //bret
        //AVMutableVideoComposition's frameDuration
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:options];
        
        //bret debug test
        //AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        currentduration = movieAsset.duration;
        finalduration.value += currentduration.value;
        clipTimeRange = CMTimeRangeMake(CMTimeMake(0, 600),CMTimeMake(currentduration.value, 600));
        //clipTimeRange = CMTimeRangeMake(CMTimeMake(0, 600),CMTimeMake(currentduration.value - 20, 600)); //remove one frame
        //
        
        //
        //AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[Utilities documentsPath:subMovieName]] options:nil];
        //end bret
        if(movieAsset==nil) NSLog(@"Sub clip %@ not exit!",subMovieName);
        if([[movieAsset tracksWithMediaType:AVMediaTypeVideo] count]<=0) {NSLog(@"Sub clip%d video render error!",i); return NO;}
        
        AVAssetTrack *clipVideoTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTrack insertTimeRange:clipTimeRange ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        NSLog(@"Clip %d:CMTime(%lld,%d)---CMTimeDuration(%lld,%d)",i,nextClipStartTime.value,nextClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
        nextClipStartTime = CMTimeAdd(nextClipStartTime, clipTimeRange.duration);
    }
		
		CMTime audioClipStartTime = CMTimeMake(0, 600);
		CMTimeRange clipTimeRange = CMTimeRangeMake(audioClipStartTime,CMTimeMake(subMovieStarts[subMovieIndex].value-subMovieStarts[0].value, 600));

        //AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:readMovieURL options:nil];
		AVAssetTrack *clipVideoTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
		compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform;
//#if 0
        if([[readMovieAsset tracksWithMediaType:AVMediaTypeAudio] count]>0)
		{
			AVAssetTrack *clipAudioTrack = [[readMovieAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
			[compositionAudioTrack insertTimeRange:clipTimeRange ofTrack:clipAudioTrack atTime:CMTimeMake(0, 600) error:nil];
			NSLog(@"Clip audio:CMTime(%lld,%d)---CMTimeDuration(%lld,%d)",audioClipStartTime.value,audioClipStartTime.timescale,clipTimeRange.duration.value,clipTimeRange.duration.timescale);
		}
//#endif
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
//this would force 720p only on ipad
#if 0
    if (sizeAVMediaOutput.width == 1920.0 || sizeAVMediaOutput.height == 1920.0)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            outputsizeOption = AVAssetExportPreset1280x720;
        else
            outputsizeOption = AVAssetExportPreset1920x1080;
    }
#endif
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
			NSLog(@"export result: %@ %ld",[avComposeSession.error localizedDescription],(long)avComposeSession.status);
			if(movieRenderState == MovieStateCompose)	
			{
				movieRenderState = MovieStateComplete;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate finishProcessMovieEvent:tempWriteMoviePath];
                });
			}
		}];
//	}
//	@catch(NSException* exc)
//	{
//		NSLog(@"%@",[exc reason]); return NO;
//	}
	return YES;	
}

-(BOOL)stopMovieSessionWithoutAudio
{
//	NSTimeInterval renderTime = [NSDate timeIntervalSinceReferenceDate];
	
//	@try{
		CMTime lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value, 600);
		if(movieRenderState == MovieStatePause || movieRenderState == MovieStateCheckPoint || movieRenderState == MovieStateStop || movieRenderState == MovieStateSamplerError)
			lastSampleTime = CMTimeMake(lastSampleTimeRange.start.value-(lastSampleTimeRange.start.value%300), 600);
		lastSampleTimeRange = CMTimeRangeFromTimeToTime(lastSampleTime, CMTimeRangeGetEnd(lastSampleTimeRange));
		
		subMovieStarts[subMovieIndex] = lastSampleTimeRange.start;
		NSLog(@"Stop w/o audio %lu at（%lld,%d） video frame!",(unsigned long)subMovieIndex,subMovieStarts[subMovieIndex].value,subMovieStarts[subMovieIndex].timescale);
		
        [avMovieWriter finishWritingWithCompletionHandler:^{}];
		[avMovieReader cancelReading];
//	}
//	@catch (NSException* exc) {
//		NSLog(@"%@",[exc reason]); return NO;
//	}
	
	if(avMovieReader.status == AVAssetReaderStatusFailed)
		NSLog(@"Reader Error:%@",[avMovieReader.error localizedDescription]);
	if(avMovieWriter.status == AVAssetWriterStatusFailed)
		NSLog(@"Writer Error:%@",[avMovieWriter.error localizedDescription]);
	
	
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
	
	tempWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%lu_%@",(unsigned long)subMovieIndex,@"bullet_movie.mov"]];
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
		NSString* lastWriteMoviePath = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%lu_%@",(unsigned long)subMovieIndex,@"bullet_movie.mov"]];
		AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:lastWriteMoviePath] options:nil];	
		if(![self checkVideoTrack:movieAsset])
        {
			lastSampleTimeRange =  CMTimeRangeFromTimeToTime(subMovieStarts[subMovieIndex-1], CMTimeRangeGetEnd(lastSampleTimeRange));
            backfromPause = YES;
        }
        else
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

-(void)finishRenderMovie//:(BOOL)withoutAudio
{	
	movieRenderState = MovieStateRenderEnd;
	
//	if(withoutAudio)
	[self stopMovieSessionWithoutAudio];
//	else
//		[self stopMovieSession];
	
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
            NSString* path = [Utilities documentsPath:[NSString stringWithFormat:@"Sub%lu_%@",(unsigned long)subMovieIndex,@"bullet_movie.mov"]];
            [self.delegate finishProcessMovieEvent:path];
        });
	}
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
