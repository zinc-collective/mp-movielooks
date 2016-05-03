//
//  RWebView.m
//
//  Created by Radar on 09-9-21.
//  Copyright 2009 Radar. All rights reserved.
//

#import "RWebView.h"



@implementation RWebView

@synthesize delegate=_delegate;
@synthesize webShowURL;

#pragma mark -
#pragma mark system functions
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code		
		
		self.backgroundColor = [UIColor blackColor];
		
		//add UIWebView
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_webView.backgroundColor = [UIColor blackColor];
		_webView.scalesPageToFit = YES;
		[_webView setDelegate:self];
		[self addSubview:_webView];
		
		//add spinner
		_waitSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_waitSpinner.hidesWhenStopped = YES;
		_waitSpinner.frame = CGRectMake((frame.size.width-25.0)/2, (frame.size.height-25.0)/2, 25.0, 25.0);
		[self addSubview:_waitSpinner];
		
    }
    return self;
}




#pragma mark -
#pragma mark out use functions
-(void)showWebforURL:(NSString*)webURL
{
	if(webURL != nil && [webURL compare:@""] != NSOrderedSame)
	{			
		self.webShowURL = webURL;
		NSRange rangehttp  = [webURL rangeOfString:@"http://"];
		NSRange rangehttps = [webURL rangeOfString:@"https://"];
		if(rangehttp.length == 0 && rangehttps.length == 0) 
		{
			self.webShowURL =  [NSString stringWithFormat:@"http://%@", self.webShowURL];
		}
		
		if(_webView.loading)
		{
			[_webView stopLoading];
		}
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webShowURL]]];
	}
	
}
-(void)webGoBack
{
	if(_webView.canGoBack)
	{
		[_webView goBack];
	}
}
-(void)webGoForward
{
	if(_webView.canGoForward)
	{
		[_webView goForward];
	}
}
-(void)webRefresh
{
	[_webView stopLoading];
	[_webView reload];
}
-(void)changeFrameByRect:(CGRect)newframe
{
	self.frame = newframe;
	_webView.frame = CGRectMake(0.0, 0.0, newframe.size.width, newframe.size.height);
	_waitSpinner.frame = CGRectMake((newframe.size.width-25.0)/2, (newframe.size.height-25.0)/2, 25.0, 25.0);
}
-(void)closeWeb
{
	if(_webView.loading)
	{
		[_webView stopLoading];
		[_waitSpinner stopAnimating];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	[self clearWebContent];
}





#pragma mark -
#pragma mark in use functions
-(void)StartWaitWeb
{
	[_waitSpinner startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
-(void)StopWaitWeb
{
	[_waitSpinner stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)clearWebContent
{
	[_webView loadHTMLString:@"<html><head><META HTTP-EQUIV=\"pragma\" CONTENT=\"no-cache\"><META HTTP-EQUIV=\"Cache-Control\" CONTENT=\"no-cache, must-revalidate\"></head><body></body><html>" baseURL:nil];
}





#pragma mark -
#pragma mark web delegate functions
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if(navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(loadStateOfGoBack:andGoForward:)])
		{
			[self.delegate loadStateOfGoBack:YES andGoForward:NO];
		}
	}
	
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{	
	[self StartWaitWeb];
	
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(loadStateOfGoBack:andGoForward:)])
	{
		[self.delegate loadStateOfGoBack:_webView.canGoBack andGoForward:_webView.canGoForward];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self StopWaitWeb];
	
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(loadStateOfGoBack:andGoForward:)])
	{
		[self.delegate loadStateOfGoBack:_webView.canGoBack andGoForward:_webView.canGoForward];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{	
	[self StopWaitWeb];
}




- (void)dealloc {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if(_webView.loading)
	{
		[_webView stopLoading];
	}
	
	[webShowURL release];
	[_waitSpinner release];
	[_webView release];
	
    [super dealloc];
}



@end
