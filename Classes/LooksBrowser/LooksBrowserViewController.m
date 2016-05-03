//
//  LooksBrowserViewController.m
//  MobileLooks
//
//  Created by George on 8/24/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "LooksBrowserViewController.h"
//#import "ScrollViewEnhancer.h"
#import "ES2Renderer.h"
#import "ToggleButton.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "MobileLooksAppDelegate.h"

#import "DeviceDetect.h"

#define BAR_OPAQUE //uncomment for semi-opaque bars

//#define FRAME_BACKGROUND_VIEW_PORTRAIT	CGRectMake(0, 0, 320, 416)
//#define FRAME_BACKGROUND_VIEW_LANDSCAPE	CGRectMake(0, 0, 480, 224)

//#define FRAME_SCROLL_VIEW_PORTRAIT		CGRectMake(13, 0, 294, 416)
//#define FRAME_SCROLL_VIEW_LANDSCAPE		CGRectMake(13, 0, 294, 416)


#define FRAME_CROP_SIZE_WIDTH 536
#define FRAME_CROP_SIZE_HEIGHT 536
#define FRAME_CROP_SIZE_WIDTH_OFFSET 20
#define FRAME_CROP_SIZE_HEIGHT_OFFSET 20
#define FRAME_OPAQUE_HEIGHT 94

#define FRAME_CROP_SIZE_WIDTH_IPHONE 190
#define FRAME_CROP_SIZE_HEIGHT_IPHONE 190
#define FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE 10
#define FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE 10
#define FRAME_OPAQUE_HEIGHT_IPHONE 44

//need fix to dynamic value
#define GROUP_COUNT 8

@interface LooksBrowserViewController(Private)

- (void)layoutBackButton:(UIInterfaceOrientation)orientation;
- (void)layoutViewsForOrientation:(UIInterfaceOrientation)orientation;

@end


@implementation LooksBrowserViewController

@synthesize isRenderThreadStop = mRenderThreadStop;

@synthesize products, groupsViews, looksViews;
//@synthesize overView, activityIndicator;
@synthesize productIdentifier;

@synthesize groupsScrollView, looksScrollView;
//@synthesize footView=mFootView;

@synthesize requestDictionary;

- (void)showNetworkActivityIndicator
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
}

- (void)hiddenNetworkActivityIndicator
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark View Life Circle

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
	
#if 0
    videoMode = VideoModeTraditionalLandscape; //bret doesn't seem to be used
    outputSize = CGSizeMake(FRAME_CROP_SIZE_WIDTH_IPHONE, FRAME_CROP_SIZE_HEIGHT_IPHONE);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //outputSize = CGSizeMake(640, 360);
        outputSize = CGSizeMake(FRAME_CROP_SIZE_WIDTH, FRAME_CROP_SIZE_HEIGHT);
    }
#endif
    [keyFrameImage release];
//#if 0
    
	double aspectRatio = (double)width/(double)height;
	//NSLog(@"aspectRatio=%.3f", aspectRatio);
	
	frameSize = CGSizeMake(width, height);
	NSLog(@"Frame Size:(%d,%d)",width, height);
