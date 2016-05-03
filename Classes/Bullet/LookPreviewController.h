//
//  LookPreviewController.h
//  MobileLooks
//
//  Created by jack on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import "ES2Renderer.h"

typedef enum
{
	RendererNew,
	RendererReady,
	RendererRendering
} RendererStatus;

@class UICustomSwitch;
@class VideoFrameTrack;
@class BulletViewController;
@class ES2Renderer;

@interface LookPreviewController : UIViewController
{
@private
	RendererStatus			mRendererStatus;
	ES2Renderer				*renderer;
	CGSize					frameSize;
	CGSize					outputSize;
	CGSize					outputSizeCropped;
	CGSize					estimateOutputSize;
	NSDictionary			*mLookDic;
	
	UIActivityIndicatorView *mActivityIndicator;	
	UIImageView				*mThumbImageView;
	UIView					*mThumbView;
	UISlider				*strengthSlider;
	UISlider				*brightnessSlider;
	//UICustomSwitch			*modeSwitcher;
	UISwitch			*modeSwitcher;
	//UISlider			*modeSwitcher;

	float					fStrengthValue;
	float					fBrightnessValue;
	float					fModeValue;
	NSTimeInterval			estimateFrameProcessTime;
	NSTimeInterval			estimateClipProcessTime;
	NSTimeInterval			estimateTotalRenderTime;
	
	UILabel					*strengthLabel;
	UIImageView				*sIncrease;
	UIImageView				*sDecrease;
	//UIImageView				*border;
	UILabel					*brightnessLabel;
	UIImageView				*bIncrease;
	UIImageView				*bDecrease;
	UIButton				*developButton;
	UIButton				*backToLooksBrowserButton;
	UILabel					*halfLabel;
	UILabel					*fullLabel;
	UILabel					*resolutionLabel;
	VideoMode				videoMode;

	UILabel					*sdLabel;
	UILabel					*hdLabel;

}

//@property (nonatomic, retain) UIImage *renderedImg;
@property (nonatomic, assign) NSDictionary *lookDic;
@property (nonatomic, assign) ES2Renderer *renderer;
@property (nonatomic) CGSize frameSize;
@property (nonatomic) CGSize outputSize;
@property (nonatomic) CGSize outputSizeCropped;
@property (nonatomic) VideoMode videoMode;

- (void) layoutiPadAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) layoutiPhoneAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
