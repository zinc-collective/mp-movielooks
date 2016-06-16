//
//  InfoViewController.swift
//  MovieLooks
//
//  Created by Sean Hess on 5/5/16.
//
//

import UIKit

let FullResolutionKey = "FullResolution"

class InfoViewController : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var fullResolutionSwitch: UISwitch!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // full resolution switch on/off on load
        let defaults = NSUserDefaults.standardUserDefaults()
        fullResolutionSwitch.on = defaults.boolForKey(FullResolutionKey)
        
        webView.backgroundColor = UIColor.clearColor()
        webView.opaque = false
        webView.scrollView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.delegate = self
        
        if let url = NSBundle.mainBundle().URLForResource("info", withExtension: "html"), path = url.path {
        
            do {
                let string = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
                webView.loadHTMLString(string, baseURL: nil)
            }
            catch let err as NSError {
                print("Web View Error: ", err.description)
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.URL where navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        
        return true
    }
    
    @IBAction func onFullResolutionChange(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(fullResolutionSwitch.on, forKey: FullResolutionKey)
        defaults.synchronize()
    }
}