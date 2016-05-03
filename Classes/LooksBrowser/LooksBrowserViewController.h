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

@interface LooksBrowserViewController : UIViewController <SKProductsRequestDelegate, LooksBrowserEventDelegate, UIScrollViewDelegate, UIAlertViewDelegate
,UITableViewDelegate, UITableViewDataSource>
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

@property (nonatomic, retain) NSArray *products;
@property (nonatomic, retain) NSMutableArray *groupsViews;
@property (nonatomic, retain) NSMutableArray *looksViews;
//
//@property (nonatomic, retain) UIImageView *overView;
//@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) NSString *productIdentifier;

@property (nonatomic, retain) UIScrollView *groupsScrollView;
@property (nonatomic, retain) UIScrollView *looksScrollView;
@property (nonatomic, retain) NSMutableDictionary *requestDictionary;

- (void)processingOnscreenLooks;
- (void)layoutAfterorientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
