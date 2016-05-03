//
//  CustomTrimView.m
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "CustomTrimView.h"

@implementation CustomTrimView

@synthesize quartzTrimView = mQuartzTrimView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		//[self.layer setContents:(id)[UIImage imageNamed:@"trimBackground.png"].CGImage];
		
		mTrimBoardLayer = [[CALayer allocWithZone:nil] init];
		[mTrimBoardLayer setAnchorPoint:CGPointMake(0.0,0.0)];
		[mTrimBoardLayer setBounds:self.layer.bounds];
		[mTrimBoardLayer setPosition:CGPointMake(0, 0)];
		[mTrimBoardLayer setContents:(id)[UIImage imageNamed:@"trimBackground.png"].CGImage];
		[self.layer addSublayer:mTrimBoardLayer];
		
		mQuartzTrimView = [[QuartzTrimView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self addSubview:mQuartzTrimView];
	}
    return self;
}

-(void)resize:(CGRect)newFrame
{
	self.frame = newFrame;
	[mQuartzTrimView resize:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
	[mThumbnailLayer setBounds:CGRectMake(0,0, mQuartzTrimView.maskWidth, mQuartzTrimView.maskHeight)];
	[mTrimBoardLayer setBounds:self.layer.bounds];
	[self setNeedsDisplay];
}

-(void)updateThumbnailLayer:(AVAsset*)avAsset withLayerNum:(NSUInteger)layerNum
{
	NSInteger originalSublayerCount = [[mThumbnailLayer sublayers] count];
	if(layerNum<originalSublayerCount)
		layerNum = originalSublayerCount;
	if(mThumbnailLayer)
	{
		[mThumbnailLayer removeFromSuperlayer];
		[mThumbnailLayer release];
	}
	
//	CGRect layerBounds = CGRectMake(mQuartzTrimView.maskWidthSpace, mQuartzTrimView.maskHeightSpace, maskWidth, maskHeight);
//	CGFloat weightScale = CGRectGetWidth(layerBounds);
	CGFloat heightScale = mQuartzTrimView.maskHeight;

	mThumbnailLayer = [[CALayer allocWithZone:nil] init];
	[mThumbnailLayer setAnchorPoint:CGPointMake(0.0,0.0)];
	[mThumbnailLayer setBounds:CGRectMake(0,0, mQuartzTrimView.maskWidth, mQuartzTrimView.maskHeight)];
	[mThumbnailLayer setPosition:CGPointMake(mQuartzTrimView.maskWidthSpace, mQuartzTrimView.maskHeightSpace)];
	[mThumbnailLayer setSublayerTransform:CATransform3DMakeScale(heightScale, heightScale, 1.f)];
	
	{
		AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
		[avImageGenerator setAppliesPreferredTrackTransform:YES];
		[avImageGenerator setMaximumSize:CGSizeMake(128, 128)];
		
		CGSize naturalSize = [avAsset naturalSize];
		NSTimeInterval duration = CMTimeGetSeconds([avAsset duration]);
		if(duration>120)
			duration -= 11;
		
		CGFloat width = naturalSize.width/naturalSize.height;
		
		NSInteger minIndex = 0;
		NSInteger maxIndex = layerNum;
		NSTimeInterval thumbnailInterval = duration/layerNum;
		
		for (NSInteger index = minIndex; index < maxIndex; index++)
		{
			NSTimeInterval thumbnailTime = thumbnailInterval * index;
			
			CALayer* layer = [CALayer layer];
						
			[layer setAnchorPoint:CGPointMake(0.0,0.0)];
			[layer setPosition:CGPointMake(width*index, 0.f)];
			[layer setBounds:CGRectMake(0.f, 0.f, width, 1.f)];
			[layer setContentsGravity:kCAGravityResizeAspect];
			[layer setEdgeAntialiasingMask:kCALayerLeftEdge|kCALayerRightEdge|kCALayerTopEdge|kCALayerBottomEdge];
			
			NSError* error;
			CGImageRef img = [avImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(thumbnailTime, 600) actualTime:nil error:&error];
			if (img)
			{
				[CATransaction begin];
				[CATransaction setDisableActions:YES];
				[layer setContents:(id)img];
				[CATransaction commit];
			}
			else {
				NSLog(@"%@",[error localizedDescription]);
			}

			CGImageRelease(img);
			[mThumbnailLayer addSublayer:layer];		
		}
	}
	
	[[self layer] insertSublayer:mThumbnailLayer below:mTrimBoardLayer];	
	[CATransaction commit];
}

- (void)dealloc
{
	if(mThumbnailLayer)
	{
		[mThumbnailLayer removeFromSuperlayer];
		[mThumbnailLayer release];
	}
	[mTrimBoardLayer release];
	[mQuartzTrimView release];
    [super dealloc];
}

@end
