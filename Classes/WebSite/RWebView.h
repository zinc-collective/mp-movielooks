//
//  RWebView.h
//
//  Created by Radar on 09-9-21.
//  Copyright 2009 Radar. All rights reserved.
//

#import <Foundation/Foundation.h>



@class RWebView;
@protocol RWebViewDelegate <NSObject>
@optional
-(void)loadStateOfGoBack:(BOOL)canGoback andGoForward:(BOOL)canGoForward;
@end


@interface RWebView : UIView <UIWebViewDelegate> {
	UIActivityIndicatorView *_waitSpinner;
	UIWebView *_webView;
	NSString *webShowURL;
	
@private
	id __weak _delegate;	
}

@property (nonatomic, strong) NSString *webShowURL;
@property (weak) id<RWebViewDelegate> delegate;


#pragma mark -
#pragma mark out use functions
-(void)showWebforURL:(NSString*)webURL;
-(void)webGoBack;
-(void)webGoForward;
-(void)webRefresh;
-(void)changeFrameByRect:(CGRect)newframe;
-(void)closeWeb;


#pragma mark -
#pragma mark in use functions
-(void)StartWaitWeb;
-(void)StopWaitWeb;
-(void)clearWebContent;


@end
