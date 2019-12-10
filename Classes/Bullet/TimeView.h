//
//  TimeView.h
//  MobileLooks
//
//  Created by George on 11/16/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimeView : UIView
{
	UILabel *titleLabel;
	UILabel *timeLabel;
	int lastSeconds;
}

-(void)setTimeRemaining:(double)seconds isInit:(BOOL)isFirst;
-(void)setTimeSaving;
-(void)setTimeDone;
@end
