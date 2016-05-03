//
//  YoutubeActivity.h
//  MobileLooks
//
//  Created by Bret Timmins on 01/05/14.
//
//

#import <UIKit/UIKit.h>
//#import "YoutubeConnect.h"
#import "YoutubeUIActivityShareViewController.h"

@interface YoutubeActivity : UIActivity <YoutubeUIActivityShareViewControllerDelegate>
{
    //YoutubeConnect		*_youtube;
    //GTMOAuth2ViewControllerTouch *youTubeSignInViewController;
    YoutubeUIActivityShareViewController *youTubeUIActivityShareViewController;
    UIImage             *mThumbImage;
    NSString    *processedMoviePath;
}
@property (nonatomic, strong) UIImage *mThumbImage;
@property (nonatomic, strong) NSString *processedMoviePath;

@end

