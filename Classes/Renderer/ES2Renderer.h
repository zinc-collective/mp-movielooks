//
//  ES2Renderer.h
//  MobileLooks
//
//  Created by George on 7/19/10.
//  Copyright RED/SAFI 2010. All rights reserved.
//

#import "Renderer.h"

#define QUICK_HALF_FACTOR_IPHONE	0.142
#define COMPLEX_HALF_FACTOR_IPHONE	0.259
#define QUICK_FULL_FACTOR_IPHONE	0.415
#define COMPLEX_FULL_FACTOR_IPHONE	0.915

#define QUICK_HALF_FACTOR_IPAD2		0.071
#define COMPLEX_HALF_FACTOR_IPAD2	0.129
#define QUICK_FULL_FACTOR_IPAD2		0.207
#define COMPLEX_FULL_FACTOR_IPAD2	0.457

@interface ES2Renderer : Renderer
{
@private
	int		diffusionSize;
	float	diffusionOpacity;
	float	diffusionHighlightsOnly;
	float	preDesatAmount;
	float	vignetteAmount;
	int		vignetteFalloff;
	BOOL	doOverlay;
	BOOL	doFlipPixel;
	unsigned char* renderBuffer;
	unsigned char *keyFrameData;
}

@property(nonatomic) int diffusionSize;
@property(nonatomic) float diffusionOpacity;
@property(nonatomic) float diffusionHighlightsOnly;
@property(nonatomic) float preDesatAmount;
@property(nonatomic) float vignetteAmount;
@property(nonatomic) int vignetteFalloff;

- (void)loadKeyFrame;
- (void)loadKeyFrameCrop;
- (bool)isKeyFrameValid;
- (void)unloadKeyFrame;
- (void)resetRenderBuffer;
- (void)freeRenderBuffer;

- (CGImageRef)frameProcessingAndReturnImage:(GLubyte *)original flipPixel:(BOOL)doInvert;
@end

