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

-(void)setBackgroundImage:(UIImage*)image
{
    if(image == nil)
	{
//		NSLog(@"setBackgroundImage:nil");
//		if (backgroundView)
//		{
//			UIView *fatherView = [backgroundView superview];
			[backgroundView removeFromSuperview];
//			backgroundView = nil;
//			[fatherView setNeedsDisplay];
//		}
	}
	else
	{
		backgroundView = [[UIImageView alloc] initWithImage:image];
		backgroundView.tag = 1;
		backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
		backgroundView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:backgroundView];
		[self sendSubviewToBack:backgroundView];
		[backgroundView release];
	}
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [super insertSubview:view atIndex:index];
    [self sendSubviewToBack:backgroundView];
}

@end