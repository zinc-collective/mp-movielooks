//
//  Renderer.h
//  MobileLooks
//
//  Created by George on 10/19/10.
//  Copyright RED/SAFI 2010. All rights reserved.
//
//bret hd
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Texture.h"
//bret hd
#define SHADER_ERROR	0

#define FRAME_WIDTH_DEFAULT		1280
#define FRAME_HEIGHT_DEFAULT	720
//#define FRAME_WIDTH_DEFAULT		1920
//#define FRAME_HEIGHT_DEFAULT	1080

enum Attribute
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

typedef enum VideoMode
{
	VideoModeWideSceenLandscape,
	VideoModeWideSceenPortrait,
	VideoModeTraditionalLandscape,
	VideoModeTraditionalPortrait
} VideoMode;


@interface Renderer : NSObject
{
@protected
    EAGLContext *context;
	
	GLint frameWidth;
    GLint frameHeight;
	
	GLint outputFrameWidth;
    GLint outputFrameHeight;
	
	float looksStrengthValue;
	float looksBrightnessValue;
	
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	BOOL doQuickRender;
}

@property (nonatomic, assign) EAGLContext *context;
@property (nonatomic) float looksStrengthValue;
@property (nonatomic) float looksBrightnessValue;
@property (nonatomic) BOOL doQuickRender;

- (id)initWithFrameSize:(CGSize)frameSize;
- (id)initWithFrameSize:(CGSize)frameSize outputFrameSize:(CGSize)outputSize;
- (void)resetFrameSize:(CGSize)frameSize outputFrameSize:(CGSize)outputSize;

- (void)loadLookParam:(NSDictionary *)lookDic withMode:(VideoMode)mode;

- (BOOL)frameProcessing:(GLubyte *)original toDest:(GLubyte *)dest flipPixel:(BOOL)doInvert;

#pragma mark -
#pragma mark Shader
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (int)loadShaderByName:(NSString *)shaderName;

- (void) saveImage;

@end
