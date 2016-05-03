//
//  CustomTrimView.h
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzTrimView.h"

@interface CustomTrimView : UIView {
	QuartzTrimView* mQuartzTrimView;
	
	CALayer* mTrimBoardLayer;
	CALayer* mThumbnailLayer;
	NSTimeInterval mThumbnailInterval;
}

-(void)resize:(CGRect)newFrame;
-(void)updateThumbnailLayer:(AVAsset*)asset withLayerNum:(NSUInteger)layerNum;
@property(nonatomic,retain) QuartzTrimView* quartzTrimView;

@end
