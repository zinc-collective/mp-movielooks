//
//  LookPreviewController.m
//  MobileLooks
//
//  Created by jack on 9/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LookPreviewControllerOld.h"
#import "BulletViewController.h"
#import "UICustomSwitch.h"
#import "AVAssetUtilities.h"

#import "DeviceDetect.h"
#import "Memory.h"

#define DEFAULT_STRENGTH	1.0
#define DEFAULT_BRIGHTNESS	0.5
#define HALF_FRAMERATE_ENABLED  false

@implementation LookPreviewControllerOld
//@synthesize renderedImg;
@synthesize lookDic=mLookDic;
@synthesize renderer;
@synthesize frameSize;
@synthesize outputSize;
@synthesize outputSizeCropped;
@synthesize videoMode;

#pragma mark -
#pragma mark Init
/*
- (void)loadKeyFrame
{
	UIImage* keyFrameImage = [[UIImage alloc] initWithContentsOfFile:[Utilities savedKeyFrameImagePath]];
	
	CGImageRef imageRef = keyFrameImage.CGImage;
	if (!imageRef)
	{ 
		[keyFrameImage release];
		return;
	}
	
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	[keyFrameImage release];
	
	double aspectRatio = (double)width/(double)height;
	//NSLog(@"aspectRatio=%.3f", aspectRatio);
	
	frameSize = CGSizeMake(width, height);
	
	if (aspectRatio > 1.77 && aspectRatio < 1.78) //16:9=1.777778
	{
		outputSize = CGSizeMake(320, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 1.33 && aspectRatio < 1.34) // 4:3=1.333333
	{
		outputSize = CGSizeMake(240, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(480, 360);
			outputSize = CGSizeMake(240*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 0.74 && aspectRatio < 0.76) // 3:4=0.75
	{
		outputSize = CGSizeMake(132, 176);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(264, 352);
			outputSize = CGSizeMake(132*2.5, 176*2.5);
		}
	}
	else if (aspectRatio > 0.56 && aspectRatio < 0.57) //9:16=0.5625
	{
		outputSize = CGSizeMake(99, 176);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(198, 352);
			outputSize = CGSizeMake(99*2.5, 176*2.5);
		}
	}
	else
	{
		NSLog(@"Video Size Not Support! Use Default ");
		outputSize = CGSizeMake(320, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	
	
	if(height<outputSize.height)
	{
		CGFloat factor = height/outputSize.height;
		outputSize = CGSizeMake(outputSize.width*factor,outputSize.height*factor);
	}
}
*/
- (void)setLookDic:(NSDictionary *)lookDic
{
	if (mLookDic == lookDic)
	{
		return;
	}
	
	mLookDic = lookDic;
	
	if (renderer && mLookDic)
	{
		mRendererStatus = RendererNew;
		
		EAGLSharegroup* group = renderer.context.sharegroup;
		
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
		
		[renderer loadLookParam:lookDic withMode:videoMode];
	}
}

