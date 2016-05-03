//
//  MobileLooksPickerItem.h
//  MobileLooks
//
//  Created by Chen Mike on 3/15/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoThumbnailOperation.h"

typedef enum  {
	PickerItemStyleForIphone,
	PickerItemStyleForIpad,	
} PickerItemStyle;

@protocol MobileLooksPickerItemDelegate
@optional
- (void)selectItem:(NSURL *)URL;
@end;

@interface MobileLooksPickerItem : UIView<VideoThumbnailOperationDelegate> {
    NSURL* mURL;
	BOOL mHasThumbnail;
	UIImageView *iconView;
	PickerItemStyle mPickerItemStyle;
    id <MobileLooksPickerItemDelegate>  _delegate;
}
- (id)initWithURL:(NSURL*)URL withStyle:(PickerItemStyle)style withFrame:(CGRect)itemFrame;
-(void)loadFromCache:(UIImage*)chachedImage withDurationString:(NSString*)durationStr;
-(void)startOpertionOnQueue:(NSOperationQueue*)queue;


@property(nonatomic,assign) id<MobileLooksPickerItemDelegate> delegate;
@property(nonatomic,assign) BOOL hasThumbnail;
@end

extern NSString* const MobileLooksPickerItemDidChangeNotification;