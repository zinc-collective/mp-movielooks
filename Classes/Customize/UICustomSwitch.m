//
//  UICustomSwitch.m
//
//  Created by Hardy Macia on 10/28/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
//  Code can be freely redistruted and modified as long as the above copyright remains.
//

#import "UICustomSwitch.h"


@implementation UICustomSwitch

@synthesize on;

-(id)initWithFrame:(CGRect)rect
{
	if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height)]))
	{
		self.clipsToBounds = YES;
		
		[self awakeFromNib];		// do all setup in awakeFromNib so that control can be created manually or in a nib file
	}
	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor clearColor];

	
	NSString *switchName = @"switch.png";
	NSString *switchBackground = @"switch_background.png";
	
	UIImage *img = [UIImage imageNamed:switchBackground];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		switchName = @"Tweak02_half.png";
		switchBackground = @"Tweak_full_half.png";
		
		img = [UIImage imageNamed:switchBackground];
		//img = [img stretchableImageWithLeftCapWidth:70 topCapHeight:0];
	}
	
	[self setThumbImage:[UIImage imageNamed:switchName] forState:UIControlStateNormal];
	//[self setThumbImage:[UIImage imageNamed:switchName] forState:UIControlStateHighlighted];
	[self setMinimumTrackImage:img forState:UIControlStateNormal];
	[self setMinimumTrackImage:img forState:UIControlStateHighlighted];
	[self setMinimumTrackImage:img forState:UIControlStateSelected];
	[self setMaximumTrackImage:img forState:UIControlStateNormal];
	[self setMaximumTrackImage:img forState:UIControlStateHighlighted];
	[self setMaximumTrackImage:img forState:UIControlStateSelected];
		
	self.minimumValue = 0;
	self.maximumValue = 1;
	self.continuous = NO;
	
	self.on = NO;
	self.value = 0.0;
}



- (void)setOn:(BOOL)turnOn animated:(BOOL)animated;
{
	on = turnOn;
	
	if(on){
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			[self setThumbImage:[UIImage imageNamed:@"Tweak02_half.png"] forState:UIControlStateNormal];
		}
	}
	else {
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			[self setThumbImage:[UIImage imageNamed:@"Tweak02_full.png"] forState:UIControlStateNormal];
		}
	}

	
	if (animated)
	{
		[UIView	 beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2];
	}
	
	if (on)
	{
		self.value = 1.0;
		
	}
	else 
	{
		self.value = 0.0;
		
	}
	
	if (animated)
	{
		[UIView	commitAnimations];	
	}
}

- (void)setOn:(BOOL)turnOn
{
	[self setOn:turnOn animated:NO];
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	m_touchedSelf = YES;
	
	[self setOn:on animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesBegan:touches withEvent:event];
	m_touchedSelf = NO;
	on = !on;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesEnded:touches withEvent:event];
	
	if (!m_touchedSelf)
	{
		[self setOn:on animated:YES];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}


@end
