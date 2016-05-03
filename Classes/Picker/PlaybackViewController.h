//
//  PlaybackViewController.h
//  MobileLooks
//
//  Created by jack on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AVPlayer;
@class PlaybackView;
@class VideoFrameTrack;
@class ThumbView;
@interface PlaybackViewController : UIViewController {
	IBOutlet PlaybackView	*mPlaybackView;
	
	IBOutlet UIView		*mLowerUI;
	IBOutlet UISlider	*mScrubber;
	IBOutlet UIButton	*mPlayButton;
	
	
	NSURL				*mURL;
	AVPlayer			*mPlayer;
	
	float				mRestoreAfterScrubbingRate;
	id					mTimeObserver;
	
	VideoFrameTrack		*mVideoFrameTrack;
	
	ThumbView			*mThumbView;
	AVAsset				*mAvAsset;
	

//	UIBarButtonItem		*playBtn;
//	UIBarButtonItem		*pauseBtn;
	
	UILabel             *currentTime;
	UILabel				*leftTime;
	
	long				mTimeInterval;
	
}
@property (nonatomic, copy) NSURL* URL;
@property (nonatomic, readonly) AVPlayer* player;

- (void)pickCurrentFrame:(id)sender;
- (void)play:(id)sender;
- (BOOL)isPlaying;

- (void)beginScrubbing:(id)sender;
- (void)scrub:(id)sender;
- (void)endScrubbing:(id)sender;
- (BOOL)isScrubbing;

- (void) processImage:(UIImage*)img;

@end