#if 0
	if (aspectRatio > 1.77 && aspectRatio < 1.78) //16:9=1.777778
	{
		videoMode = VideoModeWideSceenLandscape;
		outputSize = CGSizeMake(320, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 1.33 && aspectRatio < 1.34) // 4:3=1.333333
	{
		videoMode = VideoModeTraditionalLandscape;
		outputSize = CGSizeMake(240, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(480, 360);
			outputSize = CGSizeMake(240*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 0.74 && aspectRatio < 0.76) // 3:4=0.75
	{
		videoMode = VideoModeTraditionalPortrait;
		outputSize = CGSizeMake(240, 180);
		frameSize = CGSizeMake(height,width);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(264, 352);
			outputSize = CGSizeMake(240*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 0.56 && aspectRatio < 0.57) //9:16=0.5625
	{
		videoMode = VideoModeWideSceenPortrait;
		outputSize = CGSizeMake(320, 180);
		frameSize = CGSizeMake(height,width);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(198, 352);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	else
	{
		NSLog(@"Video Size Not Support! Use Default ");
		videoMode = VideoModeWideSceenLandscape;
		outputSize = CGSizeMake(320, 180);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	if(height<width)
	{
		if(height<outputSize.height)
		{
			CGFloat factor = height/outputSize.height;
			outputSize = CGSizeMake(outputSize.width*factor,outputSize.height*factor);
		}		
	}
	else
	{
		if(width<outputSize.height)
		{
			CGFloat factor = width/outputSize.height;
			outputSize = CGSizeMake(outputSize.width*factor,outputSize.height*factor);
		}
	}
#endif
	
    if (aspectRatio > 1.77 && aspectRatio < 1.78) //16:9=1.777778
	{
		videoMode = VideoModeWideSceenLandscape;
		outputSize = CGSizeMake(320*2, 180*2);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 1.33 && aspectRatio < 1.34) // 4:3=1.333333
	{
		videoMode = VideoModeTraditionalLandscape;
		outputSize = CGSizeMake(240*2, 180*2);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(480, 360);
			outputSize = CGSizeMake(240*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 0.74 && aspectRatio < 0.76) // 3:4=0.75
	{
		videoMode = VideoModeTraditionalPortrait;
		outputSize = CGSizeMake(240*2, 180*2);
		frameSize = CGSizeMake(height,width);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(264, 352);
			outputSize = CGSizeMake(240*2.5, 180*2.5);
		}
	}
	else if (aspectRatio > 0.56 && aspectRatio < 0.57) //9:16=0.5625
	{
		videoMode = VideoModeWideSceenPortrait;
		outputSize = CGSizeMake(320*2, 180*2);
		frameSize = CGSizeMake(height,width);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(198, 352);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	else
	{
		NSLog(@"Video Size Not Support! Use Default ");
		videoMode = VideoModeWideSceenLandscape;
		outputSize = CGSizeMake(320*2, 180*2);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			//outputSize = CGSizeMake(640, 360);
			outputSize = CGSizeMake(320*2.5, 180*2.5);
		}
	}
	if(height<width)
	{
		if(height<outputSize.height)
		{
			CGFloat factor = height/outputSize.height;
			outputSize = CGSizeMake(outputSize.width*factor,outputSize.height*factor);
		}
	}
	else
	{
		if(width<outputSize.height)
		{
			CGFloat factor = width/outputSize.height;
			outputSize = CGSizeMake(outputSize.width*factor,outputSize.height*factor);
		}
	}

    
    //#endif
    originalOutputSize = CGSizeMake(outputSize.width,outputSize.height);
    originalVideoMode = videoMode;
    videoMode = VideoModeTraditionalLandscape; //bret doesn't seem to be used
    outputSize = CGSizeMake(FRAME_CROP_SIZE_WIDTH_IPHONE, FRAME_CROP_SIZE_HEIGHT_IPHONE);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //outputSize = CGSizeMake(640, 360);
        outputSize = CGSizeMake(FRAME_CROP_SIZE_WIDTH, FRAME_CROP_SIZE_HEIGHT);
    }

}

- (void)loadData
{
	[self loadKeyFrame];
	
	self.products = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserLooks];
}

- (void)initRenderer:(id)sender
{
	//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"renderer init");
	
	thumbnailRequred = YES;
	
	renderer = [[ES2Renderer alloc] initWithFrameSize:outputSize outputFrameSize:outputSize];
//	[renderer loadKeyFrame];
	//	isRenderAlready = YES;
}

-(void)startRender
{
	[renderer resetFrameSize:outputSize outputFrameSize:outputSize];
	[renderer resetRenderBuffer];
	//[renderer loadKeyFrame];
	[renderer loadKeyFrameCrop];
	for (int i=0; i<[looksViews count]; ++i) {
		LookThumbnailView* thumbnail = [looksViews objectAtIndex:i];
		if(thumbnail.renderingState==RenderingStateRendering)
			thumbnail.renderingState = RenderingStateNone;
	}
	
	
	[self layoutAfterorientation:self.interfaceOrientation];
	renderThreadCancel = NO;
	self.isRenderThreadStop = NO;
	[NSThread detachNewThreadSelector:@selector(renderLoop) toTarget:self withObject:nil];
}

-(void)endRender
{
	[renderCondition lock];
	renderThreadCancel = YES;
	[renderCondition signal];
	[renderCondition unlock];
	/*	
	 while (!self.isRenderThreadStop)
	 {	
	 NSLog(@"Waiting Rendering Thread");
	 [NSThread sleepForTimeInterval:0.5];
	 }
	 */ 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"seque id == %@",segue.identifier);
    if ([[segue identifier] isEqualToString:@"LookPreviewController"])
    {
        //bret test
        [renderer unloadKeyFrame];
        LookPreviewController *previewController = (LookPreviewController *)segue.destinationViewController;
        NSDictionary *groupDic = [self.products objectAtIndex:selectedGroupIndex];
        NSArray *looks = [groupDic objectForKey:kProductLooks];
        NSDictionary *lookDic = [looks objectAtIndex:selectedLookIndex];
		previewController.frameSize = frameSize;
		//previewController.outputSize = outputSize;
		previewController.outputSizeCropped = outputSize;
		previewController.outputSize = originalOutputSize;
		previewController.renderer = renderer;
		previewController.videoMode = originalVideoMode; //videoMode;
		previewController.lookDic = lookDic;
    }
    
}

- (void)backAction:(id)sender
{
	looksScrollView.delegate = nil;
	for (LookThumbnailView *thumbView in looksViews)
		thumbView.delegate = nil;
	{
		//wait rendering thread stoped 
		[self endRender];
//		NSLog(@"backAction:Wait Rendering Thread");			
		while (!self.isRenderThreadStop)
		{	
			NSLog(@"Waiting Rendering Thread");
//			[NSThread sleepForTimeInterval:0.3];
		}
//		NSLog(@"backAction:Waited Rendering Thread");			
	}

	[self releaseRender:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil]; 
}

- (void)backToTrimAction:(id)sender
{
	looksScrollView.delegate = nil;
	for (LookThumbnailView *thumbView in looksViews)
		thumbView.delegate = nil;
	{
		//wait rendering thread stoped
		[self endRender];
        //		NSLog(@"backAction:Wait Rendering Thread");
		while (!self.isRenderThreadStop)
		{
			NSLog(@"Waiting Rendering Thread");
            //			[NSThread sleepForTimeInterval:0.3];
		}
        //		NSLog(@"backAction:Waited Rendering Thread");
	}
    
	[self releaseRender:nil];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToTrim" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil];
}

- (void)nextAction:(id)sender
{
    CGFloat pageWidth;
    int page;
    if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        pageWidth = looksScrollView.frame.size.width;
        page = floor((looksScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	}else
    {
        pageWidth = looksScrollView.frame.size.height;
        page = floor((looksScrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    }
    
    LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
	//[self.tapLook:page inGroup:thumbView.groupIndex];

	NSDictionary *groupDic = [self.products objectAtIndex:thumbView.groupIndex];
	NSArray *looks = [groupDic objectForKey:kProductLooks];
	NSDictionary *lookDic = [looks objectAtIndex:thumbView.lookIndex];
	{
		[[NSUserDefaults standardUserDefaults] setObject:[lookDic objectForKey:kLookName] forKey:kLookName];
        selectedLookIndex = thumbView.lookIndex;
        selectedGroupIndex = thumbView.groupIndex;
        [self performSegueWithIdentifier:@"LookPreviewController" sender:self];
		//end storyboard
        {
			//wait rendering thread stoped for a while
			[self endRender];
			while (!self.isRenderThreadStop)
			{
				NSLog(@"Waiting Rendering Thread");
			}
		}
	}
}

- (void)leftScrollButtonAnimateToHide
{
    [UIView transitionWithView:leftScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:leftScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    leftScrollButton.hidden = YES;
    leftScrollOpaque.hidden = YES;
    
}

- (void)leftScrollButtonAnimateToShow
{
#if 0
    [UIView transitionWithView:leftScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:leftScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    leftScrollButton.hidden = NO;
    leftScrollOpaque.hidden = NO;
#endif
    leftScrollButton.hidden = YES;
#ifdef BAR_OPAQUE
    leftScrollOpaque.hidden = NO;
#else
    leftScrollOpaque.hidden = YES;
#endif
}

- (void)rightScrollButtonAnimateToHide
{
    [UIView transitionWithView:rightScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:rightScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    rightScrollButton.hidden = YES;
    rightScrollOpaque.hidden = YES;
}

- (void)rightScrollButtonAnimateToShow
{
#if 0
    [UIView transitionWithView:rightScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:rightScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    rightScrollButton.hidden = NO;
    rightScrollOpaque.hidden = NO;
#endif
    rightScrollButton.hidden = YES;
#ifdef BAR_OPAQUE
    rightScrollOpaque.hidden = NO;
#else
    rightScrollOpaque.hidden = YES;
#endif
}

- (void)topScrollButtonAnimateToHide
{
    [UIView transitionWithView:topScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:topScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    topScrollButton.hidden = YES;
    topScrollOpaque.hidden = YES;
}

- (void)topScrollButtonAnimateToShow
{
#if 0
    [UIView transitionWithView:topScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:topScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    topScrollButton.hidden = NO;
    topScrollOpaque.hidden = NO;
#endif
    topScrollButton.hidden = YES;
#ifdef BAR_OPAQUE
    topScrollOpaque.hidden = NO;
#else
    topScrollOpaque.hidden = YES;
#endif
    
}

- (void)bottomScrollButtonAnimateToHide
{
    [UIView transitionWithView:bottomScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:bottomScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    bottomScrollButton.hidden = YES;
    bottomScrollOpaque.hidden = YES;
}

- (void)bottomScrollButtonAnimateToShow
{
#if 0
    [UIView transitionWithView:bottomScrollButton
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    [UIView transitionWithView:bottomScrollOpaque
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    bottomScrollButton.hidden = NO;
    bottomScrollOpaque.hidden = NO;
#endif
    bottomScrollButton.hidden = YES;
#ifdef BAR_OPAQUE
    bottomScrollOpaque.hidden = NO;
#else
    bottomScrollOpaque.hidden = YES;
#endif
}

- (void)leftScrollButtonAction:(id)sender
{
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = looksScrollView.contentOffset;
    if (IS_IPAD)
    {
        rowHeight = FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET;
        currentScrollPos = looksScrollView.contentOffset.x;
        if (currentScrollPos == 0)
            return;
        startRowBase = currentScrollPos/rowHeight;
        if (startRowBase == 0)
            currentScrollPos = 0;
        else
        {
            if (currentScrollPos % rowHeight )
                currentScrollPos = startRowBase*rowHeight;
            else
                currentScrollPos = (startRowBase-1)*rowHeight;
        }
        currentScrollPoint.x = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        rowHeight = FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
        currentScrollPos = looksScrollView.contentOffset.x;
        if (currentScrollPos == 0)
            return;
        startRowBase = currentScrollPos/rowHeight;
        if (startRowBase == 0)
            currentScrollPos = 0;
        else
        {
            if (currentScrollPos % rowHeight )
                currentScrollPos = startRowBase*rowHeight;
            else
                currentScrollPos = (startRowBase-1)*rowHeight;
        }
        currentScrollPoint.x = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }
}

- (void)rightScrollButtonAction:(id)sender
{
    NSInteger rowHeight;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = looksScrollView.contentOffset;
    if (IS_IPAD)
    {
        rowHeight = FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET;
        currentScrollPos = looksScrollView.contentOffset.x;
        if ( (looksScrollView.contentOffset.x + rowHeight ) >= looksScrollView.contentSize.width )
            return;
        currentScrollPos = currentScrollPos + rowHeight;
        currentScrollPoint.x = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        rowHeight = FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
        currentScrollPos = looksScrollView.contentOffset.x;
        if ( (looksScrollView.contentOffset.x + rowHeight ) >= looksScrollView.contentSize.width )
            return;
        currentScrollPos = currentScrollPos + rowHeight;
        currentScrollPoint.x = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }
}

- (void)topScrollButtonAction:(id)sender
{
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = looksScrollView.contentOffset;
    if (IS_IPAD)
    {
        rowHeight = FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET;
        currentScrollPos = looksScrollView.contentOffset.y;
        if (currentScrollPos == 0)
            return;
        startRowBase = currentScrollPos/rowHeight;
        if (startRowBase == 0)
            currentScrollPos = 0;
        else
        {
            if (currentScrollPos % rowHeight )
                currentScrollPos = startRowBase*rowHeight;
            else
                currentScrollPos = (startRowBase-1)*rowHeight;
        }
        currentScrollPoint.y = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        rowHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE;
        currentScrollPos = looksScrollView.contentOffset.y;
        if (currentScrollPos == 0)
            return;
        startRowBase = currentScrollPos/rowHeight;
        if (startRowBase == 0)
            currentScrollPos = 0;
        else
        {
            if (currentScrollPos % rowHeight )
                currentScrollPos = startRowBase*rowHeight;
            else
                currentScrollPos = (startRowBase-1)*rowHeight;
        }
        currentScrollPoint.y = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }
}
- (void)bottomScrollButtonAction:(id)sender
{
    NSInteger rowHeight;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = looksScrollView.contentOffset;
    if (IS_IPAD)
    {
        rowHeight = FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET;
        currentScrollPos = looksScrollView.contentOffset.y;
        if ( (looksScrollView.contentOffset.y + rowHeight ) >= looksScrollView.contentSize.height )
            return;
        currentScrollPos = currentScrollPos + rowHeight;
        currentScrollPoint.y = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        rowHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE;
        currentScrollPos = looksScrollView.contentOffset.y;
        if ( (looksScrollView.contentOffset.y + rowHeight ) >= looksScrollView.contentSize.height )
            return;
        currentScrollPos = currentScrollPos + rowHeight;
        currentScrollPoint.y = currentScrollPos;
        [looksScrollView setContentOffset:currentScrollPoint animated:YES];
    }
}
//

- (void)resetGroups:(NSUInteger)selectedIndex
{
	ToggleButton *groupButton = [groupsViews objectAtIndex:selectedIndex];
	
	if(groupButton.frame.origin.x - 20 < groupsScrollView.contentOffset.x) //left part hidden
	{
		CGPoint offset;
		offset.x = groupButton.frame.origin.x - 20;
		offset.y = 0;
		
		[groupsScrollView setContentOffset:offset animated:YES];
	}
	else if (groupButton.frame.origin.x + groupButton.frame.size.width + 20 - groupsScrollView.frame.size.width > groupsScrollView.contentOffset.x) //right part hidden
	{
		CGPoint offset;
		offset.x = groupButton.frame.origin.x + groupButton.frame.size.width + 20 - groupsScrollView.frame.size.width;
		offset.y = 0;
		
		[groupsScrollView setContentOffset:offset animated:YES];
	}
	
	for (ToggleButton *button in groupsViews)
	{
		if(button.tag == selectedIndex)
		{
			if (button.toggleState == ToggleStateNormal)
			{
				button.toggleState = ToggleStateHighlighted;
			}
		}
		else if(button.toggleState == ToggleStateHighlighted)
		{
			button.toggleState = ToggleStateNormal;
		}
	}
	
	currentSelectedGroup = groupButton.tag;
    {
		selectedGroupIndex_landscape = groupButton.tag;
	}

}

- (void)toggleGroup:(id)sender
{
	ToggleButton *groupButton = (ToggleButton*)sender;
	
	[self resetGroups:groupButton.tag];
	
	//currentSelectedGroup = groupButton.tag;
	
	for (LookThumbnailView *thumbView in looksViews)
	{
		if(thumbView.groupIndex == groupButton.tag)
		{
			CGPoint offset = thumbView.frame.origin;
            if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
			{
                //offset.x -= 7;
                offset.y = 0;
            }else
            {
                offset.x = 0;
                //offset.y -= 7;
            }
			thumbnailRequred = YES;
            {

				[looksScrollView setContentOffset:offset animated:YES];
			}

			break;
		}
	}
}

- (void) layoutUIs:(UIInterfaceOrientation)toInterfaceOrientation{
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
#ifdef BAR_OPAQUE
            topScrollOpaque.hidden = YES;
            bottomScrollOpaque.hidden = YES;
#endif
            CGFloat groupoffsetstartx = (1024 - groupsScrollView.contentSize.width)/2;
            CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
            if (groupsScrollView.contentSize.width > 1024)
            {
                groupoffsetstartx = 0;
                groupoffsetwidth = 1024;
            }
            groupsBackgroundView.frame = CGRectMake(0, 0, 1024, 80);
			groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0, groupoffsetwidth, 80);
			backgroundView_.frame = CGRectMake(0, 80, 1024, 768-80);
			//groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser_hiutiao_heng.png"];
			//backgroundView_.image = [UIImage imageNamed:@"LooksBrowser_background.png"];
            //buttonBottomOpaque.frame = CGRectMake(0, 704-FRAME_OPAQUE_HEIGHT, 1024,FRAME_OPAQUE_HEIGHT);
            buttonBottomOpaque.frame = CGRectMake(0, 768-FRAME_OPAQUE_HEIGHT, 1024,FRAME_OPAQUE_HEIGHT);
            //backToTrimButton.frame = CGRectMake(12, 768-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
            nextButton.frame = CGRectMake(1024-225-12, 768-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
        }
		else
        {
#ifdef BAR_OPAQUE
            leftScrollOpaque.hidden = YES;
            rightScrollOpaque.hidden = YES;
#endif
            CGFloat groupoffsetstartx = (768 - groupsScrollView.contentSize.width)/2;
            CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
            if (groupsScrollView.contentSize.width > 768)
            {
                groupoffsetstartx = 0;
                groupoffsetwidth = 768;
            }
			groupsBackgroundView.frame = CGRectMake(0, 0, 768, 80);
			groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0,groupoffsetwidth, 80);
			backgroundView_.frame = CGRectMake(0, 80, 768, 1024-80);
			//groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser02_huitiao_shu.png"];
			//backgroundView_.image = [UIImage imageNamed:@"LooksBrowser02_background.png"];
            buttonBottomOpaque.frame = CGRectMake(0, 1024-44-FRAME_OPAQUE_HEIGHT, 768,FRAME_OPAQUE_HEIGHT);
            //backToTrimButton.frame = CGRectMake(12, 1024-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
            nextButton.frame = CGRectMake(768-225-12, 1024-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
		}
	}else
    {
		if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
#ifdef BAR_OPAQUE
            topScrollOpaque.hidden = YES;
            bottomScrollOpaque.hidden = YES;
#endif
            if (IS_IPHONE_5)
            {
                CGFloat groupoffsetstartx = (568 - groupsScrollView.contentSize.width)/2;
                CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
                if (groupsScrollView.contentSize.width > 568)
                {
                    groupoffsetstartx = 0;
                    groupoffsetwidth = 568;
                }
                groupsBackgroundView.frame = CGRectMake(0, 0, 568, 41);
                groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0, groupoffsetwidth, 41);
                backgroundView_.frame = CGRectMake(0, 41, 568, 320-41);
                //groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser_hiutiao_heng.png"];
                //backgroundView_.image = [UIImage imageNamed:@"LooksBrowser_background.png"];
                //buttonBottomOpaque.frame = CGRectMake(0, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE, 568,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                //nextButton.frame = CGRectMake(568-106-12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
                buttonBottomOpaque.frame = CGRectMake(0, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE, 568,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                nextButton.frame = CGRectMake(568-106-12, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
            }else
            {
                CGFloat groupoffsetstartx = (480 - groupsScrollView.contentSize.width)/2;
                CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
                if (groupsScrollView.contentSize.width > 480)
                {
                    groupoffsetstartx = 0;
                    groupoffsetwidth = 480;
                }
                groupsBackgroundView.frame = CGRectMake(0, 0, 480, 41);
                groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0, groupoffsetwidth, 41);
                backgroundView_.frame = CGRectMake(0, 41, 480, 320-41);
                //groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser_hiutiao_heng.png"];
                //backgroundView_.image = [UIImage imageNamed:@"LooksBrowser_background.png"];
                //buttonBottomOpaque.frame = CGRectMake(0, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE, 480,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                //nextButton.frame = CGRectMake(480-106-12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
                buttonBottomOpaque.frame = CGRectMake(0, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE, 480,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                nextButton.frame = CGRectMake(480-106-12, 330-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
            }
            //groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser_hiutiao_heng.png"];
			//backgroundView_.image = [UIImage imageNamed:@"LooksBrowser_background.png"];
		}
		else
        {
#ifdef BAR_OPAQUE
            leftScrollOpaque.hidden = YES;
            rightScrollOpaque.hidden = YES;
#endif
            if (IS_IPHONE_5)
            {
                CGFloat groupoffsetstartx = (320 - groupsScrollView.contentSize.width)/2;
                CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
                if (groupsScrollView.contentSize.width > 320)
                {
                    groupoffsetstartx = 0;
                    groupoffsetwidth = 320;
                }
                groupsBackgroundView.frame = CGRectMake(0, 0, 320, 41);
                groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0,groupoffsetwidth, 41);
                backgroundView_.frame = CGRectMake(0, 41, 320, 568-41);
                //groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser02_huitiao_shu.png"];
                //backgroundView_.image = [UIImage imageNamed:@"LooksBrowser02_background.png"];
                buttonBottomOpaque.frame = CGRectMake(0, 568-44-FRAME_OPAQUE_HEIGHT_IPHONE, 320,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 568-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                nextButton.frame = CGRectMake(320-106-12, 568-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
            }else
            {
                CGFloat groupoffsetstartx = (320 - groupsScrollView.contentSize.width)/2;
                CGFloat groupoffsetwidth = groupsScrollView.contentSize.width;
                if (groupsScrollView.contentSize.width > 320)
                {
                    groupoffsetstartx = 0;
                    groupoffsetwidth = 320;
                }
                groupsBackgroundView.frame = CGRectMake(0, 0, 320, 41);
                groupsScrollView.frame = CGRectMake(groupoffsetstartx, 0,groupoffsetwidth, 41);
                backgroundView_.frame = CGRectMake(0, 41, 320, 480-41);
                //groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser02_huitiao_shu.png"];
                //backgroundView_.image = [UIImage imageNamed:@"LooksBrowser02_background.png"];
                buttonBottomOpaque.frame = CGRectMake(0, 480-44-FRAME_OPAQUE_HEIGHT_IPHONE, 320,FRAME_OPAQUE_HEIGHT_IPHONE);
                //backToTrimButton.frame = CGRectMake(12, 480-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
                nextButton.frame = CGRectMake(320-106-12, 480-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
            }
            //tableView_.frame = CGRectMake(0, 41, 768, 1024-144); //bret
			//groupsBackgroundView.image = [UIImage imageNamed:@"LooksBrowser02_huitiao_shu.png"];
			//backgroundView_.image = [UIImage imageNamed:@"LooksBrowser02_background.png"];
		}
        
    }
}

-(void)renderLoop
{	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSUInteger thumbnailIndex = 0;
	//for a first frame render bug 
	BOOL isRenderFirstTime = YES;
	while (!renderThreadCancel) {
//		if(!isRenderAlready) continue;
		
		[renderCondition lock];
		while ([renderQueue count]==0 && !renderThreadCancel)
			[renderCondition wait];
		if (!renderThreadCancel) 
		{
			thumbnailIndex = [[renderQueue lastObject] unsignedIntValue];
			if(!isRenderFirstTime)
				[renderQueue removeLastObject];
		}
		[renderCondition unlock];
		if(renderThreadCancel) 
			break;
		
		LookThumbnailView* thumbnailView = [looksViews objectAtIndex:thumbnailIndex];
		NSLog(@"Render thumb %d",thumbnailIndex);
		//if (thumbnailView.renderingState!=RenderingStateNone)
		//	continue;
		
		NSDictionary *packDic = [self.products objectAtIndex:thumbnailView.groupIndex];
		NSArray *items = [packDic objectForKey:kProductLooks];
		NSDictionary *lookDic = [items objectAtIndex:thumbnailView.lookIndex];
			
		[renderer loadLookParam:lookDic withMode:videoMode];
		renderer.looksStrengthValue = 1.0;
		renderer.looksBrightnessValue = 0.5;
				
		
		UIImage* processedImage = nil;
		CGImageRef processedCGImageRef = [renderer frameProcessingAndReturnImage:nil flipPixel:NO];
		if(videoMode==VideoModeWideSceenPortrait || videoMode==VideoModeTraditionalPortrait) {
			processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef  scale:1.0 orientation:UIImageOrientationRight];
		}
		else {
			processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef];
		}
		
		CGImageRelease(processedCGImageRef);
		
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   if(!isRenderFirstTime)
						   {
							   [thumbnailView setThumbnailImage:processedImage];
							   thumbnailView.renderingState = RenderingStateCompleted;
							   [thumbnailView.activityIndicator stopAnimating];
						   } 
						   [processedImage release];
					   });
		isRenderFirstTime = NO;
	}
	[pool release];	
	NSLog(@"Render Thread Stop!");
	self.isRenderThreadStop = YES;
}

- (void)resetRenderer:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	[renderLock lock];
	
	NSLog(@"renderer reset");
	[renderer resetFrameSize:frameSize outputFrameSize:outputSize];
	
//	[renderLock unlock];
	
	[pool release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    mScrollViewHackFirstTime = YES;
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = nil;
	renderQueue = [[NSMutableArray alloc] init];
	//self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
	UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backToTrimAction:)];
	self.navigationItem.leftBarButtonItem = backButton;

	//UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
	//**self.navigationItem.leftBarButtonItem = backButton;

	
	[self loadData];
	
	//self.view.backgroundColor = [UIColor blackColor];
	
	self.title = NSLocalizedString(@"Select a Look", nil);
	
    float f_width;
	float s_height;
	float f_looksScrollViewLeft;
	
	float f_looksScrollViewWidth;
	float f_looksScrollViewHeight;
	float f_looksScrollViewTop;
	float f_looksScrollOffset;

    f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
    f_width = 480;
    s_height = 320-41-44;
    f_looksScrollViewLeft = (480 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2-(f_looksScrollOffset/2);
    
    f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE+f_looksScrollOffset;
    f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE;
    
    f_looksScrollViewTop = 41+f_looksScrollOffset;

    if (IS_IPHONE_5)
    {
        f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
        f_width = 568;
        s_height = 320-41-44;
        f_looksScrollViewLeft = (568 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2-(f_looksScrollOffset/2);
        
        f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE+f_looksScrollOffset;
        f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE;
        
        f_looksScrollViewTop = 41+f_looksScrollOffset;
	}

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET;
        f_width = 1024;
		s_height = 1004-41-44;
		f_looksScrollViewLeft = (1024 - FRAME_CROP_SIZE_WIDTH)/2-(f_looksScrollOffset/2);
		
		f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH+f_looksScrollOffset;
		f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT;
		
		f_looksScrollViewTop = 80+f_looksScrollOffset;
	}
	
	//bret moved
	backgroundView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 41, f_width, s_height)];
	[backgroundView_ setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview:backgroundView_];
    self.looksScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(f_looksScrollViewLeft, f_looksScrollViewTop, f_looksScrollViewWidth, f_looksScrollViewHeight)];
	looksScrollView.backgroundColor = [UIColor clearColor];
	looksScrollView.pagingEnabled = YES;
	looksScrollView.clipsToBounds = NO;
	looksScrollView.delegate = self;
	looksScrollView.showsVerticalScrollIndicator = NO;
	looksScrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:looksScrollView];
	[looksScrollView release];

    scrollEnhancer = [[ScrollViewEnhancer alloc] initWithFrame:CGRectMake(0, f_looksScrollViewTop, f_width, f_looksScrollViewHeight)];
	scrollEnhancer.scrollView = looksScrollView;
	[self.view insertSubview:scrollEnhancer belowSubview:looksScrollView];
	[scrollEnhancer release];
    //
    
    groupsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, f_width, 41)];
	//groupsBackgroundView.image = [UIImage imageNamed:@"lb_groups_background.png"];
	groupsBackgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:groupsBackgroundView];
	
	self.groupsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, f_width, 41)];
	groupsScrollView.backgroundColor = [UIColor clearColor];
	groupsScrollView.showsVerticalScrollIndicator = NO;
	groupsScrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:groupsScrollView];
	[groupsScrollView release];
	//ScrollViewEnhancer *scrollEnhancer = [[ScrollViewEnhancer alloc] initWithFrame:CGRectMake(0, f_looksScrollViewTop, f_width, f_looksScrollViewHeight)];
	//scrollEnhancer.scrollView = looksScrollView;
	UIImage *border = [UIImage imageNamed:@"lb_thumbnail_border.png"]; //bret 325x192
	//UIImage *titleBackground = [[UIImage imageNamed:@"lb_look_title_background.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:0]; //bret 16x24
	UIImage *lock = [UIImage imageNamed:@"lb_thumbnail_lock.png"];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		border = [UIImage imageNamed:@"LooksBrowser_xiangkuang.png"];
		lock = [UIImage imageNamed:@"LooksBrowser_suo.png"];
		//titleBackground = [[UIImage imageNamed:@"LooksBrowser02_hongtiao.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	}
	
	self.groupsViews = [NSMutableArray array];
	self.looksViews = [NSMutableArray array];
	looksDic_ = [[NSMutableArray alloc] init];
	
	headers = [[NSMutableDictionary alloc] init];
	
	float lookOffset = 0.0;
	float groupOffset = 24.0;
	NSUInteger thumbViewPageIndex = 0;
	for (int i = 0; i < [products count]; i++)
	{
		NSDictionary *groupDic = [products objectAtIndex:i];
		
		NSString *groupName = [groupDic objectForKey:kProductName];
		NSArray *looks = [groupDic objectForKey:kProductLooks];
		BOOL locked = [[groupDic objectForKey:kProductLocked] boolValue];
		
		CGPoint groupOrigin = CGPointMake(groupOffset, 6);
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			groupOrigin = CGPointMake(groupOffset, 13);
		}
		
		NSString *subtitle = [NSString stringWithFormat:@"(%i)", [looks count]];
		
		ToggleButton *groupButton = [[ToggleButton alloc] initWithOrigin:groupOrigin title:groupName subtitle:subtitle];
		[groupButton addTarget:self action:@selector(toggleGroup:) forControlEvents:UIControlEventTouchUpInside];
		groupButton.tag = i;
		groupButton.exclusiveTouch = YES;
		[groupsScrollView addSubview:groupButton];
		[groupsViews addObject:groupButton];
		[groupButton release];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			//groupOffset += 10.0 + groupButton.frame.size.width;
			groupOffset += 8.0 + groupButton.frame.size.width;
		}
		else
        {
			groupOffset += 18.0 + groupButton.frame.size.width;
		}

		
