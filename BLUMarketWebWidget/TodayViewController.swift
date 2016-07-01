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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accessToken = NSUserDefaults.init(suiteName: "group.io.tom.widget")!.stringForKey("accessToken")
        var url = NSURL(string:"")
        if accessToken != nil {
            url = NSURL(string: "https://dashboard.theblumarket.com/#/login?accessToken="+accessToken!)
        } else {
            url = NSURL(string: "https://dashboard.theblumarket.com/#/login")
        }
        webViewWidget.loadRequest(NSURLRequest(URL: url!))
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let event = message.body["event"]as! String
        if (event == "pageDidLoad") {
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
        view.frame.size.height = CGFloat(165)
        view.backgroundColor = UIColor .clearColor()
        self.preferredContentSize = CGSizeMake(0, 130)
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self,name: "callbackHandler")
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        webViewWidget = WKWebView(frame: view.frame, configuration: webViewConfiguration)
        webViewWidget.frame.size.width = view.frame.size.width  * 0.75
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
