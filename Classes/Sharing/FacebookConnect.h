//
//  FacebookConnect.h
//
//  Created by Joseph Snow/Snow Software Services on 8/5/2013.
//  Copyright 2013. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "FBSession.h"
#import "FBUserInfo.h"


typedef void(^FACEBOOK_HANDLER)(void);


@protocol FacebookConnectDelegate
@optional
- (void) didFinishShare:(BOOL)success :(NSString*)errorMsg;
- (void) beganSendVideoData;
- (void) sendingVideoDataToFacebook:(NSInteger)bytesSend bytesNeedSend:(NSInteger)bytesNeedSend;
- (void) didNeedAskJoinGroup:(NSString*)joinUrl;
- (void) fbDidLogout;
@end

@interface FacebookConnect : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate, FacebookUserInfoLoadDelegate> {

	BOOL fbLoggedIn;
	BOOL fbSessionValid;
	Facebook *facebook;	
	FBSession *session;
	FBUserInfo *facebookUserInfo;
	
	NSDictionary *info_;
	
	id delegate_;
	
	int   limitSize;
	int   length;
	
	NSString *method_;
	
	NSString *vid;
	NSString *videoLink;
	
	BOOL   sendingVideo;
	
	BOOL				isPubshlishVideLinkBreak;
	
	NSString *_privacy;
	
}

@property (nonatomic, assign) id <FacebookConnectDelegate> delegate_;
@property (nonatomic, retain) NSDictionary *info_;
@property (nonatomic, retain) NSString *method_;
@property (nonatomic, retain) NSString *videoLink;
@property(copy, nonatomic) FACEBOOK_HANDLER kAuthHandler;
@property(copy, nonatomic) FACEBOOK_HANDLER kLogoutHandler;

- (NSString*) getPrivacy;

- (void) setPrivacy:(NSString *)value;

- (NSString *) getUsername;

- (Boolean) isSignedIn;

- (void) signInUser;

- (void) runSignOutUserThenHandler:(void (^)(void))handler;

- (void) runSigninThenHandler:(void (^)(void))handler;

- (void) publishOnFacebook:(NSDictionary*)info;

- (void) uploadVideoToFacebook:(NSDictionary*)info;

- (void) cancel;

- (void) facebookGetGroupList;

- (void) continuePublishVideoLinkToPage;


@end
