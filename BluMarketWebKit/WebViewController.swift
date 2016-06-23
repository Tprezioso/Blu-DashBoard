//
//  WebViewController.swift
//  BluMarketWebKit
//
//  Created by Thomas Prezioso on 6/20/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//
import UIKit
import WebKit
import SystemConfiguration

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    var webView: WKWebView!
    var webViewConfiguration: WKWebViewConfiguration!
    var contentController: WKUserContentController!
    var previousReachabilityStatus: UInt32!
    var reachabilityAlert: UIAlertController!

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var loadingView: UIView!

    override func loadView() {
        super.loadView()
        self.previousReachabilityStatus = 2
        let host = "8.8.8.8"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        SCNetworkReachabilitySetCallback(reachability,
                                            {(_, flags, info) in
                                            let mySelf = Unmanaged<ViewController>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()
                                            mySelf.handleReachabilityChange(flags.rawValue)
                                            },
                                               &context)
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes)
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": "BLU App"])
        contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        webView = WKWebView(frame: view.frame, configuration: webViewConfiguration)
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "deviceToken", options: .New, context: nil)
    }

    func handleReachabilityChange(status: UInt32!) {
        if self.previousReachabilityStatus != 0 && status == 0 {
            self.reachabilityAlert = UIAlertController(title: "Internet connection lost", message: "Check your network connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(self.reachabilityAlert, animated: true, completion: nil)
        }

        if (self.previousReachabilityStatus == 0 && status != 0) {
            self.reachabilityAlert.dismissViewControllerAnimated(true, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loadingView.alpha = 1.0
                        
                }, completion: {(completed: Bool) in self.webView.reload()})
        }
        self.previousReachabilityStatus = status
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if (message.name == "callbackHandler") {
            UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                 self.loadingView.alpha = 0.0
             }, completion: nil)
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "deviceToken" && webView.estimatedProgress >= 1 {
            self.sendDeviceToken(NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")!)
        }

        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")
         if deviceToken != nil {
            self.sendDeviceToken(deviceToken!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         let url = NSURL(string: "https://dashboard.theblumarket.com")
        webView.loadRequest(NSURLRequest(URL: url!))
    }

    func sendDeviceToken(deviceToken: String!) {
        print(deviceToken)
        self.webView.evaluateJavaScript("var __device = {token: '" + deviceToken + "', os: 'iOS'};", completionHandler: { (object, error) -> Void in if (error == nil) {
                print("success")
                print(object)
            } else {
                print("error")
                print(error)
            }
        })
    }
}
