//
//  ShareViewController.h
//  MobileLooks
//
//  Created by Joseph Snow / Snow Software Services on 8/1/2013.
//  Copyright 2013 Red Giant. All rights reserved.
//

#import "ShareViewController.h"
#import "MobileLooksAppDelegate.h"
#import "WebSiteCtrlor.h"

#import "DeviceDetect.h"

@implementation ShareViewController
@synthesize useYouTube;
@synthesize mThumbImage;
@synthesize processedMoviePath;

#define FACEBOOK_SETTINGS_TAG	11
#define FACEBOOK_LOGOUT_TAG		12
#define FACEBOOK_UPLOAD_TAG		13

#define YOUTUBE_SETTINGS_TAG	21
#define YOUTUBE_LOGOUT_TAG		22
#define YOUTUBE_UPLOAD_TAG		23

#define SETTINGS_USERNAME_TAG   31
#define SETTINGS_PRIVACY_TAG	32
#define SETTINGS_CANCEL_TAG		33

#define OFFSETFORKEYBOARD 24

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
        
        float scale = .5;
        iconView.frame = CGRectMake(48*scale,24*scale, 50, 50);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-(48*scale),24*scale, picwidth_a, picheight_a);
        
        titleLabel.frame = CGRectMake((0+48)*scale, picheight, 160, 20-4); //20 == font height
        if (IS_IPHONE_5)
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8, 480, 20+10-6); //20 == font height
        else
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8, 480*.84, 20+10-6); //20 == font height
        
        
        privacyLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4, 160, 20+4-4); //20 == font height
        if (IS_IPHONE_5)
        {
            facebookPrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480, 20+10-6); //20 == font height
            youtubePrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480, 20+10-6); //20 == font height
        }else
        {
            facebookPrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480*.84, 20+10-6); //20 == font height
            youtubePrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480*.84, 20+10-6); //20 == font height
        }
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+((80+24+24+48+24+24+12)*scale), userLabelSize.width, userLabelSize.height); //12 == font height
        btnLogout.frame = CGRectMake((screenwidth - 106)/2, picheight+((80+48+24+12+48+24+24+12)*scale), 106, 33);
        
        //if (IS_IPHONE_5)
        //    btnUpload.frame = CGRectMake(screenwidth-106-(24*scale), 568-44-44+((44-33)/2), 106, 33);
        //else
            btnUpload.frame = CGRectMake(screenwidth-106-(24*scale), 320-44-44+((44-33)/2), 106, 33);
        
        //progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
        uploadingLabel.frame = CGRectMake((screenwidth - uploadingLabelSize.width)/2, picheight+((80+24+24+48+24+24+12-120)*scale), uploadingLabelSize.width, uploadingLabelSize.height); //12 == font height
        progressView.frame = CGRectMake((screenwidth - MPROGRESSVIEW_MAX_WIDTH)/2,picheight+((80+48+24+12+48+24-120)*scale),MPROGRESSVIEW_MAX_WIDTH,MPROGRESSVIEW_MAX_WIDTH-24);
    }else
    {
        //ipad
		float screenwidth;
        contentView.frame = CGRectMake(0, 0, 1024, 768);
        screenwidth = 1024;
        
        float picwidth = 240;
        float picheight = 240;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        iconView.frame = CGRectMake(48,24, 99, 99);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-48,24, picwidth_a, picheight_a);
        
        titleLabel.frame = CGRectMake(0+48, picheight, 160, 20); //20 == font height
        titleInput.frame = CGRectMake(0+48, picheight+24, 480, 20+10); //20 == font height

        privacyLabel.frame = CGRectMake(0+48, picheight+24+24+12+12, 160, 20+4); //20 == font height
        facebookPrivacyControl.frame = CGRectMake(0+48, picheight+24+24+12+24+12+8, 480, 20+10); //20 == font height
        youtubePrivacyControl.frame = CGRectMake(0+48, picheight+24+24+12+24+12+8, 480, 20+10); //20 == font height
        
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+80+24+24+48+24+24+12, userLabelSize.width, userLabelSize.height); //12 == font height
        btnLogout.frame = CGRectMake((screenwidth - 160)/2, picheight+80+48+24+12+48+24+24+12, 160, 40);
        
        btnUpload.frame = CGRectMake(screenwidth-227-24, 768-44-94+((94-71)/2), 227, 71);
        
        //progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
        uploadingLabel.frame = CGRectMake((screenwidth - uploadingLabelSize.width)/2, picheight+80+24+24+48+24+24+12, uploadingLabelSize.width, uploadingLabelSize.height); //12 == font height
        progressView.frame = CGRectMake((screenwidth - MPROGRESSVIEW_MAX_WIDTH)/2,picheight+80+48+24+12+48+24,MPROGRESSVIEW_MAX_WIDTH,MPROGRESSVIEW_MAX_WIDTH);
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
        iconView.frame = CGRectMake(48*scale,24*scale, 50, 50);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-(48*scale),24*scale, picwidth_a, picheight_a);
        
        titleLabel.frame = CGRectMake((0+48)*scale, picheight+heightoffset, 160, 20-4); //20 == font height
        //if (IS_IPHONE_5)
            titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8+heightoffset, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
        //else
        //    titleInput.frame = CGRectMake((0+48)*scale, picheight+(24*scale)+8, 480*.84, 20+10-6); //20 == font height
        
        
        privacyLabel.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+12)*scale)+8+4+heightoffset, 160, 20+4-4); //20 == font height
        //if (IS_IPHONE_5)
        //{
            facebookPrivacyControl.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+24+12+8)*scale)+8+4+8+heightoffset, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
            youtubePrivacyControl.frame = CGRectMake((0+48)*scale, picheight+((24+24+12+24+12+8)*scale)+8+4+8+heightoffset, 320-(48*scale)-(48*scale), 20+10-6); //20 == font height
        //}else
        //{
        //    facebookPrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480*.84, 20+10-6); //20 == font height
        //    youtubePrivacyControl.frame = CGRectMake(0+48, picheight+((24+24+12+24+12+8)*scale)+8+4+8, 480*.84, 20+10-6); //20 == font height
        //}
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+((80+24+24+48+24+24+12)*scale)+heightoffset+24, userLabelSize.width, userLabelSize.height); //12 == font height
        btnLogout.frame = CGRectMake((screenwidth - 106)/2, picheight+((80+48+24+12+48+24+24+12)*scale)+heightoffset+24, 106, 33);
        
        if (IS_IPHONE_5)
            btnUpload.frame = CGRectMake(screenwidth-106-(24*scale), 568-44-44+((44-33)/2), 106, 33);
        else
            btnUpload.frame = CGRectMake(screenwidth-106-(24*scale), 480-44-44+((44-33)/2), 106, 33);
        
        //progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
        uploadingLabel.frame = CGRectMake((screenwidth - uploadingLabelSize.width)/2, picheight+((80+24+24+48+24+24+12-120)*scale)+heightoffset+24, uploadingLabelSize.width, uploadingLabelSize.height); //12 == font height
        progressView.frame = CGRectMake((screenwidth - MPROGRESSVIEW_MAX_WIDTH)/2,picheight+((80+48+24+12+48+24-120)*scale)+heightoffset+24,MPROGRESSVIEW_MAX_WIDTH,MPROGRESSVIEW_MAX_WIDTH-24);
    }else
    {
        //ipad
		float screenwidth;
        contentView.frame = CGRectMake(0, 0, 768, 1024);
        screenwidth = 768;
        
        float picwidth = 240;
        float picheight = 240;
        float picwidth_a = picwidth;
        float picheight_a = picheight;
        
        if ( mThumbImage.size.width > mThumbImage.size.height )
        {
            picheight_a = picheight_a * (mThumbImage.size.height/mThumbImage.size.width);
        }else
        {
            picwidth_a = picwidth_a * (mThumbImage.size.width/mThumbImage.size.height);
        }
        
        iconView.frame = CGRectMake(48,24, 99, 99);
        mThumbImageView.frame = CGRectMake(screenwidth-picwidth-48,24, picwidth_a, picheight_a);
        
        //for portrait
        picheight = picheight + 100;
        titleLabel.frame = CGRectMake(0+48, picheight, 160, 20); //20 == font height
        titleInput.frame = CGRectMake(0+48, picheight+24, 480, 20+10); //20 == font height
        
        privacyLabel.frame = CGRectMake(0+48, picheight+24+24+12+12, 160, 20+4); //20 == font height
        facebookPrivacyControl.frame = CGRectMake(0+48, picheight+24+24+12+24+12+8, 480, 20+10); //20 == font height
        youtubePrivacyControl.frame = CGRectMake(0+48, picheight+24+24+12+24+12+8, 480, 20+10); //20 == font height
        
        userLabel.frame = CGRectMake((screenwidth - userLabelSize.width)/2, picheight+80+24+24+48+24+24+12, userLabelSize.width, userLabelSize.height); //12 == font height
        btnLogout.frame = CGRectMake((screenwidth - 160)/2, picheight+80+48+24+12+48+24+24+12, 160, 40);
        
        btnUpload.frame = CGRectMake(screenwidth-227-24, 1024-44-94+((94-71)/2), 227, 71);
        
        //progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
        uploadingLabel.frame = CGRectMake((screenwidth - uploadingLabelSize.width)/2, picheight+80+24+24+48+24+24+12, uploadingLabelSize.width, uploadingLabelSize.height); //12 == font height
        progressView.frame = CGRectMake((screenwidth - MPROGRESSVIEW_MAX_WIDTH)/2,picheight+80+48+24+12+48+24,MPROGRESSVIEW_MAX_WIDTH,MPROGRESSVIEW_MAX_WIDTH);
    }
}

