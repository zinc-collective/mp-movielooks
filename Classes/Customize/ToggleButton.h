//
//  ToggleButton.h
//  MobileLooks
//
//  Created by George on 12/15/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ToggleStateNormal,
	ToggleStateHighlighted
} ToggleState;

@interface ToggleButton : UIControl 
{
@private
	UIImageView *backgroundView;
	UILabel *titleLabel;
	UILabel *subtitleLabel;
	
	BOOL touchUpInside;
	ToggleState _toggleState;
}

@property(nonatomic) ToggleState toggleState;

- (id)initWithOrigin:(CGPoint)postion title:(NSString*)title subtitle:(NSString*)subtitle;

@end
