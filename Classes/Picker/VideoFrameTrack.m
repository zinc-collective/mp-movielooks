//
//  VideoFrameTrack.m
//  MobileLooks
//
//  Created by jack on 8/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VideoFrameTrack.h"
#import "AVAssetUtilities.h"

//bret hd
@interface AVAsset (AsyncConvenience)

@property (nonatomic) CGSize mSize;
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue requestedTime:(NSValue*)requestedTime withBlock:(void (^)(CGImageRef thumbnail))block;
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue requestedTime:(NSValue*)requestedTime maxSize:(CGSize)maxSize withBlock:(void (^)(CGImageRef thumbnail))block;
@end

@implementation AVAsset (ThumbnailConvenience)
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue requestedTime:(NSValue*)requestedTime withBlock:(void (^)(CGImageRef thumbnail))block
{
	AVAssetImageGenerator* generator = [[AVAssetImageGenerator allocWithZone:NULL] initWithAsset:self];
	
	[generator setAppliesPreferredTrackTransform:YES];
	//[generator setMaximumSize:CGSizeMake(1920, 1080)];
	[generator setMaximumSize:CGSizeMake(1280, 720)];
	
	dispatch_retain(queue);
	
	[generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:requestedTime] completionHandler:
	 ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
	 {
		 CGImageRetain(image);
		 
		 //NSLog(@"actual got image at time:%f", CMTimeGetSeconds(requestedTime));
		 
		 dispatch_async(queue,
						^{
							block(image);
							
							CGImageRelease(image);
							dispatch_release(queue);
						});
		 
		 [generator release];
	 }];	
}

- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue requestedTime:(NSValue*)requestedTime  maxSize:(CGSize)maxSize withBlock:(void (^)(CGImageRef thumbnail))block
{
	AVAssetImageGenerator* generator = [[AVAssetImageGenerator allocWithZone:NULL] initWithAsset:self];
	
	[generator setAppliesPreferredTrackTransform:YES];
	[generator setMaximumSize:maxSize];
	
	dispatch_retain(queue);
	
	[generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:requestedTime] completionHandler:
	 ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
	 {
		 CGImageRetain(image);
		 
		 //NSLog(@"actual got image at time:%f", CMTimeGetSeconds(requestedTime));
		 
		 dispatch_async(queue,
						^{
							block(image);
							
							CGImageRelease(image);
							dispatch_release(queue);
						});
		 
		 [generator release];
	 }];	
}

@end


@implementation VideoFrameTrack

- (id)initWithURL:(NSURL*)URL
{
	mDuration = kCMTimeZero;
	if (!URL)
		return [super init];
	
	if ((self = [super init]))
	{
		NSZone* zone = [self zone];
		
		mURL = [URL copyWithZone:zone];
		
	}
	
	return self;
}

- (id)init
{
	return [self initWithURL:nil];
}

- (void) trackMiddleKeyFrame{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   ^{
					   AVAsset* asset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
					   
					   if (asset)
					   {
						   mDuration = asset.duration;
                           mSize = [AVAssetUtilities naturalSize:asset];
						   
						   NSValue *requestedTime = [NSValue valueWithCMTime:CMTimeMake(mDuration.value/2.0, mDuration.timescale)];
						   
						   CGSize max = mSize;
						   if (mSize.width > 800) {
							   max = CGSizeMake(mSize.width/2, mSize.height/2);
						   }
						   
						   [asset generateThumbnailInBackgroundAndNotifyOnQueue:dispatch_get_main_queue() requestedTime:requestedTime maxSize:max withBlock:
							^(CGImageRef image)
							{
								[mImage release];
								mImage = [[UIImage allocWithZone:[self zone]] initWithCGImage:image];
								
								[[NSNotificationCenter defaultCenter] postNotificationName:AVFrameTrackedDidFinishNotification object:self];
							}];
						   
					   }
					   
					   [asset release];
				   });
}

- (void) trackKeyFrame:(CMTime)time{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   ^{
					   AVAsset* asset = [[AVURLAsset allocWithZone:NULL] initWithURL:mURL options:nil];
					   
					   if (asset)
					   {
						   mDuration = asset.duration;
                           mSize = [AVAssetUtilities naturalSize:asset];
						   
						   CGSize max = mSize;
						   
						   if (mSize.width > 800) {
							   max = CGSizeMake(mSize.width/2, mSize.height/2);
						   }
						   
						   NSValue *requestedTime = [NSValue valueWithCMTime:time];
						   //CMTimeMake(time, mDuration.timescale)
						   
						   [asset generateThumbnailInBackgroundAndNotifyOnQueue:dispatch_get_main_queue() requestedTime:requestedTime maxSize:max withBlock:
							^(CGImageRef image)
							{
								[mImage release];
								mImage = [[UIImage allocWithZone:[self zone]] initWithCGImage:image];
								
								[[NSNotificationCenter defaultCenter] postNotificationName:AVFrameTrackedDidFinishNotification object:self];
							}];
						   
					   }
					   
					   [asset release];
				   });
}

- (void)dealloc
{
	[mURL release];
	[mImage release];
	
	[super dealloc];
}

- (NSURL*)URL
{
	return mURL;
}

- (UIImage*)trackedKeyFrame
{
	return mImage;
}

@end

NSString* const AVFrameTrackedDidFinishNotification = @"AVFrameTrackedDidFinishNotification";