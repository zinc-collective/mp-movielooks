//
//  ES2Renderer.m
//  MobileLooks
//
//  Created by George on 7/19/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//
//bret hd
#import "ES2RendererOld.h"
#import "fastBlur.h"
#import "DeviceDetect.h"

#define MIN_FRAME_WIDTH		320.0

#define SCALE_FACTOR		4
#define BLUR_FACTOR			4
#define BLUR_SUB_RADIUS1	10

GLuint scaleProgram, deartifactProgram, remapProgram, lastphaseProgram, downsampleProgram;

// uniform index
enum
{
    UNIFORM_SAMPLER,

	UNIFORM_SRC_SAMPLER,
	UNIFORM_SCALED_IMG,
	UNIFORM_SPECIAL_BRIGHTNESS_IMG,
	UNIFORM_FLIP_PIXEL,

	UNIFORM_SPECIAL_IMG,
	UNIFORM_TEMP_IMG,

	UNIFORM_BLUR_FACTOR,
	UNIFORM_BLUR_SAMPLER,

	UNIFORM_LAST_RADIUS,
	UNIFORM_LAST_SPECIAL,
	UNIFORM_LAST_DEARTIFACT,
	UNIFORM_LAST_BLUR_HILITE,
	UNIFORM_LAST_OVERLAY,

	UNIFORM_LOOKS_STRENGTH,
	UNIFORM_LOOKS_BRIGHTNESS,

	UNIFORM_DIFFUSION_OPACITY,
	UNIFORM_PREDESAT_AMOUNT,
	UNIFORM_VIGNETTE_AMOUNT,
	UNIFORM_DO_OVERLAY,
	UNIFORM_FLIP_PIXEL2,
	UNIFORM_DO_QUICK_RENDER,
	UNIFORM_DO_QUICK_RENDER2,
	UNIFORM_LOOKS_BRIGHTNESS2,
	UNIFORM_DIFFUSION_SIZE,
	UNIFORM_LAST_REMAP,

    UNIFORM_DOWNSAMPLER,

    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

GLuint originalImg;
GLuint overlayImg;
GLuint specialImg;

GLuint scaleTexture, scaleFBO;
GLuint deartifactTexture, deartifactFBO;
GLuint remapTexture, remapFBO;
GLuint blurHiliteTexture, blurHiliteFBO;
GLuint degenTexture, degenFBO;

extern GLfloat vertices[];
extern GLfloat texcoords[];

@implementation ES2RendererOld

@synthesize diffusionSize;
@synthesize diffusionOpacity;
@synthesize diffusionHighlightsOnly;
@synthesize preDesatAmount;
@synthesize vignetteAmount;
@synthesize vignetteFalloff;


#pragma mark -
#pragma mark Init

- (void)initGL
{
	int maxBufferSize = 1280 * 1280;

	//bret movielooks update
    if (IS_IPAD && IS_RETINA)
    {
		// if ipad3 or higher, increase buffer size
		// ipad3 (standard) HD video is 1920x1080
		maxBufferSize = 1920 * 1920;
	}else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            maxBufferSize = 1280 * 1280;
        else
            maxBufferSize = 1920 * 1920;
    }

    renderBuffer = malloc(maxBufferSize * glPixelSize);
	keyFrameData = NULL;

	glGenFramebuffers(1, &defaultFramebuffer);
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);

