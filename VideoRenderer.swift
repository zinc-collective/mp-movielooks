//
//  VideoRenderer.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/18/16.
//
//

import UIKit

enum RendererType {
    case Half
    case Full
}

protocol VideoRendererDelegate : class {
    func rendererFinished(videoURL:NSURL)
}

class VideoRenderer: NSObject, MovieProcessorDelegate {
    
//    var timeRemaining: Int = 0
    var renderType:RendererType = .Full
    weak var delegate:VideoRendererDelegate?
//    var renderFullFramerate: Bool = true
//    var videoMode:VideoMode = VideoModeWideSceenLandscape
    
//    let renderer = ES2Renderer(frameSize: CGSizeZero, outputFrameSize: CGSizeZero)
    var renderer : ES2Renderer!
    let movieProcessor : MovieProcessor!
    let outputSize: CGSize = CGSize(width: 100, height: 100)
    var needCheckPoint = true
    var framePastedFromPause = 0
//    var _completedFrames = 0
    
    init(videoURL:NSURL) {
        movieProcessor = MovieProcessor(readURL: videoURL)
        super.init()
        movieProcessor.delegate = self
    }
    
    func startRender(strength strength:Float, brightness:Float, look:Look, videoMode:VideoMode) {
        renderer.unloadKeyFrame()
		renderer.looksStrengthValue = strength
		renderer.looksBrightnessValue = brightness
    	renderer.loadLookParam(look.data, withMode:videoMode)
    	renderer.freeRenderBuffer()
        
        needCheckPoint = true
        
//		if([movieProcessor checkFor720P:&_totalFrames])
//			renderType = RendererTypeFull;
//		else
        
        movieProcessor.startRenderMovie()
        
//		timeRemaining = estimateFrameProcessTime*_totalFrames + ceil(_totalFrames/frameFPS)*estimateClipProcessTime;
//        timeScale = _totalFrames;
    }
    
    func processVideoFrame(sampleBuffer: CMSampleBuffer!, atTime sampleTime: CMTime) -> Unmanaged<CVPixelBuffer>! {
        
        var pixelBuffer : CVPixelBufferRef?
    		
    	// check if we are only rendering even frames.
//        if (renderFullFramerate) || (_curInputFrameIdx % 2) == 0) {
    	
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
    		// Lock the base address of the pixel buffer
    		CVPixelBufferLockBaseAddress(imageBuffer,0)
            let baseAddress = UnsafeMutablePointer<GLubyte>(CVPixelBufferGetBaseAddress(imageBuffer))
    		renderer.frameProcessing(baseAddress, toDest:baseAddress, flipPixel:true)
            
    		CVPixelBufferCreateWithBytes(nil, Int(outputSize.width), Int(outputSize.height),
    								 kCVPixelFormatType_32BGRA, baseAddress,
    								 Int(Int32(outputSize.width)*glPixelSize),
    								 nil,nil,nil,&pixelBuffer)
    	
    		CVPixelBufferUnlockBaseAddress(imageBuffer,0)
        }
        
//    		_completedFrames++;
    		framePastedFromPause += 1
//
    		// with higher resolution, we want to hold fewer frames in the checkpoint buffer.
        let CheckPointFrameCount = (renderType == .Full) ? 30 : 60
        
