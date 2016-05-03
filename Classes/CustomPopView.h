//
//  CustomPopView.h
//  MobileLooks
//
//  Created by jack on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPopViewDelegate

@optional
- (void) popView:(UIView*)sender clickedButtonAtIndex:(NSInteger)index;

@end


@interface CustomPopView : UIView {
	id __weak delegate_;
	CGSize framePortraitSize;
}
@property (nonatomic, weak) id <CustomPopViewDelegate> delegate_;

- (id) initWithButtons:(NSArray*)buttons frame:(CGRect)frame;

@end