#if 0
- (void)layoutForLandscape
{
	if (contentView != nil)
	{
		// view has already been init, return now.
		// [self setCurrentSubView:buttonsView];
		return;
	}
	

	CGRect contentRect = CGRectMake(20, 18, 440, 250);
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		contentRect = CGRectMake(0, 0, 1024, 704);
		[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info02_backscreen_heng.png"] CGImage]];
	}
	else {
		[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info_background_l.png"] CGImage]];
	}
	contentView = [[UIView alloc] initWithFrame:contentRect];
	contentView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:contentView];


	NSInteger previewHeight = 72;
	NSInteger cellPad = 8;
	NSInteger cellHeight = 64;
	NSInteger cellHeightWPad = cellHeight + 2*cellPad;
	
	/*
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 230, 22)];
	titleLabel.text = NSLocalizedString(@"Share with the world", nil);
	titleLabel.font = [UIFont systemFontOfSize:20];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor blackColor];
	[scrollView addSubview:titleLabel];
	[titleLabel release];
	*/
	
	
	/* UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 410, 220)];
	view.backgroundColor = [UIColor clearColor];
	// view.layer.cornerRadius = 10;
	view.layer.borderColor = [viewBorderColor CGColor];
	view.layer.borderWidth = 2;
	view.layer.masksToBounds = YES;
	[contentView addSubview:view];
	[view release];
	*/
	
	// video preview thumbnail
	
	int textHeight = 30;
	int totW = contentView.bounds.size.width - 2*cellPad;
	CGRect previewFrameBounds = CGRectMake(cellPad, cellPad, totW/2, previewHeight);

	CGRect titleLabelBounds = CGRectMake(totW/2, cellPad, totW/2, textHeight);
	CGRect titleInputBounds = CGRectMake(totW/2, textHeight+cellPad, totW/2, textHeight);
	
	UIImage* keyFrameImage = [[UIImage alloc] initWithContentsOfFile:[Utilities savedKeyFrameImagePath]];
	CGImageRef imageRef = keyFrameImage.CGImage;
	if (imageRef) {
		CGRect imgBounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
		imgBounds = [Utilities resizeToFit :imgBounds :previewFrameBounds];
		
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:imgBounds];
		iconView.image = keyFrameImage;
		[contentView addSubview:iconView];
		[iconView release];
		[keyFrameImage release];
	}

	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelBounds];
	titleLabel.text = NSLocalizedString(@"Video Title", nil);
	titleLabel.font = [UIFont systemFontOfSize:20];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:titleLabel];
	[titleLabel release];

	NSString *defaultTitle = [Utilities selectedVideoTitle:nil];
	titleInput = [[UITextField alloc] initWithFrame:titleInputBounds];
	titleInput.backgroundColor = [UIColor whiteColor];
	titleInput.borderStyle = UITextBorderStyleRoundedRect;
	titleInput.clearButtonMode = UITextFieldViewModeWhileEditing;
	titleInput.returnKeyType = UIReturnKeyDone;
	titleInput.keyboardType = UIKeyboardTypeDefault;
	titleInput.font = [UIFont systemFontOfSize:18];
	titleInput.delegate = self;
	titleInput.placeholder = NSLocalizedString(@"Untitled Video", nil);
	titleInput.text = defaultTitle;
	[contentView addSubview:titleInput];


	// add pad for above image, below image and above first button
	NSInteger yContentPos = previewHeight + cellPad + cellPad + cellPad;
	
	CGRect buttonsRect = CGRectMake(0, yContentPos, contentView.bounds.size.width, contentView.bounds.size.height-yContentPos);

	CGRect progressRect = CGRectMake(0, yContentPos, contentView.bounds.size.width, contentView.bounds.size.height-yContentPos);
	progressRect.origin.x = (progressRect.size.width - MPROGRESSVIEW_MAX_WIDTH)/2;
	progressRect.size.width = MPROGRESSVIEW_MAX_WIDTH;
	
	CGRect settingsRect = CGRectMake(0, yContentPos, contentView.bounds.size.width, contentView.bounds.size.height-yContentPos);
	
	progressView = [[MProgressView alloc] initWithFrame:progressRect];
	[progressView getBoxView].backgroundColor = [UIColor clearColor];
	progressView.hidden = YES;
	progressView.delegate_ = self;
	[contentView addSubview:progressView];
	[progressView updateProgress:0.0];


	buttonsView = [[UIView alloc] initWithFrame:buttonsRect];
	buttonsView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:buttonsView];
	
	NSInteger yPos = 0;
	[self addShareSubview:buttonsView :@"Facebook" :@"facebook_48x48.png" :FACEBOOK_SETTINGS_TAG :yPos];

	yPos += cellHeightWPad;
	[self addHorizontalSeparator:buttonsView :yPos];

	[self addShareSubview:buttonsView :@"YouTube" :@"youtube2_48x48.png" :YOUTUBE_SETTINGS_TAG :yPos];

	yPos += cellHeightWPad;
	[self addHorizontalSeparator:buttonsView :yPos];


