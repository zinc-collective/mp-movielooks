//
//  ScrollViewEnhancer.h
//  MobileLooks
//
//  Created by George on 9/21/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrollViewEnhancer : UIView
{
	UIScrollView *__weak _scrollView;
}

@property(nonatomic, weak) UIScrollView *scrollView;

@end