- (void)dealloc
{
	//[border release];
	self.renderer = nil;
	
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
//}

#pragma mark -
#pragma mark Renderer

- (void) processImage:(UIImage*)img{
	/*	
	 int width = outputSize.width, height = outputSize.height;
	 //	double aspectRatio = (double)width/(double)height;
	 
	 unsigned char *buffer = malloc(width * height * glPixelSize);
	 NSLog(@"processImage::Alloca a Image Buffer(%d*%d)",width,height);
	 [renderer frameProcessing:keyFrameData toDest:buffer flipPixel:NO];
	 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	 
	 CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, width * height * glPixelSize, NULL);
	 CGImageRef imageRef =  CGImageCreate(width, height, 8, 32, width*glPixelSize, colorSpace, kCGImageAlphaPremultipliedLast, provider, NULL, NO, kCGRenderingIntentDefault);
	 CGDataProviderRelease(provider);
	 CGColorSpaceRelease(colorSpace);
	 mThumbView.layer.contents = (id)imageRef;
	 CGImageRelease(imageRef);
	 */	
	//	mThumbView.image = [renderer frameProcessingAndReturnImage:nil flipPixel:NO];
}

- (void)rendererStart
{
	mRendererStatus = RendererRendering;
	[mActivityIndicator startAnimating];
	[self performSelectorInBackground:@selector(renderImage:) withObject:nil];
}

- (void)rendererEnd
{
	[mActivityIndicator stopAnimating];
	mRendererStatus = RendererReady;
}

- (void)renderImage:(id)sender
{
	@autoreleasepool {
	
		renderer.looksStrengthValue = fStrengthValue;
		renderer.looksBrightnessValue = fBrightnessValue;

		UIImage* image = nil;
		CGImageRef imageRef = [renderer frameProcessingAndReturnImage:nil flipPixel:NO];
//#if 0
		if(videoMode==VideoModeWideSceenPortrait || videoMode==VideoModeTraditionalPortrait)
			image = [[UIImage alloc] initWithCGImage:imageRef  scale:1.0 orientation:UIImageOrientationRight];
		else
			image = [[UIImage alloc] initWithCGImage:imageRef];
//#endif
//    image = [[UIImage alloc] initWithCGImage:imageRef];
		
    CGImageRelease(imageRef);
		
		dispatch_async(dispatch_get_main_queue(),
					   ^{
                       //mThumbImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
//#if 0
                       //CGRect thumbnailRect = mThumbView.frame;
                       //CGSize imagesize = image.size;
						   //if ( imagesize.width > imagesize.height )
                       //{
                       //    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                       //    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                       //}else
                       //{
                       //    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                       //    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                       //}
                       //CGSize imagesize = image.size;
                       //CGRect trect = mThumbView.frame;
                       //CGRect timagerect = mThumbImageView.frame;
//#endif
						   mThumbImageView.image = image;
                       //bret
                       if (IS_IPAD)
                           [self layoutiPadAfterorientation:self.statusBarOrientation];
                       else
                           [self layoutiPhoneAfterorientation:self.statusBarOrientation];
                       //
					   });
	}
	
	[self rendererEnd];
}

- (UIInterfaceOrientation)statusBarOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark -
#pragma mark View Life Circle

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[renderer resetFrameSize:self.outputSize outputFrameSize:self.outputSize];
	[renderer resetRenderBuffer];
	[renderer loadKeyFrame];	
	
	if (IS_IPAD)
        [self layoutiPadAfterorientation:self.statusBarOrientation];
    else
        [self layoutiPhoneAfterorientation:self.statusBarOrientation];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[self.navigationItem setHidesBackButton:NO animated:NO];
//	NSLog(@"viewDidAppear:mRendererStatus=%i", mRendererStatus);
	
	if (mRendererStatus == RendererNew)
	{
		fStrengthValue = DEFAULT_STRENGTH;
		fBrightnessValue = DEFAULT_BRIGHTNESS;
		
		strengthSlider.value = fStrengthValue;
		brightnessSlider.value = fBrightnessValue;
		modeSwitcher.on = false;
		
#if 0 && defined(DEBUG)		// turn this on you want to debug full render resolution by default
		[modeSwitcher setOn:YES animated:NO];
#endif

#if 0
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[modeSwitcher setOn:YES animated:NO];
		}
#endif
		[self rendererStart];
	}
}

- (void)dismissAction:(id)sender
{
	[renderer resetFrameSize:outputSizeCropped outputFrameSize:outputSizeCropped];
	[renderer resetRenderBuffer];
	[renderer unloadKeyFrame];
	[renderer loadKeyFrameCrop];
    [self.navigationController popViewControllerAnimated:YES];
	//[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

    //CGRect frame = self.view.frame;
	[self.navigationItem setHidesBackButton:YES];
    if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
        //CGRect frame7 = self.view.frame;
    }
    self.title = NSLocalizedString(@"Tweak Your Look", nil);
	
	//UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select a Look",nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
	//self.navigationItem.leftBarButtonItem = backButton;
	
    fStrengthValue = DEFAULT_STRENGTH;
	fBrightnessValue = DEFAULT_BRIGHTNESS;
	
	self.view.backgroundColor = [UIColor blackColor];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		//[self.view.layer setContents:(id)[UIImage imageNamed:@"LooksBrowser02_background.png"].CGImage];
		[self layoutiPadAfterorientation:self.statusBarOrientation];
	}
	else {
		[self layoutiPhoneAfterorientation:self.statusBarOrientation];
	}
}


