//
//  CustomAlertView.h
//  CakeLove
//
//  Created by radar on 10-3-29.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	indexLeft  = 0,
	indexRight = 1
} ButtonIndex;

typedef enum {
	layerBackView  = 10000,
	layerAlertView = 10001,
	layerTopImage  = 10002,
	layerMidImage  = 10003,
	layerBtmImage  = 10004,
	layerShadow    = 10005,
	layerTitle     = 10006,
	layerContent   = 10007,
	layerLeftBtn   = 10008,
	layerRightBtn  = 10009
} CustomAlertLayerTag;



@class CustomAlertView;
@protocol CustomAlertDelegate <NSObject>
@optional
- (void)customAlertView:(CustomAlertView *)cAlertView clickedButtonAtIndex:(ButtonIndex)buttonIndex;
@end



@interface CustomAlertView : UIView {

	UIView *_alertView;
	
@private
	id _delegate;	
}

@property (assign) id<CustomAlertDelegate> delegate;


#pragma mark -
#pragma mark out use
-(id)initWithTitle:(NSString*)title contentView:(UIView*)contentView delegate:(id)dele leftBtnImage:(UIImage*)leftBtnImage rightBtnImage:(UIImage*)rightBtnImage; //for contentview
-(void)show;



@end
