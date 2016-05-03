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

#import "FBFeedRequestResult.h"

@implementation FBFeedRequestResult

- (id) initializeWithDelegate:(id<FacebookFeedRequestDelegate>)delegate {
  self = [super init];
  _feedRequestDelegate = [delegate retain];
  return self;  
}

- (void)dealloc {
  [_feedRequestDelegate release];
  [super dealloc];
}

/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{

	

	[_feedRequestDelegate facebookFeedRequestCompleteWithUid:result];    
}


- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
  NSLog(@"%@",[error localizedDescription]);
  [_feedRequestDelegate userRequestFailed];
}

@end