- (void) layoutiPadAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation{
		
	if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
		if(!mThumbView)
        {
			//mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768-44)];
			mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
			mThumbImageView = [[UIImageView alloc] init];
			[mThumbView addSubview:mThumbImageView];
			mThumbView.backgroundColor = [UIColor blackColor];
			[self.view addSubview:mThumbView];
						
			mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			mActivityIndicator.center = CGPointMake(mThumbView.frame.size.width/2.0, mThumbView.frame.size.height/2.0);
			mActivityIndicator.hidesWhenStopped = YES;
			[mThumbView addSubview:mActivityIndicator];
			
			float y = 24;
			float x = 12;

            CGSize textSize;
			textSize.height = 18+18;
            UIImage *imgMin;
			UIImage *imgMax;
			UIImage *thumbImg;
            
			//y = y + textSize.height + 12;
			strengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 416, 47)];
			strengthSlider.value = fStrengthValue;
			[self.view addSubview:strengthSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_ipad_28x30.png"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpInside];
			[strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpOutside];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[strengthSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[strengthSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			strengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+416+8 , y-3, 128, 55)];
			strengthLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_strength_ipad"]];
			[self.view addSubview:strengthLabel];
            
			y = y + textSize.height + 48-16+4;
			brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 416, 47)];
			brightnessSlider.value = fBrightnessValue;
			[self.view addSubview:brightnessSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_ipad_28x30.png"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpInside];
			[brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpOutside];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[brightnessSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[brightnessSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+416+8 , y-3, 152, 55)];
			brightnessLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_brightness_ipad"]];
			[self.view addSubview:brightnessLabel];
            
            y = y + textSize.height + 48-16+4;
            modeSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(x+12, y, 76, 53)];
            [modeSwitcher addTarget: self action: @selector(modeSwitcher:) forControlEvents:UIControlEventValueChanged];
			//modeSwitcher.on = true;
            modeSwitcher.onTintColor = [UIColor grayColor];
            modeSwitcher.alpha = .90;
            //thumbTintColor
            //tintColor
            //onImage //no effect in ios 7
            //offImage //no effect in ios 7
            
            [self.view addSubview:modeSwitcher];
			resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+76-8, y-9, 66, 50)];
			resolutionLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_hd_ipad"]];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                resolutionLabel.frame = CGRectMake(x+76-8+32, y-9, 66, 50);
            [self.view addSubview:resolutionLabel];
									   
			developButton = [UIButton buttonWithType:UIButtonTypeCustom];
			developButton.frame = CGRectMake(1024-225-12, 768-44-94+((94-71)/2), 225, 71);
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button225x71.png"] forState:UIControlStateNormal];
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button225x71.png"] forState:UIControlStateHighlighted];
			[developButton addTarget:self action:@selector(develop:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:developButton];
		
			backToLooksBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
			backToLooksBrowserButton.frame = CGRectMake(12, 768-44-94+((94-71)/2), 227, 71);
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button227x71.png"] forState:UIControlStateNormal];
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button227x71.png"] forState:UIControlStateHighlighted];
			[backToLooksBrowserButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:backToLooksBrowserButton];

        }
		else {
			//mThumbView.frame = CGRectMake(0, 0, 1024, 768-44);
			mThumbView.frame = CGRectMake(0, 0, 1024, 768-44);
            //CGRect imgBounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
            //imgBounds = [Utilities resizeToFit :imgBounds :previewFrameBounds];

            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
                if ( imagesize.width > imagesize.height )
                {
                    //CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    //mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    //CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    //mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            }
			developButton.frame = CGRectMake(1024-225-12, 768-44-94+((94-71)/2), 225, 71);
			backToLooksBrowserButton.frame = CGRectMake(12, 768-44-94+((94-71)/2), 227, 71);
		}
	}
	else { //portait
		if(!mThumbView)
        {
			//mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024-44)];
			mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024-44)];
			mThumbImageView = [[UIImageView alloc] init];
			[mThumbView addSubview:mThumbImageView];
			mThumbView.backgroundColor = [UIColor blackColor];
			[self.view addSubview:mThumbView];
									
            mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			mActivityIndicator.center = CGPointMake(mThumbView.frame.size.width/2.0, mThumbView.frame.size.height/2.0);
			mActivityIndicator.hidesWhenStopped = YES;
			[mThumbView addSubview:mActivityIndicator];
			
			float y = 24;
			float x = 12;
            
            CGSize textSize;
			textSize.height = 18+18;
            UIImage *imgMin;
			UIImage *imgMax;
			UIImage *thumbImg;
            
			//y = y + textSize.height + 12;
			strengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 416, 47)];
			strengthSlider.value = fStrengthValue;
			[self.view addSubview:strengthSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_ipad_28x30.png"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpInside];
			[strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpOutside];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[strengthSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[strengthSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			strengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+416+8 , y-3, 128, 55)];
			strengthLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_strength_ipad"]];
			[self.view addSubview:strengthLabel];
            
			y = y + textSize.height + 48-16+4;
			brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 416, 47)];
			brightnessSlider.value = fBrightnessValue;
			[self.view addSubview:brightnessSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_ipad_28x30.png"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_ipad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            [brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpInside];
			[brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpOutside];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[brightnessSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[brightnessSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+416+8 , y-3, 152, 55)];
			brightnessLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_brightness_ipad"]];
			[self.view addSubview:brightnessLabel];
            
            y = y + textSize.height + 48-16+4;
            modeSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(x+12, y, 76, 53)];
            [modeSwitcher addTarget: self action: @selector(modeSwitcher:) forControlEvents:UIControlEventValueChanged];
			//modeSwitcher.on = true;
            modeSwitcher.onTintColor = [UIColor grayColor];
            modeSwitcher.alpha = .90;
            //thumbTintColor
            //tintColor
            //onImage //no effect in ios 7
            //offImage //no effect in ios 7
            
            [self.view addSubview:modeSwitcher];
			resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+76-8, y-9, 66, 50)];
			resolutionLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_hd_ipad"]];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                resolutionLabel.frame = CGRectMake(x+76-8+32, y-9, 66, 50);
            [self.view addSubview:resolutionLabel];
            
			developButton = [UIButton buttonWithType:UIButtonTypeCustom];
			developButton.frame = CGRectMake(768-225-12, 1024-44-94+((94-71)/2), 225, 71);
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button225x71.png"] forState:UIControlStateNormal];
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button225x71.png"] forState:UIControlStateHighlighted];
			[developButton addTarget:self action:@selector(develop:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:developButton];
            
			backToLooksBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
			backToLooksBrowserButton.frame = CGRectMake(12, 1024-44-94+((94-71)/2), 227, 71);
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button227x71.png"] forState:UIControlStateNormal];
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button227x71.png"] forState:UIControlStateHighlighted];
			[backToLooksBrowserButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:backToLooksBrowserButton];
		}
		else {
			//mThumbView.frame = CGRectMake(0, 0, 768, 1024-44);
			mThumbView.frame = CGRectMake(0, 0, 768, 1024);
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
#if 0
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
#endif
                if ( imagesize.width > imagesize.height )
                {
                    //CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    //mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    //CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    //mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }
                
            }
			developButton.frame = CGRectMake(768-225-12, 1024-44-94+((94-71)/2), 225, 71);
			backToLooksBrowserButton.frame = CGRectMake(12, 1024-44-94+((94-71)/2), 227, 71);
		}

	}
	
}

