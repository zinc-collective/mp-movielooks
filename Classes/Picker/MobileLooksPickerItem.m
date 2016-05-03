//
//  MobileLooksPickerItem.m
//  MobileLooks
//
//  Created by Chen Mike on 3/15/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "MobileLooksPickerItem.h"
#import "VideoThumbnailOperation.h"

#import "PickerSizes.h"
#import "DeviceDetect.h"

@interface AVAsset (AsyncConvenience)
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(CGImageRef thumbnail))block;
- (void)generateTitleInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(NSString* title))block;
@end

@implementation AVAsset (ThumbnailConvenience)
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(CGImageRef thumbnail))block
{
	AVAssetImageGenerator* generator = [[AVAssetImageGenerator allocWithZone:NULL] initWithAsset:self];
	
	[generator setAppliesPreferredTrackTransform:YES];
	[generator setMaximumSize:CGSizeMake(VPICKER_THUMB_WIDTH, VPICKER_THUMB_HEIGHT)];
	
	dispatch_retain(queue);
	
	[generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMake(5, 1)]] completionHandler:
     ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         CGImageRetain(image);
         
         dispatch_async(queue,
                        ^{
                            block(image);
                            
                            CGImageRelease(image);
                            dispatch_release(queue);
                        });
         
         [generator release];
     }];	
}

- (void)generateTitleInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(NSString* title))block
{
	dispatch_retain(queue);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString* title = nil;
                       
                       for (AVMetadataItem* metadata in [self commonMetadata])
                       {
                           if ([[metadata commonKey] isEqualToString:AVMetadataCommonKeyTitle])
                           {
                               title = [metadata stringValue];
                               break;
                           }
                       }
                       
                       dispatch_async(queue, 
                                      ^{
                                          block(title);
                                          dispatch_release(queue);
                                      });
                   });
}
@end


@implementation MobileLooksPickerItem
@synthesize delegate = _delegate;
@synthesize hasThumbnail = mHasThumbnail; 

+(CGImageRef)generateBoard:(CGImageRef)originImg withSize:(CGSize)imgSize
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef imageContext = CGBitmapContextCreate(NULL, imgSize.width, imgSize.height, 8, imgSize.width * glPixelSize, colorSpace, glImageAlphaNoneSkipLast);
		
	CGFloat boardWidth = BORDER_WIDTH; 
	CGRect boardRect = CGRectMake(boardWidth/2, boardWidth/2, imgSize.width-boardWidth, imgSize.height-boardWidth);
	
	CGContextSetRGBStrokeColor(imageContext, 1.0, 1.0, 1.0, 1.0);
	CGContextDrawImage(imageContext, CGRectMake(0, 0, imgSize.width, imgSize.height), originImg);
	CGContextStrokeRectWithWidth(imageContext, boardRect, boardWidth);

	CGImageRef imageBoarded = CGBitmapContextCreateImage(imageContext);
	CGContextRelease(imageContext);
	CGColorSpaceRelease(colorSpace);
	return imageBoarded;
}

-(void)startOpertionOnQueue:(NSOperationQueue*)queue
{
	mHasThumbnail = YES;
	VideoThumbnailOperation* op = [[VideoThumbnailOperation alloc] initWithURL:mURL withBorder:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)];
	op.resultDelegate = self;
	[queue addOperation:op];
	[op release];
}

-(void)loadFromCache:(UIImage*)chachedImage withDurationString:(NSString*)durationStr
{
	iconView.hidden = YES;

	CGSize tPickerItemSize;
	UIButton* button =[UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(pushItemEven:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
//	[button setBackgroundImage:chachedImage forState:UIControlStateNormal];
	[button setImage:chachedImage forState:UIControlStateNormal];
	
	UIView *durationView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 73, 21)];
	UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 67, 21)];
	//UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_audiotrack_video_sm.png"]];
	//imageView.frame = CGRectMake(3, 3, 15, 15);
	
	CGFloat targetW = CGImageGetWidth(chachedImage.CGImage);
	CGFloat targetH = CGImageGetHeight(chachedImage.CGImage);
	if(mPickerItemStyle==PickerItemStyleForIphone)
	{	
		tPickerItemSize = CGSizeMake(VPICKER_THUMB_WIDTH_IPHONE,VPICKER_THUMB_HEIGHT_IPHONE);
		durationView.frame = CGRectMake(0,tPickerItemSize.height-21,tPickerItemSize.width,21);
		labelView.frame = CGRectMake(4, 3, durationView.frame.size.width-4, 18); //15
		button.frame = CGRectMake(0,0,tPickerItemSize.width,tPickerItemSize.height);
	}
	else
	{
		tPickerItemSize = CGSizeMake(VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
		button.frame = CGRectMake((VPICKER_THUMB_WIDTH/2)-targetW/2,(VPICKER_THUMB_HEIGHT/2)-targetH/2,targetW,targetH);
		//durationView.frame = CGRectMake(tPickerItemSize.width/2-targetW/2+BORDER_WIDTH,tPickerItemSize.height/2+targetH/2-21-BORDER_WIDTH,targetW-BORDER_WIDTH*2,21);
		durationView.frame = CGRectMake(tPickerItemSize.width/2-targetW/2+BORDER_WIDTH,tPickerItemSize.height/2+targetH/2-36-BORDER_WIDTH,targetW-BORDER_WIDTH*2,36);
		//labelView.frame  = CGRectMake(4,3,durationView.frame.size.width-8,15);
		labelView.frame  = CGRectMake(4,6,durationView.frame.size.width-8,25);
	}
	
	//durationView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
	durationView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.50];
	durationView.userInteractionEnabled = NO;
	[self addSubview:durationView];
	
	labelView.backgroundColor = [UIColor clearColor];
	labelView.text = durationStr;
	if (IS_IPHONE)
        labelView.font = [UIFont boldSystemFontOfSize:18];
    else
        labelView.font = [UIFont boldSystemFontOfSize:22];
	labelView.textColor	= [UIColor whiteColor];
	labelView.textAlignment = NSTextAlignmentRight;
	[durationView addSubview:labelView];									
	//[durationView addSubview:imageView];
	
	[labelView release];
	//[imageView release];
	[durationView release];
}

