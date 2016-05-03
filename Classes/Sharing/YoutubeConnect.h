//
//  YoutubeConnect.h
//  MobileLooks
//
//  Created by Joseph Snow on 8/27/13.
//
//

#import <Foundation/Foundation.h>


#import "GTLYouTube.h"
#import "GTLUtilities.h"
#import "GTMHTTPUploadFetcher.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTMOAuth2ViewControllerTouch.h"


typedef void(^YOUTUBE_HANDLER)(void);


@protocol YoutubeConnectDelegate
@optional
-(UINavigationController *) getNavigationController;
-(void) beganSendVideoData;
-(void) sendingVideoDataToYoutube:(unsigned long long)bytesRead dataLength:(unsigned long long)dataLength;
-(void) didFinishShare:(BOOL)success :(NSString*)errorMsg;
@end

@interface YoutubeConnect : NSObject {

	NSString *_privacy;
	
	GTLServiceTicket *_uploadFileTicket;
    NSURL *_uploadLocationURL;  // URL for restarting an upload.
}

@property (nonatomic, assign) id <YoutubeConnectDelegate> delegate_;

// http://stackoverflow.com/questions/4081831/how-to-store-blocks-in-properties-in-objective-c
@property(copy, nonatomic) YOUTUBE_HANDLER kAuthHandler;

- (NSString*) getPrivacy;
- (void) setPrivacy:(NSString *)value;
- (NSString *) getUsername;
- (BOOL) isSignedIn;

- (void) uploadVideoToYoutube:(NSDictionary*)info;
- (void) uploadVideoToYoutubeUIActivity:(NSDictionary*)info;
- (void) runSigninThenHandler:(void (^)(void))handler;
- (GTMOAuth2ViewControllerTouch *)getGTMOAuth2ViewControllerTouch:(void (^)(void))handler;

- (void) signOutUser;
- (void) cancelUpload;

// - (void) viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;

@end
