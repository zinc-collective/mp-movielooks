//
//  MobileLooksVideoPickerController.h
//  MobileLooks
//
//  Created by Chen Mike on 3/16/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileLooksPickerItem.h"
#import "MobileLooksTrimPlayerController.h"

@class MobileLooksPickerSource;
@class MobileLooksVideoPickerController;

@protocol MobileLooksVideoPickerControllerDelegate
@optional
//-(void)selectMovie:(MobileLooksVideoPickerController*)videoPickerController withUrl:(NSURL*)URL;
-(BOOL)selectMovie:(MobileLooksVideoPickerController*)videoPickerController withUrl:(NSURL*)URL; //storyboard
-(int)selectedMovieAssetMode; //storyboard
-(NSURL*)selectedMovieURL;    //storyboard
@end

@interface MobileLooksVideoPickerController : UIViewController<MobileLooksPickerItemDelegate,UIScrollViewDelegate> {
    //UIScrollView* mScrollView; //storyboard
	
	id<MobileLooksVideoPickerControllerDelegate, MobileLooksTrimPlayerControllerDelegate> __weak _delegate;
	MobileLooksPickerSource* mSource;
	NSInteger mLastSourceCount;
	NSMutableArray* mURLs;
	CGFloat mLastScrollOffset;
	NSInteger mLastScrollIndex;
	BOOL mLastScrollAuto;
	BOOL mFirstTime;
	NSInteger lastRowIndex;
    UIButton *leftScrollButton;
    UIButton *rightScrollButton;
    UIButton *topScrollButton;
    UIButton *bottomScrollButton;
    UIButton *leftScrollOpaque;
    UIButton *rightScrollOpaque;
    UIButton *topScrollOpaque;
    UIButton *bottomScrollOpaque;
}
@property (strong, nonatomic) IBOutlet UIScrollView *mScrollView;

@property(nonatomic,weak) id<MobileLooksVideoPickerControllerDelegate, MobileLooksTrimPlayerControllerDelegate> delegate;
@end

extern NSString* const MobileLooksVideoPickerControllerDidPickURLNotification;