-(void)operationFinishedWithOperation:(VideoThumbnailOperation*)resultOpertion
{	
	if([NSThread isMainThread])
	{
		[iconView removeFromSuperview];
		[iconView release];
		
		CGSize tPickerItemSize;
		UIButton* button =[UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(pushItemEven:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[button.layer setContents:(__bridge id) resultOpertion.thumbnailImage.CGImage];
		
		UIView *durationView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 73, 21)];
		UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 67, 21)];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_audiotrack_video_sm.png"]];
		imageView.frame = CGRectMake(3, 3, 15, 15);
		
		CGFloat targetW = CGImageGetWidth(resultOpertion.thumbnailImage.CGImage);
		CGFloat targetH = CGImageGetHeight(resultOpertion.thumbnailImage.CGImage);
		NSUInteger videoSeconds =  CMTimeGetSeconds(resultOpertion.movieDuration);
		if(mPickerItemStyle==PickerItemStyleForIphone)
		{	
			tPickerItemSize = CGSizeMake(VPICKER_THUMB_WIDTH_IPHONE,VPICKER_THUMB_HEIGHT_IPHONE);
			durationView.frame = CGRectMake(0,tPickerItemSize.height-21,tPickerItemSize.width,21);
			//labelView.frame = CGRectMake(4, 3, 65, 15);
			labelView.frame = CGRectMake(4, 3, durationView.frame.size.width-4, 15);
			button.frame = CGRectMake(0,0,tPickerItemSize.width,tPickerItemSize.height);
		}
		else
		{
			tPickerItemSize = CGSizeMake(VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
			button.frame = CGRectMake((VPICKER_THUMB_WIDTH/2)-targetW/2,(VPICKER_THUMB_HEIGHT/2)-targetH/2,targetW,targetH);
			durationView.frame = CGRectMake(tPickerItemSize.width/2-targetW/2+BORDER_WIDTH,tPickerItemSize.height/2+targetH/2-21-BORDER_WIDTH,targetW-BORDER_WIDTH*2,21);
			labelView.frame  = CGRectMake(4,3,durationView.frame.size.width-8,15);
		}
		
		durationView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
		durationView.userInteractionEnabled = NO;
		[self addSubview:durationView];
		
		//AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:mURL options:nil];
		//NSUInteger videoSeconds = CMTimeGetSeconds(avAsset.duration); 
		
		labelView.backgroundColor = [UIColor clearColor];
		labelView.text = [NSString stringWithFormat:@"%02lu:%02lu",videoSeconds/60,videoSeconds%60];
		labelView.font = [UIFont boldSystemFontOfSize:12];
		labelView.textColor	= [UIColor whiteColor];
		labelView.textAlignment = NSTextAlignmentRight;
		[durationView addSubview:labelView];									
		[durationView addSubview:imageView];
		
		[labelView release];
		[imageView release];
		[durationView release];
	}
	else {
		//if(!mIsCanceled)
		//{
		//	NSString* md5EncodePath = [Utilities md5Encode:[mURL resourceSpecifier]];
		//	NSString  *jpgPath = [[Utilities cachedThumbnailPath] stringByAppendingPathComponent:md5EncodePath];
		//	[UIImageJPEGRepresentation(operation.thumbnailImage, 1.0) writeToFile:jpgPath atomically:YES];
		//}
		[self performSelectorOnMainThread:@selector(operationFinishedWithOperation:) withObject:resultOpertion waitUntilDone:NO];
	}
}

-(void)operationFinished:(VideoThumbnailOperation*)operation
{
	if (operation.isCanceled) return;
	[self operationFinishedWithOperation:operation];
}

- (id)initWithURL:(NSURL*)URL withStyle:(PickerItemStyle)style withFrame:(CGRect)itemFrame
{
	if (!URL)
		return [super init];
    
	if ((self = [super init]))
	{
		NSZone* zone = [self zone];
		
		mURL = [URL copyWithZone:zone];
		mPickerItemStyle = style;
		mHasThumbnail = NO;
	}
	CGFloat iconSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?32:16;
	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(itemFrame.size.width/2-8, itemFrame.size.height/2-8, iconSize, iconSize)];
	iconView.image = [UIImage imageNamed:@"icon_audiotrack_video_sm.png"];
	[self addSubview:iconView];
	return self;
}




-(void)pushItemEven:(id)sender
{
    if(self.delegate) {
        [self.delegate selectItem:mURL];
	}
}

- (void)dealloc
{
	[iconView removeFromSuperview];
	[iconView release];

    [mURL release];
	[super dealloc];
}

@end

NSString* const MobileLooksPickerItemDidChangeNotification = @"MobileLooksPickerItemDidChangeNotification";
