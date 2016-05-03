//
//  AVAssetUtilities.m
//  MovieLooks
//
//  Created by Sean Hess on 5/3/16.
//
//

#import "AVAssetUtilities.h"

@implementation AVAssetUtilities

+ (CGSize)naturalSize:(AVAsset*)asset {
    AVAssetTrack * track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    return CGSizeMake(fabs(size.width), fabs(size.height));
}

@end
