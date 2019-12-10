//
//  VideoThumbnailOperation.m
//  MobileLooks
//
//  Created by Chen Mike on 4/8/11.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "VideoThumbnailOperation.h"
#import "Utilities.h"

#import "PickerSizes.h"

@implementation VideoThumbnailOperation

@synthesize resultDelegate = mDelegate;
@synthesize isCanceled = mIsCanceled;
@synthesize thumbnailImage = mThumbnailImage;
@synthesize movieDuration = mMovieDuration;

-(id)initWithURL:(NSURL*)videoURL/* index:(NSUInteger)aIndex targetSize:(CGSize)aSize */withBorder:(BOOL)aBorder
{
	self = [super init];
	if(self)
	{
		mThumbnailUrl = videoURL;
		//	mScrollIndex = aIndex;
		//	mThumbnailSize = aSize;
		mWithBorder = aBorder;
		mIsCanceled = NO;
	}
	return self;
}


+(CGImageRef)generateBoard:(CGImageRef)originImg withSize:(CGSize)imgSize
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef imageContext = CGBitmapContextCreate(NULL, imgSize.width, imgSize.height, 8, imgSize.width * glPixelSize, colorSpace, glImageAlphaNoneSkipLast);

	CGFloat boardWidth = BORDER_WIDTH;
	CGRect boardRect = CGRectMake(boardWidth/2, boardWidth/2, imgSize.width-boardWidth, imgSize.height-boardWidth);

	//CGContextSetRGBStrokeColor(imageContext, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBStrokeColor(imageContext, 0.0, 0.0, 0.0, 1.0);
	CGContextDrawImage(imageContext, CGRectMake(0, 0, imgSize.width, imgSize.height), originImg);
	CGContextStrokeRectWithWidth(imageContext, boardRect, boardWidth);

	CGImageRef imageBoarded = CGBitmapContextCreateImage(imageContext);
	CGContextRelease(imageContext);
	CGColorSpaceRelease(colorSpace);
	return imageBoarded;
}

-(void)main
{

	if([self isCancelled]) return;

	@autoreleasepool {

		AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mThumbnailUrl options:nil];
		AVAssetImageGenerator* avGenerator = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
		[avGenerator setAppliesPreferredTrackTransform:YES];
		[avGenerator setMaximumSize:CGSizeMake(VPICKER_THUMB_WIDTH, VPICKER_THUMB_HEIGHT)];

		mMovieDuration = avAsset.duration;
		if (avGenerator!=nil && ![self isCancelled])
		{
			CGImageRef imageRef = [avGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
			if(mWithBorder && ![self isCancelled])
			{
				CGFloat imgWidth = CGImageGetWidth(imageRef);
				CGFloat imgHeight = CGImageGetHeight(imageRef);
				CGFloat imgAspect = imgWidth/imgHeight;

				if (imgWidth>imgHeight) {
					imgWidth = VPICKER_THUMB_WIDTH;
					imgHeight = VPICKER_THUMB_HEIGHT/imgAspect;
				}
				else {
					imgWidth = VPICKER_THUMB_WIDTH*imgAspect;
					imgHeight = VPICKER_THUMB_HEIGHT;
				}

				CGImageRef boardedImageRef = [VideoThumbnailOperation generateBoard:imageRef withSize:CGSizeMake(imgWidth, imgHeight)];
				mThumbnailImage = [[UIImage alloc] initWithCGImage:boardedImageRef];
				CGImageRelease(boardedImageRef);
				//mThumbnailSize = CGSizeMake(imgWidth, imgHeight);
			}
			else
			{
				mThumbnailImage = [[UIImage alloc] initWithCGImage:imageRef];
				//mThumbnailSize = CGSizeMake(73, 73);
			}
			CGImageRelease(imageRef);
		}
		//Cache
		if(![self isCancelled])
		{
			[self.resultDelegate operationFinished:self];
		}
		if(![self isCancelled])
		{
			NSString* md5EncodePath = [Utilities md5Encode:[mThumbnailUrl resourceSpecifier]];
			NSString  *jpgPath = [[Utilities cachedThumbnailPath] stringByAppendingPathComponent:md5EncodePath];
			NSFileManager *manager = [NSFileManager defaultManager];

			if(![manager fileExistsAtPath:jpgPath])
				[UIImageJPEGRepresentation(mThumbnailImage, 1.0) writeToFile:jpgPath atomically:YES];
			NSMutableDictionary* attributesDictionary = [NSMutableDictionary dictionaryWithDictionary:[manager attributesOfItemAtPath:jpgPath error:nil]];
			NSDate *date = [NSDate date];
			[attributesDictionary setObject:date forKey:NSFileCreationDate];
			[attributesDictionary setObject:[date dateByAddingTimeInterval:CMTimeGetSeconds(mMovieDuration)] forKey:NSFileModificationDate];
			[manager setAttributes:attributesDictionary ofItemAtPath:jpgPath error:nil];

		}
	}
}

@end
