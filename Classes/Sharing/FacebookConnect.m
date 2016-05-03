//
//  FacebookConnect.m
//
//  Created by Joseph Snow/Snow Software Services on 8/5/2013.
//  Copyright 2013. All rights reserved.
//

#import "FacebookConnect.h"
#import "JSON.h"
#import "WebSiteCtrlor.h"


// MovieLooks Facebook APP IDs
#define FACEBOOK_APP_ID 		@"208921505798008"
#define FACEBOOK_GROUP_ID 		@"153468641361463"
#define FACEBOOK_PAGE_ID 		@"164453960245918"

@interface FacebookConnect (private)

- (void) sendVideoToFacebook:(NSDictionary*)info;

@end


@implementation FacebookConnect
@synthesize info_;
@synthesize delegate_;
@synthesize method_;
@synthesize videoLink;


- (id) init{
	if(self = [super init]){
		
		delegate_ = nil;
		
		fbLoggedIn = NO;
		fbSessionValid = NO;
		session = [[FBSession alloc] init];
		facebook = [[session restore] retain];
		
		if (true || facebook == nil) {
			facebook = [[Facebook alloc] init];
			session.facebook = facebook;
		} else {
			fbSessionValid = YES;
		}
		
		limitSize = 0;
		sendingVideo = NO;
		isPubshlishVideLinkBreak = NO;
		info_ = nil;
	}
	
	return self;
}

- (NSString *) getPrivacy
{
	if (_privacy == nil) {
		_privacy = [[NSString alloc] initWithFormat:@"Public"];
	}
	return _privacy;
}

- (NSString *) getPrivacyLowercase
{
	NSString *retval = [self getPrivacy];
	if (retval) {
		retval = [retval lowercaseString];
	}
	return retval;
}

- (void) setPrivacy:(NSString *)value
{
	_privacy = [[value copy] autorelease];
}

- (NSString *) getUsername
{
	NSString *username = nil;
	if (fbLoggedIn && facebookUserInfo) {
		username = [facebookUserInfo getUsername];
	}
	return username;
}

- (Boolean) isSignedIn
{
	return fbLoggedIn;
}

- (void) signInUser {
	if (fbLoggedIn){
		return;
	}
	[self facebookLogin];
}

- (void) runSignOutUserThenHandler:(void (^)(void))handler
{
	if (fbLoggedIn) {
		if (handler) { self.kLogoutHandler = handler; }
		[self facebookLogout];
	} else {
		if (handler) { handler(); }
		self.kLogoutHandler = nil;
	}
}

- (void)runSigninThenHandler:(void (^)(void))handler
{
	if (!fbLoggedIn) {
		if (handler) { self.kAuthHandler = handler; }
		if (fbSessionValid) {
			[self fbDidLogin];
		} else {
			[self facebookLogin];
		}
	} else {
		if (handler) { handler(); }
		self.kAuthHandler = nil;
	}
}


#pragma mark Facebook


- (void) facebookLogin {
	[facebook authorize:FACEBOOK_APP_ID permissions:[NSArray arrayWithObjects:@"publish_stream", nil] delegate:self];
}

- (void) facebookLogout {
	
	fbLoggedIn = NO;
	fbSessionValid = NO;
	
	if (facebookUserInfo) {
		[facebookUserInfo release];
		facebookUserInfo = nil;
	}
	
	if (session) {
		[session unsave];
	}
	
	if (facebook) {
		[facebook logout:self];
	}
}

- (void) fbDidLogin {
	//NSLog(@"Facebook did login");
	facebookUserInfo = [[[[FBUserInfo alloc] initWithFacebook:facebook andDelegate: self]
						 autorelease] 
						retain];
	[facebookUserInfo requestAllInfo];	
}

- (void)fbDidNotLogin:(BOOL)cancelled{
	if (self.kAuthHandler) {
		self.kAuthHandler();
		self.kAuthHandler = nil;
	}
}

- (void) fbDidLogout
{
	// NSLog(@"Facebook logged out");
	if (self.kLogoutHandler) {
		self.kLogoutHandler();
		self.kLogoutHandler = nil;
	}
}

- (void) facebookUserInfoDidLoad {
	[session setSessionWithFacebook:facebook andUid:facebookUserInfo.uid];
	[session save];
	//[tocView refresh];
	//NSLog(@"Facebook Saved");
	
	fbLoggedIn = YES;
	fbSessionValid = YES;
	
	if (self.kAuthHandler) {
		self.kAuthHandler();
		self.kAuthHandler = nil;
	}
	
	if (info_) {
		[self sendVideoToFacebook:nil];
	}
}

- (void) FacebookUserInfoFailToLoad {
	[self facebookLogout]; 

	if (self.kAuthHandler) {
		self.kAuthHandler();
		self.kAuthHandler = nil;
	}
}