- (void) layoutiPhoneAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation{
	
	if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
		if(!mThumbView)
        {
            //if (IS_IPHONE_5)
            //    mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320-44)];
			//else
            //    mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320-44)];
            if (IS_IPHONE_5)
                mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
			else
                mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
            
            mThumbImageView = [[UIImageView alloc] init];
			[mThumbView addSubview:mThumbImageView];
			mThumbView.backgroundColor = [UIColor blackColor];
			[self.view addSubview:mThumbView];
            
			mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			mActivityIndicator.center = CGPointMake(mThumbView.frame.size.width/2.0, mThumbView.frame.size.height/2.0);
			mActivityIndicator.hidesWhenStopped = YES;
			[mThumbView addSubview:mActivityIndicator];
			
            float y = 24/2;
			float x = 12/2;
            
            CGSize textSize;
			textSize.height = (18+18)/2;
            UIImage *imgMin;
			UIImage *imgMax;
			UIImage *thumbImg;
            
			//y = y + textSize.height + 12;
			strengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 208, 24)];
			strengthSlider.value = fStrengthValue;
			[self.view addSubview:strengthSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_iphone_13x14"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpInside];
			[strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpOutside];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[strengthSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[strengthSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			strengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+208+(8/2) , y-2, 64, 28)];
			strengthLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_strength_iphone"]];
			[self.view addSubview:strengthLabel];
            
			y = y + textSize.height + (48-16+4)/2;
			brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 208, 24)];
			brightnessSlider.value = fBrightnessValue;
			[self.view addSubview:brightnessSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_iphone_13x14"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpInside];
			[brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpOutside];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[brightnessSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[brightnessSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+208+(8/2) , y-2, 76, 28)];
			brightnessLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_brightness_iphone"]];
			[self.view addSubview:brightnessLabel];
            
            y = y + textSize.height + (48-16+4)/2;
            modeSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(x+(12/2)-12+4, y, 76/2, 53/2)];
            [modeSwitcher addTarget: self action: @selector(modeSwitcher:) forControlEvents:UIControlEventValueChanged];
            modeSwitcher.transform = CGAffineTransformMakeScale(0.70, 0.70);
			//modeSwitcher.on = true;
            modeSwitcher.onTintColor = [UIColor grayColor];
            modeSwitcher.alpha = .90;
            //thumbTintColor
            //tintColor
            //onImage //no effect in ios 7
            //offImage //no effect in ios 7
            
            [self.view addSubview:modeSwitcher];
			resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+((76-8)/2)+8, y-(9/2)+7, 33, 25)];
			resolutionLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_hd_iphone"]];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                resolutionLabel.frame = CGRectMake(x+((76-8)/2)+8+16+12, y-(9/2)+6, 33, 25);
            
            [self.view addSubview:resolutionLabel];
            
			developButton = [UIButton buttonWithType:UIButtonTypeCustom];
			if (IS_IPHONE_5)
                developButton.frame = CGRectMake(568-105-12, 320-44-44+((44-33)/2), 105, 33);
			else
                developButton.frame = CGRectMake(480-105-12, 320-44-44+((44-33)/2), 105, 33);
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button105x33_iphone.png"] forState:UIControlStateNormal];
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button105x33_iphone.png"] forState:UIControlStateHighlighted];
			[developButton addTarget:self action:@selector(develop:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:developButton];
            
			backToLooksBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
			backToLooksBrowserButton.frame = CGRectMake(12, 320-44-44+((44-33)/2), 106, 33);
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button106x33_iphone.png"] forState:UIControlStateNormal];
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button106x33_iphone.png"] forState:UIControlStateHighlighted];
			[backToLooksBrowserButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:backToLooksBrowserButton];
            
        }
		else {
            //if (IS_IPHONE_5)
            //    mThumbView.frame = CGRectMake(0, 0, 568, 320-44);
			//else
            //    mThumbView.frame = CGRectMake(0, 0, 480, 320-44);
            if (IS_IPHONE_5)
                mThumbView.frame = CGRectMake(0, 0, 568, 320);
			else
                mThumbView.frame = CGRectMake(0, 0, 480, 320);
            
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
#if 0
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
#endif
                if ( imagesize.width > imagesize.height )
                {
                    //CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    //mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    //CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    //mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }
            
            
            }
			if (IS_IPHONE_5)
                developButton.frame = CGRectMake(568-105-12, 320-44-44+((44-33)/2), 105, 33);
			else
                developButton.frame = CGRectMake(480-105-12, 320-44-44+((44-33)/2), 105, 33);
			backToLooksBrowserButton.frame = CGRectMake(12, 320-44-44+((44-33)/2), 106, 33);
		}
	}
	else { //portait
		if(!mThumbView)
        {
			//if (IS_IPHONE_5)
            //    mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568-44)];
			//else
            //    mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44)];
			if (IS_IPHONE_5)
                mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
			else
                mThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            
            mThumbImageView = [[UIImageView alloc] init];
			[mThumbView addSubview:mThumbImageView];
			[self.view addSubview:mThumbView];
            mThumbView.backgroundColor = [UIColor blackColor];
            
			mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			mActivityIndicator.center = CGPointMake(mThumbView.frame.size.width/2.0, mThumbView.frame.size.height/2.0);
			mActivityIndicator.hidesWhenStopped = YES;
			[mThumbView addSubview:mActivityIndicator];
			
            float y = 24/2;
			float x = 12/2;
            
            CGSize textSize;
			textSize.height = (18+18)/2;
            UIImage *imgMin;
			UIImage *imgMax;
			UIImage *thumbImg;
            
			//y = y + textSize.height + 12;
			strengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 208, 24)];
			strengthSlider.value = fStrengthValue;
			[self.view addSubview:strengthSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_iphone_13x14"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpInside];
			[strengthSlider addTarget:self action:@selector(endscrubStrength:) forControlEvents:UIControlEventTouchUpOutside];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[strengthSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[strengthSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[strengthSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			strengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+208+(8/2) , y-2, 64, 28)];
			strengthLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_strength_iphone"]];
			[self.view addSubview:strengthLabel];
            
			y = y + textSize.height + (48-16+4)/2;
			brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, 208, 24)];
			brightnessSlider.value = fBrightnessValue;
			[self.view addSubview:brightnessSlider];
			thumbImg = [UIImage imageNamed:@"slider_button_iphone_13x14"];
            imgMin = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            imgMax = [[UIImage imageNamed:@"tweak_slider_max_track_iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpInside];
			[brightnessSlider addTarget:self action:@selector(endscrubBrightness:) forControlEvents:UIControlEventTouchUpOutside];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateNormal];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateSelected];
			[brightnessSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
			[brightnessSlider setMinimumTrackImage:imgMin forState:UIControlStateNormal];
			[brightnessSlider setMaximumTrackImage:imgMax forState:UIControlStateNormal];
            
			brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+208+(8/2) , y-2, 76, 28)];
			brightnessLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_brightness_iphone"]];
			[self.view addSubview:brightnessLabel];
            
            y = y + textSize.height + (48-16+4)/2;
            modeSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(x+(12/2)-12+4, y, 76/2, 53/2)];
            [modeSwitcher addTarget: self action: @selector(modeSwitcher:) forControlEvents:UIControlEventValueChanged];
            modeSwitcher.transform = CGAffineTransformMakeScale(0.70, 0.70);
			//modeSwitcher.on = true;
            modeSwitcher.onTintColor = [UIColor grayColor];
            modeSwitcher.alpha = .90;
            //thumbTintColor
            //tintColor
            //onImage //no effect in ios 7
            //offImage //no effect in ios 7
            
            [self.view addSubview:modeSwitcher];
			resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+((76-8)/2)+8, y-(9/2)+7, 33, 25)];
			resolutionLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweak_hd_iphone"]];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                resolutionLabel.frame = CGRectMake(x+((76-8)/2)+8+16+12, y-(9/2)+6, 33, 25);
            [self.view addSubview:resolutionLabel];
            
			developButton = [UIButton buttonWithType:UIButtonTypeCustom];
			if (IS_IPHONE_5)
                developButton.frame = CGRectMake(320-105-12, 568-44-44+((44-33)/2), 105, 33);
			else
                developButton.frame = CGRectMake(320-105-12, 480-44-44+((44-33)/2), 105, 33);
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button105x33_iphone.png"] forState:UIControlStateNormal];
			[developButton setBackgroundImage:[UIImage imageNamed:@"looktweak_develop_button105x33_iphone.png"] forState:UIControlStateHighlighted];
			[developButton addTarget:self action:@selector(develop:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:developButton];
            
			backToLooksBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
			if (IS_IPHONE_5)
                backToLooksBrowserButton.frame = CGRectMake(12, 568-44-44+((44-33)/2), 106, 33);
            else
                backToLooksBrowserButton.frame = CGRectMake(12, 480-44-44+((44-33)/2), 106, 33);
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button106x33_iphone.png"] forState:UIControlStateNormal];
			[backToLooksBrowserButton setBackgroundImage:[UIImage imageNamed:@"looktweak_selectlook_button106x33_iphone.png"] forState:UIControlStateHighlighted];
			[backToLooksBrowserButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:backToLooksBrowserButton];
		}
		else {
			//if (IS_IPHONE_5)
            //    mThumbView.frame = CGRectMake(0, 0, 320, 568-44);
			//else
            //    mThumbView.frame = CGRectMake(0, 0, 320, 480-44);
			if (IS_IPHONE_5)
                mThumbView.frame = CGRectMake(0, 0, 320, 568);
			else
                mThumbView.frame = CGRectMake(0, 0, 320, 480);
            if (mThumbImageView.image != nil)
            {
                CGRect thumbnailRect = mThumbView.frame;
                CGSize imagesize = mThumbImageView.image.size;
#if 0
                if ( imagesize.width > imagesize.height )
                {
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }
#endif
                if ( imagesize.width > imagesize.height )
                {
                    //CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    //mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                }else
                {
                    //CGSize thumbnailImageSize = CGSizeMake(thumbnailRect.size.width,imagesize.height*thumbnailRect.size.width/imagesize.width);
                    //mThumbImageView.frame = CGRectMake(0, (thumbnailRect.size.height-thumbnailImageSize.height)/2, thumbnailImageSize.width, thumbnailImageSize.height);
                    CGSize thumbnailImageSize = CGSizeMake(imagesize.width*thumbnailRect.size.height/imagesize.height,thumbnailRect.size.height);
                    mThumbImageView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
                }
                
            }
			if (IS_IPHONE_5)
                developButton.frame = CGRectMake(320-105-12, 568-44-44+((44-33)/2), 105, 33);
			else
                developButton.frame = CGRectMake(320-105-12, 480-44-44+((44-33)/2), 105, 33);
			if (IS_IPHONE_5)
                backToLooksBrowserButton.frame = CGRectMake(12, 568-44-44+((44-33)/2), 106, 33);
            else
                backToLooksBrowserButton.frame = CGRectMake(12, 480-44-44+((44-33)/2), 106, 33);
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"seque id == %@",segue.identifier);
    if ([[segue identifier] isEqualToString:@"BulletViewController"])
    {
        BulletViewController *bulletViewController = (BulletViewController *)segue.destinationViewController;
		bulletViewController.renderer = renderer;
		bulletViewController.fStrengthValue = fStrengthValue;
		bulletViewController.fBrightnessValue = fBrightnessValue;
		bulletViewController.estimateFrameProcessTime = estimateFrameProcessTime;
		bulletViewController.estimateClipProcessTime = estimateClipProcessTime;
		bulletViewController.estimateTotalRenderTime = estimateTotalRenderTime;
		bulletViewController.videoMode = videoMode;
        bulletViewController.mThumbImage = mThumbImageView.image;
		
		// grab the current time interval for measuring total duration later
		bulletViewController.renderStartTime = [NSDate timeIntervalSinceReferenceDate];
        
        
		RendererType type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeHalf:RendererTypeFull;
        bool modeSwitcherHD;
        if (modeSwitcher.on)
        {
            modeSwitcherHD = true;
        } else
        {
            modeSwitcherHD = false;
		}
        

        if (modeSwitcherHD) {
            type = RendererTypeFull;
        } else {
            type = RendererTypeHalf;
		}
		
        BOOL fullFramerate = YES;
        if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf)
        {
            fullFramerate = NO;
        }

        [bulletViewController setRendererType:type withFullFramerate:fullFramerate andLookParam:mLookDic];
    }
    
}


