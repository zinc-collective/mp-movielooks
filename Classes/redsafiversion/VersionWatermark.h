//
//  VersionWatermark.h
//  FlickrPlug
//
//  Created by jack on 4/8/09.
//  Copyright 2009 Redsafi. All rights reserved.
//

@interface VersionWatermark : UIView {
	
	UILabel			*_version;

}

- (void) showInView:(UIView*)view;
- (void) loadingVersion;

@end


