//
//  LooksBrowserViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit
import BButton
import Crashlytics

let LookCellIdentifier = "LookCell"
let LookGroupHeaderIdentifier = "LookGroupHeader"

class LooksBrowserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextButton: BButton!
    @IBOutlet weak var looksView: UICollectionView!
    
    var keyFrame : UIImage!
    var renderer : ES2Renderer!
    var cellSize : CGSize = CGSize(width: 170, height: 170)
    var selectedLook : Look?
    var videoURL: URL?
    
    var videoMode = VideoModeWideSceenLandscape
    
    let lookGroups = PurchaseManager.sharedManager.looks
    var lookStates : [Look : LookCellState] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setType(.primary)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        
        if (videoURL == nil) {
            CLSLogv("loadVideo not called before load", getVaList([]))
            Crashlytics.sharedInstance().crash()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
//        lookStates = [:]
        super.didReceiveMemoryWarning()
    }
    
    // needs to be called BEFORE loading
    func loadVideo(_ videoURL:URL) throws {
        self.videoURL = videoURL
        keyFrame = try Video.sharedManager.keyFrame(videoURL, atTime: CMTime.zero)
        cellSize = cellSize(keyFrame)
        lookStates = lookStates(lookGroups)
        
        let scale = UIScreen.main.scale
        let outputSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        renderer = ES2Renderer(frameSize: outputSize, outputFrameSize: outputSize)
        startRender(keyFrame)
    }
    
    func startRender(_ keyFrame:UIImage) {
        // no matter what you put in for the size, the renderer will create a square image and fill the space
        // that you give it. So make sure this is square
        let scale = UIScreen.main.scale
        let outputSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        renderer.resetFrameSize(outputSize, outputFrameSize: outputSize)
        renderer.resetRenderBuffer()
        renderer.loadKeyFrame(keyFrame)
        DispatchQueue.global().async {
            self.renderLoop()
        }
    }
    
    func lookStates(_ lookGroups: [LookGroup]) -> [Look : LookCellState] {
        var states : [Look : LookCellState] = [:]
        lookGroups
            .flatMap({group in
                return group.items.map({look in
                    return LookCellState(look: look)
                })
            })
            .forEach({(state : LookCellState) in
                states[state.look] = state
            })
       
        return states
    }
    
    func renderLoop() {
        // create all the look states
        
        var renderStates = Array(lookStates.values)
        
        // NOTE: the first one fails for some reason (this was there in the legacy code uncommented)
        // so render it twice
        renderStates = renderStates + [renderStates[0]]
        
        renderStates.forEach { (state) in
            
            let look = state.look
            renderer.loadLookParam(look.data, with: self.videoMode)
			renderer.looksStrengthValue = 1.0
			renderer.looksBrightnessValue = 0.5
            
			let processedCGImageRef = renderer.frameProcessingAndReturnImage(nil, flipPixel:false)
            
//			if(videoMode==VideoModeWideSceenPortrait || videoMode==VideoModeTraditionalPortrait) {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef  scale:1.0 orientation:UIImageOrientationRight];
//			}
//			else {
//				processedImage = [[UIImage alloc] initWithCGImage:processedCGImageRef];
//			}
            
            
            let processedImage = UIImage(cgImage: (processedCGImageRef?.takeUnretainedValue())!)
            print(" - got image", look.name)
			
            DispatchQueue.main.async {
                print(" - set image", look.name)
                state.image = processedImage
                state.onRender(processedImage)
            }
        }
    }
    
    func cellSize(_ keyFrame:UIImage) -> CGSize {
        // these should always be square
        return CGSize(width: 170, height: 170)
    }
    
    @IBAction func tappedNext() {
        print("NEXT")
        
        self.performSegue(withIdentifier: "LookPreviewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let preview = segue.destination as? LookPreviewController {
            preview.videoURL = videoURL
            preview.look = selectedLook
            preview.keyFrame = keyFrame
            preview.videoMode = self.videoMode
            preview.renderer = self.renderer
        }
    }
    
    //// Collection View //////////////////////////////////////////////////////
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return lookGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = lookGroups[section]
        return group.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = lookGroups[indexPath.section]
        selectedLook = group.items[indexPath.item]
        nextButton.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LookCellIdentifier, for: indexPath) as! LookCell
        
        let group = lookGroups[indexPath.section]
        let look = group.items[indexPath.item]
        
        cell.label.text = look.name
        
        if let state = lookStates[look] {
            print("Got cell", look.name)
            cell.update(state)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LookGroupHeaderIdentifier, for: indexPath) as! LookGroupHeader
        let group = lookGroups[indexPath.section]
        header.label.text = group.name
        return header
    }

}
