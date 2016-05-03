//
//  ComposeProgressView.m
//  MobileLooks
//
//  Created by Chen Mike on 1/20/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "ComposeProgressView.h"
#import <QuartzCore/CAGradientLayer.h>

@implementation ComposeProgressView

+ (Class)layerClass {
	return [CAGradientLayer class];
}

-(void)fillBackgroundColorWithProgress:(CGFloat)progress
{
	static NSMutableArray *colors = nil;
	if (colors == nil) {
		colors = [[NSMutableArray alloc] initWithCapacity:2];
		UIColor * color1 = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
		[colors addObject:(id)[color1 CGColor]];
		UIColor * color2 = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.75];
		[colors addObject:(id)[color2 CGColor]];
		UIColor * color3 = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.0];
		[colors addObject:(id)[color3 CGColor]];
	}

	[(CAGradientLayer *)(self.layer) setStartPoint:CGPointMake(0.0, 0.5)];
	[(CAGradientLayer *)(self.layer) setEndPoint:CGPointMake(1.0, 0.5)];
	
	[(CAGradientLayer *)(self.layer) setColors:colors];
	[(CAGradientLayer *)(self.layer) setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:progress], [NSNumber numberWithFloat:1.0],nil]];			
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		if ((self = [super initWithFrame:frame]))
		{
//			[self fillBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] withProgress:0.0];
			self.backgroundColor = [UIColor clearColor];

			//UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bullet_time_background.png"]];
			//[self addSubview:background];
			//[background release];
			
			titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			titleLabel.font = [UIFont systemFontOfSize:14.0];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.textAlignment = UITextAlignmentCenter;
			[self addSubview:titleLabel];
			[titleLabel release];
		}
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
-(void)setTitleText:(NSString*)text withProgress:(CGFloat)progress;
{
	titleLabel.text = NSLocalizedString(@"Saving...",nil);//[NSString stringWithFormat:text,progress];
	[self fillBackgroundColorWithProgress:progress];
	NSLog(@"Compose progress %f",progress);
}

- (void)dealloc {
    [super dealloc];
}


@end
