//
//  MProgressView.m
//  FlickrPlug
//
//  Created by jack on 4/8/09.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "MProgressView.h"

#define LABEL_TAG 130
#define INDICATOR_TAG 271



#define auto_update_timer_interval 0.1

@implementation MProgressView
@synthesize delegate_;

- (id) initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];

		[self createView:frame];

		return self;
	}
    return nil;
}



#pragma mark -
#pragma mark in use functions
- (void) createView:(CGRect)frame
{
	float w = frame.size.width;
	float h = frame.size.height;

	boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	boxView.backgroundColor = [UIColor clearColor];
	//boxView.layer.cornerRadius = 10;
	//boxView.layer.masksToBounds = YES;
	//boxView.alpha = 0.75;
	//boxView.userInteractionEnabled = YES;
	[self addSubview:boxView];

	progress_ = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 50.0, 200, 20.0)];
	progress_.textAlignment = NSTextAlignmentCenter;
	progress_.textColor = [UIColor blackColor];
	progress_.backgroundColor = [UIColor clearColor];
	[boxView addSubview:progress_];

    progressView_ = [[UIProgressView alloc] initWithFrame:CGRectMake(40.0, 70.0, 200, 20.0)];
	progressView_.progress = 0.0;
	[boxView addSubview:progressView_];

    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        progress_.frame = CGRectMake(40.0, 30.0, 200, 20.0);
        progressView_.frame = CGRectMake(40.0, 50.0, 200, 20.0);
    }


#if 0
	CGRect rect = CGRectMake(13.0, 100.0, 253.0, 39.0);
	cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	cancelButton.frame = rect;
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
	cancelButton.backgroundColor = [UIColor clearColor];
	[cancelButton setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
	cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[boxView addSubview:cancelButton];
#endif
}

-(UIView*)getBoxView
{
	return boxView;
}

-(UIButton*)getCancelButton
{
	return cancelButton;
}

- (void) update{
	boxView.center = self.center;
}

- (void)cancelAction:(id)sender{
	if(delegate_ && [delegate_ respondsToSelector:@selector(didButtonClickedIndex:)]){
		[delegate_ didButtonClickedIndex:0];
	}
}


- (void) updateProgress:(float)progress{
	progressView_.progress = progress;

	if(progress < 1.0){
		progress_.text = [NSString stringWithFormat:@"%d%%", (int)(progress*100)];
	}
	else{
		progress_.text = NSLocalizedString(@"Please wait...",nil);
	}
}




@end