//	facebookSettingsView = [self settingsViewWithFrame:settingsRect :@"facebook_48x48.png" :FACEBOOK_LOGOUT_TAG :FACEBOOK_UPLOAD_TAG :[self getFacebookPrivacyItems]];
//	facebookSettingsView.hidden = YES;
//	[contentView addSubview:facebookSettingsView];
//	[self _updateFacebookSettings];
//	
//	youtubeSettingsView = [self settingsViewWithFrame:settingsRect :@"youtube2_48x48.png" :YOUTUBE_LOGOUT_TAG :YOUTUBE_UPLOAD_TAG :[self getYoutubePrivacyItems]];
//	youtubeSettingsView.hidden = YES;
//	[contentView addSubview:youtubeSettingsView];
//	[self _updateYoutubeSettings];
	
	[self setCurrentSubView:buttonsView];
}
#endif
//-(UIView *) settingsViewWithFrame:(CGRect)frameRect :(NSString*)imgpath :(NSInteger)logoutTag :(NSInteger)uploadTag :(NSArray*)privacyItems
//{
////#if 0
////    NSInteger pad = 8;
////	NSInteger textHeight = 28;
////	NSInteger buttonHeight = 32;
////	NSInteger logoutButtonHeight = 24;
////
////	NSInteger xPos = 0;
////	NSInteger yPos = frameRect.size.height - buttonHeight;
////	NSInteger btnWidth = frameRect.size.width / 2 - pad;
////
////	UIView *view = [[UIView alloc] initWithFrame:frameRect];
////	view.backgroundColor = [UIColor clearColor];
////
////	UIImage *iconImage = [UIImage imageNamed:imgpath];
////	UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
////	iconView.image = iconImage;
////	[view addSubview:iconView];
////	[iconView release];
////	[iconImage release];
////
////	CGRect titleLabelBounds = CGRectMake(32+pad, 0, frameRect.size.width/2, textHeight);
////	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelBounds];
////	titleLabel.text = NSLocalizedString(@"Upload Settings", nil);
////	titleLabel.font = [UIFont systemFontOfSize:16];
////	titleLabel.backgroundColor = [UIColor clearColor];
////	titleLabel.textColor = [UIColor whiteColor];
////	titleLabel.shadowColor = [UIColor blackColor];
////	[view addSubview:titleLabel];
////	[titleLabel release];
////
////	CGRect userBounds = CGRectMake(0, logoutButtonHeight, frameRect.size.width - btnWidth/2 - pad, logoutButtonHeight);
////	UILabel *userLabel = [[UILabel alloc] initWithFrame:userBounds];
////	userLabel.tag = SETTINGS_USERNAME_TAG;
////	userLabel.text = NSLocalizedString(@"", nil);
////	userLabel.font = [UIFont systemFontOfSize:12];
////	userLabel.backgroundColor = [UIColor clearColor];
////	userLabel.textColor = [UIColor whiteColor];
////	userLabel.shadowColor = [UIColor blackColor];
////	userLabel.textAlignment = UITextAlignmentRight;
////	[view addSubview:userLabel];
////	[userLabel release];
////
////	UIButton *btnLogout = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
////	btnLogout.frame = CGRectMake(frameRect.size.width-btnWidth/2, logoutButtonHeight, btnWidth/2 , logoutButtonHeight);
////	btnLogout.backgroundColor = [UIColor clearColor];
////	btnLogout.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
////	btnLogout.tag = logoutTag;
////	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
////	[btnLogout setTitle:NSLocalizedString(@"Sign Out", nil) forState:UIControlStateNormal];
////	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
////	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
////	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
////	[btnLogout addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
////	[view addSubview:btnLogout];
////	[btnLogout release];
////
////	UISegmentedControl *privacyControl = [[UISegmentedControl alloc] initWithItems:privacyItems];
////	privacyControl.tag = SETTINGS_PRIVACY_TAG;
////	privacyControl.frame = CGRectMake(0, 56+pad, frameRect.size.width, buttonHeight);
////	privacyControl.segmentedControlStyle = UISegmentedControlStylePlain;
////	privacyControl.selectedSegmentIndex = 1;
////	[view addSubview:privacyControl];
////	[privacyControl release];
////
////	UIButton *btnCancel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
////	btnCancel.frame = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
////	btnCancel.backgroundColor = [UIColor clearColor];
////	btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
////	btnCancel.tag = SETTINGS_CANCEL_TAG;
////	[btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
////	[btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
////	[btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
////	[btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
////	[btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
////	[btnCancel addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
////	[view addSubview:btnCancel];
////	[btnCancel release];
////	
////	xPos = view.bounds.size.width / 2 + pad;
////
////	UIButton *btnUpload = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
////	btnUpload.frame = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
////	btnUpload.backgroundColor = [UIColor clearColor];
////	btnUpload.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
////	btnUpload.tag = uploadTag;
////	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
////	[btnUpload setTitle:NSLocalizedString(@"Upload Video", nil) forState:UIControlStateNormal];
////	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
////	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
////	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
////	[btnUpload addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
////	[view addSubview:btnUpload];
////	[btnUpload release];
////	return view;
////#endif
//    return nil;
//}

