//
//  InfoViewController.h
//  MobileLooks
//
//  Created by George on 12/16/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController
{
	//UIScrollView *scrollView;
	//UIImageView *contentView;
	UIBarButtonItem		*_submitBtnItem;
}
@property (retain, nonatomic) IBOutlet UIImageView *contentView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


-(void)activeAction:(id)sender;
-(void)showActiveButton;

@end