//	const char *original = [[[NSBundle mainBundle] pathForResource:@"frame" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
//	const char *original = [[Utilities savedKeyFrameImagePath] cStringUsingEncoding:NSASCIIStringEncoding];
//	originalImg = loadTexture(original);
	glGenTextures(1, &originalImg);
	glBindTexture(GL_TEXTURE_2D, originalImg);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, FRAME_WIDTH, FRAME_HEIGHT, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);

	glGenTextures(1, &overlayImg);
	glBindTexture(GL_TEXTURE_2D, overlayImg);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	const char *vignette = [[[NSBundle mainBundle] pathForResource:@"vignette" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	//const char *lut3dPath = [[[NSBundle mainBundle] pathForResource:@"Nuke" ofType:@"vf"] cStringUsingEncoding:NSASCIIStringEncoding];
	specialImg = loadSpecialImgWithBuffer(vignette, diffusionHighlightsOnly,renderBuffer);

	glGenTextures(1, &scaleTexture);
	glBindTexture(GL_TEXTURE_2D, scaleTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth/SCALE_FACTOR, frameHeight/SCALE_FACTOR, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &scaleFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, scaleFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, scaleTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

	glGenTextures(1, &deartifactTexture);
	glBindTexture(GL_TEXTURE_2D, deartifactTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, outputFrameWidth, outputFrameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &deartifactFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, deartifactFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, deartifactTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

	glGenTextures(1, &remapTexture);
	glBindTexture(GL_TEXTURE_2D, remapTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &remapFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, remapFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, remapTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

	glGenTextures(1, &blurHiliteTexture);
	glBindTexture(GL_TEXTURE_2D, blurHiliteTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth/BLUR_FACTOR, frameHeight/BLUR_FACTOR, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &blurHiliteFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, blurHiliteFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, blurHiliteTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

	glGenTextures(1, &degenTexture);
	glBindTexture(GL_TEXTURE_2D, degenTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &degenFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, degenFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, degenTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

	NSLog(@"initGL");
	NSLog(@" render width:%d, height:%d",frameWidth,frameHeight);
	NSLog(@" output width:%d, height:%d",outputFrameWidth,outputFrameHeight);
}

- (void)loadKeyFrame
{
	if(keyFrameData) return;

	UIImage* keyFrameImage = [[UIImage alloc] initWithContentsOfFile:[Utilities savedKeyFrameImagePath]];
	CGImageRef imageRef = keyFrameImage.CGImage;
	if (!imageRef)
	{
		return;
	}

	CGFloat width = CGImageGetWidth(imageRef);
	CGFloat height = CGImageGetHeight(imageRef);
	keyFrameData = malloc(frameWidth * frameHeight * 4);
//	NSLog(@"loadKeyFrame::Alloca a Image Buffer(%d*%d)",width,height);
	CGContextRef keyFrameContext = CGBitmapContextCreate(keyFrameData, frameWidth, frameHeight, 8, frameWidth * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaNoneSkipLast);
	CGContextSetBlendMode(keyFrameContext, kCGBlendModeCopy);
//#if 0
    if(width<height)
	{
		CGContextTranslateCTM(keyFrameContext, height, 0);
		CGContextRotateCTM(keyFrameContext, M_PI/2);
	}
//#endif
	CGContextDrawImage(keyFrameContext, CGRectMake(0.0, 0.0, width, height), imageRef);
//	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//	[assetsLibrary writeImageToSavedPhotosAlbum:CGBitmapContextCreateImage(keyFrameContext) orientation:ALAssetOrientationUp completionBlock:nil];
	CGContextRelease(keyFrameContext);
}

- (void)loadKeyFrameCrop
{
	if(keyFrameData)
        return;

	UIImage* keyFrameImage = [[UIImage alloc] initWithContentsOfFile:[Utilities savedKeyFrameImagePath]];
	CGImageRef imageRef = keyFrameImage.CGImage;
	if (!imageRef)
	{
		return;
	}

	CGFloat width = CGImageGetWidth(imageRef);
	CGFloat height = CGImageGetHeight(imageRef);

    CGRect originalRect = CGRectMake (0,0,width,height);
    CGRect croppedRect = [Utilities squareCrop:originalRect];
    CGImageRef imageRefCropped = CGImageCreateWithImageInRect(imageRef, croppedRect);
    if (!imageRefCropped)
	{
		return;
	}

	keyFrameData = malloc(frameWidth * frameHeight * 4);
    //	NSLog(@"loadKeyFrame::Alloca a Image Buffer(%d*%d)",width,height);
	CGContextRef keyFrameContext = CGBitmapContextCreate(keyFrameData, frameWidth, frameHeight, 8, frameWidth * 4, CGImageGetColorSpace(imageRefCropped), kCGImageAlphaNoneSkipLast);
	CGContextSetBlendMode(keyFrameContext, kCGBlendModeCopy);
#if 0
	if(width<height)
	{
		CGContextTranslateCTM(keyFrameContext, height, 0);
		CGContextRotateCTM(keyFrameContext, M_PI/2);
	}
#endif
    //CGContextDrawImage(keyFrameContext, CGRectMake(0.0, 0.0, croppedRect.size.width, croppedRect.size.height), imageRefCropped);
    CGContextDrawImage(keyFrameContext, CGRectMake(0.0, 0.0, frameWidth, frameHeight), imageRefCropped);

    CGContextRelease(keyFrameContext);
	CGImageRelease (imageRefCropped);
    //[keyFrameImage release];
}

- (bool)isKeyFrameValid
{
	if(keyFrameData)
        return YES;
    else
        return NO;
}

- (void)unloadKeyFrame
{
	if(keyFrameData)
	{
		free(keyFrameData);
		keyFrameData = NULL;
	}
}

- (void)resetRenderBuffer
{
	if(renderBuffer)
		free(renderBuffer);

    //renderBuffer = malloc(1280*720*glPixelSize); //bret
    //bret movielooks update
	if (IS_IPAD && IS_RETINA)
    {
		// if ipad3 or higher, increase buffer size
		// ipad3 (standard) HD video is 1920x1080
        renderBuffer = malloc(1920*1080*glPixelSize); //bret
	}else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            renderBuffer = malloc(1280*720*glPixelSize); //bret
        else
            renderBuffer = malloc(1920*1080*glPixelSize); //bret
    }

}

- (void)freeRenderBuffer
{
	if(renderBuffer)
	{	free(renderBuffer);
		renderBuffer = NULL;
	}
	if(keyFrameData)
	{
		free(keyFrameData);
		keyFrameData = NULL;
	}
}

- (void)resetFrameSize:(CGSize)frameSize outputFrameSize:(CGSize)outputSize
{
	frameWidth = frameSize.width;
	frameHeight = frameSize.height;
	outputFrameWidth = outputSize.width;
	outputFrameHeight = outputSize.height;
	NSLog(@"resetFrameSize");
	NSLog(@" render width:%d, height:%d",frameWidth,frameHeight);
	NSLog(@" output width:%d, height:%d",outputFrameWidth,outputFrameHeight);

	EAGLSharegroup* group = self.context.sharegroup;

	if (!group)
	{
		NSLog(@"Could not get sharegroup from the main context");
		return;
	}

	EAGLContext *subContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:group];

	if (!subContext || ![EAGLContext setCurrentContext:subContext])
	{
		NSLog(@"Could not create WorkingContext");
		return;
	}

	if (!doQuickRender)
	{
		glBindTexture(GL_TEXTURE_2D, scaleTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth/SCALE_FACTOR, frameHeight/SCALE_FACTOR, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
//		glBindFramebufferOES(GL_FRAMEBUFFER_OES, scaleFBO);
//		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, scaleTexture, 0);
//		rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

		glBindTexture(GL_TEXTURE_2D, deartifactTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, outputFrameWidth, outputFrameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
//		glBindFramebufferOES(GL_FRAMEBUFFER_OES, deartifactFBO);
//		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, deartifactTexture, 0);
//		rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

		glBindTexture(GL_TEXTURE_2D, remapTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
//		glBindFramebufferOES(GL_FRAMEBUFFER_OES, remapFBO);
//		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, remapTexture, 0);
//		rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));

		glBindTexture(GL_TEXTURE_2D, blurHiliteTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth/BLUR_FACTOR, frameHeight/BLUR_FACTOR, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
//		glBindFramebufferOES(GL_FRAMEBUFFER_OES, blurHiliteFBO);
//		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, blurHiliteTexture, 0);
//		rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
	}

	glBindTexture(GL_TEXTURE_2D, degenTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, degenFBO);
//	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, degenTexture, 0);
//	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
}

- (void)loadLookParam:(NSDictionary *)lookDic withMode:(VideoMode)mode
{
	diffusionSize = [[lookDic objectForKey:kLookDiffusionSize] intValue];
	diffusionOpacity = [[lookDic objectForKey:kLookDiffusionOpacity] floatValue];
	diffusionHighlightsOnly = [[lookDic objectForKey:kLookDiffusionHighlightsOnly] floatValue];
	preDesatAmount = [[lookDic objectForKey:kLookPreDesatAmount] floatValue];
	vignetteAmount = [[lookDic objectForKey:kLookVignetteAmount] floatValue];
	vignetteAmount = 1.0 - 0.01 * vignetteAmount;
	vignetteFalloff = [[lookDic objectForKey:kLookVignetteFalloff] intValue];
	doQuickRender = [[lookDic objectForKey:kLookQuickRender] boolValue];
	NSLog(@"doQuickRender=%i", doQuickRender);

	NSString *lutFileName = [lookDic objectForKey:kLookFile];
	const char *lut3dPath = [[[NSBundle mainBundle] pathForResource:lutFileName ofType:nil] cStringUsingEncoding:NSASCIIStringEncoding];

	NSString *vignetteName = [NSString stringWithFormat:@"vignette%i", vignetteFalloff];
	const char *vigName = [[[NSBundle mainBundle] pathForResource:vignetteName ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	loadVignetteWithBuffer(specialImg, vigName,renderBuffer);

	loadRemap(specialImg, 100 - diffusionHighlightsOnly);

	loadLookupTable(specialImg, lut3dPath);

	NSString *overlay = [lookDic objectForKey:kLookOverlay];
	if (overlay)
	{
		if((![overlay isEqualToString:@"Night_vision_circle.png"]) && (mode==VideoModeWideSceenPortrait || mode==VideoModeTraditionalPortrait))
			doOverlay = NO;
		else
		{
			doOverlay = YES;
			loadOverlayWithBuffer(overlayImg, overlay,renderBuffer);
		}
	}
	else
		doOverlay = NO;
}


#pragma mark -
#pragma mark Draw

- (void) scale:(float) factor width:(int)imgFrameWidth height:(int)imgFrameHeight img:(GLuint)sourceImg
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, scaleFBO);
	glViewport(0, 0, imgFrameWidth/factor, imgFrameHeight/factor);

    glUseProgram(scaleProgram);

	glActiveTexture(GL_TEXTURE0 + sourceImg);
	glBindTexture(GL_TEXTURE_2D, sourceImg);
	glCheckError();

	glUniform1i(uniforms[UNIFORM_SAMPLER], sourceImg);

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)deartifact
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, deartifactFBO);

	glViewport(0, 0, outputFrameWidth, outputFrameHeight);

    glUseProgram(deartifactProgram);

	glActiveTexture(GL_TEXTURE0 + originalImg);
	glBindTexture(GL_TEXTURE_2D, originalImg);
	glActiveTexture(GL_TEXTURE0 + scaleTexture);
	glBindTexture(GL_TEXTURE_2D, scaleTexture);
	glActiveTexture(GL_TEXTURE0 + specialImg);
    glBindTexture(GL_TEXTURE_2D, specialImg);
	glCheckError();

	glUniform1i(uniforms[UNIFORM_SRC_SAMPLER], originalImg);
	glUniform1i(uniforms[UNIFORM_SCALED_IMG], scaleTexture);
	glUniform1i(uniforms[UNIFORM_SPECIAL_BRIGHTNESS_IMG], specialImg);
	glUniform1f(uniforms[UNIFORM_LOOKS_BRIGHTNESS], looksBrightnessValue);
	glUniform1f(uniforms[UNIFORM_FLIP_PIXEL], doFlipPixel);
//	glUniform1f(uniforms[UNIFORM_DO_QUICK_RENDER], doQuickRender);

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)remap
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, remapFBO);
	glViewport(0, 0, frameWidth, frameHeight);

    glUseProgram(remapProgram);

	glActiveTexture(GL_TEXTURE0 + deartifactTexture);
    glBindTexture(GL_TEXTURE_2D, deartifactTexture);
    glActiveTexture(GL_TEXTURE0 + specialImg);
    glBindTexture(GL_TEXTURE_2D, specialImg);

	glUniform1i(uniforms[UNIFORM_TEMP_IMG], deartifactTexture);
	glUniform1i(uniforms[UNIFORM_SPECIAL_IMG], specialImg);
	glCheckError();

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}

- (void) fastBlur:(int) radius
{
	// Scale down
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, scaleFBO);
	glViewport(0, 0, frameWidth/BLUR_FACTOR, frameHeight/BLUR_FACTOR);

	glUseProgram(scaleProgram);

	glActiveTexture(GL_TEXTURE0 + remapTexture);
	glBindTexture(GL_TEXTURE_2D, remapTexture);
	glCheckError();

	glUniform1i(uniforms[UNIFORM_SAMPLER], remapTexture);

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	int width = frameWidth/BLUR_FACTOR;
	int height = frameHeight/BLUR_FACTOR;
	GLubyte *buffer = (GLubyte*) malloc(width * height * glPixelSize);
	//NSLog(@"fastBlur::Alloca a Image Buffer(%d*%d)",width,height);

	//NSLog(@"fastBlur glReadPixels begin");

	glReadPixels(0, 0, width, height, glPixelFormat, GL_UNSIGNED_BYTE, buffer);

	//NSLog(@"fastBlur glReadPixels completed");

	int remRadius = radius/BLUR_FACTOR;
	GLubyte* buffer_blur1 = nil;
	while ( remRadius > BLUR_SUB_RADIUS1+4 )
	{
		remRadius = remRadius-BLUR_SUB_RADIUS1;

		buffer_blur1 = fast_blur(buffer, BLUR_SUB_RADIUS1, width, height);
		free(buffer);
		buffer = buffer_blur1;
	}

	if ( remRadius > 4 )
	{
		buffer_blur1 = fast_blur(buffer, remRadius-4, width, height);
		free(buffer);
		buffer = buffer_blur1;

		remRadius = 4;
	}

	if ( remRadius > 0 )
	{
		buffer_blur1 = fast_blur(buffer, remRadius, width, height);
		free(buffer);
		buffer = buffer_blur1;
	}

	glBindTexture(GL_TEXTURE_2D, blurHiliteTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, buffer);
	free(buffer);

	//NSLog(@"fastBlur blurring completed");
}

- (void)lastphase
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, degenFBO);
	glViewport(0, 0, outputFrameWidth, outputFrameHeight);

    glUseProgram(lastphaseProgram);

	glActiveTexture(GL_TEXTURE0 + originalImg);
	glBindTexture(GL_TEXTURE_2D, originalImg);

	glActiveTexture(GL_TEXTURE0 + deartifactTexture);
    glBindTexture(GL_TEXTURE_2D, deartifactTexture);

	glActiveTexture(GL_TEXTURE0 + remapTexture);
    glBindTexture(GL_TEXTURE_2D, remapTexture);

	glActiveTexture(GL_TEXTURE0 + blurHiliteTexture);
    glBindTexture(GL_TEXTURE_2D, blurHiliteTexture);

	glActiveTexture(GL_TEXTURE0 + specialImg);
    glBindTexture(GL_TEXTURE_2D, specialImg);

	glActiveTexture(GL_TEXTURE0 + overlayImg);
    glBindTexture(GL_TEXTURE_2D, overlayImg);

	glUniform1f(uniforms[UNIFORM_LOOKS_STRENGTH], looksStrengthValue);
	glUniform1i(uniforms[UNIFORM_LAST_SPECIAL], specialImg);
	if (!doQuickRender)
	{
		glUniform1i(uniforms[UNIFORM_LAST_DEARTIFACT], deartifactTexture);
	}
	else
	{
		glUniform1i(uniforms[UNIFORM_LAST_DEARTIFACT], originalImg);
	}

	glUniform1i(uniforms[UNIFORM_LAST_REMAP], remapTexture);
	glUniform1i(uniforms[UNIFORM_LAST_BLUR_HILITE], blurHiliteTexture);
	glUniform1i(uniforms[UNIFORM_LAST_OVERLAY], overlayImg);
	glUniform1f(uniforms[UNIFORM_DIFFUSION_OPACITY], diffusionOpacity);
	glUniform1f(uniforms[UNIFORM_PREDESAT_AMOUNT], preDesatAmount);
	glUniform1f(uniforms[UNIFORM_VIGNETTE_AMOUNT], vignetteAmount);
	glUniform1f(uniforms[UNIFORM_DO_OVERLAY], doOverlay);
	glUniform1f(uniforms[UNIFORM_FLIP_PIXEL2], doFlipPixel);
	glUniform1f(uniforms[UNIFORM_DO_QUICK_RENDER2], doQuickRender);
	glUniform1f(uniforms[UNIFORM_LOOKS_BRIGHTNESS2], looksBrightnessValue);
	glUniform1f(uniforms[UNIFORM_DIFFUSION_SIZE], diffusionSize*1.0);

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (BOOL)frameProcessing:(GLubyte *)original toDest:(GLubyte *)dest flipPixel:(BOOL)doInvert;
{
	doFlipPixel = doInvert;

	[EAGLContext setCurrentContext:context];

	glBindTexture(GL_TEXTURE_2D, originalImg);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, original);

	if (!doQuickRender)
	{
		[self scale:SCALE_FACTOR width:frameWidth height:frameHeight img:originalImg];
		//NSLog(@"scale completed");

		[self deartifact];
		//NSLog(@"deartifact completed");

		[self remap];
		//NSLog(@"remap completed");

		if ( diffusionSize > 0 )
		{
			[self fastBlur:diffusionSize ];
			//NSLog(@"fastBlur completed");
		}

	}

	// flag to turn lastPhase on/off when debugging
	BOOL doLastPhase = true;
	if (doLastPhase) {
		[self lastphase];
	}
	//NSLog(@"lastphase completed");

	//NSLog(@"glReadPixels begin");
	glReadPixels(0, 0, outputFrameWidth, outputFrameHeight, glPixelFormat, GL_UNSIGNED_BYTE, dest);
	//NSLog(@"glReadPixels end");

	//[self saveImage];

	return YES;
}

- (CGImageRef)frameProcessingAndReturnImage:(GLubyte *)original flipPixel:(BOOL)doInvert
{
//	unsigned char* tmpBuffer = malloc(frameWidth*frameHeight * 4);

	[self frameProcessing:keyFrameData toDest:renderBuffer flipPixel:doInvert];

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
/*
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, tmpBuffer, frameWidth*frameHeight * 4, MyCGDataProviderReleaseDataCallback);
	CGImageRef imageRef =  CGImageCreate(frameWidth, frameHeight, 8, 32, frameWidth*4, colorSpace, kCGImageAlphaPremultipliedLast, provider, NULL, NO, kCGRenderingIntentDefault);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	UIImage* resultImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return resultImage;
*/

	CGContextRef imgCGContext = CGBitmapContextCreate (renderBuffer, frameWidth, frameHeight, 8, frameWidth*glPixelSize, colorSpace, glImageAlphaNoneSkipLast);

	CGImageRef imgRef = CGBitmapContextCreateImage(imgCGContext);
//	UIImage* resultImage = [[UIImage alloc] initWithCGImage:imgRef];
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(imgCGContext);
	return imgRef;
//	CGImageRelease(imgRef);
//	free(tmpBuffer);
//	return resultImage;
}


- (int)loadShaderByName:(NSString *)shaderName
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program
    GLuint program = glCreateProgram();

    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader: %@", shaderName);
        return SHADER_ERROR;
    }

    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader: %@", shaderName);
        return SHADER_ERROR;
    }

	// Attach vertex shader to program
    glAttachShader(program, vertShader);

    // Attach fragment shader to program
    glAttachShader(program, fragShader);

    // Bind attribute locations
    // this needs to be done prior to linking
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
	glBindAttribLocation(program, ATTRIB_TEXCOORD, "texcoord");

    // Link program
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %@", shaderName);

        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program!=0)
        {
            glDeleteProgram(program);
            program = 0;
        }

        return SHADER_ERROR;
    }

    // Get uniform locations


    // Release vertex and fragment shaders
    if (vertShader)
	{
		glDeleteShader(vertShader);
	}
    if (fragShader)
	{
	    glDeleteShader(fragShader);
	}

    return program;
}

