//
//  WebSiteCtrlor.h
//
//  Created by Radar on 10-5-4.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
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
	id __weak _delegate;
}
@property (weak) id<WebSiteCtrlorDelegate> delegate;


@property (nonatomic, strong) NSString *_webSiteURL;
@property (nonatomic, strong) NSString *_navTitle;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@property (nonatomic, strong) UIBarButtonItem *refreshBtn;
@property (nonatomic, strong) UIBarButtonItem *backBtn;
@property (nonatomic, strong) UIBarButtonItem *forwardBtn;
@property (nonatomic, strong) UIBarButtonItem *safariBtn;

@property (nonatomic, strong) UIColor *navBarTintColor;
@property (nonatomic, strong) UIColor *toolBarTintColor;
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
