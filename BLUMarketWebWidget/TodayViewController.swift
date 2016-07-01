//
//  TodayViewController.swift
//  BLUMarketWebWidget
//
//  Created by Thomas Prezioso on 6/30/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

import UIKit
import NotificationCenter
import WebKit

class TodayViewController: UIViewController, NCWidgetProviding, WKNavigationDelegate, WKScriptMessageHandler {

    var contentController: WKUserContentController!
    var webViewConfiguration: WKWebViewConfiguration!
    @IBOutlet var webViewWidget: WKWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var actInd: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actInd = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.frame.size.width = view.frame.size.width  * 0.75
        actInd.frame.size.height = view.frame.size.height
        webViewWidget.alpha = 0
        actInd.startAnimating()
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        view.addSubview(actInd)
        let accessToken = NSUserDefaults.init(suiteName: "group.io.tom.widget")!.stringForKey("accessToken")
        var url = NSURL(string:"")
        dispatch_async(dispatch_get_main_queue(), {
            if accessToken != nil {
                url = NSURL(string: "https://dashboard.theblumarket.com/#/login?accessToken="+accessToken!)
            } else {
                url = NSURL(string: "https://dashboard.theblumarket.com/#/login")
            }
            self.webViewWidget.loadRequest(NSURLRequest(URL: url!))

        })
        }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        spinner.startAnimating()

        let event = message.body["event"]as! String
        if (event == "pageDidLoad") {
            actInd.stopAnimating()
            UIView.animateWithDuration(0.5, animations: { 
                self.webViewWidget.alpha = 1
            })
        } else if (event == "didLogin") {
            NSUserDefaults.init(suiteName: "group.io.tom.widget")!.setValue(message.body, forKey: "accessToken")
        } else if event == "didLogout" {
      NSUserDefaults.init(suiteName: "group.io.tom.widget")!.removeObjectForKey("accessToken")
        } else if event == "didCallApp" {
            extensionContext?.openURL(NSURL(string: "blu://")!, completionHandler: nil)
        }
    }
    
    override func loadView() {
        super.loadView()
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": "BLU Widget"])
        contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        view.frame.size.height = CGFloat(130)
        view.backgroundColor = UIColor .clearColor()
        self.preferredContentSize = CGSizeMake(0, 130)
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self,name: "callbackHandler")
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        webViewWidget = WKWebView(frame: view.frame, configuration: webViewConfiguration)
        webViewWidget.frame.size.width = view.frame.size.width  * 0.75
        webViewWidget.frame.size.height = view.frame.size.height
        
        webViewWidget.backgroundColor = UIColor.clearColor()
        webViewWidget.scrollView.bounces = false
        webViewWidget.navigationDelegate = self
        view.addSubview(webViewWidget)
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.NewData)
    }
}
