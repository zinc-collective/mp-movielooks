//
//  MobileLooksPickerSource.m
//  MobileLooks
//
//  Created by Chen Mike on 3/15/11.
//  Copyright 2011 Red/SAFI. All rights reserved.
//

#import "MobileLooksPickerSource.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MobileLooksPickerSource_iTunesLibrary : MobileLooksPickerSource
{
	MPMediaLibrary* mLibrary;
	NSArray* mURLs;
}
-(void)regenerateURLs;
@end

@implementation MobileLooksPickerSource_iTunesLibrary
- (id)init
{
	if ((self = [super init]))
	{
		mLibrary = [MPMediaLibrary defaultMediaLibrary];
		
		[self regenerateURLs];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regenerateURLs) name:MPMediaLibraryDidChangeNotification object:mLibrary];
		[mLibrary beginGeneratingLibraryChangeNotifications];
	}
	
	return self;
}

- (void)dealloc
{
	[mLibrary endGeneratingLibraryChangeNotifications];
	
}

- (NSArray*)URLs
{
	return mURLs;
}

- (void)regenerateURLs
{
	MPMediaQuery *videoQuery = [[MPMediaQuery alloc] init];
	[videoQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:(MPMediaTypeAny ^ MPMediaTypeAnyAudio)] forProperty:MPMediaItemPropertyMediaType]];
	
	NSMutableArray* URLs = [[NSMutableArray allocWithZone:NULL] init];
	
	for (MPMediaItem* item in [videoQuery items])
		[URLs addObject:[item valueForProperty:MPMediaItemPropertyAssetURL]];
	
	mURLs = [URLs copyWithZone:nil];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MobileLooksPickerSourceItemsDidChangeNotification object:self];
}
@end

@interface MobileLooksPickerSource_iTunesFileSharing : MobileLooksPickerSource
{
	NSArray* mURLs;
	MPMediaLibrary* mLibrary;
}
- (void)regenerateURLs;
@end

@implementation MobileLooksPickerSource_iTunesFileSharing
- (id)init
{
	if ((self = [super init]))
	{
		[self regenerateURLs];
		
		/* MPMediaLibrary will fire a notification when these files change, even though they aren't in the library. */
		mLibrary = [MPMediaLibrary defaultMediaLibrary];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regenerateURLs) name:MPMediaLibraryDidChangeNotification object:mLibrary];
		[mLibrary beginGeneratingLibraryChangeNotifications];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaLibraryDidChangeNotification object:mLibrary];
	[mLibrary endGeneratingLibraryChangeNotifications];
	
}

- (NSArray*)URLs
{
	return mURLs;
}

- (void)regenerateURLs
{
	NSMutableArray* contentURLs = [NSMutableArray array];
	
	NSFileManager* fileManager = [[NSFileManager allocWithZone:NULL] init];
	NSArray* directoryURLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSAllDomainsMask];
	
	for (NSURL* directoryURL in directoryURLs)
	{
		NSArray* URLsToFilter = [fileManager contentsOfDirectoryAtURL:directoryURL
										   includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLTypeIdentifierKey, nil]
															  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles
																error:NULL];
		
		for (NSURL* URL in URLsToFilter)
		{
			NSString* typeIdentifier;
			
			if ([URL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:NULL] && !UTTypeConformsTo((__bridge CFStringRef)typeIdentifier, kUTTypeMovie))
				continue;
			
			[contentURLs addObject:URL];
		}
	}
	
	
	mURLs = [contentURLs copyWithZone:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MobileLooksPickerSourceItemsDidChangeNotification object:self];
}
@end

@interface MobileLooksPickerSource_CameraRoll : MobileLooksPickerSource
{
	ALAssetsLibrary* mLibrary;
	NSMutableArray* mAssetArray;
}
- (void)regenerateURLs;
@end

@implementation MobileLooksPickerSource_CameraRoll
- (id)init
{
	if ((self = [super init]))
	{
		mLibrary = [[ALAssetsLibrary allocWithZone:nil] init];
		mAssetArray = [[NSMutableArray alloc] init];
		[self regenerateURLs];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:mLibrary];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:mLibrary];
    
    
}

- (NSArray*)assetsArray
{
	return mAssetArray;
}

- (void)regenerateURLs
{
	[mAssetArray removeAllObjects];
	[mLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                            usingBlock:
     ^(ALAssetsGroup *group, BOOL *stop)
     {
         if (!group)
         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                //[mURLs release];
								//mURLs = [URLs copyWithZone:[self zone]];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:MobileLooksPickerSourceItemsDidChangeNotification object:self];
                            });
             
             *stop = YES;
             return;
         }

		 [group setAssetsFilter:[ALAssetsFilter allVideos]];
         [group enumerateAssetsUsingBlock:
          ^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (!asset)
              {
                  *stop = YES;
                  return;
              }
		[mAssetArray addObject:asset];
          }];
     }
                          failureBlock:
     ^(NSError *error)
     {
		 NSLog(@"%@",[error localizedDescription]);
		 [[NSNotificationCenter defaultCenter] postNotificationName:MobileLooksPickerSourceItemsDeniedAccessNotification object:self];
     }];
	
}

- (void)assetLibraryDidChange:(NSNotification*) notification
{
	[self regenerateURLs];
}
@end


@implementation MobileLooksPickerSource
/*
+ (MobileLooksPickerSource*)cameraRollSource
{
	return [[[MobileLooksPickerSource_CameraRoll allocWithZone:NULL] init] autorelease];
}
*/
+ (MobileLooksPickerSource*)cameraRollSource
{
	return [[MobileLooksPickerSource_CameraRoll alloc] init];
}

+ (MobileLooksPickerSource*)iTunesLibrarySource
{
	return [[MobileLooksPickerSource_iTunesLibrary alloc] init];
}

+ (MobileLooksPickerSource*)iTunesFileSharingSource
{
	return [[MobileLooksPickerSource_iTunesFileSharing alloc] init];
}

-(NSArray*)URLs
{
    return nil;
}

-(NSArray*)assetsArray
{
	return nil;
}
@end


NSString* const MobileLooksPickerSourceItemsDidChangeNotification = @"MobileLooksPickerSourceItemsDidChangeNotification";
NSString* const MobileLooksPickerSourceItemsDeniedAccessNotification = @"MobileLooksPickerSourceItemsDeniedAccessNotification";
