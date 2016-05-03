//
//  VideoFrameTrack.h
//  MobileLooks
//
//  Created by jack on 8/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@interface VideoFrameTrack : NSObject {
	
	NSURL		*mURL;
	UIImage		*mImage;
	CMTime		mDuration;
	CGSize		mSize;
	
}
- (id)initWithURL:(NSURL*)URL;

- (NSURL*)URL;

- (UIImage*)trackedKeyFrame;

- (void) trackMiddleKeyFrame;
- (void) trackKeyFrame:(CMTime)time;

@end

extern NSString* const AVFrameTrackedDidFinishNotification;
