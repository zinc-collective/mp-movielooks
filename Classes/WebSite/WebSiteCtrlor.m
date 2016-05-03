//
//  WebSiteCtrlor.m
//
//  Created by Radar on 10-5-4.
//  Copyright 2009 Radar. All rights reserved.
//

#import "WebSiteCtrlor.h"


//iphone
#define web_view_frame_portrait_show_toolbar			CGRectMake(0.0, 44.0, 320.0, 372.0)
#define web_view_frame_landscap_show_toolbar			CGRectMake(0.0, 44.0, 480.0, 212.0)
#define web_view_frame_portrait_no_toolbar				CGRectMake(0.0, 44.0, 320.0, 416.0)
#define web_view_frame_landscap_no_toolbar				CGRectMake(0.0, 44.0, 480.0, 256.0)

#define web_view_frame_portrait_show_toolbar_nostatus	CGRectMake(0.0, 44.0, 320.0, 392.0)
#define web_view_frame_landscap_show_toolbar_nostatus	CGRectMake(0.0, 44.0, 480.0, 232.0)
#define web_view_frame_portrait_no_toolbar_nostatus		CGRectMake(0.0, 44.0, 320.0, 436.0)
#define web_view_frame_landscap_no_toolbar_nostatus		CGRectMake(0.0, 44.0, 480.0, 276.0)

//ipad
#define web_view_frame_portrait_show_toolbar_ipad				CGRectMake(0.0, 44.0, 768.0,  916.0)
#define web_view_frame_landscap_show_toolbar_ipad				CGRectMake(0.0, 44.0, 1024.0, 660.0)
#define web_view_frame_portrait_no_toolbar_ipad					CGRectMake(0.0, 44.0, 768.0,  960.0)
#define web_view_frame_landscap_no_toolbar_ipad					CGRectMake(0.0, 44.0, 1024.0, 704.0)

#define web_view_frame_portrait_show_toolbar_nostatus_ipad		CGRectMake(0.0, 44.0, 768.0,  936.0)
#define web_view_frame_landscap_show_toolbar_nostatus_ipad		CGRectMake(0.0, 44.0, 1024.0, 680.0)
#define web_view_frame_portrait_no_toolbar_nostatus_ipad		CGRectMake(0.0, 44.0, 768.0,  980.0)
#define web_view_frame_landscap_no_toolbar_nostatus_ipad		CGRectMake(0.0, 44.0, 1024.0, 724.0)



@implementation WebSiteCtrlor

@synthesize delegate=_delegate;
@synthesize _webSiteURL;
@synthesize _navTitle;
@synthesize navBar;
@synthesize navItem;
@synthesize toolBar;
@synthesize doneBtn;
@synthesize refreshBtn;
@synthesize backBtn;
@synthesize forwardBtn;
@synthesize safariBtn;
@synthesize navBarTintColor;
@synthesize toolBarTintColor;
@synthesize bShowToolBar;
@synthesize bShowStatusBar;


#pragma mark -
#pragma mark system functions
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		bShowToolBar = YES;
		bShowStatusBar = YES;
	}
	return self;
}