-(NSTimeInterval)estimateProcessingTime:(NSURL*)processURL withType:(RendererType)renderType withFullFramerate:(BOOL)renderFullFramerate
{
	// TODO: joe- this fps should come from the video itself.
	// Or better yet, just grab a total count of all frames in the video if possible.
	// it is assumed that videos recorded from the iPhone are usually very close to 30fps.
	float fps = 30.0f;
	
	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:processURL options:nil];
	NSUInteger movieFrames = CMTimeGetSeconds(movieAsset.duration)*fps;
	
	if (!renderFullFramerate) {
		movieFrames = ceil((float)movieFrames / 2.0);
	}
	
    CGSize movieOriginSize = [AVAssetUtilities naturalSize:movieAsset];
	CGSize movieOutputSize = movieOriginSize;
	
	CGFloat smallestSupportHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?120:100;
	CGFloat smallestSupportWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?240:200;
	if (renderType == RendererTypeHalf && movieOriginSize.height>smallestSupportHeight && movieOriginSize.width>smallestSupportWidth)
		movieOutputSize = CGSizeMake(movieOriginSize.width/2.0, movieOriginSize.height/2.0);
	[renderer resetFrameSize:movieOriginSize outputFrameSize:movieOutputSize];
	estimateOutputSize = movieOutputSize;
	
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:movieAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];
	[avImageGenerator setMaximumSize:movieOriginSize];
	
	//render buffer
	CGImageRef estimateFrameRef =  [avImageGenerator copyCGImageAtTime:CMTimeMake(0, 600) actualTime:NULL error:NULL];
	unsigned char* estimateFrameData = malloc(movieOriginSize.width*movieOriginSize.height * glPixelSize);
	CGContextRef estimateFrameContext = CGBitmapContextCreate(estimateFrameData, movieOriginSize.width, movieOriginSize.height, 8, movieOriginSize.width * glPixelSize, CGImageGetColorSpace(estimateFrameRef), glImageAlphaNoneSkipLast);
	CGContextSetBlendMode(estimateFrameContext, kCGBlendModeCopy);
	CGContextDrawImage(estimateFrameContext, CGRectMake(0.0, 0.0, movieOriginSize.width, movieOriginSize.height), estimateFrameRef);
	CGImageRelease(estimateFrameRef);
	CGContextRelease(estimateFrameContext);

	//rendering
	NSTimeInterval singleFrameRenderStartTime = [NSDate timeIntervalSinceReferenceDate];
	[renderer frameProcessing:estimateFrameData toDest:estimateFrameData flipPixel:YES];
	estimateFrameProcessTime = [NSDate timeIntervalSinceReferenceDate]-singleFrameRenderStartTime;
	
	// NOTE: joe- this appears to be a scale factor that is applied to the eestimate.  Not sure where this is coming from ??
	// This could be a factor of how much time is spend doing other things during the process loop.
	// When the profiling the app, the frame rendering is approximately 66% of the time.
	estimateClipProcessTime = 0.37;		

	[renderer resetFrameSize:self.outputSize outputFrameSize:self.outputSize];
