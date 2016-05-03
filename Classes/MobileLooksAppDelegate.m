//
//  MobileLooksAppDelegate.m
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//bret hd
#import "MobileLooksAppDelegate.h"
#import "HomeViewController.h"
#import "MyStoreObserver.h"
#import "LooksBrowserViewController.h"
#import "WebSiteCtrlor.h"
#import "BulletViewController.h"
#import "InfoViewController.h"
#import "VersionWatermark.h"


#include <sys/sysctl.h>
BOOL TooHighForDevice(CGSize videoSize)
{
	// checks device memory to see if the device has enough memory to process HD video (~300MB)
	// returns YES if HD video memory is too high for this device
	
	size_t value = 0;
	size_t length = sizeof(value) ;
	int selection[2] = { CTL_HW, HW_PHYSMEM } ;
	sysctl(selection, 2, &value, &length, NULL, 0) ;
	
	int mbSize = (int)(value/1048576);
	BOOL retval = (mbSize < 300);
	NSLog(@"Memory Size %d MB, too high for device {%d}", (int)(value/1048576), retval);
	
	//return ((value/1048576<300) && videoSize.width==1280 && videoSize.height==720);
	//return ((value/1048576<300) && videoSize.width==1920 && videoSize.height==1080);
	//return ((value/1048576<300));
	return retval;
}


@interface UIWindow (PBRedsafi)

- (void)layoutSubviews;

@end

@implementation UIWindow (PBRedsafi)

- (void)layoutSubviews{
	
#ifdef __APPVERSION__
	UIView *view = [self viewWithTag:1000];
	[self bringSubviewToFront:view];
#endif
}

@end


@implementation MobileLooksAppDelegate

@synthesize videoSize, videoDuration;

//for storyboard
//@synthesize window;
@synthesize window = _window;
@synthesize viewController;
@synthesize debug;
//@synthesize notificationAlert = _notificationAlert; //bret

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

	purchaseMaskView.center = window.center;
	if(UIDeviceOrientationIsLandscape(orientation))
	{
		purchaseIndicatorView.center=CGPointMake(1024/2, 1024/2);
	}
	else 
	{
		purchaseIndicatorView.center=CGPointMake(1024/2, 1024/2);
	}
		
	//change the frame of mask
//	if(_maskView != nil && _spinner != nil)
//	{
//		CGRect maskRect;
//		CGRect spinnerRect;
//		if(UIDeviceOrientationIsLandscape(orientation))
//		{
//			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//			{
//				maskRect = CGRectMake(0, 0, 1024, 768);
//			}
//			else
//			{
//				maskRect = CGRectMake(0, 0, 480, 320);
//			}
//		}
//		else 
//		{
//			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//			{
//				maskRect = CGRectMake(0, 0, 768, 1024);
//			}
//			else
//			{
//				maskRect = CGRectMake(0, 0, 320, 480);
//			}
//		}
//		spinnerRect = CGRectMake((maskRect.size.width-25)/2, (maskRect.size.height-25)/2, 25, 25);
//	
//		_maskView.frame = maskRect;
//		_spinner.frame = spinnerRect;
//	}
	
}

-(void)updatePurchaseWithLooks:(NSArray *)newVersionLooks
{
	NSArray *userDefaultLooks = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserLooks];
	NSMutableArray *mutableLooks = [NSMutableArray arrayWithCapacity:[userDefaultLooks count]];
	NSUInteger maxLooksCount = fmax([newVersionLooks count],[userDefaultLooks count]);		
	for (NSUInteger index = 0; index < maxLooksCount; ++index)
	{
		NSDictionary* newVersionDic = [newVersionLooks objectAtIndex:index];
		NSDictionary* userDefaultDic = [userDefaultLooks objectAtIndex:index];
		
		BOOL newVersionIsLocked = [[newVersionDic objectForKey:kProductLocked] boolValue];
		if(newVersionIsLocked)
			[mutableLooks addObject:userDefaultDic];
		else
			[mutableLooks addObject:newVersionDic];
	}
	[[NSUserDefaults standardUserDefaults] setObject:mutableLooks forKey:kUserLooks];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

#pragma mark -
#pragma mark In App Purchase

