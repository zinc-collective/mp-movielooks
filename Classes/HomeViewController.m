//
//  HomeViewController.m
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "HomeViewController.h"
#import "LooksBrowserViewController.h"

#import "Utilities.h"
#import "InfoViewController.h"
#import "MobileLooksAppDelegate.h"
#import "WebSiteCtrlor.h"
#import "ShareViewController.h"

#import "MovieProcessor.h"

#import "DeviceDetect.h"

@implementation HomeViewController
//@synthesize selectedVideoUrl;
@synthesize infoButton; //storyboard
@synthesize chooseVideoButton; //storyboard

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object
{	
	// NSLog(@"HomeVC:deviceOrientationDidChange %d", self.interfaceOrientation);
	[self layoutForCurrentOrientation];
}

- (void)layoutForCurrentOrientation
{
	// UIDeviceOrientation orientation0 = self.interfaceOrientation;
	// UIDeviceOrientation orientation1 = [[UIDevice currentDevice] orientation];
	// NSLog(@"layoutForCurrentOrientation %d %d", orientation0, orientation1);
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self layoutForPortrait];
	}
	else
	{
		[self layoutForLandscape];
	}
}

- (void)layoutForPortrait
{
	// NSLog(@"layoutForPortrait");
		
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		[[self.view layer] setContents:(id)[[UIImage imageNamed:@"background_portrait.png"] CGImage]];
		infoButton.frame = CGRectMake(703, 7, 58, 58);
		chooseVideoButton.frame = CGRectMake(357+48, 944+12, 403*.86, 73*.86);
		[chooseVideoButton setImage:[UIImage imageNamed:@"gear_wheel.png"] forState:UIControlStateNormal];
        //mOpaqueView.frame = CGRectMake(0, 0, 768, 1024);
	}
	else
    {
		if (IS_IPHONE_5)
        {
            [[self.view layer] setContents:(id)[[UIImage imageNamed:@"home_background_p.png"] CGImage]];
            //CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
            infoButton.frame = CGRectMake(320-29-7, 7, 29, 29);
            chooseVideoButton.frame = CGRectMake(320-202-10, 568-37-4, 202, 37);
            [chooseVideoButton setImage:[UIImage imageNamed:@"home_choose_video_p.png"] forState:UIControlStateNormal];
            //mOpaqueView.frame = CGRectMake(0, 0, 320, 568);
        }else
        {
            [[self.view layer] setContents:(id)[[UIImage imageNamed:@"home_background_p_480.png"] CGImage]];
            //CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
            infoButton.frame = CGRectMake(320-29-7, 7, 29, 29);
            chooseVideoButton.frame = CGRectMake(320-202-10, 480-37-4, 202, 37);
            [chooseVideoButton setImage:[UIImage imageNamed:@"home_choose_video_p.png"] forState:UIControlStateNormal];
            //mOpaqueView.frame = CGRectMake(0, 0, 320, 480);
        }
	}
}

- (void)layoutForLandscape
{
	NSLog(@"layoutForLandscape");
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[[self.view layer] setContents:(id)[[UIImage imageNamed:@"background_landscape.png"] CGImage]];
		infoButton.frame = CGRectMake(959, 7, 58, 58);
		chooseVideoButton.frame = CGRectMake(613, 688, 403, 73);
		[chooseVideoButton setImage:[UIImage imageNamed:@"gear_wheel.png"] forState:UIControlStateNormal];
        //mOpaqueView.frame = CGRectMake(0, 0, 1024, 768);
	}
	else
    {
		if (IS_IPHONE_5)
        {
            [[self.view layer] setContents:(id)[[UIImage imageNamed:@"home_background_l.png"] CGImage]];
            //CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
            infoButton.frame = CGRectMake(568-29-24, 4, 29, 29);
            chooseVideoButton.frame = CGRectMake(568-202-10, 320-37-4, 202, 37);
            [chooseVideoButton setImage:[UIImage imageNamed:@"home_choose_video_l.png"] forState:UIControlStateNormal];
            //mOpaqueView.frame = CGRectMake(0, 0, 568, 320);
        }else
        {
            [[self.view layer] setContents:(id)[[UIImage imageNamed:@"home_background_l_480.png"] CGImage]];
            //CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
            infoButton.frame = CGRectMake(480-29-24, 4, 29, 29);
            chooseVideoButton.frame = CGRectMake(480-202-10, 320-37-4, 202, 37);
            [chooseVideoButton setImage:[UIImage imageNamed:@"home_choose_video_l.png"] forState:UIControlStateNormal];
            //mOpaqueView.frame = CGRectMake(0, 0, 480, 320);
        }
	}
}

