//
//  WebSiteCtrlor.h
//
//  Created by Radar on 10-5-4.
//  Copyright 2009 Radar. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RWebView.h"


@class WebSiteCtrlor;
@protocol WebSiteCtrlorDelegate <NSObject>
@optional
-(void)webSiteCtrlorDidDismissed;
@end


@interface WebSiteCtrlor : UIViewController <RWebViewDelegate> {

	NSString *_webSiteURL;
	NSString *_navTitle;
	RWebView *_webView;
	CGRect _webFramePortrait;
	CGRect _webFrameLandscap;
	
	IBOutlet UINavigationBar *navBar;
	IBOutlet UINavigationItem *navItem;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *doneBtn;
	IBOutlet UIBarButtonItem *refreshBtn;
	IBOutlet UIBarButtonItem *backBtn;
	IBOutlet UIBarButtonItem *forwardBtn;
	IBOutlet UIBarButtonItem *safariBtn;
	
	
#pragma mark -
#pragma mark for out set parameters
	UIColor *navBarTintColor;    //navigation bar tint color
	UIColor *toolBarTintColor;   //tool bar tint color
	BOOL     bShowToolBar;       //if YES, will show toolbar and hide top Done button, default is YES.
	BOOL     bShowStatusBar;     //if YES, will show statusbar, default is YES.
	
	
@private
	id _delegate;	
}
@property (assign) id<WebSiteCtrlorDelegate> delegate;


@property (nonatomic, retain) NSString *_webSiteURL;
@property (nonatomic, retain) NSString *_navTitle;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UINavigationItem *navItem;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UIBarButtonItem *doneBtn;
@property (nonatomic, retain) UIBarButtonItem *refreshBtn;
@property (nonatomic, retain) UIBarButtonItem *backBtn;
@property (nonatomic, retain) UIBarButtonItem *forwardBtn;
@property (nonatomic, retain) UIBarButtonItem *safariBtn;

@property (nonatomic, retain) UIColor *navBarTintColor;
@property (nonatomic, retain) UIColor *toolBarTintColor;
@property (nonatomic)         BOOL     bShowToolBar;
@property (nonatomic)         BOOL     bShowStatusBar;



#pragma mark -
#pragma mark out use
-(void)setCtrlorWithURL:(NSString*)webURL forTitle:(NSString*)titleStr;



#pragma mark -
#pragma mark in use
-(void)showWebSite;
-(IBAction)doneBtnAction:(id)sender;
-(IBAction)refreshBtnAction:(id)sender;
-(IBAction)backBtnAction:(id)sender;
-(IBAction)forwardBtnAction:(id)sender;
-(IBAction)safariBtnAction:(id)sender;



@end