		if(framePastedFromPause>CheckPointFrameCount && (sampleTime.value % 300 < 20) && needCheckPoint)
		{
			framePastedFromPause = 0;
			movieProcessor.checkPointRenderMovie()
		}
    	
//    	_curInputFrameIdx++;
        
//        dispatch_async(dispatch_get_main_queue()) {
//                if ( _completedFrames != lastTimeRemaining)
//                {
//                    lastTimeRemaining = _completedFrames;
//                    int screenwidthl, screenwidthp;
//                    if (IS_IPAD)
//                    {
//                        screenwidthl = 1024;
//                        screenwidthp = 768;
//                    }else
//                    {
//                        if (IS_IPHONE_5)
//                        {
//                            screenwidthl = 568;
//                            screenwidthp = 320;
//                        }else
//                        {
//                            screenwidthl = 480;
//                            screenwidthp = 320;
//                        }
//                    }
//                    
//                    //timeScale is totalframes
//                    //_completedFrames is the current frame index
//                    //curve method 2
//                    float timeoffsetl = screenwidthl/timeScale;
//                    float timeoffsetp = screenwidthp/timeScale;
//                    float timezone = timeScale/8;
//                    if (_completedFrames < (timezone*1) )
//                    {
//                        timeoffsetl = timeoffsetl * 1.50;
//                        timeoffsetp = timeoffsetp * 1.50;
//                    }else if ( _completedFrames < (timezone*2) )
//                    {
//                        timeoffsetl = timeoffsetl * 1.25;
//                        timeoffsetp = timeoffsetp * 1.25;
//                    }else if ( _completedFrames < (timezone*3) )
//                    {
//                        timeoffsetl = timeoffsetl * 0.75;
//                        timeoffsetp = timeoffsetp * 0.75;
//                    }else if ( _completedFrames < (timezone*4) )
//                    {
//                        timeoffsetl = timeoffsetl * 0.50;
//                        timeoffsetp = timeoffsetp * 0.50;
//                    }else if ( _completedFrames < (timezone*5) )
//                    {
//                        timeoffsetl = timeoffsetl * 0.50;
//                        timeoffsetp = timeoffsetp * 0.50;
//                    }else if ( _completedFrames < (timezone*6) )
//                    {
//                        timeoffsetl = timeoffsetl * 0.75;
//                        timeoffsetp = timeoffsetp * 0.75;
//                    }else if ( _completedFrames < (timezone*7) )
//                    {
//                        timeoffsetl = timeoffsetl * 1.25;
//                        timeoffsetp = timeoffsetp * 1.25;
//                    }else
//                    {
//                        timeoffsetl = timeoffsetl * 1.50;
//                        timeoffsetp = timeoffsetp * 1.50;
//                    }
//                    
//                    timeElapsedLandscape = timeElapsedLandscape + timeoffsetl; //these are for rotation during render
//                    timeElapsedPortrait = timeElapsedLandscape + timeoffsetp;
//                    
//                    CGRect frame;
//                    frame = mOpaqueViewLandscape.frame;
//                    frame.origin.x = frame.origin.x + timeoffsetl;
//                    mOpaqueViewLandscape.frame = frame;
//                    frame = mOpaqueViewPortrait.frame;
//                    frame.origin.x = frame.origin.x + timeoffsetp;
//                    mOpaqueViewPortrait.frame = frame;
//                    //end curve method 2
//                }
//            }
    	return Unmanaged.passRetained(pixelBuffer!)
    }
    
    func knownVideoInfoEvent(videoSize: CGSize, withDuration duration: CMTime) -> CGSize {
        print("KNOWN VIDEO INFO EVENT", videoSize, duration)
        
        let outputSize = videoSize
        renderer.resetFrameSize(videoSize, outputFrameSize: outputSize)
        
    	let seconds =  CMTimeGetSeconds(duration)
    	needCheckPoint = (seconds > 2.0);
        
        return outputSize
    }
    
    func checkPointRenderMovieEvent() {
//    	NSLog(@"Video Clip Check Point!");
//    	CMTimeRange processRange = [movieProcessor getProcessRange];
//    	_completedFrames = (int)(processRange.start.value/20);
        print("checkPointRenderMovieEvent")
    }
    
    func cancelRenderMovieEvent() {
//    	NSLog(@"Video Stop!");
//    	[self.navigationController popViewControllerAnimated:YES];
        print("cancelRenderMovieEvent")
    }
    
    func finishRenderMovieEvent() {
        // I should call this with any extra stuff?
        
    	movieProcessor.startComposeMovie()
        print("finishRenderMovieEVent")
    }
    
    func errorSamplerMovieEvent() {
        print("changeSamplerMovieEvent")
    }
    
    func finishProcessMovieEvent(composeFilePath: String!) {
        print("finishProcessMovieEvent", composeFilePath)
        self.delegate?.rendererFinished(NSURL(fileURLWithPath: composeFilePath))
    }
    
    func finishSaveToCameraRollEvent() {
        print("finishSaveToCameraRollEvent")
    }
    
//    func setRendererType(type:RendererType, withFullFramerate:Bool, andLookParam:[String : AnyObject]) {
//    	timeRemaining = 0
//    	renderType = type
//    	renderFullFramerate = withFullFramerate;
//        renderer.loadLookParam(andLookParam, withMode:videoMode)
//    	renderer.freeRenderBuffer()
//    }
    