- (void) initInAppPurchase
{
	//#ifndef TARGET_IPHONE_SIMULATOR
	MyStoreObserver *observer = [[MyStoreObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
	// NSLog(@"PaymentQueue init successs.");
	//[observer release];
	//#endif
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSArray *looks = [prefs arrayForKey:kUserLooks];
	if (looks == nil)
	{
		looks = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"looks" withExtension:@"plist"]];
		[prefs setObject:looks forKey:kUserLooks];
		[prefs synchronize];
	}
	else {
		NSArray* plistLooks = [NSMutableArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"looks" withExtension:@"plist"]];
		[self updatePurchaseWithLooks:plistLooks];
	}

}

#pragma mark -
#pragma mark Application lifecycle

void onUncaughtExceptionHandler(NSException *exception)
{
	NSLog(@"uncaught exception: %@", [exception description]);
	NSLog(@"\n\nstacks :\n\n %@", [exception callStackReturnAddresses]);
    NSLog(@"\n\nsymbols :\n\n %@", [exception callStackSymbols]);
	
	int dummy = 0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
	
	NSSetUncaughtExceptionHandler(&onUncaughtExceptionHandler);
	
    //bret notification while in background
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (notification)
    {
        [self showAlarm:notification.alertBody];
        NSLog(@"AppDelegate didFinishLaunchingWithOptions");
        application.applicationIconBadgeNumber = 0;
    }

#if 0 //storyboard
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	HomeViewController *homeViewController = [[HomeViewController alloc] init];
	viewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
	[homeViewController release];
#endif
    viewController = (UINavigationController *)self.window.rootViewController;
	//UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	//UINavigationController *navigationController =[[tabBarController viewControllers] objectAtIndex:0];

    purchaseMaskView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	purchaseMaskView.backgroundColor = [UIColor blackColor];
    purchaseIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(110, 225, 30, 30)];
    [purchaseMaskView addSubview:purchaseIndicatorView];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
		purchaseMaskView.frame = CGRectMake(0, 0, 1024, 1024);
		[self deviceOrientationDidChange:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange:)
													 name:@"UIDeviceOrientationDidChangeNotification"
												   object:nil];
	} else {
		[self deviceOrientationDidChange:nil];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(deviceOrientationDidChange:)
												     name: @"UIDeviceOrientationDidChangeNotification"
												   object: nil];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];		
	}
	

//Test
#if TEST_NOTIFICATION
	[[NSUserDefaults standardUserDefaults] setObject:@"2011-05-1 00:00:00" forKey:push_noti_active_time_from];
	[[NSUserDefaults standardUserDefaults] setObject:@"2011-06-1 00:00:00" forKey:push_noti_active_time_to];
	[[NSUserDefaults standardUserDefaults] setObject:@"213014392056177" forKey:push_noti_facebook_page_id];
	[[NSUserDefaults standardUserDefaults] setObject:@"http://www.facebook.com/pages/MovieTest/213014392056177?v=wall" forKey:push_noti_facebook_page_url];
#endif

	
#if 0
	// Debug Only! - Used for including test videos in simulator/iphone gallery!
	// NSString *videoPath = [Utilities bundlePath:@"IMG_0646.mov"];
    // NSString *videoPath = [Utilities bundlePath:@"sample_iPod.m4v"];
	NSString *videoPath = [Utilities bundlePath:@"iphone_sample_sophie_sunshine_time_dance_3-22-2013.m4v"];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
		UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
#endif	
    
#if 0
	NSString *videoPath = [Utilities bundlePath:@"IMG_0646.mov"];
	
	
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	
	if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]]) {
		
		[assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] 
										  completionBlock:^(NSURL *assetURL, NSError *error){
											  dispatch_async(dispatch_get_main_queue(), ^{
												  if (error) {
													  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																										  message:[error localizedRecoverySuggestion]
																										 delegate:nil
																								cancelButtonTitle:NSLocalizedString(@"OK",nil)
																								otherButtonTitles:nil];
													  [alertView show];
													  [alertView release];
												  }
											  });
											  
										  }];
	}
	[assetsLibrary release];
#endif
	
