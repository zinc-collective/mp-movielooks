//
//  ProgressView.h
//  MobileLooks
//
//  Created by jack on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressView : UIView {
	UIImageView *background;
	UIImageView *foreground;
}
@property (nonatomic, readonly) UIImageView *background;
@property (nonatomic, readonly) UIImageView *foreground;

- (void) setValue:(float)value;

@end
