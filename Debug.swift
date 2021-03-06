//
//  Debug.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/5/16.
//
//

import UIKit
import Photos

class Debug: NSObject {
    
    static func addDefaultVideoIfEmpty() {
        if !hasVideos() {
            print("Copying default video")
//            let baseURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
            
            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(baseURL.URLByAppendingPathComponent("IMG_0646.MOV"))
//                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(baseURL.URLByAppendingPathComponent("IMG_3034.MOV"))
//                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(baseURL.URLByAppendingPathComponent("error.mp4"))
            }, completionHandler: { (success, error) in
                print("copied", success, error as Any)
            })
        }
        else {
            print("DEBUG already has videos")
        }
    }
    
    static func hasVideos() -> Bool {
        let options = PHFetchOptions()
//        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(with: .video, options: options)
        return result.count > 0
    }
}
