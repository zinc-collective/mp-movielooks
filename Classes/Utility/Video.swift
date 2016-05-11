//
//  Video.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit
import AVFoundation

class Video {
    
    static let sharedManager = Video()
    
    func keyFrame(videoURL:NSURL, atTime: CMTime) throws -> UIImage {
        let avAsset = AVURLAsset(URL: videoURL, options: nil)
        let avImageGenerator = AVAssetImageGenerator(asset: avAsset)
        avImageGenerator.appliesPreferredTrackTransform = true
        avImageGenerator.maximumSize = CGSize(width: 800, height: 800)
        
//        let videoSize = AVAssetUtilities.naturalSize(avAsset)
//        let videoDuration = CMTimeGetSeconds(avAsset.duration)
//        NSLog("Video Time:%f", CMTimeGetSeconds(avAsset.duration))
        
        // where do I get this?
//        var currentTime: CMTime = mPlayer.currentTime()
        let keyFrameRef: CGImageRef = try avImageGenerator.copyCGImageAtTime(atTime, actualTime: nil)
        
        let keyFrame = UIImage(CGImage: keyFrameRef)
        return keyFrame
    }
    
    func renderSize(originalSize: CGSize, displaySize: CGSize) -> CGSize {
        let ratio = originalSize.height / originalSize.width
        
        if ratio < 1 {
            let height = displaySize.width * ratio
            return CGSize(width: displaySize.width, height: height)
        }
        else {
            let width = displaySize.height / ratio
            return CGSize(width: width, height: displaySize.height)
        }
    }
    
//        let imageData = UIImagePNGRepresentation(keyFrame)
//        var imagePath: String = Utilities.savedKeyFrameImagePath()
//        imageData.writeToFile(imagePath, atomically: false)
    
//    func saveVideo() {
//        Utilities.selectedVideoPathWithURL(mURL)
//    }
}