//		NSLog(@"groupButton.frame.origin={%.1f, %.1f}", groupButton.frame.origin.x, groupButton.frame.origin.y);
		
		if (i == 0)
		{
			groupButton.toggleState = ToggleStateHighlighted;
		}
		
		NSMutableArray *array = [NSMutableArray array];
		
		NSMutableArray *gLooksArr = [NSMutableArray array];
		
		for (int j = 0; j < [looks count]; j++)
		{
			NSDictionary *lookDic = [looks objectAtIndex:j];
			
			//if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
            //{
			//	lookOffset += 7;
			//}
			CGRect thumbRect;
			float offset;
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
				thumbRect = CGRectMake(lookOffset, 0, FRAME_CROP_SIZE_WIDTH, FRAME_CROP_SIZE_HEIGHT);
				offset = FRAME_CROP_SIZE_WIDTH;
				lookOffset += f_looksScrollOffset;
			}else
            {
				thumbRect = CGRectMake(lookOffset, 0, FRAME_CROP_SIZE_WIDTH_IPHONE, FRAME_CROP_SIZE_HEIGHT_IPHONE);
				offset = FRAME_CROP_SIZE_WIDTH_IPHONE;
				lookOffset += f_looksScrollOffset;
            }
		
			LookThumbnailView *thumbView = [[LookThumbnailView alloc] initWithFrame:thumbRect lookInfo:lookDic];
			thumbView.groupIndex = i;
			thumbView.lookIndex = j;
			thumbView.pageIndex = thumbViewPageIndex;
			thumbView.borderView.image = border;
			thumbView.delegate = self;
			lookOffset += offset;
			
			thumbView.actualRect = thumbRect;
			
			if(locked)
			{
				thumbView.lockView.image = lock;
			}
			
			[array addObject:thumbView];
			[thumbView release];
			
			[looksScrollView addSubview:thumbView];
			[self.looksViews addObject:thumbView];
			++thumbViewPageIndex;
			
			[gLooksArr addObject:thumbView];
						
		}
		
		[looksDic_ addObject:gLooksArr];
	}
	
	groupsScrollView.contentSize = CGSizeMake(groupOffset + 8, 0);
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        groupsScrollView.contentSize = CGSizeMake(groupOffset + 18, 0);
    }
	looksScrollView.contentSize = CGSizeMake(lookOffset, 0);

