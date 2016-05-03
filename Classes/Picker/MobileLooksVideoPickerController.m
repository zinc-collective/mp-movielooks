#import "MobileLooksVideoPickerController.h"
#import "MobileLooksTrimPlayerController.h"

#import "MobileLooksPickerSource.h"
#import "MobileLooksPickerItem.h"

#import "VideoThumbnailOperation.h"

#import "DeviceDetect.h"
#import "PickerSizes.h"

@implementation MobileLooksVideoPickerController

@synthesize delegate = _delegate;
@synthesize mScrollView;

#if 0 //storyboard
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    return self;
}

- (id)init
{
	return [self initWithNibName:@"MobileLooksVideoPickerController" bundle:nil];
}
#endif

- (void)dealloc
{
	//[mScrollView removeFromSuperview];
	//[mScrollView release];
	
	if (mSource)
	{	
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MobileLooksPickerSourceItemsDidChangeNotification object:mSource];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MobileLooksPickerSourceItemsDeniedAccessNotification object:mSource];
	}
	[mSource release];
	[mURLs release];
    //[_mScrollView release];
    [super dealloc];
}

-(void)layoutIPhonePortrait
{
    if (IS_IPHONE_5)
        [[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_640x1092.png"] CGImage]];
    else
        [[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_640x916.png"] CGImage]];
    
    mLastScrollAuto = NO;
	if (mLastScrollIndex>mLastSourceCount)
		mLastScrollIndex = mLastSourceCount;

    int columns = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
    int scrollFrameHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_4;
    if (IS_IPHONE_5)
    {
        columns = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
        scrollFrameHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_5;
    }
    
    CGFloat tempOffsetY = (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)*(((mLastScrollIndex-1)/columns)+1)+(VPICKER_THUMB_HEIGHT_OFFSET_IPHONE*2)-scrollFrameHeight+VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_ADJUST_IPHONE;
	CGFloat tempEndOffsetY = (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)*(((mLastSourceCount-1)/columns)+1)+(VPICKER_THUMB_HEIGHT_OFFSET_IPHONE*2);
	if(tempOffsetY<0.0)
        tempOffsetY = 0.f;
	if(tempOffsetY>tempEndOffsetY)
        tempOffsetY = tempEndOffsetY;
    
	mScrollView.frame = CGRectMake(VPICKER_SCROLL_PORTRAIT_FRAME_X_IPHONE, VPICKER_SCROLL_PORTRAIT_FRAME_Y_IPHONE, VPICKER_SCROLL_PORTRAIT_FRAME_WIDTH_IPHONE, scrollFrameHeight); //**
	mScrollView.contentSize = CGSizeMake(VPICKER_SCROLL_PORTRAIT_FRAME_WIDTH_IPHONE,(VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)*(((mLastSourceCount-1)/VPICKER_THUMB_PORTRAIT_COLS_IPHONE)+1)+(VPICKER_THUMB_HEIGHT_OFFSET_IPHONE*2));
    if ( (tempOffsetY + scrollFrameHeight ) >= mScrollView.contentSize.height )
        tempOffsetY = tempOffsetY - ((tempOffsetY + scrollFrameHeight) - mScrollView.contentSize.height);
	//bret new
	if(tempOffsetY<0.0)
        tempOffsetY = 0.f;
    //
    mScrollView.contentOffset = CGPointMake(0,tempOffsetY);
	NSLog(@"ScrollView offset:%f",mScrollView.contentOffset.y);
	mLastScrollAuto = YES;
    
	NSArray* pickerItemArray = [mScrollView subviews];
	NSUInteger pickerItemIndex = 0;
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {
        UIView* item = [pickerItemArray objectAtIndex:i];
		if([item class]==[MobileLooksPickerItem class])
		{
			//128*5+16*6
			item.frame = CGRectMake((pickerItemIndex%VPICKER_THUMB_PORTRAIT_COLS_IPHONE)*(VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)+(VPICKER_THUMB_WIDTH_OFFSET_IPHONE*2),(pickerItemIndex/VPICKER_THUMB_PORTRAIT_COLS_IPHONE)*(VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE,VPICKER_THUMB_WIDTH_IPHONE,VPICKER_THUMB_HEIGHT_IPHONE);
			++pickerItemIndex;
		}
		else if([item class]==[UITextView class])
			item.frame = CGRectMake(VPICKER_TEXT_X_IPHONE/2, VPICKER_TEXT_Y_IPHONE, mScrollView.frame.size.width-20, 300);
    }
    
    bool topScrollButtonState; //= leftScrollButton.hidden;
    bool bottomScrollButtonState; //= rightScrollButton.hidden;
    topScrollButtonState = YES;
    bottomScrollButtonState = YES;
    if (mScrollView.contentSize.height > scrollFrameHeight)
    {
        if (mScrollView.contentOffset.y > 0.0f)
        {
            topScrollButtonState = NO;
            bottomScrollButtonState = NO;
        }else
            bottomScrollButtonState = NO;
        if ( (mScrollView.contentOffset.y + scrollFrameHeight ) >= mScrollView.contentSize.height )
        {
            bottomScrollButtonState = YES;
        }
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

-(void)layoutIPhoneLandscape
{
    if (IS_IPHONE_5)
        [[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_1136x596.png"] CGImage]];
    else
        [[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_960x596.png"] CGImage]];
    
    mLastScrollAuto = NO;
	if (mLastScrollIndex>mLastSourceCount)
		mLastScrollIndex = mLastSourceCount;
	
    int columns = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
    int scrollFrameWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_4;
    if (IS_IPHONE_5)
    {
        columns = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
        scrollFrameWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_5;
    }
	
    CGFloat tempOffsetX = (VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)*(((mLastScrollIndex-1)/columns)+1)+(VPICKER_THUMB_WIDTH_OFFSET_IPHONE*2)-scrollFrameWidth+VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT_ADJUST_IPHONE;
	CGFloat tempEndOffsetX = (VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)*(((mLastSourceCount-1)/columns)+1)+(VPICKER_THUMB_WIDTH_OFFSET_IPHONE*2);
	if(tempOffsetX<0.0)
        tempOffsetX = 0.f;
	if(tempOffsetX>tempEndOffsetX)
        tempOffsetX = tempEndOffsetX;
	
	mScrollView.frame = CGRectMake(VPICKER_SCROLL_LANDSCAPE_FRAME_X_IPHONE, VPICKER_SCROLL_LANDSCAPE_FRAME_Y_IPHONE, scrollFrameWidth,VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT_IPHONE);
	CGSize scrollcontentSize = CGSizeMake((VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE)+1)+(VPICKER_THUMB_WIDTH_OFFSET_IPHONE*2),VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT_IPHONE); //** 768-30
    mScrollView.contentSize = scrollcontentSize;
    if ( (tempOffsetX + scrollFrameWidth ) >= mScrollView.contentSize.width )
        tempOffsetX = tempOffsetX - ((tempOffsetX + scrollFrameWidth) - mScrollView.contentSize.width);
	//bret new
	if(tempOffsetX<0.0)
        tempOffsetX = 0.f;
    //
    mScrollView.contentOffset = CGPointMake(tempOffsetX,0);
	NSLog(@"ScrollView offset:%f",mScrollView.contentOffset.x);
    
	mLastScrollAuto = YES;
    
	NSArray* pickerItemArray = [mScrollView subviews];
	NSUInteger pickerItemIndex = 0;
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {
        UIView* item = [pickerItemArray objectAtIndex:i];
		if([item class]==[MobileLooksPickerItem class])
		{
			//128*7+16*8 = 1024
			CGRect thumbframe = CGRectMake((pickerItemIndex/VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE)*(VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)+VPICKER_THUMB_WIDTH_OFFSET_IPHONE,(pickerItemIndex%VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE)*(VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE,VPICKER_THUMB_WIDTH_IPHONE,VPICKER_THUMB_HEIGHT_IPHONE);
            item.frame = thumbframe;
			++pickerItemIndex;
		}
		else if([item class]==[UITextView class])
            item.frame = CGRectMake(VPICKER_TEXT_X_IPHONE, VPICKER_TEXT_Y_IPHONE, mScrollView.frame.size.width-20, 300);
    }
    
    //bret button scroll
    bool leftScrollButtonState; //= leftScrollButton.hidden;
    bool rightScrollButtonState; //= rightScrollButton.hidden;
    leftScrollButtonState = YES;
    rightScrollButtonState = YES;
    if (mScrollView.contentSize.width > scrollFrameWidth)
    {
        if (mScrollView.contentOffset.x > 0.0f)
        {
            leftScrollButtonState = NO;
            rightScrollButtonState = NO;
        }else
            rightScrollButtonState = NO;
        if ( (mScrollView.contentOffset.x + scrollFrameWidth ) >= mScrollView.contentSize.width )
        {
            rightScrollButtonState = YES;
        }
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
}

-(void)layoutIPadForPortrait
{
	[[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_768x980.png"] CGImage]];

    mLastScrollAuto = NO;
	if (mLastScrollIndex>mLastSourceCount) 
		mLastScrollIndex = mLastSourceCount;
		
    //CGFloat tempOffsetY = (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastScrollIndex-1)/VPICKER_THUMB_PORTRAIT_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2)-980+30;
    CGFloat tempOffsetY = (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastScrollIndex-1)/VPICKER_THUMB_PORTRAIT_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2)-VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT+VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_ADJUST;
	CGFloat tempEndOffsetY = (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_PORTRAIT_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2);
	if(tempOffsetY<0.0)
        tempOffsetY = 0.f;
	if(tempOffsetY>tempEndOffsetY)
        tempOffsetY = tempEndOffsetY;
		
	//mScrollView.frame = CGRectMake(48+22, 0, 768-48, 980); //**
	mScrollView.frame = CGRectMake(VPICKER_SCROLL_PORTRAIT_FRAME_X, VPICKER_SCROLL_PORTRAIT_FRAME_Y, VPICKER_SCROLL_PORTRAIT_FRAME_WIDTH, VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT); //**
	//mScrollView.contentSize = CGSizeMake(768-48,(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_PORTRAIT_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2));
	mScrollView.contentSize = CGSizeMake(VPICKER_SCROLL_PORTRAIT_FRAME_WIDTH,(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_PORTRAIT_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2));
    //bret check
    //if ( (tempOffsetY + 980 ) >= mScrollView.contentSize.height )
    //    tempOffsetY = tempOffsetY - ((tempOffsetY + 980) - mScrollView.contentSize.height);
    if ( (tempOffsetY + VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT ) >= mScrollView.contentSize.height )
        tempOffsetY = tempOffsetY - ((tempOffsetY + VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT) - mScrollView.contentSize.height);
	//bret new
	if(tempOffsetY<0.0)
        tempOffsetY = 0.f;
    //
    mScrollView.contentOffset = CGPointMake(0,tempOffsetY);
	NSLog(@"ScrollView offset:%f",mScrollView.contentOffset.y);
	mLastScrollAuto = YES;

	NSArray* pickerItemArray = [mScrollView subviews];
	NSUInteger pickerItemIndex = 0;
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {   
        UIView* item = [pickerItemArray objectAtIndex:i];
		if([item class]==[MobileLooksPickerItem class])
		{
			//128*5+16*6
			item.frame = CGRectMake((pickerItemIndex%VPICKER_THUMB_PORTRAIT_COLS)*(VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)+(VPICKER_THUMB_WIDTH_OFFSET*2),(pickerItemIndex/VPICKER_THUMB_PORTRAIT_COLS)*(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)+VPICKER_THUMB_HEIGHT_OFFSET,VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
			++pickerItemIndex;
		}
		else if([item class]==[UITextView class])
			item.frame = CGRectMake(VPICKER_TEXT_X, VPICKER_TEXT_Y, mScrollView.frame.size.width-40, 300);
    }	

    bool topScrollButtonState; //= leftScrollButton.hidden;
    bool bottomScrollButtonState; //= rightScrollButton.hidden;
    topScrollButtonState = YES;
    bottomScrollButtonState = YES;
    if (mScrollView.contentSize.height > VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT)
    {
        if (mScrollView.contentOffset.y > 0.0f)
        {
            topScrollButtonState = NO;
            bottomScrollButtonState = NO;
        }else
            bottomScrollButtonState = NO;
        if ( (mScrollView.contentOffset.y + VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT ) >= mScrollView.contentSize.height )
        {
            bottomScrollButtonState = YES;
        }
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

-(void)layoutIPadForLandscape
{
	[[self.view layer] setContents:(id)[[UIImage imageNamed:@"camera_roll_background_1024x724.png"] CGImage]];

    mLastScrollAuto = NO;
	if (mLastScrollIndex>mLastSourceCount)
		mLastScrollIndex = mLastSourceCount;
	
	//CGFloat tempOffsetX = (VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)*(((mLastScrollIndex-1)/VPICKER_THUMB_LANDSCAPE_ROWS)+1)+(VPICKER_THUMB_WIDTH_OFFSET*2)-1024+30;
	CGFloat tempOffsetX = (VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)*(((mLastScrollIndex-1)/VPICKER_THUMB_LANDSCAPE_ROWS)+1)+(VPICKER_THUMB_WIDTH_OFFSET*2)-VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH+VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT_ADJUST;
	CGFloat tempEndOffsetX = (VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_ROWS)+1)+(VPICKER_THUMB_WIDTH_OFFSET*2);
	if(tempOffsetX<0.0)
        tempOffsetX = 0.f;
	if(tempOffsetX>tempEndOffsetX)
        tempOffsetX = tempEndOffsetX;
	//bret new
	if(tempOffsetX<0.0)
        tempOffsetX = 0.f;
    //
	//mScrollView.frame = CGRectMake(0, 48, 1024,724-48);
	mScrollView.frame = CGRectMake(VPICKER_SCROLL_LANDSCAPE_FRAME_X, VPICKER_SCROLL_LANDSCAPE_FRAME_Y, VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH,VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT);
	//CGSize scrollcontentSize = CGSizeMake((VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_ROWS)+1)+(VPICKER_THUMB_WIDTH_OFFSET*2),724-48); //** 768-30
	CGSize scrollcontentSize = CGSizeMake((VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_ROWS)+1)+(VPICKER_THUMB_WIDTH_OFFSET*2),VPICKER_SCROLL_LANDSCAPE_FRAME_HEIGHT); //** 768-30
    mScrollView.contentSize = scrollcontentSize;
    //bret check
    //if ( (tempOffsetX + 1024 ) >= mScrollView.contentSize.width )
    //    tempOffsetX = tempOffsetX - ((tempOffsetX + 1024) - mScrollView.contentSize.width);
    if ( (tempOffsetX + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
        tempOffsetX = tempOffsetX - ((tempOffsetX + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH) - mScrollView.contentSize.width);
	mScrollView.contentOffset = CGPointMake(tempOffsetX,0);
	NSLog(@"ScrollView offset:%f",mScrollView.contentOffset.x);
    
	mLastScrollAuto = YES;
    
	NSArray* pickerItemArray = [mScrollView subviews];
	NSUInteger pickerItemIndex = 0;
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {
        UIView* item = [pickerItemArray objectAtIndex:i];
		if([item class]==[MobileLooksPickerItem class])
		{
			//128*7+16*8 = 1024
			//item.frame = CGRectMake((pickerItemIndex%VPICKER_THUMB_LANDSCAPE_COLS)*(VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)+VPICKER_THUMB_WIDTH_OFFSET,(pickerItemIndex/VPICKER_THUMB_LANDSCAPE_COLS)*(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)+VPICKER_THUMB_HEIGHT_OFFSET,VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
			CGRect thumbframe = CGRectMake((pickerItemIndex/VPICKER_THUMB_LANDSCAPE_ROWS)*(VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)+VPICKER_THUMB_WIDTH_OFFSET,(pickerItemIndex%VPICKER_THUMB_LANDSCAPE_ROWS)*(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)+VPICKER_THUMB_HEIGHT_OFFSET,VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
            item.frame = thumbframe;
			++pickerItemIndex;
		}
		else if([item class]==[UITextView class])
			item.frame = CGRectMake(VPICKER_TEXT_X, VPICKER_TEXT_Y, mScrollView.frame.size.width-40, 300);
    }
    
    //bret button scroll
#if 0
    leftScrollButton.hidden = YES;
    rightScrollButton.hidden = YES;
    if (mScrollView.contentSize.width > VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH)
    {
        if (mScrollView.contentOffset.x > 0.0f)
        {
            leftScrollButton.hidden = NO;
            rightScrollButton.hidden = NO;
        }else
            rightScrollButton.hidden = NO;
        if ( (mScrollView.contentOffset.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
        {
            rightScrollButton.hidden = YES;
        }
    }
#endif
    bool leftScrollButtonState; //= leftScrollButton.hidden;
    bool rightScrollButtonState; //= rightScrollButton.hidden;
    leftScrollButtonState = YES;
    rightScrollButtonState = YES;
    if (mScrollView.contentSize.width > VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH)
    {
        if (mScrollView.contentOffset.x > 0.0f)
        {
            leftScrollButtonState = NO;
            rightScrollButtonState = NO;
        }else
            rightScrollButtonState = NO;
        if ( (mScrollView.contentOffset.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
        {
            rightScrollButtonState = YES;
        }
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
    
}

#if 0 //vertical scroll
-(void)layoutIPadForLandscape
{
	mLastScrollAuto = NO;
	if (mLastScrollIndex>mLastSourceCount)
		mLastScrollIndex = mLastSourceCount;
	
	CGFloat tempOffsetY = (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastScrollIndex-1)/VPICKER_THUMB_LANDSCAPE_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2)-768+30;
	CGFloat tempEndOffsetY = (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2);
	if(tempOffsetY<0.0)
        tempOffsetY = 0.f;
	if(tempOffsetY>tempEndOffsetY)
        tempOffsetY = tempEndOffsetY;
	
	mScrollView.frame = CGRectMake(0, 0, 1024,768-30);
	mScrollView.contentSize = CGSizeMake(1024,(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)*(((mLastSourceCount-1)/VPICKER_THUMB_LANDSCAPE_COLS)+1)+(VPICKER_THUMB_HEIGHT_OFFSET*2));
	mScrollView.contentOffset = CGPointMake(0,tempOffsetY);
	NSLog(@"ScrollView offset:%f",mScrollView.contentOffset.y);

	mLastScrollAuto = YES;

	NSArray* pickerItemArray = [mScrollView subviews];
	NSUInteger pickerItemIndex = 0;
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {   
        UIView* item = [pickerItemArray objectAtIndex:i];
		if([item class]==[MobileLooksPickerItem class])
		{
			//128*7+16*8 = 1024
			item.frame = CGRectMake((pickerItemIndex%VPICKER_THUMB_LANDSCAPE_COLS)*(VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)+VPICKER_THUMB_WIDTH_OFFSET,(pickerItemIndex/VPICKER_THUMB_LANDSCAPE_COLS)*(VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)+VPICKER_THUMB_HEIGHT_OFFSET,VPICKER_THUMB_WIDTH,VPICKER_THUMB_HEIGHT);
			++pickerItemIndex;
		}
		else if([item class]==[UITextView class])
			item.frame = CGRectMake(20, 20, mScrollView.frame.size.width-40, 300);
    }	
}
#endif

- (void)initSource
{
	mLastSourceCount = 0;
	mSource = [MobileLooksPickerSource cameraRollSource];
	if (mSource)
	{	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceItemsDidChange:) name:MobileLooksPickerSourceItemsDidChangeNotification object:mSource];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceItemsDeniedAccess:) name:MobileLooksPickerSourceItemsDeniedAccessNotification object:mSource];
	}
}

-(void)clearScrollView
{
	NSArray* pickerItemArray = [mScrollView subviews];
	for(int i = 0; i<[pickerItemArray count]; ++i)
    {   
        MobileLooksPickerItem* item = [pickerItemArray objectAtIndex:i];
		[item removeFromSuperview];
	}
}

-(void)loadItem:(MobileLooksPickerItem*)item withAsset:(ALAsset*)asset
{
	UIImage* thumbnailImage = nil;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CGFloat imgWidth = CGImageGetWidth(asset.thumbnail);
		CGFloat imgHeight = CGImageGetHeight(asset.thumbnail);
		CGFloat imgAspect = imgWidth/imgHeight;
		
		if (imgWidth>imgHeight) {
			imgWidth = VPICKER_THUMB_WIDTH;
			imgHeight = VPICKER_THUMB_HEIGHT/imgAspect;
		}
		else {
			imgWidth = VPICKER_THUMB_WIDTH*imgAspect;
			imgHeight = VPICKER_THUMB_HEIGHT;
		}
		
		CGImageRef boardedImageRef = [VideoThumbnailOperation generateBoard:asset.thumbnail withSize:CGSizeMake(imgWidth, imgHeight)];
		thumbnailImage = [[UIImage alloc] initWithCGImage:boardedImageRef];
		CGImageRelease(boardedImageRef);
//		mThumbnailSize = CGSizeMake(imgWidth, imgHeight);
	}
	else
	{	
		thumbnailImage = [[UIImage alloc] initWithCGImage:asset.thumbnail];
		//mThumbnailSize = CGSizeMake(73, 73);
	}
	NSUInteger duartion = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
	[item loadFromCache:thumbnailImage withDurationString:[NSString stringWithFormat:@"%02d:%02d",duartion/60,duartion%60]];
	[thumbnailImage release];
	item.hasThumbnail = YES;
}

-(void)loadItemThread:(NSNumber*)decelerateSpeed
{
	NSAutoreleasePool* threadPool = [[NSAutoreleasePool alloc] init];
	@try{
        CGFloat rowHeight; // = 79;
        CGFloat screenDim = mScrollView.frame.size.width;
        NSInteger rowCount;  //= 6; //change
    if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        //NSInteger rowCount = 6;
        screenDim = mScrollView.frame.size.height;
    }
        
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        rowCount = VPICKER_THUMB_LANDSCAPE_ROWS;
		rowHeight = VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET;
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
			rowCount = VPICKER_THUMB_PORTRAIT_COLS;
            rowHeight = VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET;
        }
	}else //bret
    {
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            rowHeight = VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE;
            rowCount = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
            if (IS_IPHONE_5)
                rowCount = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
        }
        else
        {
            rowHeight = VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE;
            rowCount = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
            if (IS_IPHONE_5)
                rowCount = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
        }
    }
		
	CGFloat scrollDeta = [decelerateSpeed floatValue];
	NSInteger startRowIndex = floor(mScrollView.contentOffset.x/rowHeight);
	NSInteger endRowIndex = ceil((mScrollView.contentOffset.x+screenDim)/rowHeight);
    if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        startRowIndex = floor(mScrollView.contentOffset.y/rowHeight);
        endRowIndex = ceil((mScrollView.contentOffset.y+screenDim)/rowHeight);
    }
    NSArray* pickerItemArray = [mScrollView subviews];
	NSArray* assetsArray = [mSource assetsArray];
	
	if(scrollDeta>0)
		startRowIndex = endRowIndex>0?(endRowIndex-1):0;
	if(scrollDeta<0)
		endRowIndex = startRowIndex+1;

//	NSInteger assetCount = [assetsArray count];
	for (NSInteger itemIndex = startRowIndex*rowCount; itemIndex<endRowIndex*rowCount&&itemIndex<[assetsArray count]; ++itemIndex)
    {
		MobileLooksPickerItem* item = [pickerItemArray objectAtIndex:itemIndex];
		ALAsset* asset = [assetsArray objectAtIndex:itemIndex];
		if([item class]==[MobileLooksPickerItem class] && !item.hasThumbnail)
			[self loadItem:item withAsset:asset];
	}
	}
	@catch (NSException* exc) {
		NSLog(@"%@",[exc reason]);
	}
	[threadPool release];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate // called on finger up if user dragged. decelerate is true if it will continue moving afterwards
{
	if(decelerate)return;
	[self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithInt:0]];
}
  
// called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithInt:0]];
}
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//	mScrollView.userInteractionEnabled = NO;
	CGFloat rowHeight; // = 79;
	CGFloat screenDim = mScrollView.frame.size.width;
	CGFloat screenOffset = mScrollView.contentOffset.x;
	CGFloat screenDetaOffset = screenOffset-mLastScrollOffset;
    if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        screenDim = mScrollView.frame.size.height;
        screenOffset = mScrollView.contentOffset.y;
        screenDetaOffset = screenOffset-mLastScrollOffset;
    }
	mLastScrollOffset = screenOffset;
	
	NSInteger rowCount = 6;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		rowCount = VPICKER_THUMB_LANDSCAPE_ROWS;
		rowHeight = VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET;
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
			rowCount = VPICKER_THUMB_PORTRAIT_COLS;
            rowHeight = VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET;
        }
	}else //bret
    {
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            rowHeight = VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET;
			rowCount = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
            if (IS_IPHONE_5)
                rowCount = VPICKER_THUMB_PORTRAIT_COLS_IPHONE;
        }
        else
        {
            rowHeight = VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE;
			rowCount = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
            if (IS_IPHONE_5)
                rowCount = VPICKER_THUMB_LANDSCAPE_ROWS_IPHONE;
        }
    }

	NSInteger startRowIndex;
    if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        startRowIndex = floor(mScrollView.contentOffset.x/rowHeight);
	
        if(mLastScrollAuto)
            mLastScrollIndex = ceil((mScrollView.contentOffset.x+screenDim)/rowHeight)*rowCount;
        if(abs(screenDetaOffset)<10 && startRowIndex!=lastRowIndex)
        {
            lastRowIndex = startRowIndex;
            [self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithFloat:screenDetaOffset]];
        }
    }else
    {
        startRowIndex = floor(mScrollView.contentOffset.y/rowHeight);
        
        if(mLastScrollAuto)
            mLastScrollIndex = ceil((mScrollView.contentOffset.y+screenDim)/rowHeight)*rowCount;
        if(abs(screenDetaOffset)<10 && startRowIndex!=lastRowIndex)
        {
            lastRowIndex = startRowIndex;
            [self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithFloat:screenDetaOffset]];
        }
    }

    //bret button scroll
    if (IS_IPAD)
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            bool leftScrollButtonState; //= leftScrollButton.hidden;
            bool rightScrollButtonState; //= rightScrollButton.hidden;
            leftScrollButtonState = YES;
            rightScrollButtonState = YES;
            if (mScrollView.contentSize.width > VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH)
            {
                if (mScrollView.contentOffset.x > 0.0f)
                {
                    leftScrollButtonState = NO;
                    rightScrollButtonState = NO;
                }else
                    rightScrollButtonState = NO;
                if ( (mScrollView.contentOffset.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= (mScrollView.contentSize.width-16.0) )
                {
                    rightScrollButtonState = YES;
                }
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
            bool topScrollButtonState; //= leftScrollButton.hidden;
            bool bottomScrollButtonState; //= rightScrollButton.hidden;
            topScrollButtonState = YES;
            bottomScrollButtonState = YES;
            if (mScrollView.contentSize.height > VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT)
            {
                if (mScrollView.contentOffset.y > 0.0f)
                {
                    topScrollButtonState = NO;
                    bottomScrollButtonState = NO;
                }else
                    bottomScrollButtonState = NO;
                if ( (mScrollView.contentOffset.y +VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT ) >= (mScrollView.contentSize.height-12.0) )
                {
                    bottomScrollButtonState = YES;
                }
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
            int scrollWidth;
            scrollWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_4;
            if (IS_IPHONE_5)
                scrollWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_5;
            bool leftScrollButtonState; //= leftScrollButton.hidden;
            bool rightScrollButtonState; //= rightScrollButton.hidden;
            leftScrollButtonState = YES;
            rightScrollButtonState = YES;
            if (mScrollView.contentSize.width > scrollWidth)
            {
                if (mScrollView.contentOffset.x > 0.0f)
                {
                    leftScrollButtonState = NO;
                    rightScrollButtonState = NO;
                }else
                    rightScrollButtonState = NO;
                if ( (mScrollView.contentOffset.x + scrollWidth ) >= (mScrollView.contentSize.width-16.0) )
                {
                    rightScrollButtonState = YES;
                }
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
            int scrollHeight;
            scrollHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_4;
            if (IS_IPHONE_5)
                scrollHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_5;
            bool topScrollButtonState; //= leftScrollButton.hidden;
            bool bottomScrollButtonState; //= rightScrollButton.hidden;
            topScrollButtonState = YES;
            bottomScrollButtonState = YES;
            if (mScrollView.contentSize.height > scrollHeight)
            {
                if (mScrollView.contentOffset.y > 0.0f)
                {
                    topScrollButtonState = NO;
                    bottomScrollButtonState = NO;
                }else
                    bottomScrollButtonState = NO;
                if ( (mScrollView.contentOffset.y + scrollHeight ) >= (mScrollView.contentSize.height-12.0) )
                {
                    bottomScrollButtonState = YES;
                }
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
}

-(void)loadFirstScreen
{
//	mScrollView.userInteractionEnabled = NO;
	mLastScrollIndex = mLastSourceCount;
	CGFloat firstOffset = mScrollView.contentSize.width-mScrollView.frame.size.width;
    if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        firstOffset = mScrollView.contentSize.height-mScrollView.frame.size.height;
    
	if(firstOffset<0)
        firstOffset = 0;
    if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        [mScrollView setContentOffset:CGPointMake(firstOffset,0)];
    else
        [mScrollView setContentOffset:CGPointMake(0, firstOffset)];
    
    [self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithInt:0]];
}

-(void)sourceItemsDeniedAccess:(NSNotification*)notification
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:/*NSLocalizedString(@"DeniedAccessTitle",nil)*/nil
														message:NSLocalizedString(@"DeniedAccess",nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil)
											  otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
/*
	[self clearScrollView];
	
	UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mScrollView.frame.size.width, 300)];
	textView.text = NSLocalizedString(@"DeniedAccess",nil);
	CGFloat fontSize = 16.0;
	UIColor* fontColor = [UIColor blackColor];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		fontSize = 30.0;
		fontColor = [UIColor whiteColor];
	}
	textView.font = [UIFont boldSystemFontOfSize:fontSize];
	textView.textColor = fontColor;
	textView.backgroundColor = [UIColor clearColor];	
	[mScrollView addSubview:textView];
	[textView release];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{	
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
			[self layoutIPadForPortrait];
		else 
			[self layoutIPadForLandscape];
	}
	else
		[self layoutIPhone];
*/ 
}

- (void)sourceItemsDidChange:(NSNotification*)notification
{	
	[self clearScrollView];
	
	NSArray* assetsArray = [mSource assetsArray];
    
	PickerItemStyle pickerItemStyle = PickerItemStyleForIphone;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		pickerItemStyle = PickerItemStyleForIpad;
	}
    
    for(NSInteger index = 0; index<[assetsArray count]; ++index)
    {   
		ALAsset* asset = [assetsArray objectAtIndex:index];
		NSURL* assetURL = [[asset defaultRepresentation] url];
		CGRect pickerItemFrame = CGRectMake(0, 0, VPICKER_THUMB_WIDTH_IPHONE, VPICKER_THUMB_HEIGHT_IPHONE);
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			pickerItemFrame = CGRectMake(0, 0, VPICKER_THUMB_WIDTH, VPICKER_THUMB_HEIGHT);
		MobileLooksPickerItem* item = [[MobileLooksPickerItem allocWithZone:NULL] initWithURL:assetURL withStyle:pickerItemStyle withFrame:pickerItemFrame];
		if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
			item.backgroundColor = [UIColor grayColor];
/*
		NSString* md5EncodePath = [Utilities md5Encode:[assetURL resourceSpecifier]];
		NSString  *jpgPath = [[Utilities cachedThumbnailPath] stringByAppendingPathComponent:md5EncodePath];
		NSFileManager *manager = [NSFileManager defaultManager];
		if([manager fileExistsAtPath:jpgPath])
		{
			NSDictionary* attributesDictionary = [manager attributesOfItemAtPath:jpgPath error:nil];
			NSDate *cd = [attributesDictionary objectForKey:NSFileCreationDate];
			NSDate *md = [attributesDictionary objectForKey:NSFileModificationDate];
			NSUInteger videoSeconds = [md timeIntervalSinceDate:cd];
			UIImage* thumbnailImage = [[UIImage alloc] initWithContentsOfFile:jpgPath];
			item.hasThumbnail = YES;
			[item loadFromCache:thumbnailImage withDurationString:[NSString stringWithFormat:@"%02d:%02d",videoSeconds/60,videoSeconds%60]];
			[thumbnailImage release];
		}
		else
		{
			VideoThumbnailOperation* op = [item startOpertion];		
			op.resultDelegate = item;
			[requestQueue addOperation:op];
			[op release];			
		  
					
			UIImage* thumbnailImage = nil;
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{
				CGFloat imgWidth = CGImageGetWidth(asset.thumbnail);
				CGFloat imgHeight = CGImageGetHeight(asset.thumbnail);
				CGFloat imgAspect = imgWidth/imgHeight;
				
				if (imgWidth>imgHeight) {
					imgWidth = 128;
					imgHeight = 128/imgAspect;
				}
				else {
					imgWidth = 128*imgAspect;
					imgHeight = 128;
				}
				
				CGImageRef boardedImageRef = [VideoThumbnailOperation generateBoard:asset.thumbnail withSize:CGSizeMake(imgWidth, imgHeight)];
				thumbnailImage = [[UIImage alloc] initWithCGImage:boardedImageRef];
				CGImageRelease(boardedImageRef);
				//mThumbnailSize = CGSizeMake(imgWidth, imgHeight);
			}
			else
			{	
				thumbnailImage = [[UIImage alloc] initWithCGImage:asset.thumbnail];
				//mThumbnailSize = CGSizeMake(73, 73);
			}
			item.hasThumbnail = YES;
			NSUInteger duartion = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
			[item loadFromCache:thumbnailImage withDurationString:[NSString stringWithFormat:@"%02d:%02d",duartion/60,duartion%60]];
			[thumbnailImage release];
			 
		}
		*/
		item.delegate = self;		
        [mScrollView addSubview:item];
		[item release];
    }
	mLastSourceCount = [assetsArray count];
	mLastScrollIndex = mLastSourceCount;
	if(mLastSourceCount==0)
	{
		UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mScrollView.frame.size.width, 300)];
		textView.text = NSLocalizedString(@"NoVideo",nil);
		textView.editable = NO;
		textView.userInteractionEnabled = NO;
		CGFloat fontSize = 16.0;
		UIColor* fontColor = [UIColor whiteColor];
        fontColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			fontSize = 28.0;
			fontColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
		}
		textView.font = [UIFont boldSystemFontOfSize:fontSize];
		textView.textColor = fontColor;
		textView.backgroundColor = [UIColor clearColor];
		[mScrollView addSubview:textView];
		[textView release];
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{	
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
			[self layoutIPadForPortrait];
		else 
			[self layoutIPadForLandscape];
	}
	else
    {
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
            [self layoutIPhonePortrait];
        else
            [self layoutIPhoneLandscape];
    }
    
	[self loadFirstScreen];
}

- (BOOL)shouldAutorotate
{
	return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#if 0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || interfaceOrientation==UIInterfaceOrientationLandscapeRight;
}
#endif

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait
            || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self layoutIPadForPortrait];
        }
        else
        {
            [self layoutIPadForLandscape];
            
        }
    }else
    {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait
            || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self layoutIPhonePortrait];
        }
        else
        {
            [self layoutIPhoneLandscape];
            
        }
    }
    
    [self performSelectorInBackground:@selector(loadItemThread:) withObject:[NSNumber numberWithInt:0]];
}

