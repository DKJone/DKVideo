//
//  WebViewController.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/5/27.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
import WebKit
class WebViewController: ViewController {
    var requestURL: URL?
    var webView = WebView()
    var exitURLParam = [String]()
    override func makeUI() {
        super.makeUI()
        contentView.addSubview(webView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }

        /// 返回按钮
        let navibackBtn = UIBarButtonItem(image: R.image.icon_navigation_back(), style: .plain, target: self, action: #selector(back))
        let space1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space1.width = 10
        let closeBtn = UIBarButtonItem(image: R.image.icon_navigation_close(), style: .plain, target: self, action:#selector(naviBack))
        navigationItem.leftBarButtonItems = [navibackBtn, space1, closeBtn]
        webView.configuration.allowsInlineMediaPlayback = false
        webView.allowsBackForwardNavigationGestures = true
        // 禁用长按弹出框
        let userScript = WKUserScript(source: "document.documentElement.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
        if requestURL != nil { webView.load(.init(url: requestURL!)) }
        // 刷新按钮
        let refreshBtn = UIButton(type: .custom)
        refreshBtn.setImage(R.image.icon_navigation_refresh()?.filled(withColor: .secondary()), for: [])
        refreshBtn.rx.tap.bind { [unowned self] _ in
            self.webView.reload()
        }.disposed(by: rx.disposeBag)
        // VIP 按钮
        let vipBtn = UIButton(type: .custom)
        vipBtn.setImage(R.image.icon_vip(), for: [])
        vipBtn.rx.tap.bind { [unowned self] _ in
            var litterWebView = self.view.viewWithTag(1970) as? WKWebView
            if litterWebView == nil {
                litterWebView = WKWebView()
                litterWebView!.tag = 1970
                self.view.insertSubview(litterWebView!, at: 0)
                litterWebView!.frame = CGRect(x: 100, y: 100, width: 10, height: 10)
            }
            if UserDefaults.currentVip.url.isEmpty {
                UserDefaults.currentVip = VipAnalysis.vips.first!
            }
            var htmlurl = (self.webView.url?.absoluteString ?? "").nsString
            if htmlurl.contains("youku"){
                htmlurl = htmlurl.substring(with: NSRange(location: 0, length: htmlurl.range(of: "html").location + 4)) as NSString
            }
            litterWebView!.load(URLRequest(urlString: "\(UserDefaults.currentVip.url)\(htmlurl)")!)

        }.disposed(by: rx.disposeBag)
        vipBtn.rx.longPressGesture().when(.recognized).bind { [unowned self] _ in
            showSelectVC(inVC: self, listDataProvider: { list in
                var vips = VipAnalysis.vips
                let index = vips.firstIndex(where: { $0.url == UserDefaults.currentVip.url }) ?? 0
                vips[index].selected = true
                list = vips
            }) { list in
                UserDefaults.currentVip = list.first!
            }
        }.disposed(by: rx.disposeBag)
        // 切换PC版网页按钮
        let pcBtn = UIButton(type: .custom)
        pcBtn.setTitle("手机版", for: [])
        pcBtn.setTitle("电脑版", for: .selected)
        pcBtn.isSelected = !UserDefaults.isPCAgent
        pcBtn.rx.tap.bind { [unowned self] _ in
            UserDefaults.isPCAgent.toggle()
            pcBtn.isSelected.toggle()
            self.webView.reload()
        }.disposed(by: rx.disposeBag)

        navigationItem.rightBarButtonItems = [
            .init(customView: refreshBtn),
            .init(customView: vipBtn),
            .init(customView: pcBtn),
        ]

        themeService.rx
            .bind({ $0.textGray }, to: [pcBtn.rx.titleColor(for: []), pcBtn.rx.titleColor(for: .selected)])
            .bind({ $0.secondary }, to: [navibackBtn.rx.tintColor, closeBtn.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    override func adjustLeftBarButtonItem() {}
    @objc func back() {
        let needExit = exitURLParam.contains {
            webView.url?.absoluteString.contains($0) ?? false
        }

        if webView.backForwardList.backList.isEmpty || needExit {
            naviBack()
        } else {
            webView.goBack()
        }
    }
    @objc func naviBack(){
        if (navigationController?.children.count ?? 0) > 1 {
            navigationController?.popViewController()
        } else if presentingViewController != nil { // presented
            dismiss(animated: true, completion: nil)
        }
    }

}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print(message)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print(message)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print(defaultText ?? "")
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //阻止跳转到第三方视频播放APP
        decisionHandler(.allow)
        //decisionHandler(WKNavigationActionPolicy.init(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {

    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

}

class WebView: WKWebView {
    override func load(_ request: URLRequest) -> WKNavigation? {
        if request.httpBody.isNilOrEmpty{
            return super.load(request)
        }else{
            print(request.httpBody)
            return super.load(request)
        }
    }
}