// disable left/right, up/down nav buttons
//#if 0
	//bret button code
    CGRect leftScrollButtonFrame = CGRectMake(16/2, 242/2, 71/2, 99/2);
	CGRect rightScrollButtonFrame = CGRectMake(873/2, 242/2, 71/2, 99/2);
	CGRect topScrollButtonFrame = CGRectMake(268/2, 10+41, 99/2, 71/2);
	CGRect bottomScrollButtonFrame = CGRectMake(268/2, 393-42, 99/2, 71/2);
    if (IS_IPHONE_5)
    {
        leftScrollButtonFrame = CGRectMake(16/2, 242/2, 71/2, 99/2);
        rightScrollButtonFrame = CGRectMake(1048/2, 242/2, 71/2, 99/2);
        topScrollButtonFrame = CGRectMake(268/2, 10+41, 99/2, 71/2);
        bottomScrollButtonFrame = CGRectMake(268/2, 481-42, 99/2, 71/2);
    }
    CGFloat landscapeheight = FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
    CGFloat landscapewidth = (480-(FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE))/2;
    CGFloat portraitwidth = 320;
    CGFloat portraitheight = ((480-44-41-FRAME_OPAQUE_HEIGHT_IPHONE)-(FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE))/2;
    CGRect leftScrollOpaqueFrame = CGRectMake(0, 41, landscapewidth,landscapeheight);
    CGRect rightScrollOpaqueFrame = CGRectMake(480-landscapewidth, 41,landscapewidth, landscapeheight);
    CGRect topScrollOpaqueFrame = CGRectMake(0, 41, portraitwidth, portraitheight);
    CGRect bottomScrollOpaqueFrame = CGRectMake(0, 480-44-FRAME_OPAQUE_HEIGHT_IPHONE-portraitheight, portraitwidth, portraitheight);
    if (IS_IPHONE_5)
    {
        landscapeheight = FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
        landscapewidth = (568-(FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE))/2;
        portraitwidth = 320;
        portraitheight = ((568-44-41-FRAME_OPAQUE_HEIGHT_IPHONE)-(FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE))/2;
        leftScrollOpaqueFrame = CGRectMake(0, 41, landscapewidth,landscapeheight);
        rightScrollOpaqueFrame = CGRectMake(568-landscapewidth, 41,landscapewidth, landscapeheight);
        topScrollOpaqueFrame = CGRectMake(0, 41, portraitwidth, portraitheight);
        bottomScrollOpaqueFrame = CGRectMake(0, 568-44-FRAME_OPAQUE_HEIGHT_IPHONE-portraitheight, portraitwidth, portraitheight);
    }
    NSString *leftScrollButtonFilename = @"camera_roll_button_left_iphone.png";
    NSString *leftScrollButtonFilenameSel = @"camera_roll_button_left_iphone.png";
    NSString *rightScrollButtonFilename = @"camera_roll_button_right_iphone.png";
    NSString *rightScrollButtonFilenameSel = @"camera_roll_button_right_iphone.png";
    NSString *topScrollButtonFilename = @"camera_roll_button_top_iphone.png";
    NSString *topScrollButtonFilenameSel = @"camera_roll_button_top_iphone.png";
    NSString *bottomScrollButtonFilename = @"camera_roll_button_bottom_iphone.png";
    NSString *bottomScrollButtonFilenameSel = @"camera_roll_button_bottom_iphone.png";
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        leftScrollButtonFrame = CGRectMake(18, 274, 86, 119);
        rightScrollButtonFrame = CGRectMake(920, 274, 86, 119);
        topScrollButtonFrame = CGRectMake(325, 14+80, 119, 86);
        bottomScrollButtonFrame = CGRectMake(325, 880-80, 119, 86);
		
        leftScrollButtonFilename = @"camera_roll_button_left_ipad.png";
        leftScrollButtonFilenameSel = @"camera_roll_button_left_ipad.png";
        rightScrollButtonFilename = @"camera_roll_button_right_ipad.png";
        rightScrollButtonFilenameSel = @"camera_roll_button_right_ipad.png";
        topScrollButtonFilename = @"camera_roll_button_top_ipad.png";
        topScrollButtonFilenameSel = @"camera_roll_button_top_ipad.png";
        bottomScrollButtonFilename = @"camera_roll_button_bottom_ipad.png";
        bottomScrollButtonFilenameSel = @"camera_roll_button_bottom_ipad.png";
        
        landscapeheight = FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET;
        landscapewidth = (1024-(FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET))/2;
        //CGFloat portraitheight = 1024 - FRAME_OPAQUE_HEIGHT - 44 - 80;
        portraitwidth = 768;
        portraitheight = ((1024-44-80-FRAME_OPAQUE_HEIGHT)-(FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET))/2;
        //f_looksScrollViewTop = ((1024-44-80-FRAME_OPAQUE_HEIGHT)-(FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET))/2;
        leftScrollOpaqueFrame = CGRectMake(0, 80, landscapewidth,landscapeheight);
        rightScrollOpaqueFrame = CGRectMake(1024-landscapewidth, 80,landscapewidth, landscapeheight);
        topScrollOpaqueFrame = CGRectMake(0, 80, portraitwidth, portraitheight);
        bottomScrollOpaqueFrame = CGRectMake(0, 1024-44-FRAME_OPAQUE_HEIGHT-portraitheight, portraitwidth, portraitheight);
	}
	
    leftScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftScrollButton.frame = leftScrollButtonFrame;
	leftScrollButton.hidden = YES;
	leftScrollButton.alpha = .85;
	[leftScrollButton setImage:[UIImage imageNamed:leftScrollButtonFilename] forState:UIControlStateNormal];
	[leftScrollButton setImage:[UIImage imageNamed:leftScrollButtonFilenameSel] forState:UIControlStateHighlighted];
	[leftScrollButton addTarget:self action:@selector(leftScrollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:leftScrollButton];
    
    rightScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightScrollButton.frame = rightScrollButtonFrame;
	rightScrollButton.hidden = YES;
	rightScrollButton.alpha = .85;
	[rightScrollButton setImage:[UIImage imageNamed:rightScrollButtonFilename] forState:UIControlStateNormal];
	[rightScrollButton setImage:[UIImage imageNamed:rightScrollButtonFilenameSel] forState:UIControlStateHighlighted];
	[rightScrollButton addTarget:self action:@selector(rightScrollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:rightScrollButton];
    
    topScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	topScrollButton.frame = topScrollButtonFrame;
	topScrollButton.hidden = YES;
	topScrollButton.alpha = .85;
	[topScrollButton setImage:[UIImage imageNamed:topScrollButtonFilename] forState:UIControlStateNormal];
	[topScrollButton setImage:[UIImage imageNamed:topScrollButtonFilenameSel] forState:UIControlStateHighlighted];
	[topScrollButton addTarget:self action:@selector(topScrollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:topScrollButton];
    
    bottomScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bottomScrollButton.frame = bottomScrollButtonFrame;
	bottomScrollButton.hidden = YES;
	bottomScrollButton.alpha = .85;
	[bottomScrollButton setImage:[UIImage imageNamed:bottomScrollButtonFilename] forState:UIControlStateNormal];
	[bottomScrollButton setImage:[UIImage imageNamed:bottomScrollButtonFilenameSel] forState:UIControlStateHighlighted];
	[bottomScrollButton addTarget:self action:@selector(bottomScrollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bottomScrollButton];
    
    leftScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	leftScrollOpaque.frame = leftScrollOpaqueFrame;
	leftScrollOpaque.hidden = YES;
	[leftScrollOpaque setEnabled:NO];
	leftScrollOpaque.backgroundColor = [UIColor blackColor];
	leftScrollOpaque.alpha = .35;
    [self.view addSubview:leftScrollOpaque];
    
    rightScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	rightScrollOpaque.frame = rightScrollOpaqueFrame;
	rightScrollOpaque.hidden = YES;
	[rightScrollOpaque setEnabled:NO];
	rightScrollOpaque.backgroundColor = [UIColor blackColor];
	rightScrollOpaque.alpha = .35;
    [self.view addSubview:rightScrollOpaque];
    
    topScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	topScrollOpaque.frame = topScrollOpaqueFrame;
	topScrollOpaque.hidden = YES;
	[topScrollOpaque setEnabled:NO];
	topScrollOpaque.backgroundColor = [UIColor blackColor];
	topScrollOpaque.alpha = .35;
    [self.view addSubview:topScrollOpaque];
    
    bottomScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	bottomScrollOpaque.frame = bottomScrollOpaqueFrame;
	bottomScrollOpaque.hidden = YES;
	[bottomScrollOpaque setEnabled:NO];
	bottomScrollOpaque.backgroundColor = [UIColor blackColor];
	bottomScrollOpaque.alpha = .35;
    [self.view addSubview:bottomScrollOpaque];
    
	buttonBottomOpaque = [[UIView alloc] initWithFrame:bottomScrollOpaqueFrame];
	buttonBottomOpaque.backgroundColor = [UIColor blackColor];
	[self.view addSubview:buttonBottomOpaque];
	//[buttonBottomOpaque release];
    
    //bret end button code
//#endif

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //backToTrimButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //backToTrimButton.frame = CGRectMake(12, 768-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
        //backToTrimButton.hidden = NO;
        //backToTrimButton.alpha = 1.0;
        //[backToTrimButton setImage:[UIImage imageNamed:@"looksbrowser_cancel_button225x72.png"] forState:UIControlStateNormal];
        //[backToTrimButton setImage:[UIImage imageNamed:@"looksbrowser_cancel_button225x72.png"] forState:UIControlStateHighlighted];
        //[backToTrimButton addTarget:self action:@selector(backToTrimAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addSubview:backToTrimButton];
        
        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextButton.frame = CGRectMake(1024-225-12, 768-44-FRAME_OPAQUE_HEIGHT+((FRAME_OPAQUE_HEIGHT-72)/2), 225, 72);
        nextButton.hidden = NO;
        nextButton.alpha = 1.0;
        [nextButton setImage:[UIImage imageNamed:@"looksbrowser_next_button225x72.png"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"looksbrowser_next_button225x72.png"] forState:UIControlStateHighlighted];
        [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }else
    {
        //backToTrimButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //if (IS_IPHONE_5)
        //    backToTrimButton.frame = CGRectMake(12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
        //else
        //    backToTrimButton.frame = CGRectMake(12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 103, 33);
        //backToTrimButton.hidden = NO;
        //backToTrimButton.alpha = 1.0;
        //[backToTrimButton setImage:[UIImage imageNamed:@"looksbrowser_cancel_button103x33_iphone.png"] forState:UIControlStateNormal];
        //[backToTrimButton setImage:[UIImage imageNamed:@"looksbrowser_cancel_button103x33_iphone.png"] forState:UIControlStateHighlighted];
        //[backToTrimButton addTarget:self action:@selector(backToTrimAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addSubview:backToTrimButton];
        
        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (IS_IPHONE_5)
            nextButton.frame = CGRectMake(568-225-12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
        else
            nextButton.frame = CGRectMake(480-225-12, 320-44-FRAME_OPAQUE_HEIGHT_IPHONE+((FRAME_OPAQUE_HEIGHT_IPHONE-33)/2), 106, 33);
        nextButton.hidden = NO;
        nextButton.alpha = 1.0;
        [nextButton setImage:[UIImage imageNamed:@"looksbrowser_next_button106x33_iphone.png"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"looksbrowser_next_button106x33_iphone.png"] forState:UIControlStateHighlighted];
        [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
        
    }
//	isRenderAlready = NO;
	renderCondition = [[NSCondition alloc] init];

	if (renderer == nil)
		[self initRenderer:nil];
	
	currentSelectedGroup = 0;
	selectedGroupIndex_Portrait = 0;
	selectedGroupIndex_landscape = 0;
	[self layoutAfterorientation:self.interfaceOrientation];
	
	if([looksScrollView superview]){
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(renderFirst) userInfo:nil repeats:NO];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseRender:) 
                                             name:@"ReleaseRender"
                                             object:nil];
    
    mScrollViewHackFirstTime = NO;

}

- (void) renderFirst{
	NSArray *a = [looksDic_ objectAtIndex:0];
	if([a count]){
		LookThumbnailView *thumb = [a objectAtIndex:0];
//		[self rendererThumbnail:thumb];
		thumb.renderingState = RenderingStateNone;
		[self rendererThumbnail:thumb];
	}
	NSArray *b = [looksDic_ objectAtIndex:0];
	if([b count]){
		LookThumbnailView *thumb = [b objectAtIndex:1];
        //		[self rendererThumbnail:thumb];
		thumb.renderingState = RenderingStateNone;
		[self rendererThumbnail:thumb];
	}

}

-(void)releaseRender:(NSNotification *)notification
{
	if (renderer) {
		[renderer release];
		renderer = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	
//#if 0
    leftScrollButton.hidden = YES;
    leftScrollOpaque.hidden = YES;
    rightScrollButton.hidden = YES;
    rightScrollOpaque.hidden = YES;
    topScrollButton.hidden = YES;
    topScrollOpaque.hidden = YES;
    bottomScrollButton.hidden = YES;
    bottomScrollOpaque.hidden = YES;
//#endif
    
    [super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:NO animated:NO];

	[self startRender];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchaseSuccess:) 
                                                 name:@"purchaseSuccess"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(faliedTransaction:) 
                                                 name:@"faliedTransaction"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelTransaction:) 
                                                 name:@"cancelTransaction"
                                               object:nil];	  
	NSLog(@"Thread Start");
    //bret
    //[self layoutAfterorientation:self.interfaceOrientation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LooksPreviewOnScreen" object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"purchaseSuccess" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"faliedTransaction" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelTransaction" object:nil];	
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Landscape Support

#if 0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
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
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
//		self.overView.hidden = YES;
//		[self.activityIndicator stopAnimating];
		MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate endPurchaseMask];
	}
	else
	{
		[self showNetworkActivityIndicator];
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:self.productIdentifier];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
	
	NSLog(@"productsRequest:didReceiveResponse:");
	NSArray *myProducts = response.products;
	
	NSLog(@"the count of products is %d", [myProducts count]);
	if ([myProducts count] == 0)
	{
//		self.overView.hidden = YES;
//		[self.activityIndicator stopAnimating];
				
//		CustomAlertView *alerView =  [[CustomAlertView alloc] initWithTitle:@"Error"
//																	message:@"Failed retrieve production infomation from Apple App Store"
//																   delegate:self
//																 leftButton:cancelButton
//																rightButton:nil];
		
//		[alerView show];
//		[alerView release];
	}
	
	// populate UI
	for(SKProduct *product in myProducts)
	{
		NSString *lookName = [requestDictionary objectForKey:[request description]];
		
		NSString *currencySymbol = [[product priceLocale] objectForKey:NSLocaleCurrencySymbol];
		NSString *msg = [NSString stringWithFormat:@"This Look is a part of the \"%@\" Look Pack. Do you wish to purchase it now for %@%@?",
						 [product localizedTitle], currencySymbol, [product price] ];
		
		UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:lookName
															 message:msg
															delegate:self
												   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
												   otherButtonTitles:NSLocalizedString(@"Purchase",nil), nil];
		
		[alertView show];
		[alertView release];
		
		self.productIdentifier = product.productIdentifier;
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[self hiddenNetworkActivityIndicator];

	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate endPurchaseMask];

	UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot connect",nil)
														message:NSLocalizedString(@"No network connection available, please check your device settings.",nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil)
											  otherButtonTitles:nil];
	
	[alerView show];
	[alerView release];
}

