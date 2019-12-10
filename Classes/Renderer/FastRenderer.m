//
//  FastRenderer.m
//  MobileLooks
//
//  Created by George on 10/26/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "FastRenderer.h"

GLuint fastlookProgram;

// uniform index
enum
{
    UNIFORM_ORIGINAL_FRAME,
	UNIFORM_LOOKUP_TABLE,
	UNIFORM_LOOKS_STRENGTH,
	UNIFORM_LOOKS_BRIGHTNESS,
    NUM_UNIFORMS
};

GLint uniforms2[NUM_UNIFORMS];

GLuint originalTexture;
GLuint lutTexture;

GLuint fastlookTexture, fastlookFBO;

extern GLfloat vertices[];
extern GLfloat texcoords[];

@implementation FastRenderer

- (void)initGL
{
	glGenFramebuffers(1, &defaultFramebuffer);
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);

	//	const char *original = [[[NSBundle mainBundle] pathForResource:@"frame" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	//	const char *original = [[Utilities savedKeyFrameImagePath] cStringUsingEncoding:NSASCIIStringEncoding];
	//	originalImg = loadTexture(original);
	glGenTextures(1, &originalTexture);
	glBindTexture(GL_TEXTURE_2D, originalTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	//	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, FRAME_WIDTH, FRAME_HEIGHT, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);

	glGenTextures(1, &fastlookTexture);
	glBindTexture(GL_TEXTURE_2D, fastlookTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, outputFrameWidth, outputFrameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, NULL);
	glGenFramebuffersOES(1, &fastlookFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fastlookFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, fastlookTexture, 0);
	rt_assert(GL_FRAMEBUFFER_COMPLETE_OES == glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
}

- (void)loadLookParam:(NSDictionary *)lookDic
{
	NSString *lutFileName = [lookDic objectForKey:kLookFile];
	const char *lut3dPath = [[[NSBundle mainBundle] pathForResource:lutFileName ofType:nil] cStringUsingEncoding:NSASCIIStringEncoding];

	lutTexture = loadFastLookupTable(lut3dPath);
}

#pragma mark -
#pragma mark Draw

- (void) fastLUT
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fastlookFBO);
	glViewport(0, 0, outputFrameWidth, outputFrameHeight);

    glUseProgram(fastlookProgram);

	glActiveTexture(GL_TEXTURE0 + originalTexture);
	glBindTexture(GL_TEXTURE_2D, originalTexture);

	glActiveTexture(GL_TEXTURE0 + lutTexture);
	glBindTexture(GL_TEXTURE_2D, lutTexture);
	glCheckError();

	glUniform1i(uniforms2[UNIFORM_ORIGINAL_FRAME], originalTexture);
	glUniform1i(uniforms2[UNIFORM_LOOKUP_TABLE], lutTexture);
	glUniform1f(uniforms2[UNIFORM_LOOKS_STRENGTH], looksStrengthValue);
	glUniform1f(uniforms2[UNIFORM_LOOKS_BRIGHTNESS], looksBrightnessValue);

	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glCheckError();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (BOOL)frameProcessing:(GLubyte *)original toDest:(GLubyte *)dest flipPixel:(BOOL)doInvert
{
	// doInvert === YES, so ignore it.

	[EAGLContext setCurrentContext:context];

	glBindTexture(GL_TEXTURE_2D, originalTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, frameWidth, frameHeight, 0, glPixelFormat, GL_UNSIGNED_BYTE, original);

	[self fastLUT];
	//NSLog(@"fastLUT completed");

	//NSLog(@"glReadPixels begin");
	glReadPixels(0, 0, outputFrameWidth, outputFrameHeight, glPixelFormat, GL_UNSIGNED_BYTE, original);
	//NSLog(@"glReadPixels end");

	//	static int test = 0;
	//	if (test == 0)
	//	{
	//		test = 1;
	//		[self saveImage];
	//	}

	return YES;
}

- (BOOL)loadShaders
{
	fastlookProgram = [self loadShaderByName:@"fastlook"];
	if (fastlookProgram)
	{
		// Get uniform locations
		uniforms2[UNIFORM_ORIGINAL_FRAME] = glGetUniformLocation(fastlookProgram, "srcQuarter");
		uniforms2[UNIFORM_LOOKUP_TABLE] = glGetUniformLocation(fastlookProgram, "lutSampler");
		uniforms2[UNIFORM_LOOKS_STRENGTH] = glGetUniformLocation(fastlookProgram, "looksStrengthFast");
		uniforms2[UNIFORM_LOOKS_BRIGHTNESS] = glGetUniformLocation(fastlookProgram, "looksBrightnessFast");
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)deleteShaders
{
	if (fastlookProgram)
    {
        glDeleteProgram(fastlookProgram);
        fastlookProgram = 0;
    }
}

@end

