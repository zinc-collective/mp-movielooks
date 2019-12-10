//
//  CustomPopView.m
//  MobileLooks
//
//  Created by jack on 4/9/11.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "CustomPopView.h"


@implementation CustomPopView
@synthesize delegate_;

- (void)deviceOrientationDidChange:(void*)object {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

	if(UIInterfaceOrientationIsPortrait(orientation)){
		self.frame = CGRectMake(0, 0, framePortraitSize.width, framePortraitSize.height);
		UIView *v = [self viewWithTag:1];
		v.frame = self.frame;

		v = [self viewWithTag:2];
		v.center = self.center;
	}
	else {
		self.frame = CGRectMake(0, 0, framePortraitSize.height, framePortraitSize.width);
		UIView *v = [self viewWithTag:1];
		v.frame = self.frame;

		v = [self viewWithTag:2];
		v.center = self.center;
	}

}
- (id) initWithButtons:(NSArray*)buttons frame:(CGRect)frame{
	self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		delegate_ = nil;
		framePortraitSize = frame.size;
		UIView *bk = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		bk.backgroundColor = [UIColor blackColor];
		bk.alpha = 0.6f;
		bk.tag = 1;
		[self addSubview:bk];

		float fontSize = 20;
		UIImage *bkImage = [UIImage imageNamed:@"pop_background.png"];
		if([buttons count] == 2){

			UIImageView *imgView = [[UIImageView alloc] initWithImage:bkImage];
			imgView.userInteractionEnabled = YES;
			imgView.tag = 2;
			[self addSubview:imgView];

			imgView.center = CGPointMake(frame.size.width/2, frame.size.height/2);


			float y = 9;
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(9, y, 270, 41);
			[btn setBackgroundImage:[UIImage imageNamed:@"pop_button.png"] forState:UIControlStateNormal];
			btn.tag = 10;
			[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

			[btn setTitle:[buttons objectAtIndex:0] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
			[imgView addSubview:btn];

			y+=41;
			y+=9;
			btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(9, y, 270, 41);
			[btn setBackgroundImage:[UIImage imageNamed:@"pop_button.png"] forState:UIControlStateNormal];
			btn.tag = 11;
			[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitle:[buttons objectAtIndex:1] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
			[imgView addSubview:btn];

		}
		else {

			bkImage = [bkImage stretchableImageWithLeftCapWidth:50 topCapHeight:50];
			UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 288, 160)];
			imgView.image = bkImage;
			imgView.userInteractionEnabled = YES;
			imgView.tag = 2;
			[self addSubview:imgView];

			imgView.center = CGPointMake(frame.size.width/2, frame.size.height/2);

			float y = 9;
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(9, y, 270, 41);
			[btn setBackgroundImage:[UIImage imageNamed:@"pop_button.png"] forState:UIControlStateNormal];
			btn.tag = 10;
			[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitle:[buttons objectAtIndex:0] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
			[imgView addSubview:btn];

			y+=41;
			y+=9;
			btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(9, y, 270, 41);
			[btn setBackgroundImage:[UIImage imageNamed:@"pop_button.png"] forState:UIControlStateNormal];
			btn.tag = 11;
			[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitle:[buttons objectAtIndex:1] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
			[imgView addSubview:btn];

			y+=41;
			y+=9;
			btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(9, y, 270, 41);
			[btn setBackgroundImage:[UIImage imageNamed:@"pop_button.png"] forState:UIControlStateNormal];
			btn.tag = 12;
			[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitle:[buttons objectAtIndex:2] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
			[imgView addSubview:btn];
		}


		[self deviceOrientationDidChange:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange:)
													 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
    if (self) {
	}
	return self;
}
/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

	[UIView animateWithDuration:0.25 delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [self setAlpha:0.0f];
					 }
					 completion:^(BOOL finished){
						 [self removeFromSuperview];
					 }
	 ];

}
*/
- (void) buttonClicked:(id)sender{

	UIButton *btn = sender;

	if(delegate_ && [delegate_ respondsToSelector:@selector(popView:clickedButtonAtIndex:)]){
		[delegate_ popView:self clickedButtonAtIndex:btn.tag-10];
	}

	[UIView animateWithDuration:0.25 delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [self setAlpha:0.0f];
					 }
					 completion:^(BOOL finished){
						 [self removeFromSuperview];
					 }
	 ];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


@end
