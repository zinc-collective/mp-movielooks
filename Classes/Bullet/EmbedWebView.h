//
//  EmbedWebView.h
//  MobileLooks
//
//  Created by jack on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmbedWebView : UIView<UIWebViewDelegate, UITextFieldDelegate> {
	UILabel						*mTitle;
	UIWebView					*browser_;
	NSString					*url_;
	BOOL						bLoading;
	
	UITextField					*mSearchField;
}
@property (nonatomic,retain) NSString* url_;

- (void) openUrl:(NSString*)uri;
- (void) reLoad;

- (void)goBack;
- (void)goForward;

@end
