//
//  ScrollViewEnhancer.m
//  MobileLooks
//
//  Created by George on 9/21/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "ScrollViewEnhancer.h"


@implementation ScrollViewEnhancer

@synthesize scrollView=_scrollView;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if ([self pointInside:point withEvent:event])
	{
		return _scrollView;
	}
	return nil;
}

@end
