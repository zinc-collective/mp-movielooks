//
//  CustomNavigationBar.h
//  CakeLove
//
//  Created by George on 3/6/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UINavigationBar (UINavigationBarCategory) 

- (void)setBackgroundImage:(UIImage*)image;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;

@end