/*
	//save rendered image  
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	CGContextRef imgCGContext = CGBitmapContextCreate (estimateFrameData, movieOutputSize.width, movieOutputSize.height, 8, movieOutputSize.width*glPixelSize, colorSpace,kCGImageAlphaPremultipliedLast);
	CGImageRef imgRef = CGBitmapContextCreateImage(imgCGContext);
	CGColorSpaceRelease(colorSpace); 
	CGContextRelease(imgCGContext);

	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	[assetsLibrary writeImageToSavedPhotosAlbum:imgRef orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error){
		dispatch_async(dispatch_get_main_queue(), ^{
			CGImageRelease(imgRef);
		});
	}];
	[assetsLibrary release];
	
*/

	NSTimeInterval estimateRenderTimeRemaining = estimateFrameProcessTime*movieFrames+ceil(movieFrames/fps)*estimateClipProcessTime;
	NSLog(@"Estimated Render Time: %f seconds", estimateRenderTimeRemaining);
	
	free(estimateFrameData);
	
	return estimateRenderTimeRemaining;
}

/*
if(TooHighForDevice(videoSize))
{
	UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@""
														message:NSLocalizedString(@"NotSupport",nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil)
											  otherButtonTitles:nil];
	
	[alerView show];
	[alerView release];
	return;
}
 */