#pragma mark -
#pragma mark Purchase Process

-(void)faliedTransaction:(NSNotification *) notification
{
	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate endPurchaseMask];
}

-(void)cancelTransaction:(NSNotification *) notification
{
	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate endPurchaseMask];
}

- (void) purchaseSuccess:(NSNotification *) notification
{
	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate endPurchaseMask];

	if ([[notification name] isEqualToString:@"purchaseSuccess"])
	{
		NSLog (@"Purchase Success!");
		
		[self hiddenNetworkActivityIndicator];
		
		self.products = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserLooks];
		
		NSString *purchasedIdentifier = [notification object];
		
		for (int i = 0; i < [products count]; i++)
		{
			NSDictionary *groupDic = [products objectAtIndex:i];
			NSString *identifier = [groupDic objectForKey:kProductIdentifier];
			if ([identifier compare:purchasedIdentifier] == NSOrderedSame)
			{
				for (LookThumbnailView *thumbView in self.looksViews)
				{
					if (thumbView.groupIndex == i)
					{
						thumbView.lockView.hidden = YES;
					}
				}
				break;
			}
		}
	}
}

#pragma mark -
#pragma mark LooksPackageDelegate

- (void) purchaseProduct:(NSString *)identifier withLookName:(NSString *)lookName
{
//	if (self.overView)
//	{
//		self.overView.hidden = NO;
//	}
//	else
//	{
//		if (self.interfaceOrientation == UIInterfaceOrientationPortrait
//			|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//		{
//			self.overView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
//		}
//		else
//		{
//			self.overView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 266)];
//		}
//
//		overView.image = [UIImage imageNamed:@"over.png"];
//		overView.userInteractionEnabled = YES;
//		[self.view addSubview:overView];
//		[self.view bringSubviewToFront:overView];
//		[overView release];
//	}
//	
//	if (activityIndicator)
//	{
//		[activityIndicator startAnimating];
//	}
//	else
//	{
//		self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		if (self.interfaceOrientation == UIInterfaceOrientationPortrait
//			|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//		{
//			activityIndicator.frame = CGRectMake(140, 200, 30, 30);
//		}
//		else
//		{
//			activityIndicator.frame = CGRectMake(225, 118, 30, 30);
//		}
//		
//		//overView.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//		[self.view addSubview:activityIndicator];
//		[self.view bringSubviewToFront:activityIndicator];
//		[activityIndicator startAnimating];
//		[activityIndicator release];
//	}
	
	[self showNetworkActivityIndicator];
	
	NSLog(@"requestProductData:%@", identifier);
	NSSet *productSet =[NSSet setWithObject:identifier];
	SKProductsRequest *request = [[[SKProductsRequest alloc] initWithProductIdentifiers: productSet] autorelease]; 
	request.delegate = self;
	
	if (requestDictionary == nil)
	{
		self.requestDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
	}
	
	[requestDictionary setObject:lookName forKey:[request description]];
	
	[request start];
}