-(void)homeAction:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BackToHome" object:nil]; 
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
}

- (void)leftScrollButtonAction:(id)sender
{
    //NSInteger rowCount;
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = mScrollView.contentOffset;
    if (IS_IPAD)
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            //rowCount = VPICKER_THUMB_PORTRAIT_COLS;
            rowHeight = VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET;
            currentScrollPos = mScrollView.contentOffset.x;
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
            //mScrollView.contentOffset = currentScrollPoint;
            [mScrollView setContentOffset:currentScrollPoint animated:YES];
        }
    }else
    {
        //rowCount = VPICKER_THUMB_PORTRAIT_COLS;
        rowHeight = VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE;
        currentScrollPos = mScrollView.contentOffset.x;
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
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
        
    }
}
#if 0
- (void)rightScrollButtonAction:(id)sender
{
    //NSInteger rowCount;
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = mScrollView.contentOffset;

    if (IS_IPAD)
    {
        if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
        {
            //rowCount = VPICKER_THUMB_PORTRAIT_COLS;
            rowHeight = VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET;
            currentScrollPos = mScrollView.contentOffset.x;
            if ( (mScrollView.contentOffset.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
                return;
            startRowBase = currentScrollPos/rowHeight;
            startRowBase++;
            currentScrollPos = startRowBase*rowHeight;
            currentScrollPoint.x = currentScrollPos;
            if ( (currentScrollPoint.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
                return;
            //mScrollView.contentOffset = currentScrollPoint;
            [mScrollView setContentOffset:currentScrollPoint animated:YES];
        }
    }else
    {
        int scrollWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_4;
        if (IS_IPHONE_5)
            scrollWidth = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_5;
        //rowCount = VPICKER_THUMB_PORTRAIT_COLS;
        rowHeight = VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE;
        currentScrollPos = mScrollView.contentOffset.x;
        if ( (mScrollView.contentOffset.x + scrollWidth ) >= mScrollView.contentSize.width )
            return;
        startRowBase = currentScrollPos/rowHeight;
        startRowBase++;
        currentScrollPos = startRowBase*rowHeight;
        currentScrollPoint.x = currentScrollPos;
        if ( (currentScrollPoint.x + scrollWidth ) >= mScrollView.contentSize.width )
            return;
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
    }
    
}
#endif
- (void)rightScrollButtonAction:(id)sender
{
    //NSInteger rowCount;
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = mScrollView.contentOffset;
    
    if (IS_IPAD)
    {
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET;
        currentScrollPos = mScrollView.contentOffset.x;
        if ( (mScrollView.contentOffset.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
            return;
        startRowBase = currentScrollPos/rowHeight;
        //startRowBase++;
        //currentScrollPos = startRowBase*rowHeight;
        NSInteger bottomScreen = (startRowBase * rowHeight)+ (rowHeight * VPICKER_THUMB_LANDSCAPE_COLS);
        NSInteger bottomScroll = currentScrollPos + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH;
        NSInteger scrollDifference = bottomScreen - bottomScroll;
        //NSInteger scrollFactor = currentScrollPos % scrollDifference;
        if (scrollDifference > 0)
            currentScrollPos += scrollDifference;
        else
            currentScrollPos += (rowHeight - ABS(scrollDifference));
        
        currentScrollPoint.x = currentScrollPos;
        if ( (currentScrollPoint.x + VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH ) >= mScrollView.contentSize.width )
            return;
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        int scrollHeight = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_4;
        int scrollRows = VPICKER_THUMB_LANDSCAPE_COLS_IPHONE_4;
        if (IS_IPHONE_5)
        {
            scrollHeight = VPICKER_SCROLL_LANDSCAPE_FRAME_WIDTH_IPHONE_5;
            scrollRows = VPICKER_THUMB_LANDSCAPE_COLS_IPHONE_5;
        }
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE;
        currentScrollPos = mScrollView.contentOffset.x;
        if ( (mScrollView.contentOffset.x + scrollHeight ) >= mScrollView.contentSize.width )
            return;
        startRowBase = currentScrollPos/rowHeight;
        //startRowBase++;
        //currentScrollPos = startRowBase*rowHeight;
        NSInteger bottomScreen = (startRowBase * rowHeight)+ (rowHeight * scrollRows);
        NSInteger bottomScroll = currentScrollPos + scrollHeight;
        NSInteger scrollDifference = bottomScreen - bottomScroll;
        if (scrollDifference > 0)
            currentScrollPos += scrollDifference;
        else
            currentScrollPos += (rowHeight - ABS(scrollDifference));
        
        currentScrollPoint.x = currentScrollPos;
        if ( (currentScrollPoint.x + scrollHeight ) >= mScrollView.contentSize.width )
            return;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
        
    }
}

- (void)topScrollButtonAction:(id)sender
{
    //NSInteger rowCount;
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = mScrollView.contentOffset;
    if (IS_IPAD)
    {
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET;
        currentScrollPos = mScrollView.contentOffset.y;
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
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE;
        currentScrollPos = mScrollView.contentOffset.y;
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
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
    }
    
}
- (void)bottomScrollButtonAction:(id)sender
{
    //NSInteger rowCount;
    NSInteger rowHeight;
    NSInteger startRowBase;
    NSInteger currentScrollPos;
    CGPoint currentScrollPoint = mScrollView.contentOffset;

    if (IS_IPAD)
    {
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET;
        currentScrollPos = mScrollView.contentOffset.y;
        if ( (mScrollView.contentOffset.y + 980 ) >= mScrollView.contentSize.height )
            return;
        startRowBase = currentScrollPos/rowHeight;
        //startRowBase++;
        //currentScrollPos = startRowBase*rowHeight;
        NSInteger bottomScreen = (startRowBase * rowHeight)+ (rowHeight * VPICKER_THUMB_PORTRAIT_ROWS);
        NSInteger bottomScroll = currentScrollPos + VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT;
        NSInteger scrollDifference = bottomScreen - bottomScroll;
        //NSInteger scrollFactor = currentScrollPos % scrollDifference;
        if (scrollDifference > 0)
            currentScrollPos += scrollDifference;
        else
            currentScrollPos += (rowHeight - ABS(scrollDifference));
        
        currentScrollPoint.y = currentScrollPos;
        if ( (currentScrollPoint.y + VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT ) >= mScrollView.contentSize.height )
            return;
        //mScrollView.contentOffset = currentScrollPoint;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
    }else
    {
        int scrollHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_4;
        int scrollRows = VPICKER_THUMB_PORTRAIT_ROWS_IPHONE_4;
        if (IS_IPHONE_5)
        {
            scrollHeight = VPICKER_SCROLL_PORTRAIT_FRAME_HEIGHT_IPHONE_5;
            scrollRows = VPICKER_THUMB_PORTRAIT_ROWS_IPHONE_5;
        }
        //rowCount = VPICKER_THUMB_PORTRAIT_ROWS;
        rowHeight = VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE;
        currentScrollPos = mScrollView.contentOffset.y;
        if ( (mScrollView.contentOffset.y + scrollHeight ) >= mScrollView.contentSize.height )
            return;
        startRowBase = currentScrollPos/rowHeight;
        //startRowBase++;
        //currentScrollPos = startRowBase*rowHeight;
        NSInteger bottomScreen = (startRowBase * rowHeight)+ (rowHeight * scrollRows);
        NSInteger bottomScroll = currentScrollPos + scrollHeight;
        NSInteger scrollDifference = bottomScreen - bottomScroll;
        if (scrollDifference > 0)
            currentScrollPos += scrollDifference;
        else
            currentScrollPos += (rowHeight - ABS(scrollDifference));
        
        currentScrollPoint.y = currentScrollPos;
        if ( (currentScrollPoint.y + scrollHeight ) >= mScrollView.contentSize.height )
            return;
        [mScrollView setContentOffset:currentScrollPoint animated:YES];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MobileLooksTrimPlayerController"])
    {
        //UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        //MobileLooksTrimPlayerController* trimPickerController = [[navigationController viewControllers] lastObject];
        MobileLooksTrimPlayerController* trimPickerController = (MobileLooksTrimPlayerController *)segue.destinationViewController;
        [trimPickerController setDelegate:self.delegate];
        int assetmode = [self.delegate selectedMovieAssetMode];
        NSURL *url = [self.delegate selectedMovieURL];
		[trimPickerController setUrl:url withAssetMode:assetmode];
        //nextController.title = [dataDict objectForKey: kNestedDataKey_title];
    }
}

- (void)selectItem:(NSURL *)URL
{
    NSLog(@"Select %@",[URL standardizedURL]);
	//[self.delegate selectMovie:self withUrl:URL];
	//storyboard
    if  ( [self.delegate selectMovie:self withUrl:URL] )
    {
        [self performSegueWithIdentifier:@"MobileLooksTrimPlayerController" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    leftScrollButton.hidden = YES;
    leftScrollOpaque.hidden = YES;
    rightScrollButton.hidden = YES;
    rightScrollOpaque.hidden = YES;
    topScrollButton.hidden = YES;
    topScrollOpaque.hidden = YES;
    bottomScrollButton.hidden = YES;
    bottomScrollOpaque.hidden = YES;

	if(mFirstTime)
	{
		mFirstTime = NO;
		return;
	}
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{	
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
			[self layoutIPadForPortrait];
		else 
			[self layoutIPadForLandscape];
	}
	else
    {
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
            [self layoutIPhonePortrait];
        else
            [self layoutIPhoneLandscape];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO; //storyboard bug????
    //self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
//#if 0 //storyboard
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(homeAction:)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
	//self.view.backgroundColor = [UIColor blackColor];
	//self.title = NSLocalizedString(@"Camera Roll", nil);
//#endif

#if 0 //storyboard
	mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	mLastScrollOffset = 0;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		mScrollView.backgroundColor = [UIColor blackColor];
	else
		mScrollView.backgroundColor = [UIColor whiteColor];
	mScrollView.delegate = self;
	[self.view addSubview:mScrollView];
#endif
	
    float leftposx = (((VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2)-33)/2; //33x51
    float leftposy = ((320-44)-51)/2;
    float rightposx = 480-leftposx-33;
    float rightposy = ((320-44)-51)/2;
    float topposx = (320-51)/2;
    float topposy = (((VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2)-33)/2;
    float bottomposx = (320-51)/2;
    float bottomposy = (480-44)-topposy-33;

	//CGRect leftScrollButtonFrame = CGRectMake(16/2, 242/2, 71/2, 99/2);
	//CGRect rightScrollButtonFrame = CGRectMake(873/2, 242/2, 71/2, 99/2);
	//CGRect topScrollButtonFrame = CGRectMake(268/2, 20/2, 99/2, 71/2);
	//CGRect bottomScrollButtonFrame = CGRectMake(268/2, (792-7)/2, 99/2, 71/2);
    CGRect leftScrollButtonFrame = CGRectMake(leftposx, leftposy, 33, 51); // 86x119
    CGRect rightScrollButtonFrame = CGRectMake(rightposx, rightposy, 33, 51); //
    CGRect topScrollButtonFrame = CGRectMake(topposx, topposy, 51, 33); //119x86
    CGRect bottomScrollButtonFrame = CGRectMake(bottomposx,bottomposy, 51, 33);
    
    if (IS_IPHONE_5)
    {
        //leftScrollButtonFrame = CGRectMake(16/2, 242/2, 71/2, 99/2);
        //rightScrollButtonFrame = CGRectMake(1048/2, 242/2, 71/2, 99/2);
        //topScrollButtonFrame = CGRectMake(268/2, 20/2, 99/2, 71/2);
        //bottomScrollButtonFrame = CGRectMake(268/2, (1053-7-84)/2, 99/2, 71/2);
        leftposx = (((VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2)-33)/2; //33x51
        leftposy = ((320-44)-51)/2;
        rightposx = 568-leftposx-33;
        rightposy = ((320-44)-51)/2;
        topposx = (320-51)/2;
        topposy = (((VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2)-33)/2;
        bottomposx = (320-51)/2;
        bottomposy = (568-44)-topposy-33;
        
        leftScrollButtonFrame = CGRectMake(leftposx, leftposy, 33, 51); // 86x119
        rightScrollButtonFrame = CGRectMake(rightposx, rightposy, 33, 51); //
        topScrollButtonFrame = CGRectMake(topposx, topposy, 51, 33); //119x86
        bottomScrollButtonFrame = CGRectMake(bottomposx,bottomposy, 51, 33);
    }
    
	CGRect leftScrollOpaqueFrame = CGRectMake(0, 0, (VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2,320-44);
	CGRect rightScrollOpaqueFrame = CGRectMake(480-(VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2, 0, VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE, 320-44);
	CGRect topScrollOpaqueFrame = CGRectMake(0, 0, 320, (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2);
	CGRect bottomScrollOpaqueFrame = CGRectMake(0, 480-44-(VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2, 320, (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2);
    if (IS_IPHONE_5)
    {
        leftScrollOpaqueFrame = CGRectMake(0, 0, (VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2,320-44);
        rightScrollOpaqueFrame = CGRectMake(568-(VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2, 0, (VPICKER_THUMB_WIDTH_IPHONE+VPICKER_THUMB_WIDTH_OFFSET_IPHONE)/2, 320-44);
        topScrollOpaqueFrame = CGRectMake(0, 0, 320, (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2);
        bottomScrollOpaqueFrame = CGRectMake(0, 568-44-(VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2, 320, (VPICKER_THUMB_HEIGHT_IPHONE+VPICKER_THUMB_HEIGHT_OFFSET_IPHONE)/2);
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
		
        float leftposx = (((VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)/2)-66)/2;
        float leftposy = ((768-44)-102)/2;
        float rightposx = 1024-leftposx-66;
        float rightposy = ((768-44)-102)/2;
        float topposx = (768-102)/2;
        float topposy = (((VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)/2)-66)/2;
        float bottomposx = (768-102)/2;
        float bottomposy = (1024-44)-topposy-66;
        
        leftScrollButtonFrame = CGRectMake(leftposx, leftposy, 66, 102); // 86x119
        rightScrollButtonFrame = CGRectMake(rightposx, rightposy, 66, 102); //
        topScrollButtonFrame = CGRectMake(topposx, topposy, 102, 66); //119x86
        bottomScrollButtonFrame = CGRectMake(bottomposx,bottomposy, 102, 66);
#if 0
        leftScrollButtonFrame = CGRectMake(18, 274, 66, 102); // 86x119
        rightScrollButtonFrame = CGRectMake(920, 274, 66, 102); //
        topScrollButtonFrame = CGRectMake(325, 14, 102, 66); //119x86
        bottomScrollButtonFrame = CGRectMake(325, 880, 102, 66);
#endif
        leftScrollButtonFilename = @"camera_roll_button_left_ipad.png";
        leftScrollButtonFilenameSel = @"camera_roll_button_left_ipad.png";
        rightScrollButtonFilename = @"camera_roll_button_right_ipad.png";
        rightScrollButtonFilenameSel = @"camera_roll_button_right_ipad.png";
        topScrollButtonFilename = @"camera_roll_button_top_ipad.png";
        topScrollButtonFilenameSel = @"camera_roll_button_top_ipad.png";
        bottomScrollButtonFilename = @"camera_roll_button_bottom_ipad.png";
        bottomScrollButtonFilenameSel = @"camera_roll_button_bottom_ipad.png";

        leftScrollOpaqueFrame = CGRectMake(0, 0, (VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)/2,980);
        rightScrollOpaqueFrame = CGRectMake(1024-((VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)/2), 0,(VPICKER_THUMB_WIDTH+VPICKER_THUMB_WIDTH_OFFSET)/2, 980);
        topScrollOpaqueFrame = CGRectMake(0, 0, 768, (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)/2);
        bottomScrollOpaqueFrame = CGRectMake(0, 980-((VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)/2), 768, (VPICKER_THUMB_HEIGHT+VPICKER_THUMB_HEIGHT_OFFSET)/2);
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
	leftScrollOpaque.alpha = .25;
    [self.view addSubview:leftScrollOpaque];

    rightScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	rightScrollOpaque.frame = rightScrollOpaqueFrame;
	rightScrollOpaque.hidden = YES;
	[rightScrollOpaque setEnabled:NO];
	rightScrollOpaque.backgroundColor = [UIColor blackColor];
	rightScrollOpaque.alpha = .25;
    [self.view addSubview:rightScrollOpaque];
    
    topScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	topScrollOpaque.frame = topScrollOpaqueFrame;
	topScrollOpaque.hidden = YES;
	[topScrollOpaque setEnabled:NO];
	topScrollOpaque.backgroundColor = [UIColor blackColor];
	topScrollOpaque.alpha = .25;
    [self.view addSubview:topScrollOpaque];
    
    bottomScrollOpaque = [UIButton buttonWithType:UIButtonTypeCustom];
	bottomScrollOpaque.frame = bottomScrollOpaqueFrame;
	bottomScrollOpaque.hidden = YES;
	[bottomScrollOpaque setEnabled:NO];
	bottomScrollOpaque.backgroundColor = [UIColor blackColor];
	bottomScrollOpaque.alpha = .25;
    [self.view addSubview:bottomScrollOpaque];

    mLastScrollOffset = 0;
	mScrollView.delegate = self;

	[self initSource];
	lastRowIndex = 0;
	mLastScrollAuto = YES;
	mFirstTime = YES;
		
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{	
	[super didReceiveMemoryWarning];
}

@end

NSString* const AVPlayerDemoPickerViewControllerDidPickURLNotification = @"AVPlayerDemoPickerViewControllerDidPickURLNotification";