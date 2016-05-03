//
//  MobileLooksAppDelegate.h
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotiPusher.h" //消息发送通知相关内容(1/4)----PS: 这个地方不需要改动
BOOL TooHighForDevice(CGSize videoSize);
//@class HomeViewController;

@interface MobileLooksAppDelegate : NSObject <UIApplicationDelegate, NotiPusherDelegate>
{
    UIWindow					*window;
	UINavigationController		*viewController;
    UIView						*purchaseMaskView;
    UIActivityIndicatorView     *purchaseIndicatorView;
	
	CGSize	videoSize;
	double	videoDuration;
	
	UIView *_maskView;
	UIActivityIndicatorView *_spinner;
	
	BOOL debug;
}

-(void)startPurchaseMask;
-(void)endPurchaseMask;

@property (nonatomic) CGSize videoSize;
@property (nonatomic) double videoDuration;
@property (nonatomic) BOOL debug;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *viewController;
//bret @property (strong, nonatomic) UIAlertView *notificationAlert;

-(BOOL)checkIfWithinActiveDuration;

-(void)startLoadingNotificationWait;
-(void)stopLoadingNotificationWait;

@end

