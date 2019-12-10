//
//  RProgressView.m
//  FlickrPlug
//
//  Created by jack on 4/8/09.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "RProgressView.h"

#define LABEL_TAG 130
#define INDICATOR_TAG 271

#define BG_UP_TAG				200
#define BG_MIDDLE_TAG			201
#define BG_LOGO_TAG				202
#define BG_DOWN_TAG				203
#define BG_CANCEL_BT_TAG		204
#define BG_BACK_BT_TAG			205
#define BG_RETRY_TAG			206
#define ICON_TAG				207
#define STATUS_LABEL_TAG		208


#define auto_update_timer_interval 0.1

@implementation RProgressView
@synthesize delegate_;



#pragma mark -
#pragma mark system functions @rewrited
- (id) initWithProgress:(CGRect)frame showLogo:(NSString*)logo{
	if(self = [super initWithFrame:frame]){

		self.backgroundColor = [UIColor clearColor];

		delegate_ = nil;

		float w = frame.size.width;
		float h = frame.size.height;
		UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, w, h)];
		backGroundView.backgroundColor = [UIColor blackColor];
		backGroundView.alpha = 0.5;
		[self addSubview:backGroundView];
		[backGroundView release];


		//background
		float width = 298.0;
		float height = 280.0;

		float l = (w-width)/2.0;
		float t = (h-height)/2.0;
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l, t, width, 53.0)];
		imgView.image = [UIImage imageNamed:@"bg_up.png"];
		imgView.tag = BG_UP_TAG;
		//imgView.alpha = 0.75;
		[self addSubview:imgView];
		[imgView release];

		if([logo isEqualToString:@"facebook"]){
			UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(l+20, t+20, 106, 22.0)];
			logo.image = [UIImage imageNamed:@"facebook.png"];
			logo.tag = BG_LOGO_TAG;
			[self addSubview:logo];
			[logo release];
		}
		else{
			UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(l+20, t+20, 79, 24.0)];
			logo.image = [UIImage imageNamed:@"flickr.png"];
			logo.tag = BG_LOGO_TAG;
			[self addSubview:logo];
			[logo release];
		}

		UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(l, t+53.0, width, height - 70.0)];
		[middle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_middle.png"]]];
		middle.tag = BG_MIDDLE_TAG;
		[self addSubview:middle];
		[middle release];

		UIImageView *imgViewDown = [[UIImageView alloc] initWithFrame:CGRectMake(l, t+height-70.0+53.0, width, 17.0)];
		imgViewDown.image = [UIImage imageNamed:@"bg_down.png"];
		imgViewDown.tag = BG_DOWN_TAG;
		[self addSubview:imgViewDown];
		[imgViewDown release];


		//progress
		float progress_left = l+(width - 252.0)/2.0;

		progress_ = [[UILabel alloc] initWithFrame:CGRectMake(progress_left, t+95.0, 252.0, 20.0)];
		progress_.textAlignment = UITextAlignmentCenter;
		progress_.textColor = [UIColor blackColor];
		progress_.backgroundColor = [UIColor clearColor];
		[self addSubview:progress_];

		progressView_ = [[UIProgressView alloc] initWithFrame:CGRectMake(progress_left, t+120.0, 252.0, 20.0)];
		progressView_.progress = 0.0;
		[self addSubview:progressView_];

		UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(progress_left+10, t+90.0, 43, 43.0)];
		icon.image = [UIImage imageNamed:@"succeed.png"];
		icon.tag = ICON_TAG;
		[self addSubview:icon];
		icon.hidden = YES;
		[icon release];

		UILabel* status = [[UILabel alloc] initWithFrame:CGRectMake(progress_left+55.0, t+104.0, 180, 20.0)];
		status.textAlignment = UITextAlignmentCenter;
		status.textColor = [UIColor blackColor];
		status.backgroundColor = [UIColor clearColor];
		status.font = [UIFont boldSystemFontOfSize:18.0];
		status.shadowColor = [UIColor whiteColor];
		status.shadowOffset = CGSizeMake(1.0, 1.0);
		status.text = @"Success Upload";
		status.tag = STATUS_LABEL_TAG;
		[self addSubview:status];
		status.hidden = YES;
		[status release];


		//button
		float btn_left = l+(width - 253)/2.0;
		float btn_top = h - t - 69.0;

		CGRect rect = CGRectMake(btn_left, btn_top, 253.0, 39.0);
		UIButton *cancelBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		cancelBtn.frame = rect;
		[cancelBtn setBackgroundImage:[UIImage imageNamed:@"bg_btn.png"] forState:UIControlStateNormal];
		[cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
		cancelBtn.backgroundColor = [UIColor clearColor];
		[cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
		cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
		cancelBtn.tag = BG_CANCEL_BT_TAG;
		[self addSubview:cancelBtn];
		[cancelBtn release];

		UIButton *backBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		backBtn.frame = rect;
		[backBtn setBackgroundImage:[UIImage imageNamed:@"bg_btn.png"] forState:UIControlStateNormal];
		[backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
		backBtn.backgroundColor = [UIColor clearColor];
		[backBtn setTitle:@"Back" forState:UIControlStateNormal];
		backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
		backBtn.tag = BG_BACK_BT_TAG;
		[self addSubview:backBtn];
		backBtn.hidden = YES;
		[backBtn release];

		UIButton *retry = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		retry.frame = CGRectMake(btn_left, btn_top-39.0-5, 253.0, 39.0);
		[retry setBackgroundImage:[UIImage imageNamed:@"bg_btn.png"] forState:UIControlStateNormal];
		[retry addTarget:self action:@selector(retryAction:) forControlEvents:UIControlEventTouchUpInside];
		retry.backgroundColor = [UIColor clearColor];
		[retry setTitle:@"Retry" forState:UIControlStateNormal];
		retry.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[retry setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[retry setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
		retry.tag = BG_RETRY_TAG;
		[self addSubview:retry];
		retry.hidden = YES;
		[retry release];

	}
    return self;
}

- (id) initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){

		self.backgroundColor = [UIColor clearColor];

		[self createView:frame];

		return self;
	}
    return nil;
}

- (void) dealloc
{
	[progress_ release];
	[progressView_ release];

    [super dealloc];
}





#pragma mark -
#pragma mark in use functions
- (void) createView:(CGRect)frame
{
	float w = frame.size.width;
	float h = frame.size.height;
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, w, h)];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0.5;
	[self addSubview:backGroundView];
    [backGroundView release];

	float l = (w-280.0)/2.0;
	float t = (h-180.0)/2.0;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l, t, 280.0, 180.0)];
    imgView.image = [UIImage imageNamed:@"progress_background.png"];
	imgView.alpha = 0.75;
    [self addSubview:imgView];
    [imgView release];

    progressView_ = [[UIProgressView alloc] initWithFrame:CGRectMake(l+40.0, t+80.0, 200, 20.0)];
	progressView_.progress = 0.0;
	[self addSubview:progressView_];

	progress_ = [[UILabel alloc] initWithFrame:CGRectMake(l+40.0, t+100.0, 200, 20.0)];
	progress_.textAlignment = UITextAlignmentCenter;
	progress_.textColor = [UIColor whiteColor];
	progress_.backgroundColor = [UIColor clearColor];
	[self addSubview:progress_];
}
- (void)cancelAction:(id)sender{
	if(delegate_ && [delegate_ respondsToSelector:@selector(didButtonClickedIndex:)]){
		[delegate_ didButtonClickedIndex:0];
	}
}

