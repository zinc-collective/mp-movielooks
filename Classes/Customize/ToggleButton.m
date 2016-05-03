//
//  ToggleButton.m
//  ToggleButton
//
//  Created by George on 12/15/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "ToggleButton.h"


@implementation ToggleButton

@synthesize toggleState=_toggleState;

- (void)setToggleState:(ToggleState)value
{
	NSLog(@"setState:%i", value);
	if (_toggleState == ToggleStateNormal && value == ToggleStateHighlighted)
	{
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_highlight_button47x68.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
			//backgroundView.image = [[UIImage imageNamed:@"LooksBrowser_button_press.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
		}
		else
		{
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_highlight_button22x27_iphone.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
		}
		//titleLabel.textColor = [UIColor whiteColor];
		titleLabel.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1];
        subtitleLabel.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1];
    }
	else if (_toggleState == ToggleStateHighlighted && value == ToggleStateNormal)
	{
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_normal_button47x69.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
			//backgroundView.image = [[UIImage imageNamed:@"LooksBrowser_button_normal.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
		}
		else {
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_normal_button22x27_iphone.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
		}
		titleLabel.textColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
        subtitleLabel.textColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
    }
	
	_toggleState = value;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	self.toggleState = !self.toggleState;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == self)
	{
		CGPoint point = [touch locationInView:self];
		if ((self.toggleState == ToggleStateHighlighted) && [self pointInside:point withEvent:event])
		{
			[self sendActionsForControlEvents:UIControlEventTouchUpInside];
		}
		else
		{
			self.toggleState = !self.toggleState;
		}
	}
}

- (id)initWithOrigin:(CGPoint)postion title:(NSString*)title subtitle:(NSString*)subtitle;
{
	//UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
	//UIFont *subtitleFont = [UIFont systemFontOfSize:14];
	UIFont *titleFont = [UIFont boldSystemFontOfSize:18];
	UIFont *subtitleFont = [UIFont systemFontOfSize:16];
	
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: titleFont}];
    CGSize subtitleSize = [subtitle sizeWithAttributes:@{NSFontAttributeName: subtitleFont}];
	
	//CGSize size = CGSizeMake(titleSize.width + subtitleSize.width + 30, 27);
	CGSize size = CGSizeMake(titleSize.width + subtitleSize.width + 26, 27);
	
	float height = size.height;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		height = 56;
	}
	
	self = [super initWithFrame:CGRectMake(postion.x, postion.y, size.width, height)];
    if (self)
	{
		backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			//backgroundView.image = [[UIImage imageNamed:@"LooksBrowser_button_normal.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_normal_button47x69.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:0];
		}
		else
        {
			//backgroundView.image = [[UIImage imageNamed:@"lb_group_button_background.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
			backgroundView.image = [[UIImage imageNamed:@"looksbrowser_normal_button22x27_iphone.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
		}
		[self addSubview:backgroundView];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, titleSize.width, titleSize.height)];
		titleLabel.font = titleFont;
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
		//titleLabel.shadowColor = [UIColor blackColor];
		titleLabel.text = title;
		[self addSubview:titleLabel];
		
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18 + titleSize.width, 4, subtitleSize.width, subtitleSize.height)];
		subtitleLabel.font = subtitleFont;
		subtitleLabel.backgroundColor = [UIColor clearColor];
		//subtitleLabel.textColor = [UIColor grayColor];
        subtitleLabel.textColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
        subtitleLabel.text = subtitle;
		[self addSubview:subtitleLabel];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			titleLabel.frame = CGRectMake(12, 14+3, titleSize.width, titleSize.height);
			//titleLabel.frame = CGRectMake(12, 14, titleSize.width, titleSize.height);
			subtitleLabel.frame = CGRectMake(18 + titleSize.width, 15+3, subtitleSize.width, subtitleSize.height);
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



@end
