//
//  CustomTrimView.m
//  MobileLooks
//
//  Created by Chen Mike on 3/17/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "QuartzTrimView.h"
//#define Trim_WIDTH_SPACE 12

#define TRIM_MIN 0.01
#define TRIM_MAX 0.99
#define IMAGE_BORDER_WIDTH 28

@implementation QuartzTrimView

@synthesize delegate = _delegate;
@synthesize maskWidth = mMaskWidth;
@synthesize maskHeight = mMaskHeight;
@synthesize maskWidthSpace = mMaskWidthSpace;
@synthesize maskHeightSpace = mMaskHeightSpace;	


//#define Trim_HEIGHT_SPACE 4

//#define PICKER_WIDTH 10
//#define PICKER_HEIGHT 26

//#define BORDER_WIDTH 18
//#define BORDER_HEIGHT 4

//#define Mask_WIDTH_SPACE 24
//#define Mask_HEIGHT_SPACE (Trim_HEIGHT_SPACE+BORDER_HEIGHT)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
        mMaskImageRef = NULL;
        mControlImageRef = NULL;
		pickerTrimValue = TRIM_MIN;
		mDrawPicker = YES;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)resize:(CGRect)newFrame
{
	self.frame = newFrame;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		mHandleWidth = 16;
		mBoardWidth = 32;
		mBoardHeight = 8;
		mMaskWidthSpace = 48;
		mMaskHeightSpace = 16;
	}
	else {
		mHandleWidth = 10;
		mBoardWidth = 18;
		mBoardHeight = 4;
		mMaskWidthSpace = 24;
		mMaskHeightSpace = 8;
	}

	mMaskWidth = newFrame.size.width - mMaskWidthSpace*2;
	mMaskHeight = newFrame.size.height - mMaskHeightSpace*2;
	[self setNeedsDisplay];
}

-(void)resetHolder//:(CGImageRef)backImageRef
{
	pickerTrimValue = TRIM_MIN;
}

-(void)resetTrimEditor//:(CGImageRef)backImageRef
{
	leftTrimValue = 0.0f;
	rightTrimValue = 1.0f;
	
	isLeftHolded = NO;
	isRightHolded = NO;
	isPickerHolded = NO;
	
	isEditing = NO;
	isRangeChanged = NO;
	
//	if(mBackImageRef!=NULL)
//		CGImageRelease(mBackImageRef);
//	mBackImageRef = CGImageCreateCopy(backImageRef);
	if(mMaskImageRef==NULL)
		mMaskImageRef = CGImageCreateCopy([UIImage imageNamed:@"trimMask.png"].CGImage);
	if(mPickerImageRef==NULL)
		mPickerImageRef = CGImageCreateCopy([UIImage imageNamed:@"trimPicker.png"].CGImage);
	if(mControlImageRef==NULL)
		mControlImageRef = CGImageCreateCopy([UIImage imageNamed:@"trimControlRed.png"].CGImage);
	if(mUnselectedControlImageRef==NULL)
		mUnselectedControlImageRef = CGImageCreateCopy([UIImage imageNamed:@"trimControlBlack.png"].CGImage);
	[self setNeedsDisplay];
}

-(void)setPickerPos:(CGFloat)factor displayPicker:(BOOL)display
{
//	if(!isEditing)
	{
		if(factor<TRIM_MIN)factor=TRIM_MIN;
		if(factor>TRIM_MAX)factor=TRIM_MAX;
		if(factor<leftTrimValue)factor=leftTrimValue;
		if(factor>rightTrimValue)factor=rightTrimValue;
		
		pickerTrimValue = factor;
		[self setNeedsDisplay];
	}
	mDrawPicker = YES;
}

-(BOOL)isOverRange
{
	return (pickerTrimValue>=rightTrimValue);
}

-(CGFloat)getLeftPos
{
	return leftTrimValue;
}

-(CGFloat)getRightPos
{
	return rightTrimValue;
}

