//
//  Utilities.h
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface Utilities : NSObject
{

}
+(NSString *)cachedThumbnailPath;
+(NSString *)md5Encode:(NSString *)str;
+(NSString *)bundlePath:(NSString *)fileName;
+(NSString *)documentsPath:(NSString *)fileName;

+(NSString *)savedKeyFrameImagePath;
+(NSString *)savedVideoPath;

+(NSString *)selectedVideoTitle:(NSString*)title;
+(NSString *)trimedVideoPath:(NSString*)originPath;
+(NSURL *)selectedVideoPathWithURL:(NSURL*)url;
+(NSFileHandle *)fileHandleForReadingFromAssetURL:(NSURL*)url;
+(NSData *)extractVideoDataFromAsset:(ALAsset*)asset;
+(CGRect)resizeToFit:(CGRect)inner :(CGRect)outer;
+(CGRect)squareCrop:(CGRect)source;
+(CGFloat)safeDivide:(CGFloat)dividend :(CGFloat)divisor :(CGFloat)defaultErrorValue;


@end