#ifdef __APPVERSION__
	VersionWatermark *watermark = [[VersionWatermark alloc] initWithFrame:CGRectMake(0.0, 20.0, window.bounds.size.width, 30.0)];
	watermark.tag = 1000;
	[watermark showInView:window];
	[watermark release];
#endif
	
	
	// Changed for IOS6 support
	// http://grembe.wordpress.com/2012/09/19/here-is-what-i/
    // [window addSubview:viewController.view];
	//bret: these are probably redundant under storyboard
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
		
	// In App Purchase
	[self initInAppPurchase];
	//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	//    [prefs setBool:NO forKey:@"NeglectHint"];
	//    [prefs synchronize];
	
	
	
	
	//消息发送通知相关内容(2/4) + ---------------------PS: 这个地方不需要改动
	//设置notipusher的代理
	[NotiPusher sharedNotiPusher].delegate = self;
	
	//check if have registed
	NSNumber *registeOK = [[NSUserDefaults standardUserDefaults] objectForKey:@"_registOK"];
	if([registeOK boolValue]) 
	{
#ifdef macro_use_rich_push_mode
		[NotiPusher sharedNotiPusher].userID   = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
		[NotiPusher sharedNotiPusher].password = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
		if([NotiPusher sharedNotiPusher].userID == nil)
		{
			[[NotiPusher sharedNotiPusher] richCreateUser];	
		}
		else
		{
			//如果bandgenumber不是0，那么肯定已经注册过devide token 和 user了，所以可以直接读取最新的消息
			if([UIApplication sharedApplication].applicationIconBadgeNumber != 0)
			{
				NSLog(@"程序初始化, 读取最新的message >>");
				[[NotiPusher sharedNotiPusher] getNewestMessage];
			}
		}
		
#endif
	}
	else
	{
		//Register for notifications
		[[UIApplication sharedApplication]
		 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
											 UIRemoteNotificationTypeSound |
											 UIRemoteNotificationTypeAlert)];
		
		// Reset badge number to 0
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
	//消息发送通知相关内容 - ---------------------------------------------
	
	
    return YES;
}

-(void)startPurchaseMask
{
	[window addSubview:purchaseMaskView];
	purchaseMaskView.center = window.center;
	[purchaseMaskView setAlpha:0.0f];
	[UIView animateWithDuration:1.50 delay:0 
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [purchaseMaskView setAlpha:0.6f];
					 }
					 completion:^(BOOL finished){
					 }
	 ];	
    [purchaseIndicatorView startAnimating];    
}

- (void)showNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
}

- (void)hiddenNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = NO;
}


-(void)endPurchaseMask
{
	[purchaseMaskView setAlpha:0.6f];
	[UIView animateWithDuration:1.50 delay:0 
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [purchaseMaskView setAlpha:0.6f];
					 }
					 completion:^(BOOL finished){
						 [purchaseMaskView removeFromSuperview];
					 }
	 ];	
    [purchaseIndicatorView stopAnimating];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (error.code != 0x00000000) {
		NSLog(@"Error: %@", [error localizedDescription]);
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"WillResignActive");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignActivePause" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"DidEnterBackground");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MultiTaskPause" object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	NSLog(@"WillEnterForeground");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MultiTaskResume" object:nil];
	
	
	//消息发送通知相关内容---------------------------------
	//check if have registed
	NSNumber *registeOK = [[NSUserDefaults standardUserDefaults] objectForKey:@"_registOK"];
	if([registeOK boolValue]) 
	{
#ifdef macro_use_rich_push_mode
		[NotiPusher sharedNotiPusher].userID   = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
		[NotiPusher sharedNotiPusher].password = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
		if([NotiPusher sharedNotiPusher].userID == nil)
		{
			[[NotiPusher sharedNotiPusher] richCreateUser];	
		}
		else
		{
			//如果bandgenumber不是0，那么肯定已经注册过devide token 和 user了，所以可以直接读取最新的消息
			if([UIApplication sharedApplication].applicationIconBadgeNumber != 0)
			{
				NSLog(@"从后台进入前台, 读取最新的message >>");
				[self startLoadingNotificationWait];
				[[NotiPusher sharedNotiPusher] getNewestMessage];
			}
		}
#endif
	}
	else
	{
		//Register for notifications
		[[UIApplication sharedApplication]
		 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
											 UIRemoteNotificationTypeSound |
											 UIRemoteNotificationTypeAlert)];
		
		// Reset badge number to 0
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
	//------------------------------------------------
	
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	// NSLog(@"DidBecomeActive");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BecomeActiveResume" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	
    [purchaseIndicatorView removeFromSuperview];
    [purchaseIndicatorView release];
	[purchaseMaskView release];
    [viewController release];
	[_maskView release];
	[_spinner release];
	[window release];
    [super dealloc];
}



