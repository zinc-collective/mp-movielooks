//
//  LookCell.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/9/16.
//
//

import UIKit

class LookCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let animationDuration = 0.100
    
    func update(_ state:LookCellState) {
        let look = state.look
        self.label.text = look.name
        
        state.onRender = { image in
            DispatchQueue.main.async {
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }
        
        if let image = state.image {
            self.imageView.image = image
        }
        else {
            self.activityIndicator.startAnimating()
            self.imageView.image = nil
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                let color = UIColor(red: 0.592, green: 0.757, blue: 0.953, alpha: 1.0) // #97C1F3
                self.layer.borderColor = color.cgColor
                self.layer.borderWidth = 2.0
                
                UIView.animate(withDuration: animationDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
                
            }
            else {
                self.layer.borderWidth = 0.0
                
                UIView.animate(withDuration: animationDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        }
    }
}

class LookCellState : NSObject {
    var look: Look
    var image: UIImage?
    var onRender : (UIImage) -> Void = {_ in}
    var rendering = false
    
    init(look:Look) {
        self.look = look
        super.init()
    }
}
