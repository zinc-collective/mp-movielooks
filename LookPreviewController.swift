//
//  LookPreviewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/6/16.
//
//

import UIKit

class LookPreviewController: LookPreviewControllerOld {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // HACK: remove when we update the UI
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            // find the smaller of the two
            let size = self.view.frame.size
            let scale = min(size.width, size.height) / CGFloat(320)
            self.view.transform = CGAffineTransformMakeScale(scale, scale)
        }
    }

}
