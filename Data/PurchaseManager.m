//
//  PurchaseManager.m
//  MovieLooks
//
//  Created by Sean Hess on 5/5/16.
//
//

#import "PurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import "MyStoreObserver.h"

@implementation PurchaseManager

-(void)updatePurchaseWithLooks:(NSArray *)newVersionLooks
{
    NSArray *userDefaultLooks = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserLooks];
    NSMutableArray *mutableLooks = [NSMutableArray arrayWithCapacity:[userDefaultLooks count]];
    NSUInteger maxLooksCount = fmax([newVersionLooks count],[userDefaultLooks count]);
    for (NSUInteger index = 0; index < maxLooksCount; ++index)
    {
        NSDictionary* newVersionDic = [newVersionLooks objectAtIndex:index];
        NSDictionary* userDefaultDic = [userDefaultLooks objectAtIndex:index];
        
        BOOL newVersionIsLocked = [[newVersionDic objectForKey:kProductLocked] boolValue];
        if(newVersionIsLocked)
            [mutableLooks addObject:userDefaultDic];
        else
            [mutableLooks addObject:newVersionDic];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableLooks forKey:kUserLooks];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark In App Purchase

- (void) initInAppPurchase
{
    //#ifndef TARGET_IPHONE_SIMULATOR
    MyStoreObserver *observer = [[MyStoreObserver alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    // NSLog(@"PaymentQueue init successs.");
    //[observer release];
    //#endif
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray *looks = [prefs arrayForKey:kUserLooks];
    if (looks == nil)
    {
        looks = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"looks" withExtension:@"plist"]];
        [prefs setObject:looks forKey:kUserLooks];
        [prefs synchronize];
    }
    else {
        NSArray* plistLooks = [NSMutableArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"looks" withExtension:@"plist"]];
        [self updatePurchaseWithLooks:plistLooks];
    }
}




//-(void)startPurchaseMask
//{
//    [window addSubview:purchaseMaskView];
//    purchaseMaskView.center = window.center;
//    [purchaseMaskView setAlpha:0.0f];
//    [UIView animateWithDuration:1.50 delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         [purchaseMaskView setAlpha:0.6f];
//                     }
//                     completion:^(BOOL finished){
//                     }
//     ];
//    [purchaseIndicatorView startAnimating];
//}
//
//- (void)showNetworkActivityIndicator
//{
//    UIApplication *application = [UIApplication sharedApplication];
//    application.networkActivityIndicatorVisible = YES;
//}
//
//- (void)hiddenNetworkActivityIndicator
//{
//    UIApplication *application = [UIApplication sharedApplication];
//    application.networkActivityIndicatorVisible = NO;
//}
//
//
//-(void)endPurchaseMask
//{
//    [purchaseMaskView setAlpha:0.6f];
//    [UIView animateWithDuration:1.50 delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         [purchaseMaskView setAlpha:0.6f];
//                     }
//                     completion:^(BOOL finished){
//                         [purchaseMaskView removeFromSuperview];
//                     }
//     ];	
//    [purchaseIndicatorView stopAnimating];
//


@end
