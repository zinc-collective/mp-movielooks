//
//  EmbedWebView.h
//  MobileLooks
//
//  Created by jack on 9/8/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmbedWebView : UIView<UIWebViewDelegate, UITextFieldDelegate> {
	UILabel						*mTitle;
	UIWebView					*browser_;
	NSString					*url_;
	BOOL						bLoading;

	UITextField					*mSearchField;
}
@property (nonatomic,strong) NSString* url_;

- (void) openUrl:(NSString*)uri;
- (void) reLoad;

- (void)goBack;
- (void)goForward;

@end
