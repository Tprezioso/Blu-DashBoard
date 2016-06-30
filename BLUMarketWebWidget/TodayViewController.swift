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
    @IBOutlet var webViewWidget: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let event = message.body["event"]as! String
        print("\(event)................")
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
        webViewWidget.alignmentRectForFrame(CGRectMake(0, 0, view.frame.height, view.frame.width))
        view.addSubview(webViewWidget)

        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": "BLU Widget"])
        contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self,name: "callbackHandler")
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("accessToken")
        var url = NSURL(string:"")
        if accessToken != nil {
            url = NSURL(string: "https://dashboard.theblumarket.com?accessToken="+accessToken!)
        } else {
            url = NSURL(string: "https://dashboard.theblumarket.com/#/login")
        }
        
        webViewWidget.loadRequest(NSURLRequest(URL: url!))


    }
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.NewData)
    }
}
