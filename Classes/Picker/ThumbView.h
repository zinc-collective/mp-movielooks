//
//  ThumbView.h
//  MobileLooks
//
//  Created by jack on 9/3/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAssetImageGenerator;
@interface ThumbView : UIView {

	dispatch_queue_t mQueue;
	NSTimeInterval mThumbnailInterval;
	NSInteger mNumberOfThumbnails;

	AVAssetImageGenerator* mImageGenerator;
	NSMutableDictionary* mThumbnailLayers;

	NSTimeInterval mDuration;
	CGSize mNaturalSize;

	CGSize mCropSize;

	BOOL isInitial;
}
@property (nonatomic) CGSize mCropSize;

- (void)_collectThumbnailLayersForTime:(NSTimeInterval) time;

- (void) setAsset:(AVAsset*)asset;

- (void) update:(NSTimeInterval)time;

- (UIImage*)currentFrame;

- (void)_clearThumbnailLayers;

- (int)timeToIndex:(NSTimeInterval)time;

- (void) ready;

@end
