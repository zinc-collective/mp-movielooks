//
//  YoutubeConnect.m
//  MobileLooks
//
//  Created by Joseph Snow on 8/27/13.
//
//

#import "YoutubeConnect.h"

// #import "GTM


// MovieLooks Google/YouTube APP IDs
#define GOOGLE_CLIENT_ID @"642649136327.apps.googleusercontent.com"
#define GOOGLE_CLIENT_SECRET @"iNHLqxyUj87Y6uRrgxftU7aC"
#define GOOGLE_APP_BUNDLE_ID @"com.redgiantsoftware.movielooks"
#define GOOGLE_APP_STORE_ID	@"id409948907"


@implementation YoutubeConnect


// Keychain item name for saving the user's authentication information.
NSString *const kKeychainItemName = @"com.redgiantsoftware.movielooks: YouTube";


- (NSString *) getPrivacy
{
	if (_privacy == nil) {
		_privacy = [[NSString alloc] initWithFormat:@"Public"];
	}
	return _privacy;
}

- (NSString *) getPrivacyLowercase
{
	NSString *retval = [self getPrivacy];
	if (retval) {
		retval = [retval lowercaseString];
	}
	return retval;
}

- (void) setPrivacy:(NSString *)value
{
	_privacy = [[value copy] autorelease];
}

- (NSString *) getUsername
{
	return [self signedInUsername];
}

- (void) signOutUser
{
	[self cancelUpload];
	
	[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
	self.youTubeService.authorizer = nil;
}

- (void) cancelUpload
{
	if (_uploadFileTicket) {
		[_uploadFileTicket cancelTicket];
		_uploadFileTicket = nil;
	}
}

- (void) uploadVideoToYoutube:(NSDictionary*)info
{
	if (![self isSignedIn]) {
		return;
	}

	// Collect the metadata for the upload from the user interface.

	// Status.
	GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
	status.privacyStatus = [self getPrivacyLowercase];

	// Snippet.
	GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
	snippet.title = [info objectForKey:@"title"]; // @"Test Title"; // [_uploadTitleField stringValue];
	snippet.descriptionProperty = @"MovieLooks Video";

	GTLYouTubeVideo *video = [GTLYouTubeVideo object];
	video.status = status;
	video.snippet = snippet;

	[self uploadVideoWithVideoObject:video info:info resumeUploadLocationURL:nil];
}

//called from UIActivity View Controller
- (void) uploadVideoToYoutubeUIActivity:(NSDictionary *)info
{
	if (![self isSignedIn]) {
		return;
	}
    
	// Collect the metadata for the upload from the user interface.
    
	// Status.
	GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
	status.privacyStatus = [self getPrivacyLowercase];
    
	// Snippet.
	GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
	snippet.title = [info objectForKey:@"title"]; // @"Test Title"; // [_uploadTitleField stringValue];
	//snippet.descriptionProperty = @"MovieLooks Video";
	snippet.descriptionProperty = [info objectForKey:@"desc"];
    if (snippet.descriptionProperty == nil)
        snippet.descriptionProperty = @"MovieLooks Video";
	GTLYouTubeVideo *video = [GTLYouTubeVideo object];
	video.status = status;
	video.snippet = snippet;
    
	[self uploadVideoWithVideoObjectUIActivity:video info:info resumeUploadLocationURL:nil];
}

- (void)uploadVideoWithVideoObject:(GTLYouTubeVideo *)video info:(NSDictionary *)info resumeUploadLocationURL:(NSURL *)locationURL
{
	// Get a file handle for the upload data.
	NSURL    *url  = [info objectForKey:@"videoUrl"];
	NSData   *data = [NSData dataWithContentsOfURL:url];

	if (data) {
		[self uploadVideoWithVideoObject2:video data:data info:info resumeUploadLocationURL:locationURL];
	} else if (url) {
		ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:url resultBlock:^(ALAsset *asset) {
			NSData *assetData = [Utilities extractVideoDataFromAsset:asset];
			[self uploadVideoWithVideoObject2:video data:assetData info:info resumeUploadLocationURL:locationURL];
		} failureBlock:^(NSError *error) {
			NSLog(@"Failed to get assetForURL");
		}];
	} else {
		NSLog(@"Failed to get URL");
	}
}