- (int) videoUploadLimitSize{
	
	if(limitSize > 0)return limitSize;
	
	self.method_ = @"video.getUploadLimits";
	
	[facebook requestWithMethodName: @"video.getUploadLimits" 
						   andParams: [NSMutableDictionary dictionary]
					   andHttpMethod: @"GET" 
						 andDelegate: self];
	
	return 0;
}

- (void) sendVideoToFacebook:(NSDictionary*)info{
	
	if (info!=nil)
		self.info_ = info;
	
	if (!fbLoggedIn){
		[self facebookLogin];
		return;
	}
	
	__block int limit = [self videoUploadLimitSize];
	
	if (limit > 0){
		
		// when posting to facebook, we can post a filename or URL
		NSURL    *url  = [self.info_ objectForKey:@"videoUrl"];
		NSData   *data = [NSData dataWithContentsOfURL:url];
		
		if (data) {
			[self sendVideoToFacebook2:info :limit :data];
		} else if (url) {
			ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
			[library assetForURL:url resultBlock:^(ALAsset *asset) {
				NSData *assetData = [Utilities extractVideoDataFromAsset:asset];
				[self sendVideoToFacebook2:info :limit :assetData];
			} failureBlock:^(NSError *error) {
				NSLog(@"Failed to get assetForURL");
			}];
		} else {
			// TODO: Joe- show error
			sendingVideo = NO;
			info_ = nil;
			return;
		}
	}
}

- (void) sendVideoToFacebook2:(NSDictionary*)info :(int)limit :(NSData*)data
{
	NSString *title = [self.info_ objectForKey:@"title"];

	NSUInteger dataLen = (data)? [data length]: 0;
	if (limit < dataLen) {
		
		limit = limit/1024;
		NSString *str = @"";
		
		int l = (int)[data length]/1024;
		
		if(length > 60){
			int m = length/60;
			
			str = [NSString stringWithFormat:@"The size of your video file is: %d MB.\nThe video should under %d MB and %d minutes.",l,limit,m];
		}
		else {
			str = [NSString stringWithFormat:@"The size of your video file is: %d MB.\nThe video should under %d MB and %d seconds.",l,limit,length];
		}
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:str
													delegate:self
													cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		sendingVideo = NO;
		info_ = nil;
		return;
	}
	
	
	

	NSString* privacyParam = nil;
	NSString *privacyStr = [self getPrivacyLowercase];
	if (privacyStr != nil) {
		if ([privacyStr isEqualToString:@"public"]) {
			privacyStr = @"EVERYONE";
		} else if ([privacyStr isEqualToString:@"friends"]) {
			privacyStr = @"ALL_FRIENDS";
		} else if ([privacyStr isEqualToString:@"only me"]) {
			privacyStr = @"SELF";
		} else {
			privacyStr = nil;
		}
		
		if (privacyStr != nil) {
			NSMutableDictionary *privacyDic = [NSMutableDictionary dictionary];
			[privacyDic setObject:privacyStr forKey:@"value"];			
			SBJSON *jsonWriter = [[SBJSON new] autorelease];
			privacyParam = [jsonWriter stringWithObject:privacyDic];
		}
	}

	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									data, @"movielooks_render.mov",
									title, @"title",
									//@"---", @"description",
									privacyParam, @"privacy",
									nil];
	
	self.method_ = @"video.upload";
	
	if(delegate_ && [delegate_ respondsToSelector:@selector(beganSendVideoData)]){
		[delegate_ beganSendVideoData];
	}
	
	[facebook requestWithMethodName: @"video.upload" 
						  andParams: params
					  andHttpMethod: @"POST" 
						andDelegate: self];		
}

- (void) uploadVideoToFacebook:(NSDictionary*)info{
	
	if(sendingVideo)return;
	sendingVideo = YES;

	
	//NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:@"http://www.facebook.com" forKey:@"video_url"];
//	[self publishOnFacebook:dic];
//	[dic release];
//	return;
	
	[self sendVideoToFacebook:info];
}

- (void) cancel{
	
	if(facebook){
		[facebook cancelFacebookRequest];
	}
	
	sendingVideo = NO;
	info_ = nil;
}

- (void) publishOnFacebook:(NSDictionary*)info{
	
	self.info_ = info;
	if (!fbLoggedIn) {
		[self facebookLogin];
		return;
	}
	
	NSString * pageId = [[NSUserDefaults standardUserDefaults] valueForKey:push_noti_facebook_page_id];
	if(pageId == nil)return;
	
	NSString *target_id = pageId;// FACEBOOK_PAGE_ID;//@"199417290098863";
	NSString *video_url = [info valueForKey:@"video_url"];
	NSString *message = video_url;
	
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"MovieLooks",@"text",@"http://www.facebook.com",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	//NSMutableDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//									   headline, @"name",
//									   @"Share On Facebook", @"caption",
//									   @"Share On Facebook", @"description",
//									   shareUrl, @"href",
//									   nil];
	
	//NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   FACEBOOK_APP_ID, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   target_id,@"target_id",
								   //attachmentStr, @"attachment",
								   message,@"message",
								   nil];
	
	
	self.method_ = @"publish.group";
	
	[facebook requestWithMethodName: @"stream.publish"
						  andParams: params
					  andHttpMethod: @"POST"
						andDelegate:self];
	
}

