//  MobileLooks
//
//  Created by jack on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WaitDialog.h"

#define LABEL_TAG 130
#define INDICATOR_TAG 271

@implementation WaitDialog

- (id) initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){
		
		UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		backGroundView.backgroundColor = [UIColor blackColor];
		backGroundView.alpha = 0.0;
		backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		[self addSubview:backGroundView];
		
		// create indicator
		float top = (frame.size.height - 20)/2.0;
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, top, 20, 20)];
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		indicator.tag = INDICATOR_TAG;
		//indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		//[indicator startAnimating];
		[self addSubview:indicator];
		[indicator release];
		
		// label
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, top+40+10, 100, 20)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont systemFontOfSize:14];
		label.textAlignment = UITextAlignmentLeft;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.tag = LABEL_TAG;
		[self addSubview:label];
		[label release];
		
		self.backgroundColor = [UIColor clearColor];
		return self;
	}
    return nil;
}

- (void) updateSpin{
	
	UIView *v = [self viewWithTag:INDICATOR_TAG];
	v.center = self.center;
}

- (void) dealloc {
    if (title_) {
		[title_ release];
    }
    [super dealloc];
}

- (UIView *) createView
{
    
    
    return nil;
}

- (void) setTitle:(NSString *)title {
    title_ = [title copy];
}

#pragma mark Actions for wait dialog
- (void) startLoading {
	//self.hidden = NO;
	// smallActivity
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
	//[indicator stopAnimating];
	[indicator startAnimating];
	
	// label
	[(UILabel *)[self viewWithTag:LABEL_TAG] setText:title_];
}

- (void) endLoading {
    if (title_) {
		[title_ release];
    }
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//self.hidden = YES;
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
	[indicator stopAnimating];
}


@end