- (void)viewDidLoad 
{	
	[self.navBar setTintColor:self.navBarTintColor];
	self.navItem.title = _navTitle;
	[self.toolBar setTintColor:self.toolBarTintColor]; 
	
	
	//got webview's frame
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)  //iPhone & iPod touch
	{
		if(bShowStatusBar)
		{
			if(bShowToolBar)
			{
				_webFramePortrait = web_view_frame_portrait_show_toolbar;
				_webFrameLandscap = web_view_frame_landscap_show_toolbar;
			}
			else
			{
				_webFramePortrait = web_view_frame_portrait_no_toolbar;
				_webFrameLandscap = web_view_frame_landscap_no_toolbar;
			}
		}
		else
		{
			if(bShowToolBar)
			{
				_webFramePortrait = web_view_frame_portrait_show_toolbar_nostatus;
				_webFrameLandscap = web_view_frame_landscap_show_toolbar_nostatus;
			}
			else
			{
				_webFramePortrait = web_view_frame_portrait_no_toolbar_nostatus;
				_webFrameLandscap = web_view_frame_landscap_no_toolbar_nostatus;
			}
		}
	}
	else //iPad
	{
		if(bShowStatusBar)
		{
			if(bShowToolBar)
			{
				_webFramePortrait = web_view_frame_portrait_show_toolbar_ipad;
				_webFrameLandscap = web_view_frame_landscap_show_toolbar_ipad;
			}
			else
			{
				_webFramePortrait = web_view_frame_portrait_no_toolbar_ipad;
				_webFrameLandscap = web_view_frame_landscap_no_toolbar_ipad;
			}
		}
		else
		{
			if(bShowToolBar)
			{
				_webFramePortrait = web_view_frame_portrait_show_toolbar_nostatus_ipad;
				_webFrameLandscap = web_view_frame_landscap_show_toolbar_nostatus_ipad;
			}
			else
			{
				_webFramePortrait = web_view_frame_portrait_no_toolbar_nostatus_ipad;
				_webFrameLandscap = web_view_frame_landscap_no_toolbar_nostatus_ipad;
			}
		}
	}


	
	
	//add webview
	if(_webView == nil)
	{
		_webView = [[RWebView alloc] initWithFrame:_webFramePortrait];
		[_webView setDelegate:self];
	}
	
	if(self.statusBarOrientation == UIInterfaceOrientationPortrait || self.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[_webView changeFrameByRect:_webFramePortrait];
	}
	else
	{
		[_webView changeFrameByRect:_webFrameLandscap];
	}

	[self.view insertSubview:_webView atIndex:0];
	
	
	//check if add top done btn
	if(!bShowToolBar)
	{
		//add topDone button
		UIBarButtonItem *topDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction:)];
		self.navItem.leftBarButtonItem = topDoneBtn;
		[topDoneBtn release];
		
		//hide toolbar
		self.toolBar.hidden = YES;
	}
	
	
	[super viewDidLoad];
}

-(UIInterfaceOrientation)statusBarOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)viewWillAppear:(BOOL)animated
{
	//shwo website
	[self showWebSite];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	
	if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[_webView changeFrameByRect:_webFramePortrait];
	}
	else
	{
		[_webView changeFrameByRect:_webFrameLandscap];
	}
	
	return YES;
}

- (void)dealloc
{
	[navBar release];
	[navItem release];
	[toolBar release];
	[doneBtn release];
	[refreshBtn release];
	[backBtn release];
	[forwardBtn release];
	[safariBtn release];
	
	[_navTitle release];
	[_webSiteURL release];
	[_webView release];
	
	[navBarTintColor release];
	[toolBarTintColor release];
	
	[super dealloc];
}




#pragma mark -
#pragma mark out use
-(void)setCtrlorWithURL:(NSString*)webURL forTitle:(NSString*)titleStr
{
	//check if http:// make the _webSiteURL must have http:// words
	NSRange rangehttp  = [webURL rangeOfString:@"http://"];
	NSRange rangehttps = [webURL rangeOfString:@"https://"];
	if(rangehttp.length == 0 && rangehttps.length == 0) 
	{
		self._webSiteURL =  [NSString stringWithFormat:@"http://%@", webURL];
	}
	else
	{
		self._webSiteURL = webURL;
	}
	
	if(titleStr == nil)
	{
		self._navTitle = @"";
	}
	else
	{
		self._navTitle  = titleStr;
	}
}




#pragma mark -
#pragma mark in use
-(void)showWebSite
{
	if(_webSiteURL == nil || [_webSiteURL compare:@""] == NSOrderedSame) return;
	[_webView showWebforURL:_webSiteURL];
}
-(IBAction)doneBtnAction:(id)sender
{
	[_webView closeWeb];
	
	if (![[self modalViewController] isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
	}
	
	//return to delegate
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(webSiteCtrlorDidDismissed)])
	{
		[self.delegate webSiteCtrlorDidDismissed];
	}
}
-(IBAction)refreshBtnAction:(id)sender
{
	[_webView webRefresh];
}
-(IBAction)backBtnAction:(id)sender
{
	[_webView webGoBack];
}
-(IBAction)forwardBtnAction:(id)sender
{
	[_webView webGoForward];
}
-(IBAction)safariBtnAction:(id)sender
{
	if(_webSiteURL == nil || [_webSiteURL compare:@""] == NSOrderedSame) return;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_webSiteURL]];
}





#pragma mark -
#pragma mark delegate
//RWebView
-(void)loadStateOfGoBack:(BOOL)canGoback andGoForward:(BOOL)canGoForward
{
	self.backBtn.enabled = canGoback;
	self.forwardBtn.enabled = canGoForward;
}




@end
