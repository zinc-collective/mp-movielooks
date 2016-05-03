//
//  VideoThumbnailOperation.h
//  MobileLooks
//
//  Created by Chen Mike on 4/8/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BORDER_WIDTH 6

@class VideoThumbnailOperation;

@protocol VideoThumbnailOperationDelegate
@optional
-(void)operationFinished:(VideoThumbnailOperation*)operation;

@end

@interface VideoThumbnailOperation : NSOperation {
	NSURL* mThumbnailUrl;
	CGSize mThumbnailSize;
	CMTime mMovieDuration;
//	NSUInteger mScrollIndex;
	UIImage* mThumbnailImage;
	BOOL mWithBorder;
	BOOL mIsCanceled;
	id<VideoThumbnailOperationDelegate> mDelegate;
}

@property(nonatomic,assign) id<VideoThumbnailOperationDelegate> resultDelegate;
@property(nonatomic,assign) BOOL isCanceled;
@property(nonatomic,assign) UIImage* thumbnailImage;
@property(nonatomic,assign) CMTime movieDuration;

-(id)initWithURL:(NSURL*)videoURL/* index:(NSUInteger)aIndex targetSize:(CGSize)aSize */withBorder:(BOOL)aBorder;
+(CGImageRef)generateBoard:(CGImageRef)originImg withSize:(CGSize)imgSize;
@end