#if 0 //storyboard
- (void)loadView
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
		[self.view release];
	}
	else {
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[self.view release];
	}
}
#endif

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
	
	[self layoutForCurrentOrientation];
		
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// show news button
	// [self showNewsButton];
#if 0
	// show debug share button
	[self showShareButton];
#endif
}

- (void)viewDidLoad
{
	//NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
	//storyboard self.navigationController.navigationBarHidden = YES;
	navigationVideoProcessor = nil;
	navigationVideoPicker = nil;
    
#if 0 //storyboard
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:infoButton];
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[infoButton setImage:[UIImage imageNamed:@"i_normal.png"] forState:UIControlStateNormal];
		[infoButton setImage:[UIImage imageNamed:@"i_press.png"] forState:UIControlStateHighlighted];
	}
	else {
		[infoButton setImage:[UIImage imageNamed:@"home_info.png"] forState:UIControlStateNormal];
		[infoButton setImage:[UIImage imageNamed:@"home_info_h.png"] forState:UIControlStateHighlighted];
	}
#endif
    
#if 0 //storyboard
	chooseVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[chooseVideoButton addTarget:self action:@selector(chooseVideoAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:chooseVideoButton];
#endif
    
	//mOpaqueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    //mOpaqueView.backgroundColor = [UIColor blackColor];
    //mOpaqueView.hidden = YES;
    //[self.view addSubview:mOpaqueView];
    
    isSelectingVideo = NO;
	isSharingVideo = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeFromMultiTask) name:@"BecomeActiveResume" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseToMultiTask) name:@"ResignActivePause" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissNavigationToHome) name:@"BackToHome" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissNavigationToHomeThenShare) name:@"BackToHomeAndShare" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissNavigationToVideo) name:@"BackToVideo" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(looksPreviewOnScreen) name:@"LooksPreviewOnScreen" object:nil];
	//bret
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissNavigationToTrim) name:@"BackToTrim" object:nil];

	if(![CLLocationManager locationServicesEnabled]){
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
		[locationManager startUpdatingLocation];
	}
	
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy < 0) return;
    
	if (newLocation.horizontalAccuracy <= manager.desiredAccuracy)
	{
		
		[manager stopUpdatingLocation];
		manager.delegate = nil;
		
	
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location Failed.");
	
	if ([error code] != kCLErrorLocationUnknown)
	{
		[manager stopUpdatingLocation];
		manager.delegate = nil;
		
	}
}

#if 0 //storyboard
- (void) infoAction:(id)sender
{	
	InfoViewController *infoViewController = [[InfoViewController alloc] init];
	[self.navigationController pushViewController:infoViewController animated:YES];
	[infoViewController release];
}
#endif

#if 0 //storyboard -- now a seque
- (IBAction)infoButtonAction:(id)sender
{
	InfoViewController *infoViewController = [[InfoViewController alloc] init];
	[self.navigationController pushViewController:infoViewController animated:YES];
	[infoViewController release];
}
#endif

#if 0 //storyboard -- now a seque
- (IBAction)chooseVideoButtonAction:(id)sender
{
	isSharingVideo = NO;
	[self showChooseVideoView];
}
#endif

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"seque id == %@",segue.identifier);
    if ([[segue identifier] isEqualToString:@"MobileLooksVideoPickerController"])
    {
        //UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        navigationVideoPicker = (UINavigationController *)segue.destinationViewController;
        MobileLooksVideoPickerController* videoPickerController = [[navigationVideoPicker viewControllers] lastObject];
        [videoPickerController setDelegate:self];
        //linkedInViewController setUrlAddress:self.authUrl];
        //if(navigationVideoPicker.parentViewController==nil)
        //{
        //    NSLog(@"Unexpected Error 1a!");
        //}
    }else if ([[segue identifier] isEqualToString:@"LooksBrowserViewController"])
    {
        navigationVideoProcessor = (UINavigationController *)segue.destinationViewController;
        //LooksBrowserViewController* videoProcessorController = [[navigationVideoPicker viewControllers] lastObject];
        //[videoProcessorController setDelegate:self];
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL allowseque = true;
    
    if ([identifier isEqualToString:@"MobileLooksVideoPickerController"])
    {
        if(![CLLocationManager locationServicesEnabled])
        {
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"DeniedAccess",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                      otherButtonTitles:nil];
            
            [alerView show];
            //return;
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            //MobileLooksVideoPickerController* videoPickerController = [[MobileLooksVideoPickerController alloc] init];
            //videoPickerController.delegate = self;
            
            //navigationVideoPicker = [[UINavigationController alloc] initWithRootViewController:videoPickerController];
            //navigationVideoPicker.navigationBar.barStyle = UIBarStyleBlack;
            //[navigationVideoPicker setNavigationBarHidden:NO];
            
            //[videoPickerController release];
            //videoPickerController = nil;
            
            //[self presentModalViewController:navigationVideoPicker animated:YES];
            //if(navigationVideoPicker.parentViewController==nil)
            //{
            //    // NSLog(@"Unexpected Error 1a!");
            //}
            allowseque = true;
        }else
            allowseque = false;
    }
    
    return allowseque;
}

