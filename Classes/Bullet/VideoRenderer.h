//
//  VideoRenderer
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
#import "ES2RendererOld.h"

#import "PlaybackView.h" //bret

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

@protocol VideoRenderDelegate
-(void)videoFinishedProcessing:(NSURL*)url;
-(void)videoCompletedFrames:(int)completed ofTotal:(int)total;
//-(void)videoTimeRemaining:(int)time;
//-(void)videoTimeElapsed:(float)portrait landscape:(float)landscape;
@end

@interface VideoRenderer : NSObject <MovieProcessorDelegate, MProgressViewDelegate> {
	
	RendererType renderType;
	BOOL		 renderFullFramerate;
    BOOL         isAppActive;
	
	CGSize				videoSize_;
	CGSize				outputSize;
	ES2RendererOld			*__weak renderer;
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
	
	struct timeval		lastUpdate;
	NSTimer				*timer;
	
	float				fStrengthValue;
	float				fBrightnessValue;
	BOOL				needCheckPoint;
	
	NSTimeInterval 			renderStartTime;
	NSTimeInterval			estimateFrameProcessTime;		// amount of time a single frame is expected to endure
	NSTimeInterval			estimateClipProcessTime;		// adjustment factor applied to estimates for a single frame
	NSTimeInterval			estimateTotalRenderTime;		// initial estimate of total render time
	NSTimeInterval 			measuredTotalRenderTime;		// the actual render time once  calculated
	CGSize					estimateOutputSize;
    CMTime			mVideoDuration;
	VideoMode				videoMode;
}

@property (nonatomic) VideoMode videoMode;
@property (nonatomic, weak) ES2RendererOld *renderer;
@property (nonatomic) float fStrengthValue;
@property (nonatomic) float fBrightnessValue;
@property (nonatomic) NSTimeInterval renderStartTime;
@property (nonatomic) NSTimeInterval estimateFrameProcessTime;
@property (nonatomic) NSTimeInterval estimateClipProcessTime;
@property (nonatomic) NSTimeInterval estimateTotalRenderTime;
@property (nonatomic) NSTimeInterval measuredTotalRenderTime;
@property (nonatomic, strong) UIImage *mThumbImage;

@property id<VideoRenderDelegate> __weak delegate;

-(void)setRendererType:(RendererType)type withFullFramerate:(BOOL)fullFramerate andLookParam:(NSDictionary*)lookDic;
- (void)load:(NSURL*)sourceVideoURL renderer:(ES2RendererOld*)rend videoMode:(VideoMode)mode brightness:(float)brightness strength:(float)strength rendererType:(RendererType)type fullFramerate:(BOOL)fullFramerate lookParam:(NSDictionary*)lookDic;
- (void)startRenderInBackground;
- (void)reset;
- (void)cancel;

@end
