/*
     File: Texture.m
 Abstract: n/a
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import "Texture.h"
//bret hd


GLuint loadTexture(const char *c_path)
{
	NSString *path = [[NSString alloc] initWithCString:c_path];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[path release];
		[image release];
		return 0;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	GLubyte *data = malloc(width * height * glPixelSize);
	
	CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == data)
	{
		[path release];
		[image release];
		return 0;
	}
	
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_2D, texID);
	// Set filtering parameters appropriate for this application (image processing on screen-aligned quads.)
	// Depending on your needs, you may prefer linear filtering, or mipmap generation.
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, data);
	
	[path release];
	[image release];
	free(data);
	
	return texID;
}

void generateRemapLUT(unsigned char *data, int lutDepth, float range)
{
	// remap LUT
	float mapPoint = 1.0f - 0.01 * range;
	float kk = 1.0f / (1.0f - mapPoint);
	float bb = -mapPoint * kk;
	int tempInt;
	unsigned char *remap = data;
	for (int i = 0; i < 256; i++)
	{
		tempInt = i * kk + bb*255;
		if (tempInt<0) remap[glPixelSize*i]=0;
		else if (tempInt>255) remap[glPixelSize*i] = 255;
		else remap[glPixelSize*i] = tempInt;
		
		remap[glPixelSize*i+1] = remap[glPixelSize*i+2] = remap[glPixelSize*i];
	}
	
	for (int row = 1; row < lutDepth; row++)
	{
		memcpy(remap + 256*row*glPixelSize, remap, 256*glPixelSize);
	}
}

void generateDarkenLUT(unsigned char *data)
{
	//load darken LUT
	//
	const char *darkenCStr = [[[NSBundle mainBundle] pathForResource:@"darkenLUT" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *filepathString = [NSString stringWithCString:darkenCStr encoding:NSUTF8StringEncoding];
	UIImage* darkenImg = [[UIImage alloc] initWithContentsOfFile:filepathString];
	
	CFDataRef darkenLUTData = CGDataProviderCopyData(CGImageGetDataProvider(darkenImg.CGImage));
	
	int *m_darkenLUTdata = (int *)CFDataGetBytePtr(darkenLUTData);
	uint8_t *darkenb = (unsigned char *)&m_darkenLUTdata[0];
	unsigned char *darken = data;
	
	for (int i = 0; i < 256*glPixelSize; i++)
	{
		*darken++ = *darkenb++;
		// *darken++ = *darkenb++;
		// *darken++ = *darkenb++;
		// *darken++ = *darkenb++;
	}		
	CFRelease(darkenLUTData);
	
	darken = data;
	for (int row = 1; row < 128; row++)
	{
		memcpy(darken + 1280*row*glPixelSize, darken, 256*glPixelSize);
	}
	[darkenImg release];
}

void generateBrightnessLUT(unsigned char *data)
{
	//load Darken LUT
	//
	const char *darken_01CStr = [[[NSBundle mainBundle] pathForResource:@"mobileLookdarken_01" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *filepathString1 = [NSString stringWithCString:darken_01CStr encoding:NSUTF8StringEncoding];
	UIImage* darkenImg = [[UIImage alloc] initWithContentsOfFile:filepathString1];
	CFDataRef darkenLUTData = CGDataProviderCopyData(CGImageGetDataProvider(darkenImg.CGImage));
	
	//load Brigten LUT
	//
	const char *brighten_01CStr = [[[NSBundle mainBundle] pathForResource:@"mobileLookbrighten_01" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *filepathString2 = [NSString stringWithCString:brighten_01CStr encoding:NSUTF8StringEncoding];
	UIImage* brightenImg = [[UIImage alloc] initWithContentsOfFile:filepathString2];
	CFDataRef brightenLUTData = CGDataProviderCopyData(CGImageGetDataProvider(brightenImg.CGImage));
	
	int *m_darkenLUTdata = (int *)CFDataGetBytePtr(darkenLUTData);
	int *m_brightenLUTdata = (int *)CFDataGetBytePtr(brightenLUTData);
	uint8_t *darkenb = (unsigned char *)&m_darkenLUTdata[0];
	uint8_t *brightenb = (unsigned char *)&m_brightenLUTdata[0];
	unsigned char *darken = data + 1280 * glPixelSize * 256;
	unsigned char *brighten = data + 1280 * glPixelSize * 384;
	for (int i = 0; i < 256 * glPixelSize; i++)
	{
		*darken++ = *darkenb++;
		// *darken++ = *darkenb++;
		// *darken++ = *darkenb++;
		// *darken++ = *darkenb++;
		
		*brighten++ = *brightenb++;
		// *brighten++ = *brightenb++;
		// *brighten++ = *brightenb++;
		// *brighten++ = *brightenb++;
	}
	CFRelease(darkenLUTData);
	CFRelease(brightenLUTData);
	
	darken = data + 1280 * glPixelSize * 256;
	brighten = data + 1280 * glPixelSize * 384;
	for (int row = 1; row < 128; row++)
	{
		memcpy(darken + 1280*row*glPixelSize, darken, 256*glPixelSize);
		memcpy(brighten + 1280*row*glPixelSize, brighten, 256*glPixelSize);
	}
	[darkenImg release];
	[brightenImg release];
}

//void generate3DLUT(unsigned char *data, const char *lut3dPath)
//{
//	// Read 3D LUT
//	float lutf[14739]; //17*17*17*3
//	
//	FILE *file = fopen(lut3dPath, "r");
//	if (file != NULL)
//	{
//		float *lutp = lutf;
//		int count = 0;
//		char lineContent[256];
//		
//		// Skip first 2 rows in .3dl format
//		//
//		if (!fgets(lineContent, sizeof(lineContent), file))
//			return;
//		if (!fgets(lineContent, sizeof(lineContent), file))
//			return;		
//		while (fgets(lineContent, sizeof(lineContent), file) != NULL)
//		{
//			count = sscanf(lineContent, "%f %f %f", lutp, lutp+1, lutp+2);
//			
//			if (count == 3)
//			{
//				lutp += 3;
//			}
//			else
//			{
//				continue;
//			}
//		}
//	}
//	else
//	{
//		return;
//	}
//	
//	
//	unsigned char *lut = data;
//	
//	// Clear to black
//	int offset;
//	for (int g=0; g<32; g++)
//	{
//		offset = (512 + 1280*g);			
//		for (int b=0; b<17; b++)
//		{
//			for (int r=0; r<32; r++)
//			{
//				lut[4*offset] = 0;
//				lut[4*offset+1] = 0;
//				lut[4*offset+2] = 0;
//				offset++;
//			}
//		}
//	}
//	
//	float kCalibration = 1.0 / 4095.0;
//	int offsetf;
//	for (int i=0; i<17; i++)
//	{
//		for (int j=0; j<17; j++)
//		{
//			for (int k=0; k<17; k++)
//			{
//				offset = (512 + i + 32*k + 1280*j) * glPixelSize;
//				offsetf = (k + j*17 + i*289) * 3;
//				lut[offset] = lutf[offsetf] * kCalibration  * 255;
//				lut[offset+1] = lutf[offsetf+1] * kCalibration  * 255;
//				lut[offset+2] = lutf[offsetf+2] * kCalibration  * 255;
//			}
//		}
//	}	
//}

void loadRemap(GLuint specialTexID, float range)
{
	int dataSize = 256 * LUT_DEPTH * glPixelSize;
	
	unsigned char lut[dataSize];
	generateRemapLUT(lut, LUT_DEPTH, range);
	
	// assumes remap texture is 256x4
	glBindTexture(GL_TEXTURE_2D, specialTexID);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 190, 256, 4, glPixelFormat, GL_UNSIGNED_BYTE, lut);
}

void loadLookupTable(GLuint specialTexID, const char *lut3dPath)
{
	// Read 3D LUT File
	float lutf[14739]; //17*17*17*3
	
	FILE *file = fopen(lut3dPath, "r");
	if (file != NULL)
	{
		float *lutp = lutf;
		int count = 0;
		char lineContent[256];
		
		// Skip first 2 rows in .3dl format
		//
		if (!fgets(lineContent, sizeof(lineContent), file))
			return;
		if (!fgets(lineContent, sizeof(lineContent), file))
			return;
		while (fgets(lineContent, sizeof(lineContent), file) != NULL)
		{
			count = sscanf(lineContent, "%f %f %f", lutp, lutp+1, lutp+2);
			
			if (count == 3)
			{
				lutp += 3;
			}
			else
			{
				continue;
			}
		}
	}
	else
	{
		return;
	}

	
	int dataSize = 17 * 32 * 32 * glPixelSize;
	unsigned char lut[dataSize];
	
	// Clear to black
	for (int i=0; i<dataSize; i++)
	{
		lut[i] = 0;
	}
	
	// Set 3D LUT to Texture
	float kCalibration = 1.0 / 4095.0;
	int offset = 0;
	int offsetf = 0;
	for (int i=0; i<17; i++)
	{
		for (int j=0; j<17; j++)
		{
			for (int k=0; k<17; k++)
			{
				offset = (i + k*32 + j*544) * glPixelSize; //544 = 32 * 17
				offsetf = (k + j*17 + i*289) * 3;
				
				lut[offset] = lutf[offsetf] * kCalibration  * 255;		// R
				lut[offset+1] = lutf[offsetf+1] * kCalibration  * 255;		// G
				lut[offset+2] = lutf[offsetf+2] * kCalibration  * 255;		// B
				if (glPixelSize >= 4) {
					lut[offset+3] = 255;									// A
				}
			}
		}
	}
	
	glBindTexture(GL_TEXTURE_2D, specialTexID);
	glTexSubImage2D (GL_TEXTURE_2D, 0, 512, 0, 32*17, 32, glPixelFormat, GL_UNSIGNED_BYTE, lut);
	fclose(file);
	printf("loadLookupTable: %s\n", lut3dPath);
}

GLuint loadFastLookupTable(const char *lut3dPath)
{
	// Read 3D LUT
	float lutf[14739]; //17*17*17*3
	
	FILE *file = fopen(lut3dPath, "r");
	if (file != NULL)
	{
		float *lutp = lutf;
		int count = 0;
		char lineContent[256];
		
		// Skip first 2 rows in .3dl format
		//
		if (!fgets(lineContent, sizeof(lineContent), file))
			return 0;
		if (!fgets(lineContent, sizeof(lineContent), file))
			return 0;
		while (fgets(lineContent, sizeof(lineContent), file) != NULL)
		{
			count = sscanf(lineContent, "%f %f %f", lutp, lutp+1, lutp+2);
			
			if (count == 3)
			{
				lutp += 3;
			}
			else
			{
				continue;
			}
		}
	}
	else
	{
		return 0;
	}
	
	
	int dataSize = 17 * 32 * 32 * glPixelSize;
	unsigned char lut[dataSize];
	
	// Clear to black
	for (int i=0; i<dataSize; i++)
	{
		lut[i] = 0;
	}
	
	// Set 3D LUT to Texture
	float kCalibration = 1.0 / 4095.0;
	int offsetf = 0;
	int offset = 0;
	for (int i=0; i<17; i++)
	{
		for (int j=0; j<17; j++)
		{
			for (int k=0; k<17; k++)
			{
				offset = (i + k*32 + j*544) * glPixelSize; //544 = 32 * 17
				offsetf = (k + j*17 + i*289) * 3;
				
				lut[offset] = lutf[offsetf] * kCalibration  * 255;
				lut[offset+1] = lutf[offsetf+1] * kCalibration  * 255;
				lut[offset+2] = lutf[offsetf+2] * kCalibration  * 255;
				if (glPixelSize >= 4) {
					lut[offset+3] = 255;
				}
			}
		}
	}

	//load Darken LUT
	//
	const char *darken_01CStr = [[[NSBundle mainBundle] pathForResource:@"mobileLookdarken_01" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *filepathString1 = [NSString stringWithCString:darken_01CStr encoding:NSUTF8StringEncoding];
	UIImage* darkenImg = [[UIImage alloc] initWithContentsOfFile:filepathString1];
	CFDataRef darkenLUTData = CGDataProviderCopyData(CGImageGetDataProvider(darkenImg.CGImage));
	
	//load Brigten LUT
	//
	const char *brighten_01CStr = [[[NSBundle mainBundle] pathForResource:@"mobileLookbrighten_01" ofType:@"png"] cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *filepathString2 = [NSString stringWithCString:brighten_01CStr encoding:NSUTF8StringEncoding];
	UIImage* brightenImg = [[UIImage alloc] initWithContentsOfFile:filepathString2];
	CFDataRef brightenLUTData = CGDataProviderCopyData(CGImageGetDataProvider(brightenImg.CGImage));
	
	const unsigned char *darken = CFDataGetBytePtr(darkenLUTData);
	const unsigned char *brighten = CFDataGetBytePtr(brightenLUTData);
	
	for (int row=0; row<glPixelSize; row++)
	{
		memcpy(lut + 544*(19+row)*glPixelSize, darken, 256*glPixelSize);
		memcpy(lut + 544*(26+row)*glPixelSize, brighten, 256*glPixelSize);
	}
	
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, 32*17, 32, 0, glPixelFormat, GL_UNSIGNED_BYTE, lut);
	
	
//	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 19, 256, 4, glPixelFormat, GL_UNSIGNED_BYTE, darken);
//	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 26, 256, 4, glPixelFormat, GL_UNSIGNED_BYTE, brighten);

	CFRelease(darkenLUTData);
	CFRelease(brightenLUTData);	
	[darkenImg release];
	[brightenImg release];
	fclose(file);
	return texID;
}

void loadVignette(GLuint specialTexID, const char *VigName)
{
	NSString *filepathString = [NSString stringWithCString:VigName encoding:NSUTF8StringEncoding];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[image release];
		return;
	}

	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	
	// * 2 by George.
	GLubyte *data = malloc(width * height * glPixelSize);
	CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == data)
	{
		[image release];
		return;
	}
	
	glBindTexture(GL_TEXTURE_2D, specialTexID);
	glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 1280-height, width, height, glPixelFormat, GL_UNSIGNED_BYTE, data);
	[image release];
	free(data);
}

void loadOverlay(GLuint texID, NSString *name)
{
	NSString *filepathString = [[NSBundle mainBundle] pathForResource:name ofType:@""];	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[image release];
		return;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	
	GLubyte *data = malloc(width * height * glPixelSize);
	CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == data)
	{
		[image release];
		return;
	}
	
	glBindTexture(GL_TEXTURE_2D, texID);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, data);
	
	[image release];
	free(data);
}

GLuint loadSpecialImg(const char *name, const float diffusionHighlightsOnly)
{
	NSString *filepathString = [[NSString alloc] initWithCString:name];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[filepathString release];
		[image release];
		return 0;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	
	// * 2 by George.
	GLubyte *data = malloc(width * height * glPixelSize);
	//NSLog(@"loadSpecialImg::Alloca a Image Buffer(%d*%d)",width,height);

	CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == data)
	{
		[filepathString release];
		[image release];
		return 0;
	}
	
	//generateRemapLUT(data + 1280 * glPixelSize * 128, diffusionHighlightsOnly);
	generateDarkenLUT(data);
	generateBrightnessLUT(data);
//	if (lut3dPath != NULL)
//	{
//		generate3DLUT(data, lut3dPath);
//	}
	
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, data);
	
	[filepathString release];
	[image release];
	free(data);
	
	return texID;
}


GLuint loadTextureWithBuffer(const char *c_path, unsigned char* buffer)
{
	NSString *path = [[NSString alloc] initWithCString:c_path];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[path release];
		[image release];
		return 0;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);	
	CGContextRef context = CGBitmapContextCreate(buffer, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == buffer)
	{
		[path release];
		[image release];
		return 0;
	}
	
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_2D, texID);
	// Set filtering parameters appropriate for this application (image processing on screen-aligned quads.)
	// Depending on your needs, you may prefer linear filtering, or mipmap generation.
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, buffer);
	
	[path release];
	[image release];
	
	return texID;
}

GLuint loadSpecialImgWithBuffer(const char *name, const float diffusionHighlightsOnly, unsigned char* buffer)
{
	NSString *filepathString = [[NSString alloc] initWithCString:name];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[filepathString release];
		[image release];
		return 0;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	
	// * 2 by George.	
	CGContextRef context = CGBitmapContextCreate(buffer, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == buffer)
	{
		[filepathString release];
		[image release];
		return 0;
	}
	
	//generateRemapLUT(data + 1280 * glPixelSize * 128, diffusionHighlightsOnly);
	generateDarkenLUT(buffer);
	generateBrightnessLUT(buffer);
	//	if (lut3dPath != NULL)
	//	{
	//		generate3DLUT(data, lut3dPath);
	//	}
	
	GLuint texID;
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, buffer);
	
	[filepathString release];
	[image release];
	
	return texID;
}

void loadOverlayWithBuffer(GLuint texID, NSString *name, unsigned char* buffer)
{
	NSString *filepathString = [[NSBundle mainBundle] pathForResource:name ofType:@""];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[image release];
		return;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);		
	CGContextRef context = CGBitmapContextCreate(buffer, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	//Flip Vertical
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == buffer)
	{
		[image release];
		return;
	}
	
	glBindTexture(GL_TEXTURE_2D, texID);
	glTexImage2D(GL_TEXTURE_2D, 0, glPixelFormat, width, height, 0, glPixelFormat, GL_UNSIGNED_BYTE, buffer);
	
	[image release];
}

void loadVignetteWithBuffer(GLuint specialTexID, const char *VigName, unsigned char* buffer)
{
	NSString *filepathString = [NSString stringWithCString:VigName encoding:NSUTF8StringEncoding];
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:filepathString];
	
	CGImageRef imageRef = image.CGImage;
	if (!imageRef)
	{ 
		[image release];
		return;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	
	// * 2 by George.
	CGContextRef context = CGBitmapContextCreate(buffer, width, height, 8, width * glPixelSize, CGImageGetColorSpace(imageRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
	CGContextRelease(context);
	
	if(NULL == buffer)
	{
		[image release];
		return;
	}
	
	glBindTexture(GL_TEXTURE_2D, specialTexID);
	glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 1280-height, width, height, glPixelFormat, GL_UNSIGNED_BYTE, buffer);
	[image release];
}