#if 0 //storyboard
- (void) chooseVideoAction:(id)sender
{
	isSharingVideo = NO;
	[self showChooseVideoView];
}
#endif

#if 0 //storyboard
- (void) showChooseVideoView
{
	if(![CLLocationManager locationServicesEnabled]){
		UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@""
															message:NSLocalizedString(@"DeniedAccess",nil)
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"OK",nil)
												  otherButtonTitles:nil];
		
		[alerView show];
		[alerView release];
		//return;
	}
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
#if 0
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
#endif
        MobileLooksVideoPickerController* videoPickerController = [[MobileLooksVideoPickerController alloc] init]; 
        videoPickerController.delegate = self;
        
		navigationVideoPicker = [[UINavigationController alloc] initWithRootViewController:videoPickerController];
        navigationVideoPicker.navigationBar.barStyle = UIBarStyleBlack;
		[navigationVideoPicker setNavigationBarHidden:NO];
		
		[videoPickerController release];
		videoPickerController = nil;
	
        [self presentModalViewController:navigationVideoPicker animated:YES];
		if(navigationVideoPicker.parentViewController==nil)
		{
			// NSLog(@"Unexpected Error 1a!");
		}
	}
}
#endif

-(CGImageRef)getStartKeyFrame:(NSURL *)videoUrl;
{
	NSError* err = nil;
	AVAsset* avAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];	
	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
	[avImageGenerator setAppliesPreferredTrackTransform:YES];
	[avImageGenerator setMaximumSize:CGSizeMake(320, 320)];
	CGImageRef cgImageRefKeyFrameS =  [avImageGenerator copyCGImageAtTime:CMTimeMake(0,600) actualTime:NULL error:&err];
	
	if(err)
		NSLog(@"%@",[err localizedDescription]);
	return cgImageRefKeyFrameS;//jack modify
}
#pragma mark -
#pragma mark MultiTaskHandle 
-(void)pauseToMultiTask
{
}

-(void)resumeFromMultiTask
{
	if (isSelectingVideo) {
		NSLog(@"Error Operation!");	
#if 0
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
#endif
	
		if (![[self presentedViewController] isBeingDismissed]) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:^{}];
		}
	}
}


-(void)dismissNavigationPicker
{
	
    //UINavigationController * navigationController = self.navigationController;
    //[navigationController popToRootViewControllerAnimated:NO];
    //[navigationController pushViewController:someOtherViewController animated:YES];
    if(navigationVideoPicker)
	{
		if (![[self presentedViewController] isBeingDismissed])
        {
			//[self.navigationController popToRootViewControllerAnimated:NO];
            [navigationVideoPicker popToRootViewControllerAnimated:NO];
            //[self.navigationController pushViewController:self animated:YES];
            [self dismissViewControllerAnimated:NO completion:^{}];
			//bret [navigationVideoPicker release];
			navigationVideoPicker = nil;
		}
	}
}

-(void)dismissNavigationProcessor
{
	if(navigationVideoProcessor)
	{
		if (![[self presentedViewController] isBeingDismissed])
        {
			//[self.navigationController popToRootViewControllerAnimated:NO];
			[navigationVideoProcessor popToRootViewControllerAnimated:NO];
            //[self.navigationController pushViewController:self animated:YES];
            [self dismissViewControllerAnimated:NO completion:^{}];
			//bret [navigationVideoProcessor release];
			navigationVideoProcessor = nil;
		}
	}
}


