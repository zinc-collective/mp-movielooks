    //
//  InfoViewController.m
//  MobileLooks
//
//  Created by George on 12/16/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "InfoViewController.h"
#import "MobileLooksAppDelegate.h"
#import "WebSiteCtrlor.h"
#import "DeviceDetect.h"

@implementation InfoViewController
@synthesize contentView; //storyboard
@synthesize scrollView; //storyboard

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)layoutForPortrait
{
	//CGRect scrollFrame = CGRectMake(24, 20, 270, 390);
	//CGRect contentRect = CGRectMake(0, 0, 270, 833);
	CGRect scrollFrame = CGRectMake(24, 20, 270, 408);
	CGRect contentRect = CGRectMake(0, 0, 270, 833);
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
		scrollFrame = CGRectMake(0, 1024-960, 768, 960);
		contentRect = CGRectMake((768-682)/2.0-5, 0, 682, 714);
		//[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info02_backscreen_shu.png"] CGImage]];
	}
	else
    {
        CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
        scrollFrame = CGRectMake(24, 20, 270, 408 * iphonescalefactor);
        contentRect = CGRectMake(0, 0, 270, 833);
        //[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info_background_p.png"] CGImage]];
	}

#if 0 //bret storyboard
	if (scrollView == nil)
	{
		scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.showsVerticalScrollIndicator = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		[self.view addSubview:scrollView];
		[scrollView release];
	}
	else
	{
		scrollView.frame = scrollFrame;
	}
#endif 
    scrollView.frame = scrollFrame;

#if 0 //bret storyboard
	if (contentView == nil)
	{
		contentView = [[UIImageView alloc] initWithFrame:contentRect];
		[scrollView addSubview:contentView];
		[contentView release];
	}
	else
	{
		contentView.frame = contentRect;
	}
#endif
    contentView.frame = contentRect;
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		contentView.image = [UIImage imageNamed:@"info02_text_shu.png"];
		scrollView.contentSize = CGSizeMake(0, 714);
		scrollView.contentOffset = CGPointZero;
	}
	else {
		contentView.image = [UIImage imageNamed:@"info_detail_p.png"];
		scrollView.contentSize = CGSizeMake(0, 827);
		scrollView.contentOffset = CGPointZero;
	}
	
}

- (void)layoutForLandscape
{
	CGRect scrollFrame = CGRectMake(24, 14, 430, 272);
	CGRect contentRect = CGRectMake(0, 0, 430, 711);
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		scrollFrame = CGRectMake(0, 0, 1024, 704);
		contentRect = CGRectMake(0, 0, 1024, 704);
		//[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info02_backscreen_heng.png"] CGImage]];
	}
	else
    {
        CGFloat iphonescalefactor = [[UIScreen mainScreen] bounds].size.height / IPHONE_SCALE_HEIGHT;
        scrollFrame = CGRectMake(24, 14, 430*iphonescalefactor, 272);
        contentRect = CGRectMake(0, 0, 430, 711);
        //[[self.view layer] setContents:(id)[[UIImage imageNamed:@"info_background_l.png"] CGImage]];
	}
	
#if 0 //bret storyboard
	if (scrollView == nil)
	{
		scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.showsVerticalScrollIndicator = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		[self.view addSubview:scrollView];
		[scrollView release];
	}
	else
	{
		scrollView.frame = scrollFrame;
	}
#endif
    scrollView.frame = scrollFrame;
    
	
#if 0 //bret storyboard
	if (contentView == nil)
	{
		contentView = [[UIImageView alloc] initWithFrame:contentRect];
		[scrollView addSubview:contentView];
		[contentView release];
	}
	else
	{
		contentView.frame = contentRect;
	}
#endif
    contentView.frame = contentRect;
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		contentView.image = [UIImage imageNamed:@"info02_text_heng.png"];
		scrollView.contentSize = CGSizeMake(0, 704);
	}
	else {
		contentView.image = [UIImage imageNamed:@"info_detail_l.png"];
		scrollView.contentSize = CGSizeMake(0, 705);
	}
	
	scrollView.contentOffset = CGPointZero;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	//[self showActiveButton];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO; //storyboard bug????
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	//self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
	//self.title = @"Info";
	
	// NSLog(@"viewWillAppear:");
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation == UIInterfaceOrientationPortrait
	   || orientation == UIInterfaceOrientationPortraitUpsideDown)
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

- (BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#if 0
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#endif

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


- (void)dealloc {
	[_submitBtnItem release];
    //[_contentView release];
    //[_scrollView release];
    [super dealloc];
}


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
    [self presentViewController:webSite animated:YES completion:^{}];
	[webSite release];
}


@end
