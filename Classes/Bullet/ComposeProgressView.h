//
//  ComposeProgressView.h
//  MobileLooks
//
//  Created by Chen Mike on 1/20/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComposeProgressView : UIView {
	UILabel *titleLabel;
}

-(void)setTitleText:(NSString*)text withProgress:(CGFloat)progress;
@end
