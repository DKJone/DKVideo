//
//  TestWebVC.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/19.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
import WebKit
class TestWebVC: ViewController, UIWebViewDelegate {
    let webView = UIWebView()
    override func makeUI() {
        super.makeUI()
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }
        webView.loadRequest(URLRequest(urlString: "https://jx.688ing.com/")!)
        webView.delegate = self
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = true
    }

    

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
}