#pragma mark -
#pragma mark Bullet Events

- (void) develop:(id)sender
{
	NSString *title = NSLocalizedString(@"Half Resolution",nil);
	//NSString *content = @"Press the Develop button to create a new video with your Look."
	//" This process can take some time, approximately %02d:%02d.";
//	NSString *content = @"Press the Develop button to create a new video with your Look."
//	" This process can take some time.";
/*
	//" This process%@ will take approximately %02d:%02d.";
	NSString *replace = @"";
	
	MobileLooksAppDelegate *appDelegate = (MobileLooksAppDelegate*)[[UIApplication sharedApplication] delegate];
	//CGSize videoSize = appDelegate.videoSize;
	double videoDuration = appDelegate.videoDuration;
	double duration = 0.0;
	
	BOOL quickRender = [[mLookDic objectForKey:kLookQuickRender] boolValue];
	//float width = videoSize.width > videoSize.height ? videoSize.width : videoSize.height;
*/	
#if 0 //bret
	BOOL type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeHalf:RendererTypeFull;
	if ([modeSwitcher isOn])
	{
		type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeFull:RendererTypeHalf;
	}
	if (type == RendererTypeFull)
		title = NSLocalizedString(@"Full Resolution",nil);
		
	BOOL fullFramerate = YES;
	if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf) {
		fullFramerate = NO;
	}
