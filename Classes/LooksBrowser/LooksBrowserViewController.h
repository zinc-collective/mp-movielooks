//
//  LooksBrowserViewController.h
//  MobileLooks
//
//  Created by George on 8/24/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "LookPreviewController.h"
#import "LookThumbnailView.h"
#import "ScrollViewEnhancer.h"

@class ES2Renderer;
//@class FootView;

@interface LooksBrowserViewController : UIViewController <SKProductsRequestDelegate, LooksBrowserEventDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
	NSArray *products;
	NSMutableArray *groupsViews;
	NSMutableArray *looksViews;
	
    NSInteger selectedLookIndex; //storyboard
    NSInteger selectedGroupIndex;//storyboard
    
	NSString *productIdentifier;
	
	UIScrollView *groupsScrollView;
	BOOL thumbnailRequred;
    ScrollViewEnhancer *scrollEnhancer;
	UIScrollView *looksScrollView;
	NSMutableDictionary *requestDictionary;
	
	ES2Renderer *renderer;
	CGSize frameSize;
	CGSize outputSize; //bret now cropped
	CGSize originalOutputSize; //
	VideoMode videoMode;
	VideoMode originalVideoMode;
//	BOOL isRenderAlready;
	
	BOOL renderThreadCancel;
	BOOL mRenderThreadStop;
	NSCondition* renderCondition;
	NSMutableArray* renderQueue;
	
	NSMutableArray  *looksDic_;
	//UITableView		*tableView_;
	int				currentSelectedGroup;
	int				selectedGroupIndex_landscape;
	int				selectedGroupIndex_Portrait;
	
	
	UIImageView *backgroundView_;
	UIView *groupsBackgroundView;
	//UIImageView *groupsBackgroundView;
	
    UIButton *leftScrollButton;
    UIButton *rightScrollButton;
    UIButton *topScrollButton;
    UIButton *bottomScrollButton;
    UIButton *leftScrollOpaque;
    UIButton *rightScrollOpaque;
    UIButton *topScrollOpaque;
    UIButton *bottomScrollOpaque;
    UIView *buttonBottomOpaque;
    
    UIButton *backToTrimButton;
    UIButton *nextButton;
    BOOL mScrollViewHackFirstTime;

	NSMutableDictionary *headers;
}


@property (assign) BOOL isRenderThreadStop;

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSMutableArray *groupsViews;
@property (nonatomic, strong) NSMutableArray *looksViews;
//
//@property (nonatomic, retain) UIImageView *overView;
//@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *productIdentifier;

@property (nonatomic, strong) UIScrollView *groupsScrollView;
@property (nonatomic, strong) UIScrollView *looksScrollView;
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;

@property (nonatomic, strong) SKProduct *currentProduct;

- (void)processingOnscreenLooks;
- (void)layoutAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