//消息发送通知相关内容(3/4) + ----------------------PS: 这个地方需要根据实际情况进行改动
//这个函数用来处理接收到了消息以后，点击查看按钮以后的事件，或者就在程序开启状态下接收到消息的事件
#pragma mark -
#pragma mark notifications 处理相关
- (void)receiveNotificationAction:(NSDictionary *)notiInfo
{    
	
	//如果使用rich push方式，
#ifdef macro_use_rich_push_mode
	//这个地方写使用rich push方式应该做的操作 
	NSLog(@"读取最新的message >>");
	[[NotiPusher sharedNotiPusher] getNewestMessage];
	return;
#endif
	
	//如果使用标准方式push
	//这个地方去写使用nomal push方式应该做的操作
	//......
	
}
//消息发送通知相关内容 - ---------------------------------------------------------


//消息发送通知相关内容(4/4) + ---------------------PS: 这个地方不需要改动
#pragma mark -
#pragma mark notifications 注册相关

//bret notification
- (void)showAlarm:(NSString *)text
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alarm"
                                                        message:text delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}
#if 0
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // show an alert only if the application is active, to avoid doubly notifiying the user.
    if ([application applicationState] == UIApplicationStateActive)
    {
        // Initialize the alert view.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        if (!_notificationAlert)
        {
            [self setNotificationAlert:alert];
        }
        
        // Set the title of the alert with the notification's body.
        [_notificationAlert setTitle:[notification alertBody]];
        [alert show];
    }
}
#endif
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self showAlarm:notification.alertBody];
    application.applicationIconBadgeNumber = 0;
    NSLog(@"AppDelegate didReceiveLocalNotification %@", notification.userInfo);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    
	//got device alias
    [NotiPusher sharedNotiPusher].deviceAlias = [[NSUserDefaults standardUserDefaults] stringForKey: @"_UADeviceAliasKey"];
	NSLog(@"Device Alias: %@", [NotiPusher sharedNotiPusher].deviceAlias);
	
	// Get a hex string from the device token with no spaces or < >
    [NotiPusher sharedNotiPusher].deviceToken = [[[[_deviceToken description]
												   stringByReplacingOccurrencesOfString: @"<" withString: @""] 
												  stringByReplacingOccurrencesOfString: @">" withString: @""] 
												 stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSLog(@"Device Token: %@", [NotiPusher sharedNotiPusher].deviceToken);
	
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		NSLog(@"Notifications are disabled for this application. Not registering with Urban Airship");
		return;
	}
	
	
	//check if have registed
	NSNumber *registeOK = [[NSUserDefaults standardUserDefaults] objectForKey:@"_registOK"];
	if([registeOK boolValue]) 
	{
#ifdef macro_use_rich_push_mode
		[NotiPusher sharedNotiPusher].userID   = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
		[NotiPusher sharedNotiPusher].password = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
		if([NotiPusher sharedNotiPusher].userID == nil)
		{
			[[NotiPusher sharedNotiPusher] richCreateUser];	
		}
#endif
		return;
	}
	
	
	NSLog(@">>开始注册设备...");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//rigister the device to the arban sever
    NSString *UAServer = @"https://go.urbanairship.com";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", [NotiPusher sharedNotiPusher].deviceToken];
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    // Send along our device alias as the JSON encoded request body
    if([NotiPusher sharedNotiPusher].deviceAlias != nil && [[NotiPusher sharedNotiPusher].deviceAlias length] > 0) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", [NotiPusher sharedNotiPusher].deviceAlias]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    }
	
	
    // Authenticate to the server
    [request addValue:[NSString stringWithFormat:@"Basic %@",
                       [[NotiPusher sharedNotiPusher] base64forData:[[NSString stringWithFormat:@"%@:%@",
																	  kApplicationKey,
																	  kApplicationSecret] dataUsingEncoding: NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"Failed to register with error: %@", error);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse %@, %d", [(NSHTTPURLResponse *)response allHeaderFields],
          [(NSHTTPURLResponse *)response statusCode]);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: [NotiPusher sharedNotiPusher].deviceToken forKey: @"_UALastDeviceToken"];
    [userDefaults setValue: [NotiPusher sharedNotiPusher].deviceAlias forKey: @"_UALastAlias"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if([(NSHTTPURLResponse *)response statusCode] == 200)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"_registOK"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"<<注册设备完成");
	
#ifdef macro_use_rich_push_mode //这个宏在NotiPusher类的头文件里定义的，如果要使用rich就打开，如果使用普通push，就注释掉该宏
	[NotiPusher sharedNotiPusher].userID   = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
	[NotiPusher sharedNotiPusher].password = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
	if([NotiPusher sharedNotiPusher].userID == nil)
	{
		[[NotiPusher sharedNotiPusher] richCreateUser];	
	}
#endif
	
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle:
                              @"Network error" message: @"Error registering with server"
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles: nil];
    [someError show];
    [someError release];
    //NSLog(@"ERROR: NSError query result: %@", error);
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//NSLog(@"<<注册设备失败");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
	//handle the notification infomation
	[self receiveNotificationAction:userInfo];
}