- (void)uploadVideoWithVideoObjectUIActivity:(GTLYouTubeVideo *)video info:(NSDictionary *)info resumeUploadLocationURL:(NSURL *)locationURL
{
	// Get a file handle for the upload data.
	NSURL    *url  = [info objectForKey:@"videoUrl"];
	NSData   *data = [NSData dataWithContentsOfURL:url];
    
	if (data)
    {
		[self uploadVideoWithVideoObject2UIActivity:video data:data info:info resumeUploadLocationURL:locationURL];
	} else if (url)
    {
		ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:url resultBlock:^(ALAsset *asset) {
			NSData *assetData = [Utilities extractVideoDataFromAsset:asset];
			[self uploadVideoWithVideoObject2UIActivity:video data:assetData info:info resumeUploadLocationURL:locationURL];
		} failureBlock:^(NSError *error) {
			NSLog(@"Failed to get assetForURL");
		}];
	} else {
		NSLog(@"Failed to get URL");
	}
}

- (void)uploadVideoWithVideoObject2:(GTLYouTubeVideo *)video data:(NSData *)data info:(NSDictionary *)info resumeUploadLocationURL:(NSURL *)locationURL
{
	if (data) { 
		NSString *mimeType = [self MIMETypeForFilename:nil defaultMIMEType:@"video/mp4"];
		GTLUploadParameters *uploadParameters =	[GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
		uploadParameters.uploadLocationURL = locationURL;

		GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
																			part:@"snippet,status"
																uploadParameters:uploadParameters];

		GTLServiceYouTube *service = self.youTubeService;
		_uploadFileTicket = [service executeQuery:query
								completionHandler:^(GTLServiceTicket *ticket,
													GTLYouTubeVideo *uploadedVideo,
													NSError *error) {
			// Callback
			_uploadFileTicket = nil;
			if (error == nil) {
				// upload success
				NSLog(@"youtube uploaded successfully");
				[self.delegate_ didFinishShare:true :nil];
			} else {
				NSLog(@"YouTube Upload Failed");
				NSString *error = [NSString stringWithFormat: @"%@", error];
				[self.delegate_ didFinishShare:false :error];
			}

			// [_uploadProgressIndicator setDoubleValue:0.0];
			_uploadLocationURL = nil;
			// [self updateUI];
		}];


		_uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
												  unsigned long long numberOfBytesRead,
												  unsigned long long dataLength) {
			[self.delegate_ sendingVideoDataToYoutube:numberOfBytesRead dataLength:dataLength];
		};

		// To allow restarting after stopping, we need to track the upload location
		// URL.
		//
		// For compatibility with systems that do not support Objective-C blocks
		// (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
		// progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL

		GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
		uploadFetcher.locationChangeBlock = ^(NSURL *url) {
			_uploadLocationURL = url;
		};
	} else {
		// Could not read file data.
		// [self displayAlert:@"File Not Found" format:@"Path: %@", path];
		NSLog(@"Error - File Not Found");
	}
}

