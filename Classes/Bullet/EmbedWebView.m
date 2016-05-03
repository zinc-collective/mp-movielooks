//
//  EmbedWebView.m
//  MobileLooks
//
//  Created by jack on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EmbedWebView.h"


@implementation EmbedWebView
@synthesize url_;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		bLoading = NO;
		
		UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 63.0)];//126/2
		header.image = [UIImage imageNamed:@"bulleting_header.png"];
		[self addSubview:header];
		[header release];
		
		mTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		mTitle.backgroundColor = [UIColor clearColor];
		mTitle.textColor = [UIColor whiteColor];
		mTitle.font = [UIFont boldSystemFontOfSize:14];
		mTitle.textAlignment = UITextAlignmentCenter;
		[self addSubview:mTitle];
		
		mSearchField = [[UITextField alloc] initWithFrame:CGRectMake(70, 25, frame.size.width-80, 30)];
		mSearchField.backgroundColor = [UIColor clearColor];
		mSearchField.borderStyle = UITextBorderStyleRoundedRect;
		mSearchField.clearButtonMode = UITextFieldViewModeWhileEditing;
		mSearchField.returnKeyType = UIReturnKeyGo;
		mSearchField.keyboardType = UIKeyboardTypeURL;
		mSearchField.font = [UIFont systemFontOfSize:18];
		mSearchField.delegate = self;
		[self addSubview:mSearchField];
		
		float x = 5;
		
		UIButton *forward = [UIButton buttonWithType:UIButtonTypeCustom];
		forward.frame = CGRectMake(x, 25, 26, 30);
		[forward setBackgroundImage:[UIImage imageNamed:@"bullet_prev_page.png"] forState:UIControlStateNormal];
		[forward addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
		//[forward setTitle:@">" forState:UIControlStateNormal];
		[self addSubview:forward];
		
		UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
		back.frame = CGRectMake(x+36, 26, 26, 29);
		[back setBackgroundImage:[UIImage imageNamed:@"bullet_next_page.png"] forState:UIControlStateNormal];
		[back addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
		//[back setTitle:@"<" forState:UIControlStateNormal];
		[self addSubview:back];
		
		
		
		/*
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(textFieldDidChaned:) 
													 name:UITextFieldTextDidChangeNotification 
												   object:nil];
		 */
		
		browser_ = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 63.0, frame.size.width, frame.size.height-63)];
		browser_.delegate = self;
		browser_.scalesPageToFit = YES;
		browser_.userInteractionEnabled = YES;
		browser_.autoresizingMask = 
		UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		
		
		[self addSubview:browser_];
		
		mSearchField.text = @"http://www.google.com";
		[self openUrl:@"http://www.google.com"];
    }
    return self;
}

- (void) openUrl:(NSString*)uri{
	//self.title = uri;
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[browser_ stopLoading];
	[browser_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uri]]];
	self.url_ = uri;
}

- (void) reLoad{
	if(self.url_){
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
		[browser_ stopLoading];
		[browser_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url_]]];
	}
}

- (void) backAction:(id)sender{
	[self goForward];
}

- (void) forwardAction:(id)sender{
	[self goBack];
}

- (void)goBack{
	[browser_ goBack];

}
- (void)goForward{
	[browser_ goForward];
}

#pragma mark UITextField delegate
#pragma mark UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	
	if(!textField.text || [textField.text isEqualToString:@""])return YES;
	
	NSString *url = textField.text;
	
	NSRange range = [url rangeOfString:@"http"];
	if(range.location == NSNotFound){
		
		url = [NSString stringWithFormat:@"http://%@", url];
		
	}
	
	textField.text = url;
	
	[self openUrl:url];
	
	return YES;
}

- (void)textFieldDidChaned:(id)sender{
	
	if(sender != mSearchField)return;
	
	if(mSearchField){
		NSLog(@"%@", mSearchField.text);
		
		if(![mSearchField.text isEqualToString:@""]){
			
			
		}
		else {
			
		}
		
		
	}
	
}


#pragma mark webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {

	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	bLoading = YES;
	//[self performSelectorOnMainThread:@selector(showSpin) withObject:nil waitUntilDone:NO];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[self performSelectorOnMainThread:@selector(hideSpin) withObject:nil waitUntilDone:NO];
	bLoading = NO;
	
	mTitle.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	mSearchField.text = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
	//NSLog(@"%@", title);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[self performSelectorOnMainThread:@selector(hideSpin) withObject:nil waitUntilDone:NO];
	bLoading = NO;
	
	if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) && [error code] != -999) {
		UIAlertView* alert =[[UIAlertView alloc] initWithTitle:@"" 
													   message:[error localizedDescription] 
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(NSLocalizedString(@"OK",nil), nil) 
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[mSearchField release];
	[url_ release];
	[browser_ release];
    [super dealloc];
}


@end