- (void)backAction:(id)sender{
	if(delegate_ && [delegate_ respondsToSelector:@selector(didButtonClickedIndex:)]){
		[delegate_ didButtonClickedIndex:1];
	}
}

- (void)retryAction:(id)sender{
	if(delegate_ && [delegate_ respondsToSelector:@selector(didButtonClickedIndex:)]){
		[delegate_ didButtonClickedIndex:2];
	}
}






#pragma mark -
#pragma mark out use functions
- (void) showSuccess{
	progressView_.hidden = YES;
	progress_.hidden = YES;

	UIView * view = [self viewWithTag:BG_CANCEL_BT_TAG];
	view.hidden = YES;

	view = [self viewWithTag:BG_RETRY_TAG];
	view.hidden = YES;

	UIImageView* icon = (UIImageView*)[self viewWithTag:ICON_TAG];
	icon.image = [UIImage imageNamed:@"succeed.png"];
	icon.hidden = NO;

	UILabel *status = (UILabel*)[self viewWithTag:STATUS_LABEL_TAG];
	status.text = @"Message Posted";
	status.hidden = NO;

	view = [self viewWithTag:BG_BACK_BT_TAG];
	view.hidden = NO;
}
- (void) showFailed{
	progressView_.hidden = YES;
	progress_.hidden = YES;

	UIView* view = [self viewWithTag:BG_BACK_BT_TAG];
	view.hidden = YES;

	view = [self viewWithTag:BG_CANCEL_BT_TAG];
	view.hidden = NO;

	view = [self viewWithTag:BG_RETRY_TAG];
	view.hidden = NO;

	UIImageView* icon = (UIImageView*)[self viewWithTag:ICON_TAG];
	icon.image = [UIImage imageNamed:@"failed.png"];
	icon.hidden = NO;

	UILabel *status = (UILabel*)[self viewWithTag:STATUS_LABEL_TAG];
	status.text = @"Posting Failed";
	status.hidden = NO;

}
- (void) showProgress{

	progressView_.hidden = NO;
	progress_.hidden = NO;

	progress_.text = @"0%";
	progressView_.progress = 0;

	UIView* view = [self viewWithTag:BG_CANCEL_BT_TAG];
	view.hidden = NO;

	view = [self viewWithTag:BG_BACK_BT_TAG];
	view.hidden = YES;

	view = [self viewWithTag:BG_RETRY_TAG];
	view.hidden = YES;

	UIImageView* icon = (UIImageView*)[self viewWithTag:ICON_TAG];
	icon.hidden = YES;

	UILabel *status = (UILabel*)[self viewWithTag:STATUS_LABEL_TAG];
	status.hidden = YES;
}

- (void) updteProgress:(float)progress{
	progressView_.progress = progress;

	if(progress < 1.0){
		progress_.text = [NSString stringWithFormat:@"%d%%", (int)(progress*100)];
	}
	else{
		progress_.text = @"Please wait...";
	}
}




@end