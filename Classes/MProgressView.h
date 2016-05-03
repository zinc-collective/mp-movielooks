//
//  MProgressView.h
//  FlickrPlug
//
//  Created by jack on 4/8/09.
//  Copyright 2009 Redsafi. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MPROGRESSVIEW_MAX_WIDTH 280


@protocol MProgressViewDelegate
@optional
- (void) didButtonClickedIndex:(int)index;
@end


@protocol MProgressViewDelegate;

@interface MProgressView : UIView {
	
	id				 delegate_;
    UILabel	         *progress_;
	UIProgressView   *progressView_;
	UIButton		 *cancelButton;
	UIView			 *boxView;
}
@property (nonatomic, assign) id <MProgressViewDelegate> delegate_;

-(UIView*)getBoxView;
-(UIButton*)getCancelButton;

#pragma mark -
#pragma mark system functions @rewrited


#pragma mark -
#pragma mark in use functions
- (void) createView:(CGRect)frame;



#pragma mark -
#pragma mark out use functions
- (void) updateProgress:(float)progress;


- (void) update;

@end




