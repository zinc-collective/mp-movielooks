//
//  FootView.h
//  MobileLooks
//
//  Created by George on 10/18/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FootView : UIView
{
	UILabel *groupNameLabel;
	UILabel *lookNameLabel;
}

-(void)setGroupName:(NSString*)groupName andLookName:(NSString*)lookName;

@end
