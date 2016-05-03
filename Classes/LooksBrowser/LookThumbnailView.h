//
//  ThumbnailView.h
//  MobileLooks
//
//  Created by George on 9/14/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LooksBrowserEventDelegate

- (void)tapLook:(NSInteger)lookIndex inGroup:(NSInteger)groupIndex;

@end

enum
{
    RenderingStateNone			= 0,
    RenderingStateRendering		= 1 << 0,
    RenderingStateCompleted		= 1 << 1
};
typedef NSUInteger RenderingState;

@protocol LooksBrowserEventDelegate;

@interface LookThumbnailView : UIView
{
	NSInteger groupIndex;
	NSInteger lookIndex;
	NSInteger pageIndex;

	id<LooksBrowserEventDelegate> delegate;
	
	UIImageView *frameView;
	UIImageView *borderView;
	UIView *titleBackgroundView;
	UILabel *titleLabel;
	UIView *descBackgroundView;
	UILabel *descLabel;
	UIImageView *lockView;
	UIActivityIndicatorView *activityIndicator;
	
	RenderingState renderingState;
	
	CGRect  actualRect;
}

@property(nonatomic) NSInteger groupIndex;
@property(nonatomic) NSInteger lookIndex;
@property(nonatomic) NSInteger pageIndex;

@property(nonatomic, assign) id<LooksBrowserEventDelegate> delegate;

@property(nonatomic, retain) UIImageView *frameView;
@property(nonatomic, retain) UIImageView *borderView;
//@property(nonatomic, retain) UIImageView *titleBackgroundView;
@property(nonatomic, retain) UIView *titleBackgroundView;
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UIView *descBackgroundView;
@property(nonatomic, retain) UILabel *descLabel;
@property(nonatomic, retain) UIImageView *lockView;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) RenderingState renderingState;

@property(nonatomic) CGRect actualRect;

- (id)initWithFrame:(CGRect)frame lookInfo:(NSDictionary*)lookDic;
- (void)setThumbnailImage:(UIImage*)image;
- (void)resizeThumbnailImage; //bret
//- (void)landscapeWithFrame:(CGRect)frame;
//
//- (void)portraitWithFrame:(CGRect)frame;

@end