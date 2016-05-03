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

	id<LooksBrowserEventDelegate> __weak delegate;
	
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

@property(nonatomic, weak) id<LooksBrowserEventDelegate> delegate;

@property(nonatomic, strong) UIImageView *frameView;
@property(nonatomic, strong) UIImageView *borderView;
//@property(nonatomic, retain) UIImageView *titleBackgroundView;
@property(nonatomic, strong) UIView *titleBackgroundView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *descBackgroundView;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *lockView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) RenderingState renderingState;

@property(nonatomic) CGRect actualRect;

- (id)initWithFrame:(CGRect)frame lookInfo:(NSDictionary*)lookDic;
- (void)setThumbnailImage:(UIImage*)image;
- (void)resizeThumbnailImage; //bret
//- (void)landscapeWithFrame:(CGRect)frame;
//
//- (void)portraitWithFrame:(CGRect)frame;

@end