//消息发送通知相关内容 - ---------------------------------------------




//@Radar
//NotiPusherDelegate
-(void)notiPusherDidLoadNewestUnreadMessage:(RUAMessage*)message
{
	//stop loading
	[self stopLoadingNotificationWait];
	
	//读取最新消息完毕，mark 所有unread消息为read
	NSLog(@"最新消息读取完毕, 把所有unread变为read");
	[[NotiPusher sharedNotiPusher] markAllUnreadMessagesAsRead];
	
	
	if(message == nil) return;
	NSLog(@"得到的content内容是 : %@", message.content);
	if(message.content == nil || [message.content compare:@""] == NSOrderedSame) return;
	
	//把得到的conntent内容存到userdefault里面
	NSDictionary *contentDic = (NSDictionary*)[message.content JSONValue];
	if(contentDic == nil || [contentDic count] == 0) return;
	
	NSString *active_link_url	= [contentDic objectForKey:@"active_link_url"];
	NSString *active_link_title = @"MovieLooks"; //[contentDic objectForKey:@"active_link_title"];
	NSString *active_time_from	= [contentDic objectForKey:@"active_time_from"];
	NSString *active_time_to    = [contentDic objectForKey:@"active_time_to"];
	NSString *facebook_page_id = [contentDic objectForKey:@"facebook_page_id"];
	NSString *facebook_page_url = [contentDic objectForKey:@"facebook_page_url"];
	
	if(!active_link_url || !active_time_from || !active_time_to || !active_link_url) return;
	
	//把配置信息保存在本地
	[[NSUserDefaults standardUserDefaults] setObject:active_link_url forKey:push_noti_active_link_url];
	[[NSUserDefaults standardUserDefaults] setObject:active_link_title forKey:push_noti_active_link_title];
	[[NSUserDefaults standardUserDefaults] setObject:active_time_from forKey:push_noti_active_time_from];
	[[NSUserDefaults standardUserDefaults] setObject:active_time_to forKey:push_noti_active_time_to];
	[[NSUserDefaults standardUserDefaults] setObject:facebook_page_id forKey:push_noti_facebook_page_id];
	[[NSUserDefaults standardUserDefaults] setObject:facebook_page_url forKey:push_noti_facebook_page_url];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
	//使用获取的配置信息，启动web页面展示活动内容
	UIViewController *topViewCtrlor = [viewController visibleViewController];

	//start website
	WebSiteCtrlor *webSite = [[WebSiteCtrlor alloc] initWithNibName:@"WebSiteCtrlor" bundle:nil];
	webSite.navBarTintColor = [UIColor blackColor];
	webSite.toolBarTintColor = [UIColor blackColor];
	//webSite.bShowToolBar = NO;
	webSite.bShowStatusBar = NO;
	[webSite setCtrlorWithURL:active_link_url forTitle:active_link_title];
	[topViewCtrlor presentModalViewController:webSite animated:YES];
	[webSite release];
	
	
	//使用获取的配置信息，触发一些隐藏功能显示出来
	//如果当前处于info页面或者bullet页面的时候，就把相关按钮显示出来
//	if([topViewCtrlor isKindOfClass:[BulletViewController class]])
//	{
//		BulletViewController *bviewCtrlor = (BulletViewController*)topViewCtrlor;
//		[bviewCtrlor showShareButton];
//	}
//	if([topViewCtrlor isKindOfClass:[InfoViewController class]])
//	{
//		InfoViewController *iviewCtrlor = (InfoViewController*)topViewCtrlor;
//		[iviewCtrlor showActiveButton];
//	}
	
	if([topViewCtrlor isKindOfClass:[HomeViewController class]])
	{
		HomeViewController *hviewCtrlor = (HomeViewController*)topViewCtrlor;
		[hviewCtrlor showNewsButton];
	}
}
-(void)notiPusherGetError
{
	//stop loading
	[self stopLoadingNotificationWait];
}

