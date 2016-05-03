//
//  CustomNavigationBar.m
//  CakeLove
//
//  Created by George on 3/6/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationBar (UINavigationBarCategory)

UIImageView *backgroundView;

-(UIView*)backgroundView {
    for (UIView * view in self.subviews) {
        if (view.tag == 111) {
            return view;
        }
    }
    return nil;
}

-(void)setBackgroundImage:(UIImage*)image
{
    if(image == nil)
	{
//		NSLog(@"setBackgroundImage:nil");
//		if (backgroundView)
//		{
//			UIView *fatherView = [backgroundView superview];
			[self.backgroundView removeFromSuperview];
//			backgroundView = nil;
//			[fatherView setNeedsDisplay];
//		}
	}
	else
	{
		UIView * backgroundView = [[UIImageView alloc] initWithImage:image];
		backgroundView.tag = 111;
		backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
		backgroundView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
	}
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [super insertSubview:view atIndex:index];
    [self sendSubviewToBack:backgroundView];
}

@end