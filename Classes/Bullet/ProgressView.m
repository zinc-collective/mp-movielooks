//
//  ProgressView.m
//  MobileLooks
//
//  Created by jack on 9/27/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "ProgressView.h"


@implementation ProgressView
@synthesize background;
@synthesize foreground;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, frame.size.width, 15)];
		foreground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 0, 15)];

		[self addSubview:background];
		[self addSubview:foreground];

    }
    return self;
}

- (void) setValue:(float)value{

	CGRect r2 = foreground.frame;
	if(value == 0){

		foreground.frame = CGRectMake(0, 2, 0, r2.size.height);
	}

	CGRect r1 = background.frame;


	float w = r1.size.width*value;

	foreground.frame = CGRectMake(0, 2, w, r2.size.height);


}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
