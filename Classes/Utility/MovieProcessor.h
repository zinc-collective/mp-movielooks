//
//  MovieProcessor.h
//  MobileLooks
//
//  Created by Chen Mike on 1/19/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MovieProcessorDelegate
-(CVPixelBufferRef)processVideoFrame:(CMSampleBufferRef)sampleBuffer atTime:(CMTime)sampleTime;
-(CGSize)knownVideoInfoEvent:(CGSize)videoSize withDuration:(CMTime)duration;
-(void)checkPointRenderMovieEvent;
-(void)cancelRenderMovieEvent;
-(void)finishRenderMovieEvent;
-(void)errorSamplerMovieEvent;
-(void)finishProcessMovieEvent:(NSString*)composeFilePath;
-(void)finishSaveToCameraRollEvent;
@end


@interface MovieProcessor : NSObject {
	enum MovieProcessState
	{
		MovieStateReady,
		MovieStateStop,
		MovieStateRendering,
		MovieStatePause,
		MovieStateCheckPoint,
		MovieStateResume,
		MovieStateRenderEnd,
		MovieStateCompose,
		MovieStateComplete,
		MovieStateSamplerError,
	}movieRenderState;
	
	AVAssetReader		*avMovieReader;
	AVAssetReaderOutput *avVideoReaderOutput;
	AVAssetReaderOutput *avAudioReaderOutput;
	
	AVAssetWriter		*avMovieWriter;
	AVAssetWriterInput  *avVideoWriterInput;
	AVAssetWriterInput  *avAudioWriterInput;
	AVAssetWriterInputPixelBufferAdaptor* avMoviePixelBufferAdaptor;
	AVAssetExportSession *avComposeSession;
	NSCondition* avMovieCondition;	
	BOOL	avVideoProcessCompleted;
	BOOL	avAudioProcessCompleted;
	BOOL	avVideoProcessPaused;
	BOOL	avAudioProcessPaused;
	BOOL	avVideoProcessStoped;
	BOOL	avAudioProcessStoped;
	BOOL	avVideoProcessCheckPoint;
	BOOL	avAudioProcessCheckPoint;

	CMTimeRange	lastSampleTimeRange;
	CMTime durationAVAsset;
	CGSize sizeAVMediaInput;
	CGSize sizeAVMediaOutput;

	NSURL *readMovieURL;
	AVURLAsset *readMovieAsset;
	NSString *tempWriteMoviePath;
	NSString *prevWriteMoviePath; //bret movielooks update
    CMTime currentStartTime; //bret movielooks update
    CMTime totalDurationTime; //bret movielooks update
    BOOL backfromPause; //bret movielooks update
	int subMovieIndex;
	CMTime subMovieStarts[4096];
	id<MovieProcessorDelegate> __weak _delegate;
}

@property(nonatomic, weak) id<MovieProcessorDelegate> delegate;
-(id)initWithReadURL:(NSURL*)readURL;
-(void)writeMovieToAlbum:(NSString*)writePath;
-(void)startComposeMovie;
-(void)pauseComposeMovie;
-(void)stopComposeMovie;
-(void)startRenderMovie;
-(void)stopRenderMovie;
-(void)finishRenderMovie;
-(void)resumeRenderMovie;
-(void)pauseRenderMovie;
-(void)checkPointRenderMovie;
-(void)errorSamplerRenderMovie;

-(CMTimeRange)getProcessRange;
-(NSUInteger)getProcessState;
-(CGFloat)getComposeProgress;
+(BOOL)checkMovieSession:(NSURL*)movieURL;
-(BOOL)checkFor720P:(float*)frameCount;
@end
