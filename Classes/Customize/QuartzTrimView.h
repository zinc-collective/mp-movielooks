//
//  CustomTrimView.h
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzView.h"

@class QuartzTrimView;

@protocol QuartzTrimViewDelegate
@optional
-(void)trimBeginEdit:(QuartzTrimView*)trimView;
-(void)trimCancelEdit:(QuartzTrimView*)trimView;
-(void)changePicker:(QuartzTrimView*)trimView withPos:(CGFloat)factor;
-(void)changeTrimRange:(QuartzTrimView*)trimView withLeftPos:(CGFloat)lFactor withRightPos:(CGFloat)rFactor;
@end


@interface QuartzTrimView : QuartzView {
    CGFloat leftTrimValue;
    CGFloat rightTrimValue;
	CGFloat pickerTrimValue;
	
	CGFloat mMaskWidth;
	CGFloat mMaskHeight;
	CGFloat mMaskWidthSpace;
	CGFloat mMaskHeightSpace;	
	
	CGFloat mBoardWidth;
	CGFloat mBoardHeight;
//	CGFloat mBoardWidthSpace;
//	CGFloat mBoardHeightSpace;
	CGFloat mHandleWidth;
	
	CGImageRef mMaskImageRef;
    CGImageRef mPickerImageRef;
    CGImageRef mControlImageRef;
    CGImageRef mUnselectedControlImageRef;
	
    BOOL isLeftHolded;
    BOOL isRightHolded;
	BOOL isPickerHolded;
	BOOL mDrawPicker;
	
    BOOL isEditing;
    BOOL isRangeChanged;
	
	id<QuartzTrimViewDelegate> __weak _delegate;
}

@property(nonatomic,weak) id<QuartzTrimViewDelegate> delegate;
@property(nonatomic,assign) CGFloat maskWidth;
@property(nonatomic,assign) CGFloat maskHeight;
@property(nonatomic,assign) CGFloat maskWidthSpace;
@property(nonatomic,assign) CGFloat maskHeightSpace;	

-(void)resize:(CGRect)newFrame;
-(void)resetHolder;
-(void)resetTrimEditor;//:(CGImageRef)backImageRef;
-(void)setPickerPos:(CGFloat)factor displayPicker:(BOOL)display;
-(CGFloat)getLeftPos;
-(CGFloat)getRightPos;
-(BOOL)isOverRange;
-(void)setEditing:(BOOL)editing;
@end