-(void)drawInContext:(CGContextRef)context
{
	// Default is to do nothing!
	
    CGFloat maskOffsetX = mMaskWidthSpace;
    CGFloat maskOffsetY = mMaskHeightSpace;
	CGFloat boardOffsetY = self.bounds.size.height/2-mMaskHeight/2-mBoardHeight;
	
    CGFloat height = self.bounds.size.height;
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
    //draw back image
    //CGImageRef backImageRef = mBackImage.CGImage;
    //CGContextDrawImage(context, CGRectMake(maskOffsetX, maskOffsetY, mMaskWidth, mMaskHeight), mBackImageRef);
	
    
    //draw mask
    //CGImageRef maskImageRef = mMaskImage.CGImage;
//    CGFloat maskImgWidth = CGImageGetWidth(mMaskImageRef);
    CGFloat maskImgHeight = CGImageGetWidth(mMaskImageRef);
    CGFloat leftTrimX = mMaskWidth*leftTrimValue;
    CGFloat rightTrimX = mMaskWidth*rightTrimValue;
    
    CGContextSaveGState(context);
	// For this operation we extract the 35 pixel strip on each side of the source image.
	CGRect clips[] =
	{
		CGRectMake(maskOffsetX+0, maskOffsetY, leftTrimX, maskImgHeight),
		CGRectMake(maskOffsetX+rightTrimX, maskOffsetY, mMaskWidth-rightTrimX, mMaskHeight),
	};
	CGContextClipToRects(context, clips, sizeof(clips) / sizeof(clips[0]));
	CGContextDrawImage(context, CGRectMake(maskOffsetX, maskOffsetY, mMaskWidth, mMaskHeight), mMaskImageRef);
	CGContextRestoreGState(context);
    //draw trim control
	if(isEditing)	
	{
		CGFloat controlWidth = CGImageGetWidth(mControlImageRef);
		CGFloat controlHeight = CGImageGetWidth(mControlImageRef);
		
		CGRect leftClipRect = CGRectMake(0, 0, IMAGE_BORDER_WIDTH, controlHeight);
		CGRect rightClipRect = CGRectMake(controlWidth-IMAGE_BORDER_WIDTH, 0,IMAGE_BORDER_WIDTH, controlHeight);
		CGRect middleClipRect = CGRectMake(IMAGE_BORDER_WIDTH, 0,controlWidth-IMAGE_BORDER_WIDTH*2, controlHeight);
		
		CGImageRef leftClipImageRef = CGImageCreateWithImageInRect(mControlImageRef, leftClipRect);
		CGImageRef rightClipImageRef = CGImageCreateWithImageInRect(mControlImageRef, rightClipRect);
		CGImageRef middleClipImageRef = CGImageCreateWithImageInRect(mControlImageRef, middleClipRect);
		
		CGContextDrawImage(context, CGRectMake(maskOffsetX+mMaskWidth*leftTrimValue-mBoardWidth	,boardOffsetY, mBoardWidth, mMaskHeight+mBoardHeight*2)									,leftClipImageRef);
		CGContextDrawImage(context, CGRectMake(maskOffsetX+mMaskWidth*leftTrimValue				,boardOffsetY, mMaskWidth*(rightTrimValue-leftTrimValue), mMaskHeight+mBoardHeight*2)	,middleClipImageRef); 
		CGContextDrawImage(context, CGRectMake(maskOffsetX+mMaskWidth*rightTrimValue			,boardOffsetY, mBoardWidth, mMaskHeight+mBoardHeight*2)									,rightClipImageRef);
		
		if(mDrawPicker)
		{
			CGFloat pickerTrimX = mMaskWidth*pickerTrimValue;
			CGContextDrawImage(context, CGRectMake(maskOffsetX+pickerTrimX-mHandleWidth/2, boardOffsetY, mHandleWidth, mMaskHeight+mBoardHeight*2),mPickerImageRef);
		}
		
		CGImageRelease(leftClipImageRef);
		CGImageRelease(rightClipImageRef);
		CGImageRelease(middleClipImageRef);
	}
	else
	{	
		CGFloat controlWidth = CGImageGetWidth(mControlImageRef);
		CGFloat controlHeight = CGImageGetWidth(mControlImageRef);
		
		CGRect leftClipRect = CGRectMake(0, 0, IMAGE_BORDER_WIDTH, controlHeight);
		CGRect rightClipRect = CGRectMake(controlWidth-IMAGE_BORDER_WIDTH, 0,IMAGE_BORDER_WIDTH, controlHeight);
		CGRect middleClipRect = CGRectMake(IMAGE_BORDER_WIDTH, 0,controlWidth-IMAGE_BORDER_WIDTH*2, controlHeight);
		
		CGImageRef leftClipImageRef = CGImageCreateWithImageInRect(mUnselectedControlImageRef, leftClipRect);
		CGImageRef rightClipImageRef = CGImageCreateWithImageInRect(mUnselectedControlImageRef, rightClipRect);
		CGImageRef middleClipImageRef = CGImageCreateWithImageInRect(mUnselectedControlImageRef, middleClipRect);
		
		CGContextDrawImage(context, CGRectMake(maskOffsetX-mBoardWidth	,boardOffsetY, mBoardWidth, mMaskHeight+mBoardHeight*2)	,leftClipImageRef);
		CGContextDrawImage(context, CGRectMake(maskOffsetX				,boardOffsetY, mMaskWidth, mMaskHeight+mBoardHeight*2)	,middleClipImageRef); 
		CGContextDrawImage(context, CGRectMake(maskOffsetX+mMaskWidth	,boardOffsetY, mBoardWidth, mMaskHeight+mBoardHeight*2)	,rightClipImageRef);
		
		CGFloat pickerTrimX = mMaskWidth*pickerTrimValue;
		CGContextDrawImage(context, CGRectMake(maskOffsetX+pickerTrimX-mHandleWidth/2, boardOffsetY, mHandleWidth, mMaskHeight+mBoardHeight*2),mPickerImageRef);
	
		CGImageRelease(leftClipImageRef);
		CGImageRelease(rightClipImageRef);
		CGImageRelease(middleClipImageRef);
	
	}
}