-(void)dismissNavigationToHome
{
	[self dismissNavigationPicker];
	[self dismissNavigationProcessor];
	
	isSelectingVideo = NO;
	isSharingVideo = NO;
}

/*
-(void)dismissNavigationToTrim
{
	[self dismissNavigationPicker];
	[self dismissNavigationProcessor];
	
	isSelectingVideo = NO;
	isSharingVideo = NO;
    [self performSegueWithIdentifier:@"MobileLooksTrimPlayerController2" sender:self];
}
*/

-(void)dismissNavigationToHomeThenShare
{
	[self dismissNavigationToHome];
	//[self.navigationController popToRootViewControllerAnimated:NO];
    //[self dismissModalViewControllerAnimated:YES];
    [self shareAction:nil];
}

-(void)looksPreviewOnScreen
{
    //mOpaqueView.hidden = YES;
}

-(void)delayPresentPicker
{
#if 0 //storyboard
	MobileLooksVideoPickerController* videoPickerController = [[MobileLooksVideoPickerController alloc] init];
	videoPickerController.delegate = self;
	
	navigationVideoPicker = [[UINavigationController alloc] initWithRootViewController:videoPickerController];
	navigationVideoPicker.navigationBar.barStyle = UIBarStyleBlack;
	[navigationVideoPicker setNavigationBarHidden:NO];
	
	[videoPickerController release];
	videoPickerController = nil;
	
	[self presentModalViewController:navigationVideoPicker animated:YES];
	if(navigationVideoPicker.parentViewController==nil)
	{
		// NSLog(@"Unexpected Error 1b!");
		// [self dismissNavigationPicker];
	}	
	self.view.userInteractionEnabled = YES;
#endif
    [self performSegueWithIdentifier:@"MobileLooksVideoPickerController" sender:self];
    
}

-(void)dismissNavigationToVideo
{
	NSLog(@"dismissNavigationToVideo!");
	self.view.userInteractionEnabled = NO;
	
	if(navigationVideoPicker)
	{
		if (![[self presentedViewController] isBeingDismissed])
        {
			[navigationVideoPicker popToRootViewControllerAnimated:NO];
			//**[self dismissModalViewControllerAnimated:NO];
			//bret [navigationVideoPicker release];
			navigationVideoPicker = nil;
		}
	}
	
	if(navigationVideoProcessor)
	{
		if (![[self presentedViewController] isBeingDismissed])
        {
			[navigationVideoProcessor popToRootViewControllerAnimated:NO];
			//**[self dismissModalViewControllerAnimated:NO];
			//bret [navigationVideoProcessor release];
			navigationVideoProcessor = nil;
		}
	}
	
	//[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayPresentPicker) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(delayPresentPicker) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
//storyboard
-(int)selectedMovieAssetMode
{
    return assetMode;
}

-(NSURL*)selectedMovieURL
{
    return selectedURL;
}

-(BOOL)selectMovie:(MobileLooksVideoPickerController*)videoPicker withUrl:(NSURL*)videoURL
{
	BOOL ret;
    if([MovieProcessor checkMovieSession:videoURL])
	{	
		CGImageRef imageRef = [self getStartKeyFrame:videoURL];
		CGFloat imageWidth = CGImageGetWidth(imageRef);
		CGFloat imageHeight = CGImageGetHeight(imageRef);
		//AssetMode assetMode = VideoModeLandscape;
		selectedURL = videoURL; //storyboard
        assetMode = VideoModeLandscape; //storyboard
        if(imageWidth<imageHeight)
			assetMode = VideoModePortrait; 
		CGImageRelease(imageRef);
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];

		[Utilities selectedVideoPathWithURL:videoURL];
		[Utilities selectedVideoTitle:nil];
		
		NSLog(@"Goto MobileLooksTrimPlayerController");
		if(navigationVideoPicker.parentViewController==nil)
		{
			//NSLog(@"Unexpected Error 2!"); //bret
		}

#if 0 //storyboard
		MobileLooksTrimPlayerController* trimController = [[MobileLooksTrimPlayerController alloc] initWithUrl:videoURL withAssetMode:assetMode];
		trimController.delegate = self;
		[navigationVideoPicker pushViewController:trimController animated:YES];
		[trimController release];
        //[self performSegueWithIdentifier:@"MobileLooksTrimPlayerController" sender:self];
        [navigationVideoPicker performSegueWithIdentifier:@"MobileLooksTrimPlayerController" sender:navigationVideoPicker];
#endif
        ret = true;
	}
	else {
		UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@""
															message:NSLocalizedString(@"EmailVideo",nil)
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"OK",nil)
												  otherButtonTitles:nil];
		
		[alerView show];
        ret = false;
	}
    
    return ret;
}

