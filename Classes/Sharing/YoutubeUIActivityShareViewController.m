//
//  ShareViewController.h
//  MobileLooks
//
//  Created by Joseph Snow / Snow Software Services on 8/1/2013.
//  Copyright 2013 Red Giant. All rights reserved.
//

#import "YoutubeUIActivityShareViewController.h"
#import "WebSiteCtrlor.h"

#import "DeviceDetect.h"

@implementation YoutubeUIActivityShareViewController
@synthesize useYouTube;
@synthesize mThumbImage;
@synthesize processedMoviePath;

#define YOUTUBE_SETTINGS_TAG	21
#define YOUTUBE_LOGOUT_TAG		22
#define YOUTUBE_UPLOAD_TAG		23

#define SETTINGS_USERNAME_TAG   31
#define SETTINGS_PRIVACY_TAG	32
#define SETTINGS_CANCEL_TAG		33

#define OFFSETFORKEYBOARD 76
//#define OFFSETFORKEYBOARD 24

- (void)layoutForLandscape
{
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
		float screenwidth;
        //iphone
        if (IS_IPHONE_5)
        {
            contentView.frame = CGRectMake(0, 0, 568, 320);
            screenwidth = 568;
        }
        else
        {
            contentView.frame = CGRectMake(0, 0, 480, 320);
            screenwidth = 480;
        }
        
        float picwidth = 100; //120;
        float picheight = 100; //120;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        float scale = .5; //.5
        float heightoffset = 12;
        iconView.frame = CGRectMake(48*scale,6*scale+44, 50, 50);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-(48*scale),6*scale+44, picwidth_a, picheight_a);
        
        picheight = 80;
        titleLabel.frame = CGRectMake((0+48)*scale, picheight+heightoffset+44, 160, 20-4); //20 == font height
        if (IS_IPHONE_5)
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8+heightoffset+44, 480-(48*scale)-(48*scale), 20+10-6); //20 == font height
        else
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8+heightoffset+44, 480-(48*scale)-(48*scale), 20+10-6); //20 == font height
        
        descLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44, 320-(48*scale)-(48*scale), 20+10-6);
        descInput.frame = CGRectMake(0+24, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22, 480-(48*scale)-(48*scale), 20+10-6); //20 == font height
        
        privacyLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22+22+22-12, 160, 20+4-4); //20 == font height
        //if (IS_IPHONE_5)
        //{
        youtubePrivacyControl.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22+22+22+22+6-12-2, 480-(48*scale)-(48*scale), 20+10-6); //20 == font height
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+((80+24+24+48+24+24+12)*scale)+heightoffset+24+44+22+22+12-12-12-8, userLabelSize.width, userLabelSize.height); //12 == font height
    }else
    {
        //ipad
		float screenwidth;
        //contentView.frame = CGRectMake(0, 0, 768, 1024);
        //screenwidth = 768;
        contentView.frame = CGRectMake(0, 0, 540, 620);
        screenwidth = 540;
        
        float picwidth = 160;
        float picheight = 160;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        iconView.frame = CGRectMake(48,44+24, 99, 99);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-24,44+24, picwidth_a, picheight_a);
        
        //for portrait
        picheight = picheight + 50+24;
        titleLabel.frame = CGRectMake(0+24, picheight, 160, 20); //20 == font height
        titleInput.frame = CGRectMake(0+24, picheight+24, 480, 20+10); //20 == font height
        
        descLabel.frame = CGRectMake(0+24, picheight+24+24+12+12, 160, 20); //20 == font height
        descInput.frame = CGRectMake(0+24, picheight+24+24+12+12+24, 480, 20+10); //20 == font height
        
        privacyLabel.frame = CGRectMake(0+24, picheight+24+24+24+24+24+12+12, 160, 20+4); //20 == font height
        youtubePrivacyControl.frame = CGRectMake(0+24, picheight+24+24+24+24+24+12+24+12+8, 480, 20+10); //20 == font height
        
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+80+24+24+48+24+24+12+24+24, userLabelSize.width, userLabelSize.height); //12 == font height
    }
}
- (void)layoutForPortrait
{
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
		float screenwidth;
        float screenheight;
        //iphone
        if (IS_IPHONE_5)
        {
            contentView.frame = CGRectMake(0, 0, 320, 568);
            screenwidth = 320;
            screenheight = 568;
        }
        else
        {
            contentView.frame = CGRectMake(0, 0, 320, 568);
            screenwidth = 320;
            screenheight = 480;
        }
        
        float picwidth = 120; //120;
        float picheight = 120; //120;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        float scale = .5;
        float heightoffset = 24;
        iconView.frame = CGRectMake(48*scale,24*scale+44, 50, 50);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-(24*scale),24*scale+44, picwidth_a, picheight_a);
        
        titleLabel.frame = CGRectMake((0+48)*scale, picheight+heightoffset+44, 160, 20-4); //20 == font height
        //if (IS_IPHONE_5)
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8+heightoffset+44, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
        //else
        //    titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8, 480*.84, 20+10-6); //20 == font height
        
        descLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44, 320-(48*scale)-(48*scale), 20+10-6);
        descInput.frame = CGRectMake(0+24, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
        
        privacyLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22+22+22, 160, 20+4-4); //20 == font height
        //if (IS_IPHONE_5)
        //{
            youtubePrivacyControl.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset+44+22+22+22+22+6, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
        //}else
        //{
        //    youtubePrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480*.84, 20+10-6); //20 == font height
        //}
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+((80+24+24+48+24+24+12)*scale)+heightoffset+24+44+22+22+12, userLabelSize.width, userLabelSize.height); //12 == font height
    }else
    {
        //ipad
		float screenwidth;
        //contentView.frame = CGRectMake(0, 0, 768, 1024);
        //screenwidth = 768;
        contentView.frame = CGRectMake(0, 0, 540, 620);
        screenwidth = 540;
        
        float picwidth = 160;
        float picheight = 160;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        iconView.frame = CGRectMake(48,44+24, 99, 99);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-24,44+24, picwidth_a, picheight_a);
        
        //for portrait
        picheight = picheight + 50+24;
        titleLabel.frame = CGRectMake(0+24, picheight, 160, 20); //20 == font height
        titleInput.frame = CGRectMake(0+24, picheight+24, 480, 20+10); //20 == font height
        
        descLabel.frame = CGRectMake(0+24, picheight+24+24+12+12, 160, 20); //20 == font height
        descInput.frame = CGRectMake(0+24, picheight+24+24+12+12+24, 480, 20+10); //20 == font height

        privacyLabel.frame = CGRectMake(0+24, picheight+24+24+24+24+24+12+12, 160, 20+4); //20 == font height
        youtubePrivacyControl.frame = CGRectMake(0+24, picheight+24+24+24+24+24+12+24+12+8, 480, 20+10); //20 == font height
        
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+80+24+24+48+24+24+12+24+24, userLabelSize.width, userLabelSize.height); //12 == font height
        //btnLogout.frame = CGRectMake((screenwidth - 160)/2, picheight+80+48+24+12+48+24+24+12, 160, 40);
        
        //btnUpload.frame = CGRectMake(screenwidth-227-24, 1024-44-94+((94-71)/2), 227, 71);
        
        //progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
        //uploadingLabel.frame = CGRectMake((screenwidth - uploadingLabelSize.width)/2, picheight+80+24+24+48+24+24+12, uploadingLabelSize.width, uploadingLabelSize.height); //12 == font height
        //progressView.frame = CGRectMake((screenwidth - MPROGRESSVIEW_MAX_WIDTH)/2,picheight+80+48+24+12+48+24,MPROGRESSVIEW_MAX_WIDTH,MPROGRESSVIEW_MAX_WIDTH);
    }
}

