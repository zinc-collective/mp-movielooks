//
//  Renderer.m
//  MobileLooks
//
//  Created by George on 11/5/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "Renderer.h"

const GLfloat vertices[] =
{
	-1.0f, -1.0f,
	1.0f,  -1.0f,
	-1.0f,  1.0f,
	1.0f,   1.0f,
};

const GLfloat texcoords[] =
{
	0.0f, 0.0f,
	1.0f, 0.0f,
	0.0f, 1.0f,
	1.0f, 1.0f,
};

@implementation Renderer

@synthesize context;
@synthesize looksStrengthValue;
@synthesize looksBrightnessValue;
@synthesize doQuickRender;				// doQuickRender allows the renderer and shader to turn certain algorhythm specific features on/off

#pragma mark -
#pragma mark Init

- (void)initGL
{
	NSAssert( 0, @"Renderer#initGL, Overwrite Me!");
}

- (void)loadLookParam:(NSDictionary *)lookDic withMode:(VideoMode)mode
{
	NSAssert( 0, @"Renderer#loadLookParam:, Overwrite Me!");
}

- (void)resetFrameSize:(CGSize)frameSize outputFrameSize:(CGSize)outputSize
{
	NSAssert( 0, @"Renderer#resetFrameSize:outputFrameSize:, Overwrite Me!");
}

- (id)initWithFrameSize:(CGSize)frameSize outputFrameSize:(CGSize)outputSize
{
	if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
        {
            return nil;
        }
		
		frameWidth = frameSize.width;
		frameHeight = frameSize.height;
		outputFrameWidth = outputSize.width;
		outputFrameHeight = outputSize.height;
		looksStrengthValue = 1.0;
		looksBrightnessValue = 0.5;
		doQuickRender = TRUE;
		
		[self initGL];
	}
	
    return self;
}

- (id)initWithFrameSize:(CGSize)frameSize
{
    return [self initWithFrameSize:frameSize outputFrameSize:frameSize];
}

- (id)init
{
    return [self initWithFrameSize:CGSizeMake(FRAME_WIDTH_DEFAULT, FRAME_HEIGHT_DEFAULT)];
}

- (BOOL)frameProcessing:(GLubyte *)original toDest:(GLubyte *)dest flipPixel:(BOOL)doInvert
{
	NSAssert( 0, @"Render#frameProcessing:toDest:flipPixel, Overwrite Me!");
	return FALSE;
}

// removing this overloaded function as an optimization -- use the other version directly instead
/* - (BOOL)frameProcessing:(GLubyte *)original flipPixel:(BOOL)doInvert
{
	return [self frameProcessing:original toDest:original flipPixel:doInvert];
}
*/

- (void) saveImage
{
	CGRect sourceRect =CGRectMake(0, 0, outputFrameWidth, outputFrameHeight);
	
	GLubyte *buffer = (GLubyte*) malloc(sourceRect.size.width*sourceRect.size.height*glPixelSize);
    memset(buffer, 0, sourceRect.size.width*sourceRect.size.height*glPixelSize);
	
	NSLog(@"glReadPixels begin");
	
	glReadPixels(sourceRect.origin.x,
				 sourceRect.origin.y,
				 sourceRect.size.width,
				 sourceRect.size.height,
				 glPixelFormat,
				 GL_UNSIGNED_BYTE,
				 buffer);
	
	NSLog(@"saveImage begin");
	
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, 
															  buffer, 
															  sourceRect.size.width*sourceRect.size.height*glPixelSize,
															  NULL);
	
	CGImageRef iref = CGImageCreate(sourceRect.size.width,
									sourceRect.size.height,
									8,
									32,
									sourceRect.size.width*glPixelSize,
									CGColorSpaceCreateDeviceRGB(),
									glImageAlphaLast,
									provider,
									NULL,
									NO,
									kCGRenderingIntentDefault);
	
	
	size_t width         = CGImageGetWidth(iref);
	size_t height        = CGImageGetHeight(iref);
	
	//NSLog(@"width=%i, height=%i", width, height);
	
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
 	CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, width, height), iref);
	UIImage* outputImage =  UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
 	CGDataProviderRelease(provider);
	CGImageRelease(iref);
 	free(buffer);
	buffer = NULL;
	
	UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil);
}

#pragma mark -
#pragma mark Load Shader

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
	
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
#if GL_DEBUG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
	
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
	
    glLinkProgram(prog);
	
#if GL_DEBUG
	GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
	
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
#if GL_DEBUG
    GLint logLength, status;
	
	glCheckError();
	
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
	NSLog(@"Failed to validate program: %d", prog);
        return FALSE;
	}
#endif
	
    return TRUE;
}

- (int)loadShaderByName:(NSString *)shaderName
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
	
    // Create shader program
    GLuint program = glCreateProgram();
	
    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader: %@", shaderName);
        return SHADER_ERROR;
    }
	
    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader: %@", shaderName);
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
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return SHADER_ERROR;
    }
	
    // Get uniform locations
//	if ([shaderName compare:@"fastlook"] == NSOrderedSame)
//	{
//		
//	}
//	else
//	{
//		return SHADER_ERROR;
//	}
	
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
	NSAssert( 0, @"Renderer#loadShaders, Overwrite Me!");
	return FALSE;
}

- (void)deleteShaders
{
	NSAssert( 0, @"Renderer#deleteShaders, Overwrite Me!");
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
	
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
	
	[self deleteShaders];
	
    // Tear down context
    if ([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
    context = nil;
	
}

@end