-(void)presentBullet
{
	if(navigationVideoProcessor){
		navigationVideoProcessor = nil;
	}
	LooksBrowserViewController *looksBrowser = [[LooksBrowserViewController alloc] init];
	navigationVideoProcessor = [[UINavigationController alloc] initWithRootViewController:looksBrowser];
    [self presentViewController:navigationVideoProcessor animated:YES completion:^{}];
}


-(void)videoPickerDone:(MobileLooksTrimPlayerController*)trimPlayerController;
{
	NSLog(@"Pick done");
    //mOpaqueView.hidden = NO;
    [self dismissNavigationPicker];
#if 0
	if (isSharingVideo) {
		[self presentShareView];
	} else {
		[self presentBullet];
	}
#endif
    //storyboard
    [self performSegueWithIdentifier:@"LooksBrowserViewController" sender:self];
    
//	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(presentBullet) userInfo:nil repeats:NO];
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

- (BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
#if 0
	NSUInteger mask = 0;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		mask = UIInterfaceOrientationMaskAll;
	} else {
		mask = UIInterfaceOrientationMaskLandscape;
	}
	return mask;
#endif
    return UIInterfaceOrientationMaskAll;
}

#if 0
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationLandscapeLeft;
}
#endif

#if 0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
#endif
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warring");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if(navigationVideoPicker) {
		navigationVideoPicker = nil;
	}
	if(navigationVideoProcessor) {
		navigationVideoProcessor = nil;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BecomeActiveResume" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResignActivePause" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackToHome" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackToHomeAndShare" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackToVideo" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LooksPreviewOnScreen" object:nil];
	
}



-(void)showNewsButton
{	
	MobileLooksAppDelegate* appDelegate = (MobileLooksAppDelegate*)[UIApplication sharedApplication].delegate;
	BOOL bWithInActive = [appDelegate checkIfWithinActiveDuration];
	
	if(bWithInActive)
	{
		if(_newsBtn != nil && [_newsBtn superview]) return;
		
		//add submit button
		if(_newsBtn == nil)
		{
			CGRect btnFrame = CGRectMake(0, 0, 59, 40);
			NSString *btnImageName = @"news.png";
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{
				btnFrame = CGRectMake(0, 0, 117, 80);
				btnImageName = @"news-iPad.png";
			}
			
			_newsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			_newsBtn.frame = btnFrame;
			[_newsBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
			[_newsBtn addTarget:self action:@selector(newsAction:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		if(![_newsBtn superview])
		{
			[self.view addSubview:_newsBtn];
		}
	}
	else
	{
		if(_newsBtn != nil && [_newsBtn superview])
		{
			[_newsBtn removeFromSuperview];
		}
	}
}

-(void)newsAction:(id)sender
{
	//点击查看web信息
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
    [self presentViewController:webSite animated:YES completion:^{}];
}

-(void)showShareButton
{
	if(_shareBtn != nil && [_shareBtn superview]) return;
		
	//add submit button
	if(_shareBtn == nil)
	{
		// CGRect btnFrame = CGRectMake(636, 570, 125, 40);
		CGRect btnFrame = CGRectMake(318, 286, 125, 40);
		NSString *btnImageName = @"bullet_share_button.png";
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			// TODO: add impl
		}
			
		_shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_shareBtn.frame = btnFrame;
		[_shareBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
		[_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if(![_shareBtn superview])
	{
		[self.view addSubview:_shareBtn];
	}
}


-(void)shareAction:(id)sender
{
	// if we don't have a share video already selected, select one now.
	
	NSURL *videoUrl = [Utilities selectedVideoPathWithURL:nil];
	if (videoUrl == nil)
    {
		isSharingVideo = YES;
		//storyboard [self showChooseVideoView];
        [self performSegueWithIdentifier:@"MobileLooksVideoPickerController" sender:self];
	} else
    {
		isSharingVideo = YES;
		[self presentShareView];
	}
}

-(void)presentShareView
{
#if 0
	ShareViewController *shareViewController = [[ShareViewController alloc] init];
	[self.navigationController pushViewController:shareViewController animated:YES];
	[shareViewController release];
#endif
    //storyboard
    [self performSegueWithIdentifier:@"ShareViewController" sender:self];

}




@end
