//
//  RenderDefs.h
//  MobileLooks
//
//  Created by Joseph Snow on 6/21/13.
//
//

#ifndef MobileLooks_RenderDefs_h
#define MobileLooks_RenderDefs_h


#define LUT_DEPTH 5
#define USE_ALPHA_CHANNEL 1


#define glPixelFormatRGBA					GL_RGBA
#define glPixelSizeRGBA						4
#define glImageAlphaNoneSkipLastRGBA		kCGImageAlphaNoneSkipLast
#define glImageAlphaPremultipliedLastRGBA	kCGImageAlphaPremultipliedLast
#define glImageAlphaPremultipliedFirstRGBA	kCGImageAlphaPremultipliedFirst
#define glImageAlphaLastRGBA				kCGImageAlphaLast

#define glPixelFormatRGB					GL_RGB
#define glPixelSizeRGB						3
#define glImageAlphaNoneSkipLastRGB			kCGImageAlphaNoneSkipLast	
#define glImageAlphaPremultipliedLastRGB	kCGImageAlphaNoneSkipLast
#define glImageAlphaPremultipliedFirstRGB	kCGImageAlphaNoneSkipLast
#define glImageAlphaLastRGB					kCGImageAlphaNone


// choose between GL_RGBA or GL_RGB
#if USE_ALPHA_CHANNEL
	#define glPixelFormat 					glPixelFormatRGBA
	#define glPixelSize 					glPixelSizeRGBA
	#define glImageAlphaNoneSkipLast 		glImageAlphaNoneSkipLastRGBA
	#define glImageAlphaPremultipliedLast	glImageAlphaPremultipliedLastRGBA
	#define glImageAlphaPremultipliedFirst 	glImageAlphaPremultipliedFirstRGBA
	#define glImageAlphaLast 				glImageAlphaLastRGBA
#else
	#define glPixelFormat 					glPixelFormatRGB
	#define glPixelSize 					glPixelSizeRGB
	#define glImageAlphaNoneSkipLast 		glImageAlphaNoneSkipLastRGB
	#define glImageAlphaPremultipliedLast	glImageAlphaPremultipliedLastRGB
	#define glImageAlphaPremultipliedFirst 	glImageAlphaPremultipliedFirstRGB
	#define glImageAlphaLast 				glImageAlphaLastRGB
#endif



#endif