- (void)uploadVideoWithVideoObject2UIActivity:(GTLYouTubeVideo *)video data:(NSData *)data info:(NSDictionary *)info resumeUploadLocationURL:(NSURL *)locationURL
{
	if (data)
    {
		NSString *mimeType = [self MIMETypeForFilename:nil defaultMIMEType:@"video/mp4"];
		GTLUploadParameters *uploadParameters =	[GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
		uploadParameters.uploadLocationURL = locationURL;
        
		GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
																			part:@"snippet,status"
																uploadParameters:uploadParameters];
        
		GTLServiceYouTube *service = self.youTubeService;
        
        service.shouldFetchInBackground = YES;
		
        _uploadFileTicket = [service executeQuery:query
								completionHandler:^(GTLServiceTicket *ticket,
													GTLYouTubeVideo *uploadedVideo,
													NSError *error) {
                                    // Callback
                                    _uploadFileTicket = nil;
                                    if (error == nil)
                                    {
                                        // upload success
                                        NSLog(@"youtube uploaded successfully UIActivity");
                                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                                        
                                        UILocalNotification *_localNotification = [[UILocalNotification alloc]init];
                                        //setting the fire dat of the local notification
                                        _localNotification.fireDate = nil;
                                        //setting the time zone
                                        _localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                        //setting the message to display
                                        _localNotification.alertBody = @"Upload successful! Your video will appear on Youtube shortly.";
                                        //default notification sound
                                        _localNotification.soundName = UILocalNotificationDefaultSoundName;
                                        //displaying the badge number
                                        //_localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
                                        _localNotification.applicationIconBadgeNumber = 1;
                                        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
                                        _localNotification.userInfo = infoDict;
                                        //schedule a notification at its specified time with the help of the app delegate
                                        [[UIApplication sharedApplication]scheduleLocalNotification:_localNotification];
                                        //bret
                                        //[self.delegate_ didFinishShare:true :nil];
                                    } else
                                    {
                                        NSLog(@"YouTube Upload Failed UIActivity");
                                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                                        NSString *error = [NSString stringWithFormat: @"%@", error];
                                        UILocalNotification *_localNotification = [[UILocalNotification alloc]init];
                                        //setting the fire dat of the local notification
                                        _localNotification.fireDate = nil;
                                        //setting the time zone
                                        _localNotification.timeZone = [NSTimeZone defaultTimeZone];
                                        //setting the message to display
                                        _localNotification.alertBody = @"Upload error! Please try again later.";
                                        //default notification sound
                                        _localNotification.soundName = UILocalNotificationDefaultSoundName;
                                        //displaying the badge number
                                        //_localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
                                        _localNotification.applicationIconBadgeNumber = 1;
                                        //schedule a notification at its specified time with the help of the app delegate
                                        [[UIApplication sharedApplication]scheduleLocalNotification:_localNotification];
                                        //bret
                                        //[self.delegate_ didFinishShare:false :error];
                                    }
                                    
                                    // [_uploadProgressIndicator setDoubleValue:0.0];
                                    _uploadLocationURL = nil;
                                    // [self updateUI];
                                }];
        
		//bret
        //_uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
		//										  unsigned long long numberOfBytesRead,
		//										  unsigned long long dataLength) {
		//	[self.delegate_ sendingVideoDataToYoutube:numberOfBytesRead dataLength:dataLength];
		//};
        
		// To allow restarting after stopping, we need to track the upload location
		// URL.
		//
		// For compatibility with systems that do not support Objective-C blocks
		// (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
		// progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
        
		GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
		uploadFetcher.locationChangeBlock = ^(NSURL *url) {
			_uploadLocationURL = url;
		};
	} else
    {
		// Could not read file data.
		// [self displayAlert:@"File Not Found" format:@"Path: %@", path];
		NSLog(@"Error - File Not Found");
	}
}

- (NSString *)MIMETypeForFilename:(NSString *)filename
                  defaultMIMEType:(NSString *)defaultType
{
#if 1
	return defaultType;
#else
	NSString *result = defaultType;
	NSString *extension = [filename pathExtension];
	CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
	if (uti) {
		CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
		if (cfMIMEType) {
		  result = CFBridgingRelease(cfMIMEType);
		}
		CFRelease(uti);
	}
	return result;
#endif
}

- (NSString *)signedInUsername {
	// Get the email address of the signed-in user.
	GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
	BOOL isSignedIn = (auth != nil && auth.canAuthorize);
	if (isSignedIn) {
		return auth.userEmail;
	} else {
		return nil;
	}
}

- (BOOL)isSignedIn {
	NSString *name = [self signedInUsername];
    if (name != nil)
        return YES;
    else
        return NO;
	//return (name != nil);
}


-(void)backAction:(id)sender
{
    //UINavigationController* navigationController = [self.delegate_ getNavigationController];
    //[navigationController popViewControllerAnimated:YES];
}

