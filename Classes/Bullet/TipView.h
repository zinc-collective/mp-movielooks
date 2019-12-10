//
//  TipView.h
//  MobileLooks
//
//  Created by George on 11/15/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TipView : UIView
{
	UIImageView *borderView;
	UIImageView *background;

	UILabel *titleLabel;
	UILabel *contentLabel;
}

- (id)initWithFrame:(CGRect)frame title:(NSString*)title content:(NSString*)text;

- (void) setNewFrame:(CGRect)frame landscape:(BOOL)landscape;

@end
