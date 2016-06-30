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


class TodayViewController: UIViewController, NCWidgetProviding, WKNavigationDelegate {
        
    @IBOutlet var webViewWidget: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view .addSubview(webViewWidget)
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
