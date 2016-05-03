//  MobileLooks
//
//  Created by jack on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface WaitDialog : UIView {
    NSString	   *title_;

}



- (UIView *) createView;

- (void) setTitle:(NSString *)title;
- (void) startLoading;
- (void) endLoading;

- (void) updateSpin;

@end