- (BOOL)loadShaders
{
	scaleProgram = [self loadShaderByName:@"scale"];
	if (scaleProgram)
	{
	 	[self validateProgram:scaleProgram];

		uniforms[UNIFORM_SAMPLER] = glGetUniformLocation(scaleProgram, "sampler");
	}
	else
	{
		return NO;
	}


	deartifactProgram = [self loadShaderByName:@"deartifact"];
	if (deartifactProgram)
	{
		[self validateProgram:deartifactProgram];

		uniforms[UNIFORM_SRC_SAMPLER] = glGetUniformLocation(deartifactProgram, "srcSampler");
		uniforms[UNIFORM_SCALED_IMG] = glGetUniformLocation(deartifactProgram, "scaledImg");
		uniforms[UNIFORM_SPECIAL_BRIGHTNESS_IMG] = glGetUniformLocation(deartifactProgram, "specialImg");
		uniforms[UNIFORM_LOOKS_BRIGHTNESS] = glGetUniformLocation(deartifactProgram, "looksBrightness");
		uniforms[UNIFORM_FLIP_PIXEL] = glGetUniformLocation(deartifactProgram, "flipPixel");
//		uniforms[UNIFORM_DO_QUICK_RENDER] = glGetUniformLocation(deartifactProgram, "doQuickRender");
	}
	else
	{
		return NO;
	}


	remapProgram = [self loadShaderByName:@"remap"];
	if (remapProgram)
	{
	 	[self validateProgram:remapProgram];

		uniforms[UNIFORM_SPECIAL_IMG] = glGetUniformLocation(remapProgram, "specialImg");
		uniforms[UNIFORM_TEMP_IMG] = glGetUniformLocation(remapProgram, "tempImg");
	}
	else
	{
		return NO;
	}

	lastphaseProgram = [self loadShaderByName:@"lastphase"];
	if (lastphaseProgram)
	{
		[self validateProgram:lastphaseProgram];

		uniforms[UNIFORM_LAST_SPECIAL] = glGetUniformLocation(lastphaseProgram, "specialImg");
		uniforms[UNIFORM_LAST_DEARTIFACT] = glGetUniformLocation(lastphaseProgram, "deartifactTexture");
		uniforms[UNIFORM_LAST_REMAP] = glGetUniformLocation(lastphaseProgram, "remapTexture");
		uniforms[UNIFORM_LAST_BLUR_HILITE] = glGetUniformLocation(lastphaseProgram, "blurHiliteTexture");
		uniforms[UNIFORM_LAST_OVERLAY] = glGetUniformLocation(lastphaseProgram, "overlayImg");
		uniforms[UNIFORM_LOOKS_STRENGTH] = glGetUniformLocation(lastphaseProgram, "looksStrength");
		uniforms[UNIFORM_DIFFUSION_OPACITY] = glGetUniformLocation(lastphaseProgram, "diffusionOpacity");
		uniforms[UNIFORM_PREDESAT_AMOUNT] = glGetUniformLocation(lastphaseProgram, "presatAmount");
		uniforms[UNIFORM_VIGNETTE_AMOUNT] = glGetUniformLocation(lastphaseProgram, "vignetteAmount");
		uniforms[UNIFORM_DO_OVERLAY] = glGetUniformLocation(lastphaseProgram, "doOverlay");
		uniforms[UNIFORM_FLIP_PIXEL2] = glGetUniformLocation(lastphaseProgram, "flipPixel2");
		uniforms[UNIFORM_DO_QUICK_RENDER2] = glGetUniformLocation(lastphaseProgram, "doQuickRender2");
		uniforms[UNIFORM_LOOKS_BRIGHTNESS2] = glGetUniformLocation(lastphaseProgram, "looksBrightness2");
		uniforms[UNIFORM_DIFFUSION_SIZE] = glGetUniformLocation(lastphaseProgram, "diffusionSize");
	}
	else
	{
		return NO;
	}

	return YES;
}

- (void)deleteShaders
{
	if (scaleProgram)
    {
        glDeleteProgram(scaleProgram);
        scaleProgram = 0;
    }

	if (deartifactProgram)
    {
        glDeleteProgram(deartifactProgram);
        deartifactProgram = 0;
    }

	if (remapProgram)
    {
        glDeleteProgram(remapProgram);
        remapProgram = 0;
    }

	if (downsampleProgram)
    {
        glDeleteProgram(downsampleProgram);
        downsampleProgram = 0;
    }

	if (lastphaseProgram)
    {
        glDeleteProgram(lastphaseProgram);
        lastphaseProgram = 0;
    }
}

- (void)dealloc
{
	glDeleteTextures(1, &specialImg);
	glDeleteTextures(1, &originalImg);
	glDeleteTextures(1, &overlayImg);
	glDeleteTextures(1, &scaleTexture);
	glDeleteTextures(1, &deartifactFBO);
	glDeleteTextures(1, &remapTexture);
	glDeleteTextures(1, &blurHiliteTexture);
	glDeleteTextures(1, &degenTexture);
	if(renderBuffer)
		free(renderBuffer);
	if(keyFrameData)
		free(keyFrameData);
}

@end
