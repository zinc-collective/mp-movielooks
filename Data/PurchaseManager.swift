//
//  PurchaseManager.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//



import UIKit

class PurchaseManager: NSObject {
    
    static let sharedManager = PurchaseManager()
    
    let looks = PurchaseManager.loadLooks()
    let observer = MyStoreObserver()
    
    static func loadLooks() -> [LookGroup] {
        let bundleLooksURL = Bundle.main.url(forResource: "looks", withExtension: "plist")!
        let bundleLooks = NSArray(contentsOf: bundleLooksURL) as! [[String : AnyObject]]
        return bundleLooks.compactMap(LookGroup.parse)
    }
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(observer)
    }
    
//    let kUserLooks = "looks"
//    let	kProductLocked = "locked"
    
//    func updatePurchaseWithLooks(newVersionLooks:[NSDictionary]) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        let userDefaultLooks = defaults.arrayForKey(kUserLooks) ?? []
//        let looks :NSMutableArray = []
//        let maxLooksCount = max(newVersionLooks.count, userDefaultLooks.count)
//        
//        for index in 0...(maxLooksCount-1)
//        {
//            let newVersionDic = newVersionLooks[index]
//            let userDefaultDic = userDefaultLooks[index]
//            
//            let newVersionIsLocked :Bool = newVersionDic.objectForKey(kProductLocked)!.boolValue
//            if newVersionIsLocked {
//                looks.addObject(userDefaultDic)
//            }
//            else {
//                looks.addObject(newVersionDic)
//            }
//        }
//        
//        print(looks)
//        
//        defaults.setObject(looks, forKey: kUserLooks)
//        defaults.synchronize()
//    }
    

//    func initInAppPurchase() {
//        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let bundleLooksURL = NSBundle.mainBundle().URLForResource("looks", withExtension: "plist")!
//        
//        var looks = defaults.arrayForKey(kUserLooks) as NSArray?
//        if (looks == nil)
//        {
//            looks = NSArray(contentsOfURL: bundleLooksURL)
//            defaults.setObject(looks, forKey: kUserLooks)
//            defaults.synchronize()
//        }
//        else {
//            let bundleLooks = NSArray(contentsOfURL: bundleLooksURL) as! [NSDictionary]
//            self.updatePurchaseWithLooks(bundleLooks)
//        }
//    }




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

}
