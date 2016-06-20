//
//  WebViewController.swift
//  BluMarketWebKit
//
//  Created by Thomas Prezioso on 6/20/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//
import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    var webViewConfiguration: WKWebViewConfiguration!
    var contentController: WKUserContentController!
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var loadingView: UIView!
    
    override func loadView() {
        super.loadView()
        
        UserDefaults.standard().register(["UserAgent": "BLU App"])
        
        contentController = WKUserContentController()
        
        let userScript = WKUserScript(
            source: "",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        
        contentController.addUserScript(userScript)
        
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: view.frame, configuration: webViewConfiguration)
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        view.sendSubview(toBack: webView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        UserDefaults.standard().addObserver(self, forKeyPath: "deviceToken", options: .new, context: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if (message.name == "callbackHandler") {
//            if (message.body as! String == "statusbar") {
//                UIApplication.shared().statusBarStyle = .default
//            }
//            if (message.body as! String == "load") {
                UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
        
                    self.loadingView.alpha = 0.0
                    
                    }, completion: nil)
//            }
//        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey: AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if keyPath == "deviceToken" && webView.estimatedProgress >= 1 {
            self.sendDeviceToken(UserDefaults.standard().string(forKey: "deviceToken")!)
        }
        
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let deviceToken = UserDefaults.standard().string(forKey: "deviceToken")
        
        if deviceToken != nil {
            self.sendDeviceToken(deviceToken!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://dashboard.theblumarket.com")
        webView.load(URLRequest(url: url!))
        UIApplication.shared().statusBarStyle = .lightContent

    }
    
    func sendDeviceToken(_ deviceToken: String!) {
        print(deviceToken)
        self.webView.evaluateJavaScript("var __device = {token: '" + deviceToken + "', os: 'iOS'};", completionHandler: { (object, error) -> Void in if (error == nil) {
            print("success")
            print(object)
        }
        else {
            print("error")
            print(error)
            }
        })
    }
}
