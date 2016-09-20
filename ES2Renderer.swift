//
//  ES2Renderer.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/10/16.
//
//

import UIKit

class ES2Renderer: ES2RendererOld {
    
    func loadKeyFrame(_ image:UIImage) {
        // save the key frame
        // the renderer requires this, because it is retarted
        if let imageData = UIImagePNGRepresentation(image) {
            let imagePath = Utilities.savedKeyFrameImagePath()
            try? imageData.write(to: URL(fileURLWithPath: imagePath!), options: [])
        }
        
        self.loadKeyFrameCrop()
    }
}
