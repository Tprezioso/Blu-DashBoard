//
//  ViewController.swift
//  BluMarketWebKit
//
//  Created by Thomas Prezioso on 6/20/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    func setupWebView() {
        let url = URL(string:"https://google.com")
        let request = URLRequest(url:url!)
        webView.loadRequest(request)
    }
}
