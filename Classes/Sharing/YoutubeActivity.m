//
//  YoutubeActivity.m
//  MobileLooks
//
//  Created by Bret Timmins on 01/05/14.
//
//

#import "YoutubeActivity.h"

@implementation YoutubeActivity
@synthesize mThumbImage;
@synthesize processedMoviePath;

//OAuth1 Client login test
#if 0
- (BOOL)login:(NSString *)username password:(NSString *)password{
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"]];
    
    NSString *params = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&service=youtube&source=&continue=http://www.google.com/",username,password];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    
    NSHTTPURLResponse *response;
    NSError *error;
    [request setTimeoutInterval:120];
    NSData *replyData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *replyString = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",replyString);
    
    
    
    if([replyString rangeOfString:@"Auth="].location!=NSNotFound)
    {
        authToken=[[replyString componentsSeparatedByString:@"Auth="] objectAtIndex:1];
        return YES;
    }else{
        return NO;
    }
}
#endif

- (NSString *)activityType
{
    return @"com.redgiantsoftware.movielooks";
    //return @"yourappname.Review.App";
}

- (NSString *)activityTitle
{
    return @"YouTube";
}

- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"youtube_ui_ipad.png"];
    }
    else
    {
        return [UIImage imageNamed:@"youtube_ui_iphone.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"bret %s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"bret %s",__FUNCTION__);
#if 0
    if (_youtube == nil)
    {
        _youtube = [[YoutubeConnect alloc] init];
        _youtube.delegate_ = self;
    }
    
    [_youtube signOutUser];
    
    youTubeSignInViewController  = [_youtube getGTMOAuth2ViewControllerTouch:
     ^{
         if ([_youtube isSignedIn])
         {
             //[self _updateYoutubeSettings];
         }else
         {
         }
     }];
#endif
	youTubeUIActivityShareViewController = [[YoutubeUIActivityShareViewController alloc] init];
    youTubeUIActivityShareViewController.useYouTube = YES;
    youTubeUIActivityShareViewController.mThumbImage = mThumbImage;
    youTubeUIActivityShareViewController.processedMoviePath = processedMoviePath;
    youTubeUIActivityShareViewController.delegate = self;

}

- (UIViewController *)activityViewController
{
    NSLog(@"bret %s",__FUNCTION__);
#if 0
    if (youTubeSignInViewController != nil)
        return youTubeSignInViewController;
    else
        return nil;
#endif
    //return youTubeUIActivityShareViewController;

    //GSDropboxDestinationSelectionViewController *vc = [[GSDropboxDestinationSelectionViewController alloc] initWithStyle:UITableViewStylePlain];
    //vc.delegate = self;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:youTubeUIActivityShareViewController];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    return nc;

}

- (void)performActivity
{
    //bret: this function should not be called
    
    // This is where you can do anything you want, and is the whole reason for creating a custom
    // UIActivity
    NSLog(@"bret %s",__FUNCTION__);
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=yourappid"]];
    //[self activityDidFinish:YES];
}

#pragma mark - YoutubeUIActivityShareViewController delegate methods
- (void)youTubeUIActivityShareViewControllerDidUpload:(YoutubeUIActivityShareViewController *)viewController
{
    [self activityDidFinish:YES];
}

- (void)youTubeUIActivityShareViewControllerDidCancel:(YoutubeUIActivityShareViewController *)viewController
{
    [self activityDidFinish:NO];
}





@end