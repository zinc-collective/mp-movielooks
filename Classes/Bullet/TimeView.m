//
//  TimeView.m
//  MobileLooks
//
//  Created by George on 11/16/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "TimeView.h"


@implementation TimeView


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        self.backgroundColor = [UIColor clearColor];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Processing_xianshishijian.png"]];
			[self addSubview:background];
			
			titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 3, 160, frame.size.height-6)];
			titleLabel.font = [UIFont systemFontOfSize:20.0];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.text = NSLocalizedString(@"Time Remaining:", nil);
			[self addSubview:titleLabel];
			
			timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 1, 100, frame.size.height-4)];
			timeLabel.font = [UIFont systemFontOfSize:28.0];
			timeLabel.backgroundColor = [UIColor clearColor];
			timeLabel.textAlignment = NSTextAlignmentCenter;
			timeLabel.textColor = [UIColor whiteColor];
			timeLabel.text = @"0:00:00";
			[self addSubview:timeLabel];
		}
		else {
			UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bullet_time_background.png"]];
			[self addSubview:background];
			
			titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 95, 18)];
			titleLabel.font = [UIFont systemFontOfSize:12.0];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.text = NSLocalizedString(@"Time Remaining:", nil);
			[self addSubview:titleLabel];
			
			timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 1, 55, 22)];
			timeLabel.font = [UIFont systemFontOfSize:16.0];
			timeLabel.backgroundColor = [UIColor clearColor];
			timeLabel.textAlignment = NSTextAlignmentCenter;
			timeLabel.textColor = [UIColor whiteColor];
			timeLabel.text = @"0:00:00";
			[self addSubview:timeLabel];
		}
		
		
	}
    return self;
}

-(void)setTimeRemaining:(double)seconds isInit:(BOOL)isFirst
{
	if(seconds>lastSeconds && !isFirst)
	{
		NSLog(@"Check point jump!");
		return;
	}
	lastSeconds = seconds;
	
	int hours = seconds / 3600;
	int mins = (seconds - hours * 3600) / 60;
	int secs = seconds - hours * 3600 - mins * 60;
	NSString *timeString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, mins, secs];
	timeLabel.text = timeString;
}

-(void)setTimeSaving
{
	titleLabel.text = NSLocalizedString(@"Saving",nil);
	timeLabel.text = @"";
}

-(void)setTimeDone
{
	titleLabel.text = NSLocalizedString(@"Done",nil);
	timeLabel.text = @"";
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