-(void)setEditing:(BOOL)editing
{
	isEditing = editing;
	[self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch* touch = [touches anyObject];
    CGPoint position = [touch locationInView:self];
    
    CGFloat maskOffsetX = mMaskWidthSpace;
//    CGFloat maskOffsetY = Mask_HEIGHT_SPACE;
	
    CGFloat leftTrimPosX = maskOffsetX+leftTrimValue*mMaskWidth-mBoardWidth/2;
    CGFloat rightTrimPosX = maskOffsetX+rightTrimValue*mMaskWidth+mBoardWidth/2;
	CGFloat pickerTrimX = maskOffsetX+mMaskWidth*pickerTrimValue;

	//priority to Pick Holder
	if(position.x-pickerTrimX<mHandleWidth && position.x-pickerTrimX>-mHandleWidth)
    {
		isPickerHolded = YES;
		isLeftHolded = NO;
		isRightHolded = NO;
		return;
	}
	
    if(position.x-leftTrimPosX<mBoardWidth/2 && position.x-leftTrimPosX>-mBoardWidth/2)
        isLeftHolded = YES;
    if(position.x-rightTrimPosX<mBoardWidth/2 && position.x-rightTrimPosX>-mBoardWidth/2)
        isRightHolded = YES;  
	
	if(!isEditing && (isLeftHolded || isRightHolded))
	{
		isEditing = YES;
		isPickerHolded = NO;
		[self.delegate trimBeginEdit:self];
		[self setNeedsDisplay];
	} 
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint position = [touch locationInView:self];
	
    CGFloat maskOffsetX = mMaskWidthSpace;
//    CGFloat maskOffsetY = Mask_HEIGHT_SPACE;
    
    CGFloat leftTrimPosX = maskOffsetX+leftTrimValue*mMaskWidth-mBoardWidth/2;
    CGFloat rightTrimPosX = maskOffsetX+rightTrimValue*mMaskWidth+mBoardWidth/2;
	CGFloat pickerTrimX = maskOffsetX+mMaskWidth*pickerTrimValue;
    
	if(position.x-pickerTrimX<mHandleWidth && position.x-pickerTrimX>-mHandleWidth && !isLeftHolded && !isRightHolded)
		isPickerHolded = YES;
    if(position.x-leftTrimPosX<mBoardWidth/2 && position.x-leftTrimPosX>-mBoardWidth/2 && !isPickerHolded)
        isLeftHolded = YES;
    if(position.x-rightTrimPosX<mBoardWidth/2 && position.x-rightTrimPosX>-mBoardWidth/2 && !isPickerHolded)
        isRightHolded = YES; 
	
    if(isLeftHolded && isEditing)
    {
        CGFloat detaX = position.x-leftTrimPosX;
        CGFloat newLeftValue = leftTrimValue+detaX/mMaskWidth;
        if(newLeftValue<rightTrimValue-0.05 && newLeftValue>0.f && fabs(detaX)>0.4f)
        {    
            leftTrimValue = newLeftValue;
			if(pickerTrimValue<leftTrimValue)
			{	
				pickerTrimValue = leftTrimValue;
				[self.delegate changePicker:self withPos:pickerTrimValue];
			}
			else
				[self.delegate changeTrimRange:self withLeftPos:leftTrimValue withRightPos:rightTrimValue];
            [self setNeedsDisplay];
        }
		isRangeChanged = YES;
    }
    if(isRightHolded && isEditing)
    {
        CGFloat detaX = position.x-rightTrimPosX;
        CGFloat newRightValue = rightTrimValue+detaX/mMaskWidth;
        if(newRightValue>leftTrimValue+0.05 && newRightValue<1.f && fabs(detaX)>0.4f)
        {   
            rightTrimValue = newRightValue;
			if(pickerTrimValue>rightTrimValue)
			{	
				pickerTrimValue = rightTrimValue;
				[self.delegate changePicker:self withPos:pickerTrimValue];
			}
			else
				[self.delegate changeTrimRange:self withLeftPos:leftTrimValue withRightPos:rightTrimValue];
			[self setNeedsDisplay];
        }
		isRangeChanged = YES;
    }
	if(isPickerHolded)
    {
        CGFloat detaX = position.x-pickerTrimX;
        CGFloat newPickerValue = pickerTrimValue+detaX/mMaskWidth;
        if(newPickerValue<leftTrimValue) newPickerValue = leftTrimValue;
		if(newPickerValue>rightTrimValue) newPickerValue = rightTrimValue;

        if(fabs(detaX)>=0.4f)
		{
			pickerTrimValue = newPickerValue;
			[self setNeedsDisplay];
			[self.delegate changePicker:self withPos:pickerTrimValue];
		}
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isLeftHolded = NO;
    isRightHolded = NO;
	isPickerHolded = NO;
	
	if(!isRangeChanged && isEditing)
	{	
		[self.delegate trimCancelEdit:self];
		[self resetTrimEditor];
	} 
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isLeftHolded = NO;
    isRightHolded = NO;
	isPickerHolded = NO;
	
	if(!isRangeChanged && isEditing)
	{	
		[self.delegate trimCancelEdit:self];
		[self resetTrimEditor];
	}
}


- (void)dealloc
{
//	if(mBackImageRef)
//		CGImageRelease(mBackImageRef);
	if(mMaskImageRef)
		CGImageRelease(mMaskImageRef);
	if(mPickerImageRef)
		CGImageRelease(mPickerImageRef);
	if(mControlImageRef)
		CGImageRelease(mControlImageRef);
	if(mUnselectedControlImageRef)
		CGImageRelease(mUnselectedControlImageRef);	
    [super dealloc];
}

@end
