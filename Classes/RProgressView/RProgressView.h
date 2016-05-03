//
//  RProgressView.h
//  FlickrPlug
//
//  Created by jack on 4/8/09.
//  Copyright 2009 Redsafi. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RProgressViewDelegate
@optional
- (void) didButtonClickedIndex:(int)index;
@end


@protocol RProgressViewDelegate;

@interface RProgressView : UIView {
	
	id				 delegate_;
    UILabel	         *progress_;
	UIProgressView   *progressView_;

}
@property (nonatomic, assign) id <RProgressViewDelegate> delegate_;



#pragma mark -
#pragma mark system functions @rewrited
//logo: facebook, flickr
- (id) initWithProgress:(CGRect)frame showLogo:(NSString*)logo;



#pragma mark -
#pragma mark in use functions
- (void) createView:(CGRect)frame;



#pragma mark -
#pragma mark out use functions
- (void) updteProgress:(float)progress;
- (void) showSuccess;
- (void) showFailed;
- (void) showProgress;


@end