- (void)shareButtonsAnimateToShow
{
//#if 0
//    youtubePrivacyControl.hidden = YES;
//    facebookPrivacyControl.hidden = YES;
//    userLabel.hidden = YES;
//    btnLogout.hidden = YES;
//    progressView.hidden = NO;
//    [progressView updateProgress:0.5];
//    titleLabel.hidden = YES;
//    privacyLabel.hidden = YES;
//    titleInput.hidden = YES;
//    uploadingLabel.hidden = NO;
//#endif
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
        if (facebookPrivacyControl.hidden == YES)
        {
            [UIView transitionWithView:facebookPrivacyControl
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        facebookPrivacyControl.hidden = NO;
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
        if (facebookPrivacyControl.hidden == NO)
        {
            [UIView transitionWithView:facebookPrivacyControl
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
        }
        facebookPrivacyControl.hidden = YES;
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

-(NSArray*) getFacebookPrivacyItems
{
	return [NSArray arrayWithObjects: @"Public", @"Friends", @"Only Me", nil];
}

-(NSArray*) getYoutubePrivacyItems
{
	return [NSArray arrayWithObjects: @"Public", @"Unlisted", @"Private", nil];
}

-(void)_updateFacebookSettings
{
	//UISegmentedControl *privacyControl = (UISegmentedControl*)[facebookSettingsView viewWithTag:SETTINGS_PRIVACY_TAG];
	//if (privacyControl)
    //{
		
		NSString *privacyValue = (_facebook != nil)? [_facebook getPrivacy]: @"Public";

		NSArray *privacyItems = [self getFacebookPrivacyItems];
		NSUInteger idx = [privacyItems indexOfObject:privacyValue];
		if (idx == NSNotFound) { idx = 0; }
		facebookPrivacyControl.selectedSegmentIndex = idx;
	//}
	
	//UILabel *userLabel = (UILabel *)[facebookSettingsView viewWithTag:SETTINGS_USERNAME_TAG];
	//if (userLabel)
    //{
		NSString *username = (_facebook != nil)? [_facebook getUsername]: nil;
		if (username == nil) { username = @""; }
		[userLabel setText:username];
	//}
    
    
    CGSize maxSize = CGSizeMake(300, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine;
    userLabelSize = [username boundingRectWithSize:maxSize options:options attributes:@{NSFontAttributeName: userLabel.font} context:nil].size;
    
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

-(NSString *)_getFacebookPrivacyFromUI:(NSString *)defaultValue
{
	NSString *retval = nil;
	
	NSArray *privacyItems = [self getFacebookPrivacyItems];
	//UISegmentedControl *privacyControl = (UISegmentedControl*)[facebookSettingsView viewWithTag:SETTINGS_PRIVACY_TAG];
	if (facebookPrivacyControl.selectedSegmentIndex >= 0)
    {
		retval = [privacyItems objectAtIndex:facebookPrivacyControl.selectedSegmentIndex];
	}
	
	if (!retval) { retval = defaultValue; }
	return retval;
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
	return [self navigationController];
}

-(void)addShareSubview:(UIView *)view :(NSString*)title :(NSString*)imagepath :(NSInteger)tag :(NSInteger)yPos
{
#if 0
	NSInteger pad = 8;
	NSInteger buttonHeight = 64;

	UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	button.frame = CGRectMake(0, yPos, view.bounds.size.width, buttonHeight);
	button.backgroundColor = [UIColor clearColor];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	button.tag = tag;
	[button setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[button setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:button];
	[button release];


	UIImage *iconImage = [UIImage imageNamed:imagepath];
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(pad, yPos + pad, 48, 48)];
	iconView.image = iconImage;
	[view addSubview:iconView];
	[iconView release];
	[iconImage release];
#endif
}

-(void)addHorizontalSeparator:(UIView*)view :(NSInteger)yPos
{
	UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, view.bounds.size.width, 2)];
	separator.backgroundColor = viewBorderColor;
	[view addSubview:separator];
	[separator release];
}

-(void)delayPresentProviders:(BOOL) resignin
{
    //bret new
//#if 0
    if (!resignin)
    {
        if (!useYouTube) //Facebook
        {
            if (_facebook != nil)
            {
                return;
            }
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
        if (_facebook == nil)
        {
            _facebook = [[FacebookConnect alloc] init];
            _facebook.delegate_ = self;
        }
        
        NSString *currPrivacy = [self _getFacebookPrivacyFromUI:nil];
        if (currPrivacy)
        {
            [_facebook setPrivacy:currPrivacy];
        }
        [_facebook runSigninThenHandler:
         ^{
             if ([_facebook isSignedIn])
             {
                 //[self setCurrentSubView:facebookSettingsView];
                 if (useYouTube)
                 {
                     [self _updateYoutubeSettings];
                 }else
                 {
                     [self _updateFacebookSettings];
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
#if 0
                 isAlertViewShown = YES;
                 mAlertView = [[UIAlertView alloc] initWithTitle:@"Sign-in Error"
                                                         message:NSLocalizedString(@"There was an error signing in to Facebook. Try signing in with Safari before sharing this video.",nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                               otherButtonTitles:nil];
                 mAlertView.tag = 1004;
                 [mAlertView show];
#endif
             }
         }];
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
                 }else
                 {
                     [self _updateFacebookSettings];
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
#if 0
                 isAlertViewShown = YES;
                 mAlertView = [[UIAlertView alloc] initWithTitle:@"Sign-in Error"
                                                         message:NSLocalizedString(@"There was an error signing in to Youtube. Try signing in with Safari before sharing this video.",nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                               otherButtonTitles:nil];
                 mAlertView.tag = 1004;
                 [mAlertView show];
#endif
             }
         }];
    }
    
    if (useYouTube)
    {
        [self _updateYoutubeSettings];
    }else
    {
        [self _updateFacebookSettings];
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
    //useYouTube = NO; //temp
    mAlertView = nil;
    isUploading = NO;
    iskeyboardUp = NO;
    isAlertViewShown = NO;
    [super viewDidLoad];
    
    if (!useYouTube)
        self.title = NSLocalizedString(@"Share this movie on Facebook", nil);
    else
        self.title = NSLocalizedString(@"Share this movie on Youtube", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToDisactive) name:@"ResignActivePause" object:nil];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
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
    
    CGSize maxSize = CGSizeMake(300, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine;
    uploadingLabelSize = [uploadingLabel.text boundingRectWithSize:maxSize options:options attributes:@{NSFontAttributeName: uploadingLabel.font} context:nil].size;
    
    progressView = [[MProgressView alloc] initWithFrame:CGRectMake(0, 0, MPROGRESSVIEW_MAX_WIDTH, MPROGRESSVIEW_MAX_WIDTH)];
	[progressView getBoxView].backgroundColor = [UIColor clearColor];
	progressView.hidden = YES;
	progressView.delegate_ = self;
	[contentView addSubview:progressView];
	[progressView updateProgress:0.0];
    
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
	//**[iconImage release];
/*
	upLoadSettingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	upLoadSettingsLabel.text = NSLocalizedString(@"Upload Settings", nil);
	upLoadSettingsLabel.font = [UIFont systemFontOfSize:16];
	upLoadSettingsLabel.backgroundColor = [UIColor clearColor];
	upLoadSettingsLabel.textColor = [UIColor whiteColor];
	upLoadSettingsLabel.shadowColor = [UIColor blackColor];
	[contentView addSubview:upLoadSettingsLabel];
*/
    
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

   	btnLogout = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//btnLogout.frame = CGRectMake(frameRect.size.width-btnWidth/2, logoutButtonHeight, btnWidth/2 , logoutButtonHeight);
	btnLogout.backgroundColor = [UIColor clearColor];
	btnLogout.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    if (useYouTube)
        btnLogout.tag = YOUTUBE_LOGOUT_TAG;
    else
        btnLogout.tag = FACEBOOK_LOGOUT_TAG;
    
	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[btnLogout setTitle:NSLocalizedString(@"Sign Out", nil) forState:UIControlStateNormal];
	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[btnLogout setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[btnLogout setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[btnLogout addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:btnLogout];
#if 0
	btnCancel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//btnCancel.frame = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
	btnCancel.backgroundColor = [UIColor clearColor];
	btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	btnCancel.tag = SETTINGS_CANCEL_TAG;
	[btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
	[btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[btnCancel addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:btnCancel];
#endif
    btnUpload = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//btnUpload.frame = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
	btnUpload.backgroundColor = [UIColor clearColor];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        btnUpload.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    else
        btnUpload.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    
    if (useYouTube)
        btnUpload.tag = YOUTUBE_UPLOAD_TAG;
    else
        btnUpload.tag = FACEBOOK_UPLOAD_TAG;
	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
	[btnUpload setTitle:NSLocalizedString(@"Upload Video", nil) forState:UIControlStateNormal];
	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateHighlighted];
	[btnUpload setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
	[btnUpload addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:btnUpload];

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
    
    NSArray *itemArrayfacebook = [NSArray arrayWithObjects: @"Public", @"Friends", @"Only Me", nil];
    facebookPrivacyControl = [[UISegmentedControl alloc] initWithItems:itemArrayfacebook];
	facebookPrivacyControl.tag = SETTINGS_PRIVACY_TAG;
	//facebookPrivacyControl.frame = CGRectMake(0, 56+pad, frameRect.size.width, buttonHeight);
	facebookPrivacyControl.selectedSegmentIndex = 1;
	[contentView addSubview:facebookPrivacyControl];

    UIFont *font;
    //UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        font = [UIFont boldSystemFontOfSize:16.0f];
    else
        font = [UIFont boldSystemFontOfSize:12.0f];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [facebookPrivacyControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
	
    NSArray *itemArrayyoutube = [NSArray arrayWithObjects: @"Public", @"Unlisted", @"Private", nil];
    youtubePrivacyControl = [[UISegmentedControl alloc] initWithItems:itemArrayyoutube];
	youtubePrivacyControl.tag = SETTINGS_PRIVACY_TAG;
    //[[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
	//facebookPrivacyControl.frame = CGRectMake(0, 56+pad, frameRect.size.width, buttonHeight);
	youtubePrivacyControl.selectedSegmentIndex = 1;
	[contentView addSubview:youtubePrivacyControl];

    
    [youtubePrivacyControl setTitleTextAttributes:attributes forState:UIControlStateNormal];

    if (useYouTube)
    {
        youtubePrivacyControl.hidden = NO;
        facebookPrivacyControl.hidden = YES;
    }
    else
    {
        youtubePrivacyControl.hidden = YES;
        facebookPrivacyControl.hidden = NO;
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

#if 0
    if(self.statusBarOrientation == UIInterfaceOrientationPortrait
	   || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}
#endif
    //bret new
    //[NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(delayPresentProviders) userInfo:nil repeats:NO];
}

-(void)backActionDelay
{
    [self.navigationController popViewControllerAnimated:YES];
}

//bret
-(void)backAction:(id)sender
{
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
        }else
        {
            [self backActionDelay];
        }
    }
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

- (UIInterfaceOrientation)statusBarOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
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
		[mAlertView release];
		mAlertView = nil;
	}
    
	if (titleInput)
    {
		[titleInput release];
		titleInput = nil;
	}

	if (_facebook) //nil
    {
		[_facebook release];
		_facebook = nil;
	}
	
    if (_youtube)//nil
    {
		[_youtube release];
		_youtube = nil;
	}
#if 0
	if (buttonsView)
    {
		[buttonsView release];
		buttonsView = nil;
	}
#endif
	if (progressView)
    {
		[progressView release];
		progressView = nil;
	}
	
	if (youtubeSettingsView)
    {
		[youtubeSettingsView release];
		youtubeSettingsView = nil;
	}
	
	if (contentView)
    {
		[contentView release];
		contentView = nil;
	}
    
    [mThumbImageView release];
    [mThumbImage release]; //check
    [titleLabel release];
    //titleInput
    [uploadingLabel release];
    //progressView
    [iconView release];
    [userLabel release];
    [btnLogout release];
    [btnUpload release];
    [privacyLabel release];
    [facebookPrivacyControl release];
    [youtubePrivacyControl release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResignActivePause" object:nil];
	[super dealloc];
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
	if (view == facebookSettingsView) {
		[self _updateFacebookSettings];
	} else if (view == youtubeSettingsView) {
		[self _updateYoutubeSettings];
	}

	[self _showView:buttonsView activeView:view];
	[self _showView:progressView activeView:view];
	
	[self _showView:facebookSettingsView activeView:view];
	[self _showView:youtubeSettingsView activeView:view];
}

-(void)cancelUploadAction
{
	if (_facebook) {
		[_facebook cancel];
	}
	
	if (_youtube) {
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
	
	Boolean isFacebook = NO;
	Boolean isYoutube = NO;
	
	switch (button.tag)
	{
	//case FACEBOOK_SETTINGS_TAG:
	case FACEBOOK_UPLOAD_TAG:
	case FACEBOOK_LOGOUT_TAG:
		isFacebook = YES;
		break;
		
	//case YOUTUBE_SETTINGS_TAG:
	case YOUTUBE_UPLOAD_TAG:
	case YOUTUBE_LOGOUT_TAG:
		isYoutube = YES;
		break;

	default:
		break;
	}
	
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

		if (isFacebook)
        {
			if (_facebook == nil)
            {
				_facebook = [[FacebookConnect alloc] init];
				_facebook.delegate_ = self;
			}
			
			NSString *currPrivacy = [self _getFacebookPrivacyFromUI:nil];
			if (currPrivacy)
            {
				[_facebook setPrivacy:currPrivacy];
			}

			if (button.tag == FACEBOOK_LOGOUT_TAG)
            {
                [_facebook runSignOutUserThenHandler:
                 ^{
                     [self delayPresentProviders:YES];
                 }];
#if 0
                [_facebook runSignOutUserThenHandler:
                 ^{
					[_facebook runSigninThenHandler:
                     ^{
						[self _updateFacebookSettings];
						if ([_facebook isSignedIn])
                        {
							//[self setCurrentSubView:facebookSettingsView];
						} else
                        {
							[self backAction:nil];
						}
					}];
				}];
#endif
			} else if (button.tag == FACEBOOK_SETTINGS_TAG)
            {
				[_facebook runSigninThenHandler:
                 ^{
					if ([_facebook isSignedIn])
                    {
						//[self setCurrentSubView:facebookSettingsView];
					} else
                    {
						[self backAction:nil];
					}
				}];
			} else if (button.tag == FACEBOOK_UPLOAD_TAG)
            {
				[_facebook runSigninThenHandler:
                 ^{
					if ([_facebook isSignedIn])
                    {
						[self shareButtonsAnimateToHide];
                        isUploading = YES;
                        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
                        self.navigationItem.leftBarButtonItem = backButton;
                        [backButton release];
                        [_facebook uploadVideoToFacebook:dic];
						[progressView updateProgress:0.0];
						//[self setCurrentSubView:progressView];
					} else
                    {
						[self backAction:nil];
					}
				}];
			}

		} else if (isYoutube)
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

			if (button.tag == YOUTUBE_LOGOUT_TAG)
            {
				[_youtube signOutUser];
                [self delayPresentProviders:YES];
#if 0
				[_youtube runSigninThenHandler:
                 ^{
					[self _updateYoutubeSettings];
					if ([_youtube isSignedIn])
                    {
						//[self setCurrentSubView:youtubeSettingsView];
					} else {
						[self backAction:nil];
					}
				}];
#endif
			} else if (button.tag == YOUTUBE_SETTINGS_TAG)
            {
				[_youtube runSigninThenHandler:
                 ^{
					if ([_youtube isSignedIn])
                    {
						//[self setCurrentSubView:youtubeSettingsView];
					} else
                    {
						[self backAction:nil];
					}
				}];
			} else if (button.tag == YOUTUBE_UPLOAD_TAG)
            {
				[_youtube runSigninThenHandler:
                 ^{
					if ([_youtube isSignedIn])
                    {
                        [self shareButtonsAnimateToHide];
                        isUploading = YES;
                        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
                        self.navigationItem.leftBarButtonItem = backButton;
                        [backButton release];
                        [_youtube uploadVideoToYoutube:dic];
						[progressView updateProgress:0.0];
						//[self setCurrentSubView:progressView];
					} else
                    {
						[self backAction:nil];
					}
				}];
			}
		}

		[shareVideoUrl release];
		[dic release];

	} else
    {
		// TODO: joe- show error about missing video
	}
}

#if 0
-(void)showActiveButton
{	
	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	BOOL bWithInActive = [appDelegate checkIfWithinActiveDuration];
	
	if(bWithInActive)
	{
		if(self.navigationItem.rightBarButtonItem != nil) return;
		
		//add submit button
		UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
		submit.frame = CGRectMake(0, 0, 32, 32);
		[submit setBackgroundImage:[UIImage imageNamed:@"active_btn.png"] forState:UIControlStateNormal];
		[submit addTarget:self action:@selector(activeAction:) forControlEvents:UIControlEventTouchUpInside];
		
		_submitBtnItem = [[UIBarButtonItem alloc] initWithCustomView:submit];
		self.navigationItem.rightBarButtonItem = _submitBtnItem;
	}
	else
	{
		if(self.navigationItem.rightBarButtonItem != nil)
		{
			self.navigationItem.rightBarButtonItem = nil;
		}
	}
}

-(void)activeAction:(id)sender
{
	//TO DO: 点击查看web信息
	
	NSString *active_link_title = [[NSUserDefaults standardUserDefaults] objectForKey:push_noti_active_link_title];
	NSString *active_link_url   = [[NSUserDefaults standardUserDefaults] objectForKey:push_noti_active_link_url];
	if(active_link_url == nil || [active_link_url compare:@""] == NSOrderedSame) return;
	
	//start website
	WebSiteCtrlor *webSite = [[WebSiteCtrlor alloc] initWithNibName:@"WebSiteCtrlor" bundle:nil];
	webSite.navBarTintColor = [UIColor blackColor];
	webSite.toolBarTintColor = [UIColor blackColor];
	//webSite.bShowToolBar = NO;
	webSite.bShowStatusBar = NO;
	[webSite setCtrlorWithURL:active_link_url forTitle:active_link_title];
	[self presentModalViewController:webSite animated:YES];
	[webSite release];
}
#endif


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
            [backButton release];
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
		[mAlertView release];
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
    
#if 0
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancel Upload",nil)
							message:NSLocalizedString(@"Are you sure you want to cancel this upload?",nil)
							delegate:self
					 		cancelButtonTitle:NSLocalizedString(@"NO",nil)
					 		otherButtonTitles:NSLocalizedString(@"YES",nil),nil];
	alert.tag = 1001;
	[alert show];
	[alert release];
#endif
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
            [mAlertView release];
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
        }else
        {
            mAlertView = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"Upload successful! Your video will appear on Facebook shortly.",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                          otherButtonTitles:nil];
        }
        mAlertView.tag = 1002;
        [mAlertView show];
#if 0
		alert = [[UIAlertView alloc] initWithTitle:@""
									  	message:NSLocalizedString(@"Upload successful!",nil)
									  	delegate:self
									  	cancelButtonTitle:NSLocalizedString(@"OK",nil)
									  	otherButtonTitles:nil];
		alert.tag = 1002;
		[alert show];
		[alert release];
#endif
	}
	else
	{
		if (!errorMsg) { errorMsg = @"Unknown Error"; }
		NSString* msg = [NSString stringWithFormat:@"Upload failed.%@\n\nPlease try again.", errorMsg];

        if(mAlertView)
        {
            [mAlertView release];
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
		
#if 0
        alert = [[UIAlertView alloc] initWithTitle:@""
									  	message:NSLocalizedString(msg, nil)
									  	delegate:self
									  	cancelButtonTitle:NSLocalizedString(@"OK",nil)
									  	otherButtonTitles:nil];
		alert.tag = 1003;
		[alert show];
		[alert release];
#endif
	}
}

-(void)beganSendVideoData
{
	[progressView updateProgress:0.0];
	//[self setCurrentSubView:progressView];
}

-(void)sendingVideoDataToFacebook:(NSInteger)bytesSend bytesNeedSend:(NSInteger)bytesNeedSend
{
	[progressView updateProgress:(float)bytesSend/(float)bytesNeedSend];
}

-(void)sendingVideoDataToYoutube:(unsigned long long)bytesRead dataLength:(unsigned long long)dataLength
{
	[progressView updateProgress:(float)bytesRead/(float)dataLength];
}

-(void)didNeedAskJoinGroup:(NSString*)joinUrl
{
	//start website
	WebSiteCtrlor *webSite = [[WebSiteCtrlor alloc] initWithNibName:@"WebSiteCtrlor" bundle:nil];
	webSite.navBarTintColor = [UIColor blackColor];
	webSite.toolBarTintColor = [UIColor blackColor];
	//webSite.bShowToolBar = NO;
	webSite.bShowStatusBar = NO;
	webSite.delegate = self;
	[webSite setCtrlorWithURL:joinUrl forTitle:@"Like MovieLooks Facebook page"];
    [self presentViewController:webSite animated:YES completion:^{}];
	[webSite release];
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

@end
