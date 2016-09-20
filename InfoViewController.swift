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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // full resolution switch on/off on load
        let defaults = UserDefaults.standard
        fullResolutionSwitch.isOn = defaults.bool(forKey: FullResolutionKey)
        
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.delegate = self
        
        if let url = Bundle.main.url(forResource: "info", withExtension: "html") {
        
            do {
                let string = try String(contentsOfFile: url.path)
                webView.loadHTMLString(string, baseURL: nil)
            }
            catch let err as NSError {
                print("Web View Error: ", err.description)
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.url , navigationType == .linkClicked {
            UIApplication.shared.openURL(url)
            return false
        }
        
        return true
    }
    
    @IBAction func onFullResolutionChange(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(fullResolutionSwitch.isOn, forKey: FullResolutionKey)
        defaults.synchronize()
    }
}
