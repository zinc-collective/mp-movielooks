//
//  UICustomSwitch.h
//
//  Created by Hardy Macia on 10/28/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
//  Code can be freely redistruted and modified as long as the above copyright remains.
//

#import <Foundation/Foundation.h>


@interface UICustomSwitch : UISlider {
	BOOL on;
	BOOL m_touchedSelf;
}

@property(nonatomic,getter=isOn) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;


@end