#endif


    bool modeSwitcherHD;
	if (modeSwitcher.on)
	{
        modeSwitcherHD = true;
    } else
    {
        modeSwitcherHD = false;
	}
	
#if 0
    BOOL type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeHalf:RendererTypeFull;
	if (modeSwitcherHD)
	{
		type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeFull:RendererTypeHalf;
	}
	BOOL fullFramerate = YES;
	if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf) {
		fullFramerate = NO;
	}
#endif
    
	BOOL type;
    if (modeSwitcherHD)
	{
        type = RendererTypeFull;
    } else
	{
        type = RendererTypeHalf;
    }
	
	BOOL fullFramerate = YES;
	if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf)
    {
		fullFramerate = NO;
	}
	
    estimateTotalRenderTime = [self estimateProcessingTime:[Utilities selectedVideoPathWithURL:nil] withType:type withFullFramerate:fullFramerate];
    [self performSegueWithIdentifier:@"BulletViewController" sender:self];

	if (TooHighForDevice(estimateOutputSize))
	{
		// force renderTypeHalf
		NSLog(@"WARNING: HD Video not supported, using half quality render type");
		type = RendererTypeHalf;
	}
	
	if (type == RendererTypeFull)
	{
		title = NSLocalizedString(@"Full Resolution",nil);
    }
}

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
#if 0 //storyboard
        BulletViewController *bulletViewController = [[BulletViewController alloc] init];
		bulletViewController.renderer = renderer;
		bulletViewController.fStrengthValue = fStrengthValue;
		bulletViewController.fBrightnessValue = fBrightnessValue;
		bulletViewController.estimateFrameProcessTime = estimateFrameProcessTime;
		bulletViewController.estimateClipProcessTime = estimateClipProcessTime;
		bulletViewController.estimateTotalRenderTime = estimateTotalRenderTime;
		bulletViewController.videoMode = videoMode;
		
		// grab the current time interval for measuring total duration later
		bulletViewController.renderStartTime = [NSDate timeIntervalSinceReferenceDate];
	

		RendererType type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeHalf:RendererTypeFull;
		if ([modeSwitcher isOn])
		{
			type = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)?RendererTypeFull:RendererTypeHalf;
		}
		
		BOOL fullFramerate = YES;
		if (HALF_FRAMERATE_ENABLED && type == RendererTypeHalf) {
			// NOTE: fullFramerate is currently tied to the same UI toggle switch as the render resolution
			fullFramerate = NO;
		}
		
		[bulletViewController setRendererType:type withFullFramerate:fullFramerate andLookParam:mLookDic];
		[self.navigationController pushViewController:bulletViewController animated:YES];
		[bulletViewController release];
#endif
        [self performSegueWithIdentifier:@"BulletViewController" sender:self];
	}
}

#pragma mark -
#pragma mark Slider Events

- (void) endscrubStrength:(UISlider*)slider
{
	fStrengthValue = slider.value;
	
	NSLog(@"%f", fStrengthValue);
	
	if (mRendererStatus == RendererReady)
	{
		[self rendererStart];
	}
}

- (void) endscrubBrightness:(UISlider*)slider
{
	fBrightnessValue = slider.value;
	
	if (mRendererStatus == RendererReady)
	{
		[self rendererStart];
	}
}

/*
- (void) modeSwitcher:(UISlider*)slider
{
    if ( slider.value < (slider.maximumValue/2.0))
        slider.value = slider.minimumValue;
    else
        slider.value = slider.maximumValue;
}
*/
- (void) modeSwitcher:(UISwitch*)slider
{
/*
    if ( slider.on < (slider.maximumValue/2.0))
        slider.value = slider.minimumValue;
    else
        slider.value = slider.maximumValue;
*/
}

#if 0
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return YES;
	}
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
#endif
- (BOOL)shouldAutorotate
{
	return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	if (IS_IPAD)
        [self layoutiPadAfterorientation:toInterfaceOrientation];
    else
        [self layoutiPhoneAfterorientation:toInterfaceOrientation];
    
}

@end