- (void) continuePublishVideoLinkToPage{
	
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:videoLink,@"video_url",nil];
	[self publishOnFacebook:dic];
	[dic release];	
}

- (void) joinFacebookPage{
	
	if(delegate_ && [delegate_ respondsToSelector:@selector(didNeedAskJoinGroup:)]){
		
		isPubshlishVideLinkBreak = YES;
		
		NSString * facebook_page_url = [[NSUserDefaults standardUserDefaults] valueForKey:push_noti_facebook_page_url];
		if(facebook_page_url == nil)return;
		[delegate_ didNeedAskJoinGroup:facebook_page_url];
	}
	
	
}

- (void) facebookAskJoinToGroup
{
	
	if(delegate_ && [delegate_ respondsToSelector:@selector(didNeedAskJoinGroup:)]){
		[delegate_ didNeedAskJoinGroup:@"http://www.facebook.com/home.php?sk=group_153468641361463&ap=1"];
	}
	
//	UIWebView* view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 800)];
//	[self addSubview:view];
//	[view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com/home.php?sk=group_153468641361463&ap=1"]]];
}

- (void) facebookGetGroupList{
	
	NSString* temp = session.uid;
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									temp, @"uid",
									nil];
	
	self.method_ = @"fql.query.user.group";
	[facebook requestWithMethodName: @"groups.get" 
						   andParams: params
					   andHttpMethod: @"POST" 
						 andDelegate: self]; 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(alertView.tag == 200){
		if(buttonIndex == 1){
			[self joinFacebookPage];
		}
	}
}

- (void) askJoinGroup{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:NSLocalizedString(@"You need to like the page to finish your video submitting.",nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										  otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
	alert.tag = 200;
	[alert show];
	[alert release];
}

#pragma mark Facebook delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate
- (void)request:(FBRequest*)request didLoad:(id)result {
	
	if([method_ isEqualToString:@"video.getUploadLimits"]){
		limitSize = [[result objectForKey:@"size"] intValue];
		length = [[result objectForKey:@"length"] intValue];
		
		[self sendVideoToFacebook:nil];
		
		return;
	}
	else if([method_ isEqualToString:@"video.upload"]){
		
		self.videoLink = [result objectForKey:@"link"];
		
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:videoLink,@"video_url",nil];
		[self publishOnFacebook:dic];
		[dic release];
		
		if(delegate_ && [delegate_ respondsToSelector:@selector(didFinishShare::)]){
			[delegate_ didFinishShare:YES :nil];
		}
		
		sendingVideo = NO;
		info_ = nil;
	}
	else if([method_ isEqualToString:@"publish.group"]){
		
		BOOL isOK = NO;
		//"199417290098863_199690196738239"
		if([result isKindOfClass:[NSData class]]){
			NSString *string = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
			
			NSString *target_id = [[NSUserDefaults standardUserDefaults] valueForKey:push_noti_facebook_page_id];;
			
			NSRange range = [string rangeOfString:target_id];
			if(range.location != NSNotFound){
				isOK = YES;
			}
			
			[string release];
		}
		
		
		if(!isOK){
			
			[self askJoinGroup];
			return;
		}
		isPubshlishVideLinkBreak = NO;
	}
}


/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	
	sendingVideo = NO;
	info_ = nil;
	
	if([method_ isEqualToString:@"publish.group"] && [error code] == 210){
		
		[self askJoinGroup];
	}
	else
	{
		if(delegate_ && [delegate_ respondsToSelector:@selector(didFinishShare::)]){
			NSString *errMsg = [[error userInfo] valueForKey:@"error_msg"];
			[delegate_ didFinishShare:NO :errMsg];
		}
	}
}

- (void)request:(FBRequest*)request bytesWritten:(NSInteger)bytesWritten totalBytes:(NSInteger)totalBytes{
	if(delegate_ && [delegate_ respondsToSelector:@selector(sendingVideoDataToFacebook:bytesNeedSend:)]){
		[delegate_ sendingVideoDataToFacebook:bytesWritten bytesNeedSend:totalBytes];
	}
}



- (void)dealloc{
	[videoLink release];
	[method_ release];
	[info_ release];
	facebook.sessionDelegate = nil;
	[facebook release];
	[session release];
	[facebookUserInfo release];
	[super dealloc];
}

@end