- (void)runSigninThenHandler:(void (^)(void))handler {
	// Applications should have client ID and client secret strings
	// hardcoded into the source, but the sample application asks the
	// developer for the strings.
	NSString *clientID = GOOGLE_CLIENT_ID;
	NSString *clientSecret = GOOGLE_CLIENT_SECRET;

	GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
  
	if (auth == nil || !auth.canAuthorize) {

		self.kAuthHandler = handler;
  
		// Show the OAuth 2 sign-in controller.
		GTMOAuth2ViewControllerTouch *viewController;
		viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
								 clientID:clientID
						     clientSecret:clientSecret
						 keychainItemName:kKeychainItemName
							     delegate:self
						 finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
        //UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Test",nil) style:UIBarButtonItemStylePlain target:viewController action:@selector(backAction:)];
        //viewController.navigationItem.leftBarButtonItem = backButton;
        //viewController.navigationItem.leftBarButtonItem = nil;
        //[backButton release];
		
		//UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        UINavigationController* navigationController = [self.delegate_ getNavigationController];
        //ios 7
#if 0
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            //UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:viewController action:@selector(backAction:)];
            viewController.navigationItem.backBarButtonItem.title= @"Cancel";
            //[backButton release];
        }
#endif
		[navigationController pushViewController:viewController animated:YES];
        //[self presentModalViewController:navigationController animated:YES];
		
		auth = viewController.authentication;
		self.youTubeService.authorizer = auth;
		
		// [viewController release];
	} else
    {
		// Callback
		if (handler)
        {
            handler();
        }
		self.kAuthHandler = nil;
		
		// UINavigationController* navigationController = [self.delegate_ getNavigationController];
		// [navigationController popViewControllerAnimated:YES];
	}
}

- (GTMOAuth2ViewControllerTouch *)getGTMOAuth2ViewControllerTouch:(void (^)(void))handler
{
	// Applications should have client ID and client secret strings
	// hardcoded into the source, but the sample application asks the
	// developer for the strings.
	NSString *clientID = GOOGLE_CLIENT_ID;
	NSString *clientSecret = GOOGLE_CLIENT_SECRET;
    
	GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
    
	if (auth == nil || !auth.canAuthorize)
    {
        
		self.kAuthHandler = handler;
        
		// Show the OAuth 2 sign-in controller.
		GTMOAuth2ViewControllerTouch *viewController;
		viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                     clientID:clientID
                                                                 clientSecret:clientSecret
                                                             keychainItemName:kKeychainItemName
                                                                     delegate:self
                                                             finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
		
        //[self presentViewController:viewController animated:TRUE completion:nil];
		
		auth = viewController.authentication;
		self.youTubeService.authorizer = auth;
        return viewController;
		// [viewController release];
	} else
    {
		// Callback
		if (handler)
        {
            handler();
        }
		self.kAuthHandler = nil;
		
		// UINavigationController* navigationController = [self.delegate_ getNavigationController];
		// [navigationController popViewControllerAnimated:YES];
        return nil;
	}
    
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
				finishedWithAuth:(GTMOAuth2Authentication *)auth
                error:(NSError *)error
{
	// UINavigationController* navigationController = [self.delegate_ getNavigationController];
	// [navigationController popViewControllerAnimated:YES];
	
	if (error != nil) {
		// Authentication failed
	} else {
		// Authentication succeeded
	}
	
	if (self.kAuthHandler) {
		self.kAuthHandler();
		self.kAuthHandler = nil;
	}
	
	/* if (viewController) {
		[viewController release];
		viewController = nil;
	} */
}

// Get a service object with the current username/password.
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information such as cookies set by the server in response
// to queries.

- (GTLServiceYouTube *)youTubeService {
  static GTLServiceYouTube *service;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    service = [[GTLServiceYouTube alloc] init];

    // Have the service object set tickets to fetch consecutive pages
    // of the feed so we do not need to manually fetch them.
    service.shouldFetchNextPages = YES;

    // Have the service object set tickets to retry temporary error conditions
    // automatically.
    service.retryEnabled = YES;
	
	// assign the default authorizer and retrieve cached user credentials if they exist
	service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
																		 clientID:GOOGLE_CLIENT_ID
																		 clientSecret:GOOGLE_CLIENT_SECRET];
  });
  return service;
}


@end