- (void)tapLook:(NSInteger)lookIndex inGroup:(NSInteger)groupIndex;
{
	NSDictionary *groupDic = [self.products objectAtIndex:groupIndex];
	NSArray *looks = [groupDic objectForKey:kProductLooks];
	NSDictionary *lookDic = [looks objectAtIndex:lookIndex];
	
	//Business
	BOOL locked = [[groupDic objectForKey:kProductLocked] boolValue];
	if (locked)
	{
		MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate startPurchaseMask];
		
		NSString *identifier = [groupDic objectForKey:kProductIdentifier];
		NSString *lookName = [lookDic objectForKey:kLookName];
		[self purchaseProduct:identifier withLookName:lookName];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[lookDic objectForKey:kLookName] forKey:kLookName];
#if 0 //storyboard
		LookPreviewController* previewController = [[LookPreviewController alloc] init];
		previewController.frameSize = frameSize;
		previewController.outputSize = outputSize;
		previewController.renderer = renderer;
		previewController.videoMode = videoMode;
		previewController.lookDic = lookDic;		
		[self.navigationController pushViewController:previewController animated:YES];
		[previewController release];
#endif
        selectedLookIndex = lookIndex;
        selectedGroupIndex = groupIndex;
        [self performSegueWithIdentifier:@"LookPreviewController" sender:self];
		//end storyboard
        {
			//wait rendering thread stoped for a while
			[self endRender];
//			NSLog(@"tapLook:Wait Rendering Thread");			
			while (!self.isRenderThreadStop)
			{	
				NSLog(@"Waiting Rendering Thread");
				//[NSThread sleepForTimeInterval:0.3];
			}
//			NSLog(@"tapLook:Waited Rendering Thread");			
		}
	}
}

