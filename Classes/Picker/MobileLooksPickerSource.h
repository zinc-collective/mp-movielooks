//
//  MobileLooksPickerSource.h
//  MobileLooks
//
//  Created by Chen Mike on 3/15/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MobileLooksPickerSource : NSObject {

}
+ (MobileLooksPickerSource*)cameraRollSource;
+ (MobileLooksPickerSource*)iTunesLibrarySource;
+ (MobileLooksPickerSource*)iTunesFileSharingSource;

-(NSArray*)URLs;
-(NSArray*)assetsArray;
@end

extern NSString* const MobileLooksPickerSourceItemsDidChangeNotification;
extern NSString* const MobileLooksPickerSourceItemsDeniedAccessNotification;