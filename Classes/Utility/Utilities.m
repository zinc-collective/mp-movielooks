//
//  Utilities.m
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <CommonCrypto/CommonDigest.h>

static NSURL* g_selectedVideoURL = nil;
static NSString* g_selectedVideoTitle = nil;

@implementation Utilities

+(NSString *)md5Encode:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString *string = [NSString stringWithFormat:
						@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
						result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
						];
    return [string lowercaseString];
}

+(NSString *)bundlePath:(NSString *)fileName {
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+(NSString *)savedKeyFrameImagePath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"video_choosed_key_frame.png"];	
	return imagePath;
}

+(NSString *)cachedThumbnailPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	return documentsDirectory;
}

+(NSString *)savedVideoPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *videoPath = [documentsDirectory stringByAppendingPathComponent:@"video_choosed.mov"];
	
	return videoPath;
}

+(NSString *)trimedVideoPath:(NSString*)originPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if([originPath isEqualToString:[documentsDirectory stringByAppendingPathComponent:@"video_choosed1.mov"]])
	{
		return [documentsDirectory stringByAppendingPathComponent:@"video_choosed2.mov"];
	}
	else if([originPath isEqualToString:[documentsDirectory stringByAppendingPathComponent:@"video_choosed2.mov"]])
	{	
		return [documentsDirectory stringByAppendingPathComponent:@"video_choosed1.mov"];
	}
	else {
		return [documentsDirectory stringByAppendingPathComponent:@"video_choosed1.mov"];
	}
	return nil;
}

+(NSString *)selectedVideoTitle:(NSString*)title{
	if(title!=nil)
	{
		g_selectedVideoTitle = [title copy];
	}
	return g_selectedVideoTitle;
}

+(NSURL *)selectedVideoPathWithURL:(NSURL*)url{
	if(url!=nil)
	{
		g_selectedVideoURL = [url copy];
	}
	return g_selectedVideoURL; 
}

+(NSData*)extractVideoDataFromAsset:(ALAsset*)asset{
	NSData *data = nil;
	
	if (asset) {
		ALAssetRepresentation *rep = [asset defaultRepresentation];
		NSUInteger bufferSize = (NSUInteger) rep.size;
		if (bufferSize > 0) {
			Byte *buffer = (Byte*)malloc(bufferSize);
			NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:bufferSize error:nil];
			data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
		}
	}
	
	return data;
}

+(NSFileHandle *)fileHandleForReadingFromAssetURL:(NSURL*)url
{
	__block NSFileHandle *fileHandle = nil;
	
	NSError *error = nil;
	fileHandle = [NSFileHandle fileHandleForReadingFromURL:url error:&error];

	if (fileHandle == nil) {
		ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:url resultBlock:^(ALAsset *asset) {
			ALAssetRepresentation *rep = [asset defaultRepresentation];
			NSError *error2 = nil;
			fileHandle = [NSFileHandle fileHandleForReadingFromURL:[rep url] error:&error2];
			
		} failureBlock:^(NSError *error) {
			NSLog(@"Failed to get fileHandleForReadingFromAssetURL");
		}];
	}
	
	return fileHandle;
}

+(CGRect)resizeToFit:(CGRect)inner :(CGRect)outer
{
	BOOL maintainAspectRatio = YES;
	BOOL allowUpscale = NO;
	BOOL center = YES;
	
	CGFloat targetX = outer.origin.x;
	CGFloat targetY = outer.origin.y;
	CGFloat targetW = outer.size.width;
	CGFloat targetH = outer.size.height;
	
	CGFloat innerW = inner.size.width;
	CGFloat innerH = inner.size.height;
	CGFloat outerW = outer.size.width;
	CGFloat outerH = outer.size.height;

	if (maintainAspectRatio) {
		CGFloat innerAR = [self safeDivide:innerW :innerH: 1];
		CGFloat outerAR = [self safeDivide:outerW :outerH: 1];
		if (innerAR >= outerAR) {
			targetW = outerW;
			targetH = targetW / innerAR;
		} else {
			targetH = outerH;
			targetW = targetH * innerAR;
		}

		if (!allowUpscale && (targetW > innerW || targetH > innerH)) {
			targetW = innerW;
			targetH = innerH;
		}
	} else {
		if (allowUpscale) {
			targetW = outerW;
			targetH = outerH;			
		} else {
			targetW = MIN(innerW, outerW);
			targetH = MIN(innerH, outerH);
		}
	}
	
	if (center) {
		targetX = (outerW - targetW) / 2.0 + outer.origin.x;
		targetY = (outerH - targetH) / 2.0 + outer.origin.y;
	}
	
	return CGRectMake(targetX, targetY, targetW, targetH);
}

+(CGRect)squareCrop:(CGRect)source
{
    CGFloat offsetx = 0.0f;
    CGFloat offsety = 0.0f;
    CGFloat squarelength;
    
    if ( source.size.width > source.size.height )
    {
        offsetx = (source.size.width - source.size.height)/2.0f;
        squarelength = source.size.height;
    }else
    {
        offsety = (source.size.height - source.size.width)/2.0f;
        squarelength = source.size.width;
    }
    
	return CGRectMake(offsetx, offsety, squarelength, squarelength);
}
    
    
+(CGFloat)safeDivide:(CGFloat)dividend :(CGFloat)divisor :(CGFloat)defaultErrorValue
{
	if (divisor == 0 || isnan(dividend) || isnan(divisor)) { return defaultErrorValue; }
    return dividend / divisor;
}

@end