#pragma mark -
#pragma mark Thumbnail Preview Rendering
- (void) rendererThumbnail:(LookThumbnailView*)thumbView
{	
	 if(thumbView.renderingState == RenderingStateNone)
	 {
		 [renderCondition lock];
		 thumbView.renderingState = RenderingStateRendering;
		 [thumbView.activityIndicator startAnimating];
		 [renderQueue addObject:[NSNumber numberWithUnsignedInt:thumbView.pageIndex]];
		 [renderCondition signal];
		 [renderCondition unlock];
	 }	
}

- (void)processingOnscreenLooks
{
	//NSLog(@"processingOnscreenLooks:");
	
	//CGFloat pageWidth = looksScrollView.frame.size.width;
    //int page = floor((looksScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    CGFloat pageWidth;
    int page;
    if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        pageWidth = looksScrollView.frame.size.width;
        page = floor((looksScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	}else
    {
        pageWidth = looksScrollView.frame.size.height;
        page = floor((looksScrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    }
    
	if (page < [looksViews count])
	{
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
		[self rendererThumbnail:thumbView];
	}
	
	if (page+1 < [looksViews count])
	{
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page+1];
		[self rendererThumbnail:thumbView];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	if(sender != looksScrollView)return;

    //bret button scroll
//#if 0
    if (IS_IPAD)
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }else
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }
//#endif
    //end button scroll
	if (!thumbnailRequred)
	{
		return;
	}
	
    CGFloat pageWidth;
    int page;
    if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        pageWidth = sender.frame.size.width;
        page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	}else
    {
        pageWidth = sender.frame.size.height;
        page = floor((sender.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    }
    
	if (page < [looksViews count])
	{
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
		[self resetGroups:thumbView.groupIndex];
		[self rendererThumbnail:thumbView];
	}
	
	if (page+1 < [looksViews count])
	{
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page+1];
		[self rendererThumbnail:thumbView];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if(scrollView != looksScrollView)return;
	
    //bret button scroll
//#if 0
    if (IS_IPAD)
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }else
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }
//#endif
    //end button scroll

	thumbnailRequred = YES;
	[self processingOnscreenLooks];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//	NSLog(@"scrollViewDidEndDragging:%i", decelerate);
//	if (decelerate)
//	{
//		CGFloat pageWidth = scrollView.frame.size.width;
//		int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//		
//		if (page < [looksViews count])
//		{
//			LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
//			[self resetGroups:thumbView.groupIndex];
//			[self rendererThumbnail:thumbView];
//		}
//		
//		if (page+1 < [looksViews count])
//		{
//			LookThumbnailView *thumbView = [looksViews objectAtIndex:page+1];
//			[self rendererThumbnail:thumbView];
//		}
//	}
//}

- (void) layoutAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation{
	
#if 0
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return;
	}
#endif
	[self layoutUIs:toInterfaceOrientation];
    
    float f_width;
	float s_height;
	float f_looksScrollViewLeft;
	
	float f_looksScrollViewWidth;
	float f_looksScrollViewHeight;
	float f_looksScrollViewTop;
	float f_looksScrollOffset;
    float lookOffset;
    float offset;
    
	CGPoint currentScrollPoint = looksScrollView.contentOffset;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        if (IS_IPAD)
        {
            if (mScrollViewHackFirstTime)
            {
                currentScrollPoint.x = FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET;
                [looksScrollView setContentOffset:currentScrollPoint animated:NO];
            }
            
            f_looksScrollOffset = 20;
            f_width = 1024;
            s_height = 1004-41-44;
            f_looksScrollViewLeft = (1024 - FRAME_CROP_SIZE_WIDTH)/2-(f_looksScrollOffset/2);
            
            f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH+f_looksScrollOffset;
            f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT;
            
            f_looksScrollViewTop = 80+(f_looksScrollOffset/2);
            
            self.looksScrollView.frame = CGRectMake(f_looksScrollViewLeft, f_looksScrollViewTop, f_looksScrollViewWidth, f_looksScrollViewHeight);
            scrollEnhancer.frame = CGRectMake(0, f_looksScrollViewTop, f_width, f_looksScrollViewHeight);
            lookOffset = 0.0;
            offset = FRAME_CROP_SIZE_WIDTH;
            for(int i = 0; i < [looksDic_ count]; i++)
            {
                NSArray *objs = [looksDic_ objectAtIndex:i];
                for(int i = 0; i < [objs count]; i++)
                {
                    LookThumbnailView *thumbView = [objs objectAtIndex:i];
                    //bret fix for portrait to landscape
                    thumbView.frame = CGRectMake(lookOffset, 0, FRAME_CROP_SIZE_WIDTH, FRAME_CROP_SIZE_HEIGHT);
                    offset = FRAME_CROP_SIZE_WIDTH;
                    lookOffset += offset;
                    lookOffset += f_looksScrollOffset;
                }
            }
        }else
        {
            //iphone landscape
            if (mScrollViewHackFirstTime)
            {
                currentScrollPoint.x = FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
                [looksScrollView setContentOffset:currentScrollPoint animated:NO];
            }
            
            if (IS_IPHONE_5)
            {
                f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
                f_width = 568;
                s_height = 320-41-44;
                f_looksScrollViewLeft = (568 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2-(f_looksScrollOffset/2);
                
                f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE+f_looksScrollOffset;
                f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE;
                
                f_looksScrollViewTop = 41+f_looksScrollOffset;
            }else
            {
                f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
                f_width = 480;
                s_height = 320-41-44;
                f_looksScrollViewLeft = (480 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2-(f_looksScrollOffset/2);
                
                f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE+f_looksScrollOffset;
                f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE;
                
                f_looksScrollViewTop = 41+f_looksScrollOffset;
            }
            self.looksScrollView.frame = CGRectMake(f_looksScrollViewLeft, f_looksScrollViewTop, f_looksScrollViewWidth, f_looksScrollViewHeight);
            scrollEnhancer.frame = CGRectMake(0, f_looksScrollViewTop, f_width, f_looksScrollViewHeight);
            lookOffset = 0.0;
            offset = FRAME_CROP_SIZE_WIDTH_IPHONE;
            for(int i = 0; i < [looksDic_ count]; i++)
            {
                NSArray *objs = [looksDic_ objectAtIndex:i];
                for(int i = 0; i < [objs count]; i++)
                {
                    LookThumbnailView *thumbView = [objs objectAtIndex:i];
                    //bret fix for portrait to landscape
                    thumbView.frame = CGRectMake(lookOffset, 0, FRAME_CROP_SIZE_WIDTH_IPHONE, FRAME_CROP_SIZE_HEIGHT_IPHONE);
                    offset = FRAME_CROP_SIZE_WIDTH_IPHONE;
                    lookOffset += offset;
                    lookOffset += f_looksScrollOffset;
                }
            }
        }
        looksScrollView.contentSize = CGSizeMake(lookOffset, 0);
        if (currentScrollPoint.y > 0.0 )
        {
            currentScrollPoint.x = currentScrollPoint.y;
            currentScrollPoint.y = 0;
        }
        [looksScrollView setContentOffset:currentScrollPoint animated:NO];
        CGFloat pageWidth;
        int page;
        pageWidth = looksScrollView.frame.size.width;
        page = floor((looksScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
		[self resetGroups:thumbView.groupIndex];
        //CGFloat pageWidth = looksScrollView.frame.size.width;
		//selectedGroupIndex_landscape = selectedGroupIndex_Portrait;
	}
	else
    {
        //portrait
        if (IS_IPAD)
        {
            if (mScrollViewHackFirstTime)
            {
                currentScrollPoint.y = FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET;
                [looksScrollView setContentOffset:currentScrollPoint animated:NO];
            }

            f_looksScrollOffset = 20;
            f_width = 768;
            //s_height = 1004-41-44;
            f_looksScrollViewLeft = (768 - FRAME_CROP_SIZE_WIDTH)/2;  //-(f_looksScrollOffset/2);
            
            f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH;
            f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT+f_looksScrollOffset;
            
            //f_looksScrollViewTop = 80+f_looksScrollOffset;
            //f_looksScrollViewTop = ((1024-44-80) - FRAME_CROP_SIZE_HEIGHT)/2-(f_looksScrollOffset/2);
            f_looksScrollViewTop = ((1024-44-80-FRAME_OPAQUE_HEIGHT)-(FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET))/2;
            self.looksScrollView.frame = CGRectMake(f_looksScrollViewLeft, f_looksScrollViewTop+80, f_looksScrollViewWidth, f_looksScrollViewHeight);
            scrollEnhancer.frame = CGRectMake(0, 80, f_width, 1024-44-80-FRAME_OPAQUE_HEIGHT ); //f_looksScrollViewHeight);
            lookOffset = 0.0;
            offset = FRAME_CROP_SIZE_HEIGHT;
            for(int i = 0; i < [looksDic_ count]; i++)
            {
                NSArray *objs = [looksDic_ objectAtIndex:i];
                for(int i = 0; i < [objs count]; i++)
                {
                    LookThumbnailView *thumbView = [objs objectAtIndex:i];
                    //bret fix for portrait to landscape
                    thumbView.frame = CGRectMake(0,lookOffset, FRAME_CROP_SIZE_WIDTH, FRAME_CROP_SIZE_HEIGHT);
                    //offset = FRAME_CROP_SIZE_HEIGHT;
                    lookOffset += offset;
                    lookOffset += f_looksScrollOffset;
                }
            }
        }else
        {
            //iphone portrait
            if (mScrollViewHackFirstTime)
            {
                currentScrollPoint.y = FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE;
                [looksScrollView setContentOffset:currentScrollPoint animated:NO];
            }
            if (IS_IPHONE_5)
            {
                f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
                f_width = 320;
                //s_height = 1004-41-44;
                f_looksScrollViewLeft = (320 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2;  //-(f_looksScrollOffset/2);
                
                f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE;
                f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE+f_looksScrollOffset;
            }else
            {
                f_looksScrollOffset = FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE;
                f_width = 320;
                //s_height = 1004-41-44;
                f_looksScrollViewLeft = (320 - FRAME_CROP_SIZE_WIDTH_IPHONE)/2;  //-(f_looksScrollOffset/2);
                
                f_looksScrollViewWidth = FRAME_CROP_SIZE_WIDTH_IPHONE;
                f_looksScrollViewHeight = FRAME_CROP_SIZE_HEIGHT_IPHONE+f_looksScrollOffset;
            }
            //f_looksScrollViewTop = 80+f_looksScrollOffset;
            //f_looksScrollViewTop = ((1024-44-80) - FRAME_CROP_SIZE_HEIGHT)/2-(f_looksScrollOffset/2);
            if (IS_IPHONE_5)
                f_looksScrollViewTop = ((568-44-41-FRAME_OPAQUE_HEIGHT_IPHONE)-(FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE))/2;
            else
                f_looksScrollViewTop = ((480-44-41-FRAME_OPAQUE_HEIGHT_IPHONE)-(FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE))/2;
            self.looksScrollView.frame = CGRectMake(f_looksScrollViewLeft, f_looksScrollViewTop+41, f_looksScrollViewWidth, f_looksScrollViewHeight);
            
            if (IS_IPHONE_5)
                scrollEnhancer.frame = CGRectMake(0, 41, f_width, 568-44-41-FRAME_OPAQUE_HEIGHT_IPHONE ); //f_looksScrollViewHeight);
            else
                scrollEnhancer.frame = CGRectMake(0, 41, f_width, 480-44-41-FRAME_OPAQUE_HEIGHT_IPHONE ); //f_looksScrollViewHeight);
            
            lookOffset = 0.0;
            offset = FRAME_CROP_SIZE_HEIGHT_IPHONE;
            for(int i = 0; i < [looksDic_ count]; i++)
            {
                NSArray *objs = [looksDic_ objectAtIndex:i];
                for(int i = 0; i < [objs count]; i++)
                {
                    LookThumbnailView *thumbView = [objs objectAtIndex:i];
                    //bret fix for portrait to landscape
                    thumbView.frame = CGRectMake(0,lookOffset, FRAME_CROP_SIZE_WIDTH_IPHONE, FRAME_CROP_SIZE_HEIGHT_IPHONE);
                    //offset = FRAME_CROP_SIZE_HEIGHT;
                    lookOffset += offset;
                    lookOffset += f_looksScrollOffset;
                }
            }
        }

        looksScrollView.contentSize = CGSizeMake(0,lookOffset);
        if (currentScrollPoint.x > 0.0 )
        {
            currentScrollPoint.y = currentScrollPoint.x;
            currentScrollPoint.x = 0;
        }
        [looksScrollView setContentOffset:currentScrollPoint animated:NO];
        CGFloat pageWidth;
        int page;
        pageWidth = looksScrollView.frame.size.height;
        page = floor((looksScrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
		LookThumbnailView *thumbView = [looksViews objectAtIndex:page];
		[self resetGroups:thumbView.groupIndex];
		//CGFloat pageWidth = looksScrollView.frame.size.width;
		//int page = floor((looksScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	}
    
    //bret button scroll
//#if 0
    if (IS_IPAD)
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH+FRAME_CROP_SIZE_WIDTH_OFFSET) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT+FRAME_CROP_SIZE_HEIGHT_OFFSET) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }else
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            bool leftScrollButtonState = YES;
            bool rightScrollButtonState = YES;
            if (looksScrollView.contentOffset.x > 0.0f)
            {
                leftScrollButtonState = NO;
                rightScrollButtonState = NO;
            }else
                rightScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.x + (FRAME_CROP_SIZE_WIDTH_IPHONE+FRAME_CROP_SIZE_WIDTH_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.width) )
            {
                rightScrollButtonState = YES;
            }
            if ( leftScrollButtonState != leftScrollButton.hidden )
            {
                if (leftScrollButton.hidden == YES)
                    [self leftScrollButtonAnimateToShow];
                else
                    [self leftScrollButtonAnimateToHide];
            }
            if ( rightScrollButtonState != rightScrollButton.hidden )
            {
                if (rightScrollButton.hidden == YES)
                    [self rightScrollButtonAnimateToShow];
                else
                    [self rightScrollButtonAnimateToHide];
            }
        }else
        {
            bool topScrollButtonState = YES;
            bool bottomScrollButtonState = YES;
            if (looksScrollView.contentOffset.y > 0.0f)
            {
                topScrollButtonState = NO;
                bottomScrollButtonState = NO;
            }else
                bottomScrollButtonState = NO;
            if ( (looksScrollView.contentOffset.y + (FRAME_CROP_SIZE_HEIGHT_IPHONE+FRAME_CROP_SIZE_HEIGHT_OFFSET_IPHONE) ) >= (looksScrollView.contentSize.height) )
            {
                bottomScrollButtonState = YES;
            }
            if ( topScrollButtonState != topScrollButton.hidden )
            {
                if (topScrollButton.hidden == YES)
                    [self topScrollButtonAnimateToShow];
                else
                    [self topScrollButtonAnimateToHide];
            }
            if ( bottomScrollButtonState != bottomScrollButton.hidden )
            {
                if (bottomScrollButton.hidden == YES)
                    [self bottomScrollButtonAnimateToShow];
                else
                    [self bottomScrollButtonAnimateToHide];
            }
        }
    }
    //end button scroll
//#endif
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self layoutAfterorientation:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReleaseRender" object:nil];

	[self releaseRender:nil];
	[headers release];
	[groupsBackgroundView release];
	[backgroundView_ release];
	[looksDic_ release];
	[products release];
	[groupsViews release];
	[looksViews release];
    
	[productIdentifier release];	
	[looksScrollView release];
	[requestDictionary release];

	[renderQueue release];	
	[renderCondition release];
	
	[super dealloc];
}

@end