- (void)shareButtonsAnimateToShow
{
    //buttons to show
    if (userLabel.hidden == YES)
    {
        [UIView transitionWithView:userLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    userLabel.hidden = NO;
    
    if (useYouTube)
    {
        if (youtubePrivacyControl.hidden == YES)
        {
            [UIView transitionWithView:youtubePrivacyControl
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        youtubePrivacyControl.hidden = NO;
    }else
    {
    }
    
    if (btnLogout.hidden == YES)
    {
        [UIView transitionWithView:btnLogout
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    btnLogout.hidden = NO;

    if (titleLabel.hidden == YES)
    {
        [UIView transitionWithView:titleLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    titleLabel.hidden = NO;

    if (titleInput.hidden == YES)
    {
        [UIView transitionWithView:titleLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    titleInput.hidden = NO;
    
    if (privacyLabel.hidden == YES)
    {
        [UIView transitionWithView:privacyLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    privacyLabel.hidden = NO;
    
    if (btnUpload.hidden == YES)
    {
        [UIView transitionWithView:btnUpload
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    btnUpload.hidden = NO;
    
    //buttons to hide
    if (progressView.hidden == NO)
    {
        [UIView transitionWithView:progressView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    progressView.hidden = YES;

    if (uploadingLabel.hidden == NO)
    {
        [UIView transitionWithView:uploadingLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    uploadingLabel.hidden = YES;
    
}

- (void)shareButtonsAnimateToHide
{
    //buttons to hide
    if (userLabel.hidden == NO)
    {
        [UIView transitionWithView:userLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    userLabel.hidden = YES;
    
    if (useYouTube)
    {
        if (youtubePrivacyControl.hidden == NO)
        {
            [UIView transitionWithView:youtubePrivacyControl
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        youtubePrivacyControl.hidden = YES;
    }else
    {
    }
    
    if (btnLogout.hidden == NO)
    {
        [UIView transitionWithView:btnLogout
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    btnLogout.hidden = YES;
    
    if (titleLabel.hidden == NO)
    {
        [UIView transitionWithView:titleLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    titleLabel.hidden = YES;
    
    if (titleInput.hidden == NO)
    {
        [UIView transitionWithView:titleLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    titleInput.hidden = YES;
    
    if (privacyLabel.hidden == NO)
    {
        [UIView transitionWithView:privacyLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    privacyLabel.hidden = YES;
    
    if (btnUpload.hidden == NO)
    {
        [UIView transitionWithView:btnUpload
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    btnUpload.hidden = YES;

    //buttons to SHOW
    if (progressView.hidden == YES)
    {
        [UIView transitionWithView:progressView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    progressView.hidden = NO;
    
    if (uploadingLabel.hidden == YES)
    {
        [UIView transitionWithView:uploadingLabel
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
    }
    uploadingLabel.hidden = NO;

}


-(NSArray*) getYoutubePrivacyItems
{
	return [NSArray arrayWithObjects: @"Public", @"Unlisted", @"Private", nil];
}


-(void)_updateYoutubeSettings
{
	//UISegmentedControl *privacyControl = (UISegmentedControl*)[youtubeSettingsView viewWithTag:SETTINGS_PRIVACY_TAG];
	//if (privacyControl)
    //{
		
		NSString *privacyValue = (_youtube != nil)? [_youtube getPrivacy]: @"Public";

		NSArray *privacyItems = [self getYoutubePrivacyItems];
		NSUInteger idx = [privacyItems indexOfObject:privacyValue];
		if (idx == NSNotFound) { idx = 0; }
		youtubePrivacyControl.selectedSegmentIndex = idx;
	//}
	
	//UILabel *userLabel = (UILabel *)[youtubeSettingsView viewWithTag:SETTINGS_USERNAME_TAG];
	//if (userLabel)
    //{
#if 0
    NSString *username = (_youtube != nil)? [_youtube getUsername]: nil;
		if (username == nil) { username = @""; }
		[userLabel setText:username];
	//}
#endif
    NSString *username;
    if (_youtube != nil)
    {
        username = [_youtube getUsername];
        
    }else
    {
        username = nil;
    }
    [userLabel setText:username];
    
    CGSize maxSize = CGSizeMake(300, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine;
    userLabelSize = [username boundingRectWithSize:maxSize options:options attributes:@{NSFontAttributeName: userLabel.font} context:nil].size;
    
}


-(NSString *)_getYoutubePrivacyFromUI:(NSString *)defaultValue
{
	NSString *retval = nil;
	
	NSArray *privacyItems = [self getYoutubePrivacyItems];
	//UISegmentedControl *privacyControl = (UISegmentedControl*)[youtubeSettingsView viewWithTag:SETTINGS_PRIVACY_TAG];
	if (youtubePrivacyControl.selectedSegmentIndex >= 0)
    {
		retval = [privacyItems objectAtIndex:youtubePrivacyControl.selectedSegmentIndex];
	}
	
	if (!retval) { retval = defaultValue; }
	return retval;
}

-(UINavigationController*) getNavigationController
{
	self.title = NSLocalizedString(@"Cancel", nil);
    return [self navigationController];
}

-(void)addShareSubview:(UIView *)view :(NSString*)title :(NSString*)imagepath :(NSInteger)tag :(NSInteger)yPos
{
}

-(void)addHorizontalSeparator:(UIView*)view :(NSInteger)yPos
{
	UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, view.bounds.size.width, 2)];
	separator.backgroundColor = viewBorderColor;
	[view addSubview:separator];
}

-(void)delayPresentProviders:(BOOL) resignin
{
    //bret new
//#if 0
    if (!resignin)
    {
        if (!useYouTube) //Facebook
        {
        }else
        {
            if (_youtube != nil)
            {
                return;
            }
        }
    }
    //
//#endif
    if (!useYouTube) //Facebook
    {
    } else //Youtube
    {
        if (_youtube == nil)
        {
            _youtube = [[YoutubeConnect alloc] init];
            _youtube.delegate_ = self;
        }
        
        NSString *currPrivacy = [self _getYoutubePrivacyFromUI:nil];
        if (currPrivacy)
        {
            [_youtube setPrivacy:currPrivacy];
        }
        
        [_youtube runSigninThenHandler:
         ^{
             if ([_youtube isSignedIn])
             {
                 if (useYouTube)
                 {
                     [self _updateYoutubeSettings];
                 }
                 
                 if(self.statusBarOrientation == UIInterfaceOrientationPortrait
                    || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
                 {
                     [self layoutForPortrait];
                 }
                 else
                 {
                     [self layoutForLandscape];
                 }
             } else
             {
                 [self backAction:nil];
             }
         }];
    }
    
    if (useYouTube)
    {
        [self _updateYoutubeSettings];
    }

    if(self.statusBarOrientation == UIInterfaceOrientationPortrait
	   || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    useYouTube = YES; //temp
    mAlertView = nil;
    isUploading = NO;
    iskeyboardUp = NO;
    isAlertViewShown = NO;
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"YouTube", nil);
    //if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    //{
    //    self.navigationItem.backBarButtonItem.title= @"Cancel";
    //}
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToDisactive) name:@"ResignActivePause" object:nil];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
	self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem* postButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post",nil) style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
	self.navigationItem.rightBarButtonItem = postButton;

	viewBorderColor = [UIColor clearColor];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	contentView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:contentView];
    
    mThumbImageView = [[UIImageView alloc] init];
    [contentView addSubview:mThumbImageView];
    mThumbImageView.backgroundColor = [UIColor clearColor];
    mThumbImageView.image = mThumbImage;
    
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	titleLabel.text = NSLocalizedString(@"Video Title", nil);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        titleLabel.font = [UIFont systemFontOfSize:20];
    }else
    {
        titleLabel.font = [UIFont systemFontOfSize:14];
    }
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor blackColor];
	//titleLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:titleLabel];
    
	NSString *defaultTitle = [Utilities selectedVideoTitle:nil];
	titleInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	titleInput.backgroundColor = [UIColor whiteColor];
    titleInput.textColor = [UIColor blackColor];
	titleInput.borderStyle = UITextBorderStyleRoundedRect;
	titleInput.clearButtonMode = UITextFieldViewModeWhileEditing;
	titleInput.returnKeyType = UIReturnKeyDone;
	titleInput.keyboardType = UIKeyboardTypeDefault;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        titleInput.font = [UIFont systemFontOfSize:18];
    }else
    {
        titleInput.font = [UIFont systemFontOfSize:14];
    }
	titleInput.delegate = self;
	titleInput.placeholder = NSLocalizedString(@"Untitled Video", nil);
	titleInput.text = defaultTitle;
	[contentView addSubview:titleInput];
    

	descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	descLabel.text = NSLocalizedString(@"Description", nil);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        descLabel.font = [UIFont systemFontOfSize:20];
    }else
    {
        descLabel.font = [UIFont systemFontOfSize:14];
    }
	descLabel.backgroundColor = [UIColor clearColor];
	descLabel.textColor = [UIColor blackColor];
	//titleLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:descLabel];
    
	descInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	descInput.backgroundColor = [UIColor whiteColor];
    descInput.textColor = [UIColor blackColor];
	descInput.borderStyle = UITextBorderStyleRoundedRect;
	descInput.clearButtonMode = UITextFieldViewModeWhileEditing;
	descInput.returnKeyType = UIReturnKeyDone;
	descInput.keyboardType = UIKeyboardTypeDefault;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        descInput.font = [UIFont systemFontOfSize:18];
    }else
    {
        descInput.font = [UIFont systemFontOfSize:14];
    }
	descInput.delegate = self;
	titleInput.placeholder = nil;
	//descInput.text = defaultTitle;
	[contentView addSubview:descInput];


#if 0
	uploadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	uploadingLabel.text = NSLocalizedString(@"Uploading...", nil);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        uploadingLabel.font = [UIFont systemFontOfSize:20];
    else
        uploadingLabel.font = [UIFont systemFontOfSize:14];
    
	uploadingLabel.backgroundColor = [UIColor clearColor];
	uploadingLabel.textColor = [UIColor blackColor];
    uploadingLabel.hidden = YES;
	//titleLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:uploadingLabel];
    uploadingLabelSize = [uploadingLabel.text sizeWithFont:uploadingLabel.font
                                  forWidth:300
                             lineBreakMode:NSLineBreakByTruncatingTail];
    
    progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
	[progressView getBoxView].backgroundColor = [UIColor clearColor];
	progressView.hidden = YES;
	progressView.delegate_ = self;
	[contentView addSubview:progressView];
	[progressView updateProgress:0.0];
#endif
    UIImage *iconImage;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (useYouTube)
            iconImage = [UIImage imageNamed:@"develop_youtube_button127x126.png"];
        else
            iconImage = [UIImage imageNamed:@"develop_facebook_button127x126.png"];
    }
    else
    {
        if (useYouTube)
            iconImage = [UIImage imageNamed:@"develop_youtube_button58x58_iphone.png"];
        else
            iconImage = [UIImage imageNamed:@"develop_facebook_button58x58_iphone.png"];
    }
    
	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
	iconView.image = iconImage;
	[contentView addSubview:iconView];
    
	userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	userLabel.tag = SETTINGS_USERNAME_TAG;
	userLabel.text = NSLocalizedString(@"", nil);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        userLabel.font = [UIFont systemFontOfSize:14];
    else
        userLabel.font = [UIFont systemFontOfSize:12];
    
	userLabel.backgroundColor = [UIColor clearColor];
	userLabel.textColor = [UIColor blackColor];
	//userLabel.shadowColor = [UIColor blackColor];
	userLabel.textAlignment = NSTextAlignmentRight;
	[contentView addSubview:userLabel];
    
    //UIButton *btnLogout; //sign out of facebook/youtube
    //UIButton *btnCancel;
#if 0
   	btnLogout = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//btnLogout.frame = CGRectMake(frameRect.size.width-btnWidth/2, logoutButtonHeight, btnWidth/2 , logoutButtonHeight);
	btnLogout.backgroundColor = [UIColor clearColor];
	btnLogout.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    btnLogout.tag = YOUTUBE_LOGOUT_TAG;
    
	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[btnLogout setTitle:NSLocalizedString(@"Sign Out", nil) forState:UIControlStateNormal];
	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[btnLogout addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:btnLogout];

    btnUpload = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//btnUpload.frame = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
	btnUpload.backgroundColor = [UIColor clearColor];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        btnUpload.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    else
        btnUpload.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    
    btnUpload.tag = YOUTUBE_UPLOAD_TAG;
	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[btnUpload setTitle:NSLocalizedString(@"Upload Video", nil) forState:UIControlStateNormal];
	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[btnUpload addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:btnUpload];
#endif
	privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	privacyLabel.text = NSLocalizedString(@"Privacy", nil);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        privacyLabel.font = [UIFont systemFontOfSize:20];
    else
        privacyLabel.font = [UIFont systemFontOfSize:14];
    
	privacyLabel.backgroundColor = [UIColor clearColor];
	privacyLabel.textColor = [UIColor blackColor];
	//titleLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:privacyLabel];
    
    UIFont *font;
    //UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        font = [UIFont boldSystemFontOfSize:16.0f];
    else
        font = [UIFont boldSystemFontOfSize:12.0f];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    NSArray *itemArrayyoutube = [NSArray arrayWithObjects: @"Public", @"Unlisted", @"Private", nil];
    youtubePrivacyControl = [[UISegmentedControl alloc] initWithItems:itemArrayyoutube];
	youtubePrivacyControl.tag = SETTINGS_PRIVACY_TAG;
	youtubePrivacyControl.selectedSegmentIndex = 1;
	[contentView addSubview:youtubePrivacyControl];

    [youtubePrivacyControl setTitleTextAttributes:attributes forState:UIControlStateNormal];

    if (useYouTube)
    {
        youtubePrivacyControl.hidden = NO;
    }
    
    //temp
#if 0
    youtubePrivacyControl.hidden = YES;
    facebookPrivacyControl.hidden = YES;
    userLabel.hidden = YES;
    btnLogout.hidden = YES;
    progressView.hidden = NO;
    [progressView updateProgress:0.5];
    titleLabel.hidden = YES;
    privacyLabel.hidden = YES;
    titleInput.hidden = YES;
    uploadingLabel.hidden = NO;
#endif

}

-(void)backActionDelay
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

//bret
-(void)backAction:(id)sender
{
    //[_youtube signOutUser]; //**bret temp**
    [self.delegate youTubeUIActivityShareViewControllerDidCancel:self];
#if 0
    if ( isUploading )
    {
        isAlertViewShown = YES;
        mAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancel Upload",nil)
                                                message:NSLocalizedString(@"Are you sure you want to cancel this upload?",nil)
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"NO",nil)
                                      otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
        mAlertView.tag = 1001;
        [mAlertView show];
    }else
    {
        if (useYouTube)
        {
            if ([_youtube isSignedIn])
                [self.navigationController popViewControllerAnimated:YES];
            else
            {
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(backActionDelay) userInfo:nil repeats:NO];
                return;
            }
        }
    }
#endif
}

- (void) viewDidAppear:(BOOL)animated{
	
	[super viewDidAppear:animated];

    if(self.statusBarOrientation == UIInterfaceOrientationPortrait
	   || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}
    [self delayPresentProviders:NO];
    
}//

- (void)viewWillAppear:(BOOL)animated
{
	//[self.navigationController setNavigationBarHidden:NO animated:NO];
	//self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
	//self.title = @"Share Online";
	self.title = NSLocalizedString(@"YouTube", nil);
    [super viewWillAppear:animated];
	// NSLog(@"viewWillAppear:");
	
	if(self.statusBarOrientation == UIInterfaceOrientationPortrait
	   || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}
    
    // HACK: for larger devices, just blow it up
    // this was designed for iPhone 5 max
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat scale = self.view.frame.size.width / 320.0f;
        self.view.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait
		|| toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)saveTitle {
	if (titleInput) {
		NSString *title = titleInput.text;
		[Utilities selectedVideoTitle:title];
	}
}

- (void)dealloc {
	// TODO: joe- add release

    [self saveTitle];
    
	if(mAlertView)
	{
		mAlertView = nil;
	}
    
	if (titleInput)
    {
		titleInput = nil;
	}
	
    if (_youtube)//nil
    {
		_youtube = nil;
	}

	if (progressView)
    {
		progressView = nil;
	}
	
	if (youtubeSettingsView)
    {
		youtubeSettingsView = nil;
	}
	
	if (contentView)
    {
		contentView = nil;
	}
    
     //check
    //titleInput
    //progressView
    //[iconView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResignActivePause" object:nil];
}

-(Boolean) _showView:(UIView *)view activeView:(UIView *)activeView
{
	Boolean viewVisible = (view == activeView);
	if (view) {
		view.hidden = !viewVisible;
	}
	return viewVisible;
}

-(void)setCurrentSubView:(UIView *)view
{
	if (view == youtubeSettingsView)
    {
		[self _updateYoutubeSettings];
	}

	[self _showView:buttonsView activeView:view];
	[self _showView:progressView activeView:view];
	
	[self _showView:youtubeSettingsView activeView:view];
}

-(void)cancelUploadAction
{
	if (_youtube)
    {
		[_youtube cancelUpload];
	}

	//[self setCurrentSubView:buttonsView];
	[progressView updateProgress:0.0];
}

-(void)shareButtonAction:(id)sender
{
	UIButton *button = (UIButton*)sender;
	if (button.tag == SETTINGS_CANCEL_TAG)
    {
        [self backAction:nil];
		return;
	}
	
	Boolean isYoutube = YES;
		
	//NSURL *shareVideoUrl = [Utilities selectedVideoPathWithURL:nil];
    NSURL *shareVideoUrl = [NSURL fileURLWithPath:processedMoviePath];
    if (shareVideoUrl)
    {
		shareVideoUrl = [shareVideoUrl copy];
		
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		
		[dic setObject:shareVideoUrl forKey:@"videoUrl"];
		
		// TODO: joe- see if we need to allow the user to change names??
		NSString *title = nil;
		if (titleInput)
        {
			title = titleInput.text;
		}
		if (title)
        {
			[self saveTitle];
		} else
        {
			title = NSLocalizedString(@"Untitled Video", nil);
		}
		
		[dic setObject:title forKey:@"title"];
		[dic setObject:descInput.text forKey:@"desc"];

		if (isYoutube)
        {
			if (_youtube == nil)
            {
				_youtube = [[YoutubeConnect alloc] init];
				_youtube.delegate_ = self;
			}
			
			NSString *currPrivacy = [self _getYoutubePrivacyFromUI:nil];
			if (currPrivacy)
            {
				[_youtube setPrivacy:currPrivacy];
			}

            [_youtube runSigninThenHandler:
             ^{
                 if ([_youtube isSignedIn])
                 {
                     [self shareButtonsAnimateToHide];
                     isUploading = YES;
                     UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
                     self.navigationItem.leftBarButtonItem = backButton;
                     [_youtube uploadVideoToYoutubeUIActivity:dic];
                     [self.delegate youTubeUIActivityShareViewControllerDidUpload:self];
                     [progressView updateProgress:0.0];
                     //[self setCurrentSubView:progressView];
                 } else
                 {
                     [self backAction:nil];
                 }
             }];
		}


	} else
    {
		// TODO: joe- show error about missing video
	}
}

// UIAlertView helpers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 1002)
    {
		isAlertViewShown = NO;
        //[self setCurrentSubView:buttonsView];
		[progressView updateProgress:0.0];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = backButton;
        [self backAction:nil];
	} else if (alertView.tag == 1001)
    {
		isAlertViewShown = NO;
        if (buttonIndex == 1)
        {
			isUploading = NO;
            [self shareButtonsAnimateToShow];
            [self cancelUploadAction];
            UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
            self.navigationItem.leftBarButtonItem = backButton;
            [self backAction:nil];
		}
	}else if (alertView.tag == 1003)
    {
        isAlertViewShown = NO;
        [self shareButtonsAnimateToShow];
    }else if (alertView.tag == 1004)
    {
        isAlertViewShown = NO;
        [self backAction:nil];
    }
}

// MProgressViewDelegate implementation

-(void)didButtonClickedIndex:(int)index
{
	
	if(mAlertView)
	{
		mAlertView = nil;
	}
    isAlertViewShown = YES;
    mAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancel Upload",nil)
                                                    message:NSLocalizedString(@"Are you sure you want to cancel this upload?",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO",nil)
                                          otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
	mAlertView.tag = 1001;
	[mAlertView show];
    
}


// FacebookConnectDelegate implementation

-(void)didFinishShare:(BOOL)success :(NSString*)errorMsg
{
	// NSLog(@"OK");
	//UIAlertView *alert = nil;
	[self shareButtonsAnimateToShow];
    isUploading = NO;
    if(success)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoWasShared" object:nil];
        
        if(mAlertView)
        {
            mAlertView = nil;
        }
        isAlertViewShown = YES;
        if (useYouTube)
        {
            mAlertView = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"Upload successful! Your video will appear on Youtube shortly.",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                          otherButtonTitles:nil];
        }
        mAlertView.tag = 1002;
        [mAlertView show];
	}
	else
	{
		if (!errorMsg) { errorMsg = @"Unknown Error"; }
		NSString* msg = [NSString stringWithFormat:@"Upload failed.%@\n\nPlease try again.", errorMsg];

        if(mAlertView)
        {
            mAlertView = nil;
        }
        isAlertViewShown = YES;
        mAlertView = [[UIAlertView alloc] initWithTitle:@""
                                           message:NSLocalizedString(msg, nil)
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                 otherButtonTitles:nil];
        mAlertView.tag = 1003;
        [mAlertView show];
		
	}
}

-(void)beganSendVideoData
{
	[progressView updateProgress:0.0];
	//[self setCurrentSubView:progressView];
}

-(void)sendingVideoDataToYoutube:(unsigned long long)bytesRead dataLength:(unsigned long long)dataLength
{
	[progressView updateProgress:(float)bytesRead/(float)dataLength];
}

#pragma mark UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return NO;
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    float offset = OFFSETFORKEYBOARD;
    CGRect rect = contentView.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= offset;
        rect.size.height += offset;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += offset;
        rect.size.height -= offset;
    }
    contentView.frame = rect;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    iskeyboardUp = NO;

    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        if(self.statusBarOrientation == UIDeviceOrientationLandscapeRight || self.statusBarOrientation == UIDeviceOrientationLandscapeLeft)
            [self setViewMovedUp:NO];
    }
}
- (void)keyboardWillShow:(NSNotification *)notif
{
    iskeyboardUp = YES;
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        if(self.statusBarOrientation == UIDeviceOrientationLandscapeRight || self.statusBarOrientation == UIDeviceOrientationLandscapeLeft)
            [self setViewMovedUp:YES];
    }
}

-(void)pauseToDisactive
{
    //
    if (isAlertViewShown)
    {
        if (mAlertView.tag == 1004)
            [self backAction:nil];
    }
}

-(UIInterfaceOrientation) statusBarOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