//    func estimateProcessingTimebyFrame(numFramesRemainingToProcess:Int) -> Int {
//        let fps:Float = 30.0
//    	let timeLeft = 0;
//    	// BOOL quickRender = renderer.doQuickRender;
//    	timeLeft = estimateFrameProcessTime*numFramesRemainingToProcess+ceil(numFramesRemainingToProcess/fps)*estimateClipProcessTime;
//    	if(numFramesRemainingToProcess==1)
//    		NSLog(@"========Last Frame!=======");
//    	return timeLeft;
//    }
    
    
//
//-(NSTimeInterval)estimateProcessingTime:(NSURL*)processURL withType:(RendererType)renderType withFullFramerate:(BOOL)renderFullFramerate
//{
//	// TODO: joe- this fps should come from the video itself.
//	// Or better yet, just grab a total count of all frames in the video if possible.
//	// it is assumed that videos recorded from the iPhone are usually very close to 30fps.
//	float fps = 30.0f;
//	
//	AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:processURL options:nil];
//	NSUInteger movieFrames = CMTimeGetSeconds(movieAsset.duration)*fps;
//	
//	if (!renderFullFramerate) {
//		movieFrames = ceil((float)movieFrames / 2.0);
//	}
//	
//    CGSize movieOriginSize = [AVAssetUtilities naturalSize:movieAsset];
//	CGSize movieOutputSize = movieOriginSize;
//	
//	CGFloat smallestSupportHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?120:100;
//	CGFloat smallestSupportWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?240:200;
//	if (renderType == RendererTypeHalf && movieOriginSize.height>smallestSupportHeight && movieOriginSize.width>smallestSupportWidth)
//		movieOutputSize = CGSizeMake(movieOriginSize.width/2.0, movieOriginSize.height/2.0);
//	[renderer resetFrameSize:movieOriginSize outputFrameSize:movieOutputSize];
//	estimateOutputSize = movieOutputSize;
//	
//	AVAssetImageGenerator* avImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:movieAsset];
//	[avImageGenerator setAppliesPreferredTrackTransform:YES];
//	[avImageGenerator setMaximumSize:movieOriginSize];
//	
//	//render buffer
//	CGImageRef estimateFrameRef =  [avImageGenerator copyCGImageAtTime:CMTimeMake(0, 600) actualTime:NULL error:NULL];
//	unsigned char* estimateFrameData = malloc(movieOriginSize.width*movieOriginSize.height * glPixelSize);
//	CGContextRef estimateFrameContext = CGBitmapContextCreate(estimateFrameData, movieOriginSize.width, movieOriginSize.height, 8, movieOriginSize.width * glPixelSize, CGImageGetColorSpace(estimateFrameRef), glImageAlphaNoneSkipLast);
//	CGContextSetBlendMode(estimateFrameContext, kCGBlendModeCopy);
//	CGContextDrawImage(estimateFrameContext, CGRectMake(0.0, 0.0, movieOriginSize.width, movieOriginSize.height), estimateFrameRef);
//	CGImageRelease(estimateFrameRef);
//	CGContextRelease(estimateFrameContext);
//
//	//rendering
//	NSTimeInterval singleFrameRenderStartTime = [NSDate timeIntervalSinceReferenceDate];
//	[renderer frameProcessing:estimateFrameData toDest:estimateFrameData flipPixel:YES];
//	estimateFrameProcessTime = [NSDate timeIntervalSinceReferenceDate]-singleFrameRenderStartTime;
//	
//	// NOTE: joe- this appears to be a scale factor that is applied to the eestimate.  Not sure where this is coming from ??
//	// This could be a factor of how much time is spend doing other things during the process loop.
//	// When the profiling the app, the frame rendering is approximately 66% of the time.
//	estimateClipProcessTime = 0.37;		
//
//	[renderer resetFrameSize:self.outputSize outputFrameSize:self.outputSize];
///*
//	//save rendered image  
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
//	CGContextRef imgCGContext = CGBitmapContextCreate (estimateFrameData, movieOutputSize.width, movieOutputSize.height, 8, movieOutputSize.width*glPixelSize, colorSpace,kCGImageAlphaPremultipliedLast);
//	CGImageRef imgRef = CGBitmapContextCreateImage(imgCGContext);
//	CGColorSpaceRelease(colorSpace); 
//	CGContextRelease(imgCGContext);
//
//	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//	[assetsLibrary writeImageToSavedPhotosAlbum:imgRef orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error){
//		dispatch_async(dispatch_get_main_queue(), ^{
//			CGImageRelease(imgRef);
//		});
//	}];
//	[assetsLibrary release];
//	
//*/
//
//	NSTimeInterval estimateRenderTimeRemaining = estimateFrameProcessTime*movieFrames+ceil(movieFrames/fps)*estimateClipProcessTime;
//	NSLog(@"Estimated Render Time: %f seconds", estimateRenderTimeRemaining);
//	
//	free(estimateFrameData);
//	
//	return estimateRenderTimeRemaining;
//}
    
}
