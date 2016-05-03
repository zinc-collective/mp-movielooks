//
//  AVAssetUtilities.h
//  MovieLooks
//
//  Created by Sean Hess on 5/3/16.
//
//

#import <Foundation/Foundation.h>

@interface AVAssetUtilities : NSObject

+ (CGSize)naturalSize:(AVAsset*)asset;

@end
