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

#import "FBUserInfo.h"
#import "FBConnect.h"



@implementation FBUserInfo

@synthesize facebook = _facebook,
				 uid = _uid,
			userInfo = _userInfo,
			    feed = _feed,
    userInfoDelegate = _userInfoDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * initialization
 */
- (id) initWithFacebook:(Facebook *)facebook andDelegate:(id<FacebookUserInfoLoadDelegate>)delegate {
    self = [super init];
    if (self) {
      _facebook = facebook;
      _userInfoDelegate = delegate;
    }
    return self;
}


- (NSString *) getUsername
{
	return (self.userInfo)? [self.userInfo objectForKey:@"name"]: nil;
}


/**
 * Request all info from the user is start with request user id as the authorization flow does not 
 * return the user id. This is an intermediate solution to obtain the logged in user id
 * All other information are requested in the FBRequestDelegate function after Uid obtained. 
 */
- (void) requestAllInfo {
  [self requestUid];
}

/**
 * Request the user id of the logged in user.
 *
 * Currently the authorization flow does not return a user id anymore. This is
 * an intermediate solution to get the logged in user id.
 */
- (void) requestUid{
  FBUserRequestResult *userRequestResult = 
    [[FBUserRequestResult alloc] initWithDelegate:self];
  [_facebook requestWithGraphPath:@"me" andDelegate:userRequestResult];

}

- (void) requestFeed{
//	FBFeedRequestResult *feedRequestResult = 
//    [[[[FBFeedRequestResult alloc] initializeWithDelegate:self] autorelease] retain];
//	[_facebook requestWithGraphPath:@"me/home" andDelegate:feedRequestResult];
	
	
	
	FBFeedRequestResult *feedRequestResult = 
    [[FBFeedRequestResult alloc] initWithDelegate:self];
	
	NSString *query = @"SELECT owner,pid,caption, src_small, src_big FROM photo WHERE aid IN ( SELECT aid FROM album WHERE owner = ";
	query = [query stringByAppendingFormat:@"%@  OR owner  IN (SELECT uid2 FROM friend WHERE uid1 = %@)) ORDER BY created DESC LIMIT 1,18", _uid,_uid];
		
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									query, @"query",
									nil];
	[_facebook requestWithMethodName: @"fql.query" 
						   andParams: params
					   andHttpMethod: @"POST" 
						 andDelegate: feedRequestResult]; 
	
}

/**
 * UserRequestDelegate
 */
- (void)facebookUserRequestCompleteWithUid:(NSString *)uid :(NSDictionary *)userInfo {
  self.uid = uid;
  self.userInfo = (userInfo != nil)? [userInfo copy]: nil;
  [self requestFeed];
}

- (void)facebookUserRequestFailed {
//  if ([self.userInfoDelegate respondsToSelector:@selector(userInfoFailToLoad)]) {
//    [_userInfoDelegate userInfoFailToLoad];
//  }
}

/**
 * FeedRequestDelegate
 */

- (void)facebookFeedRequestCompleteWithUid:(id)feed {
  	self.feed = feed;
	if ([self.userInfoDelegate respondsToSelector:@selector(facebookUserDidLoad)]) {
        [_userInfoDelegate facebookUserDidLoad];
	}	
}

- (void)facebookFeedRequestFailed {
    
}

  
@end