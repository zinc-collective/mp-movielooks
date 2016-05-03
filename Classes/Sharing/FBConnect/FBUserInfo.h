/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FBUserRequestResult.h"
#import "FBFeedRequestResult.h"


@protocol FacebookUserInfoLoadDelegate <NSObject>

@optional
- (void)facebookUserDidLoad;

- (void)facebookUserInfoFailToLoad;

@end

@interface FBUserInfo : NSObject<FacebookUserRequestDelegate, FacebookFeedRequestDelegate> {
	NSString *_uid;
	NSDictionary *_userInfo;
	id _feed;
	NSMutableArray * _friendsList;
	NSMutableArray *_friendsInfo;
	Facebook *_facebook;
	id<FacebookUserInfoLoadDelegate> _userInfoDelegate; 
	FBRequest *_reqUid;
}

@property(nonatomic, strong) id<FacebookUserInfoLoadDelegate> userInfoDelegate;
@property(strong, nonatomic) id feed;
@property(strong, nonatomic) NSString *uid;
@property(strong, nonatomic) NSDictionary *userInfo;
@property(strong, nonatomic) Facebook *facebook;

- (void) requestUid;
- (id) initWithFacebook:(Facebook *)facebook andDelegate:(id<FacebookUserInfoLoadDelegate>)delegate;
- (void) requestAllInfo;

- (NSString *) getUsername;

@end