-(BOOL)checkIfWithinActiveDuration
{
	NSString *active_time_from = [[NSUserDefaults standardUserDefaults] objectForKey:push_noti_active_time_from];
	NSString *active_time_to   = [[NSUserDefaults standardUserDefaults] objectForKey:push_noti_active_time_to];
	
	if(active_time_from == nil || [active_time_from compare:@""] == NSOrderedSame ||
	   active_time_to == nil   || [active_time_to compare:@""] == NSOrderedSame)
	{
		return NO;
	}
	
	
	BOOL bWithin = NO;
	
	
	//make up open date
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	// set default time zone by device own zone.
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	
	// convert the time keep on 24-hour
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
	[formatter setLocale:usLocale];
	[usLocale release];
	
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *fromDate = [formatter dateFromString:active_time_from];
	NSDate *toDate = [formatter dateFromString:active_time_to];
	[formatter release];
	
	//compare time
	NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
	NSTimeInterval timeFrom = [fromDate timeIntervalSince1970];
	NSTimeInterval timeTo = [toDate timeIntervalSince1970];
	
	if(timeNow >= timeFrom && timeNow <= timeTo)
	{
		bWithin = YES;
	}
	else
	{
		bWithin = NO;
	}
	
	
	return bWithin;
}
-(void)startLoadingNotificationWait
{
	CGRect maskRect;
	CGRect spinnerRect;
	
//	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//	if(UIDeviceOrientationIsLandscape(orientation))
//	{
//		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//		{
//			maskRect = CGRectMake(0, 0, 1024, 768);
//		}
//		else
//		{
//			maskRect = CGRectMake(0, 0, 480, 320);
//		}
//
//	}
//	else 
//	{
//		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//		{
//			maskRect = CGRectMake(0, 0, 768, 1024);
//		}
//		else
//		{
//			maskRect = CGRectMake(0, 0, 320, 480);
//		}
//	}
	
	maskRect = CGRectMake(0, 0, 320, 480);
	spinnerRect = CGRectMake((maskRect.size.width-25)/2, (maskRect.size.height-25)/2, 25, 25);
	
	
	if(_maskView == nil)
	{
		_maskView = [[UIView alloc] initWithFrame:maskRect];
		_maskView.backgroundColor = [UIColor blackColor];
		_maskView.alpha = 0.5;
	}
	if(_spinner == nil)
	{
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_spinner.frame = spinnerRect;
	}
	
	[_spinner startAnimating];
	
	_spinner.center = window.center;
	
	[window addSubview:_maskView];
	[window addSubview:_spinner];
	[window bringSubviewToFront:_maskView];
	[window bringSubviewToFront:_spinner];
	
}
-(void)stopLoadingNotificationWait
{
	if(_maskView != nil && [_maskView superview])
	{
		[_maskView removeFromSuperview];
	}
	if(_spinner != nil && [_spinner superview])
	{
		[_spinner stopAnimating];
		[_spinner removeFromSuperview];
	}
}


@end
