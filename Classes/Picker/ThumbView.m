//
//  ThumbView.m
//  MobileLooks
//
//  Created by jack on 9/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbView.h"


@implementation ThumbView
@synthesize mCropSize;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		mThumbnailLayers = [[NSMutableDictionary alloc] init];
		
		mQueue = dispatch_queue_create("PlayerThumbnailView queue", 0);
		
		mNumberOfThumbnails = 128;
		mThumbnailInterval = 0.3f;
		
		mCropSize = CGSizeMake(640, 640);
		
		isInitial = YES;
    }
    return self;
}

- (void)_collectThumbnailLayersForTime:(NSTimeInterval) time
{
	NSTimeInterval minTime = fmax(0.f, time - 1.5f * mNumberOfThumbnails * mThumbnailInterval);
	NSTimeInterval maxTime = fmin(mDuration, time + 1.5f * mNumberOfThumbnails * mThumbnailInterval);
	
	for (NSNumber* key in [mThumbnailLayers allKeys])
	{
		NSTimeInterval keyAsTime = [key doubleValue];
		
		if (keyAsTime < minTime || keyAsTime > maxTime)
		{
			[[mThumbnailLayers objectForKey:key] removeFromSuperlayer];
			[mThumbnailLayers removeObjectForKey:key];
		}
	}
}

- (CALayer*)_makeThumbnailLayerForTime:(NSTimeInterval) time
{
	if (!mImageGenerator)
		return nil;
	
	CALayer* layer = [CALayer layer];
	
	CGFloat height;
	
	if (mNaturalSize.width == 0.f || mNaturalSize.height == 0.f)
		height = 1.f;
	else
		height = mNaturalSize.height / mNaturalSize.width;
	
	[layer setAnchorPoint:CGPointMake(0.5f, 0.f)];
	[layer setBounds:CGRectMake(0.f, 0.f, 1.f, height)];
	[layer setContentsGravity:kCAGravityResizeAspect];
	[layer setEdgeAntialiasingMask:kCALayerLeftEdge|kCALayerRightEdge|kCALayerTopEdge|kCALayerBottomEdge];
	
	[mImageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)]] completionHandler:
	 ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
	 {
		 if (image)
		 {
			 [CATransaction begin];
			 [CATransaction setDisableActions:YES];
			 [layer setContents:(__bridge id)image];
			 
			 if(isInitial){
				 isInitial = NO;
				 [self update:0];
			 }
			 
			 [CATransaction commit];
		 }
	 }];
	
	return layer;
}

- (void)_generateThumbnailLayersForTime:(NSTimeInterval) time
{
	if (!mImageGenerator)
		return;
	
	NSInteger minIndex = ceil(fmax(0.f, time - 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	NSInteger maxIndex = floor(fmin(mDuration, time + 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	
	NSLog(@"%ld - %ld", (long)minIndex, (long)maxIndex);
	for (NSInteger index = minIndex; index < maxIndex; index++)
	{
		NSTimeInterval thumbnailTime = mThumbnailInterval * index;
		NSNumber* key = [NSNumber numberWithDouble:thumbnailTime];
		
		if ([mThumbnailLayers objectForKey:key])
			continue;
		
		CALayer* layer = [self _makeThumbnailLayerForTime:thumbnailTime];
		
		if (layer)
		{
			[mThumbnailLayers setObject:layer forKey:key];
		}
	}
}

- (int) timeToIndex:(NSTimeInterval)time{
	
	NSInteger minIndex = ceil(fmax(0.f, time - 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	NSInteger maxIndex = floor(fmin(mDuration, time + 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	
	NSInteger x = time*maxIndex/mDuration + minIndex;
	
	return (int)x;
	
}

- (CALayer *)getLayerByTime:(NSTimeInterval) time{
	if (!mImageGenerator)
		return nil;
	
	NSInteger minIndex = ceil(fmax(0.f, time - 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	NSInteger maxIndex = floor(fmin(mDuration, time + 1.5f * mNumberOfThumbnails * mThumbnailInterval) / mThumbnailInterval);
	
	NSInteger x = time*maxIndex/mDuration + minIndex;
	NSLog(@"%ld",(long)x);
	
	CALayer *findlayer = nil;
	
	NSTimeInterval thumbnailTime = mThumbnailInterval * x;
	NSNumber* findkey = [NSNumber numberWithDouble:thumbnailTime];
	findlayer = [mThumbnailLayers objectForKey:findkey];
	if (findlayer)
	{
		return findlayer;
	}
	else {
		for (NSInteger index = minIndex; index < maxIndex; index++)
		{
			NSTimeInterval thumbnailTime = mThumbnailInterval * index;
			NSNumber* key = [NSNumber numberWithDouble:thumbnailTime];
			
			if ([mThumbnailLayers objectForKey:key])
				continue;
			
			CALayer* layer = [self _makeThumbnailLayerForTime:thumbnailTime];
			
			if (layer)
			{
				//[[self layer] addSublayer:layer];
				[mThumbnailLayers setObject:layer forKey:key];
			}
		}
		
		[self _generateThumbnailLayersForTime:time];
		
		findlayer = [mThumbnailLayers objectForKey:findkey];
	}
	return findlayer;
	
}

- (void) ready{
	//[self update:0];
}

- (void) update:(NSTimeInterval)time{
	CALayer * layer = [self getLayerByTime:time];
	if(layer){
		[self.layer setContents:layer.contents];
	}
	else {
		NSArray *allKeys = [mThumbnailLayers allKeys];
		layer = [mThumbnailLayers objectForKey:[allKeys lastObject]];
		[self.layer setContents:layer.contents];
	}

	
	[self setNeedsDisplay];
}

- (UIImage*)currentFrame{
	
	CGImageRef imgRef = (CGImageRef)[self.layer contents];
	
	if(imgRef == nil)return nil;
	
	UIImage *img = [UIImage imageWithCGImage:imgRef];
	
	return img;
}

- (void)_clearThumbnailLayers
{
	[mThumbnailLayers enumerateKeysAndObjectsUsingBlock:
	 ^(id key, id obj, BOOL *stop)
	 {
		 [obj removeFromSuperlayer];
	 }];
	[mThumbnailLayers removeAllObjects];
}

- (void) setAsset:(AVAsset *)asset{
	
	mDuration = CMTimeGetSeconds(asset.duration);
	
	dispatch_sync(mQueue,
				  ^{
					  if (mImageGenerator)
					  {
						  [mImageGenerator release];
						  mImageGenerator = nil;
					  }
					  
					  if (asset)
					  {
						  mImageGenerator = [[AVAssetImageGenerator allocWithZone:[self zone]] initWithAsset:asset];
						  [mImageGenerator setAppliesPreferredTrackTransform:YES];
						  [mImageGenerator setMaximumSize:mCropSize];
					  }
					  
					  [self _clearThumbnailLayers];
					  [self _generateThumbnailLayersForTime:CMTimeGetSeconds(kCMTimeZero)];	

				  });
	
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
	[mImageGenerator release];
	[mThumbnailLayers release];
	dispatch_release(mQueue);
    [super dealloc];
}


@end
