//
//  WebViewController.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/5/27.
//  Copyright © 2019 DKJone. All rights reserved.
//

import FloatingPanel
import Foundation
import WebKit
class WebViewController: ViewController {
    var requestURL: URL?
    var webView = WebView()
    var exitURLParam = [String]()
    var fpc: FloatingPanelController!
    var didEvaluatedJS = true
    let litterWebView = UIWebView()
    override func makeUI() {
        super.makeUI()
        contentView.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }

        /// 返回按钮
        let navibackBtn = UIBarButtonItem(image: R.image.icon_navigation_back(), style: .plain, target: self, action: #selector(back))
        let space1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space1.width = 10
        let closeBtn = UIBarButtonItem(image: R.image.icon_navigation_close(), style: .plain, target: self, action: #selector(naviBack))
        navigationItem.leftBarButtonItems = [navibackBtn, space1, closeBtn]

        if requestURL != nil { webView.load(.init(url: requestURL!)) }
        // 刷新按钮
        let refreshBtn = UIButton(type: .custom)
        refreshBtn.setImage(R.image.icon_navigation_refresh()?.template, for: [])
        refreshBtn.rx.tap.bind { [unowned self] _ in
            self.webView.reload()
        }.disposed(by: rx.disposeBag)
        // VIP 按钮
        let vipBtn = UIButton(type: .custom)
        vipBtn.setImage(R.image.icon_vip(), for: [])
        vipBtn.rx.tap.bind { [unowned self] _ in
            self.fpc.move(to: UserDefaults.showVipWebView ? .half : .hidden, animated: true)
            self.didEvaluatedJS = false
            let litterWebView = self.view.viewWithTag(1970) as? UIWebView
            if UserDefaults.currentVip.url.isEmpty {
                UserDefaults.currentVip = VipAnalysis.vips.first!
            }
            var htmlurl = (self.webView.url?.absoluteString ?? "").nsString
            if htmlurl.contains("youku"), htmlurl.contains("html") {
                htmlurl = htmlurl.substring(with: NSRange(location: 0, length: htmlurl.range(of: "html").location + 4)) as NSString
            }
            litterWebView!.loadRequest(URLRequest(urlString: "\(UserDefaults.currentVip.url)\(htmlurl)")!)

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
        // 复制网页地址
        let copyBtn = UIButton(type: .custom)
        copyBtn.setTitle("复制地址", for: [])
        copyBtn.rx.tap.bind { [unowned self] _ in
            UIPasteboard.general.string = self.webView.url?.absoluteString
        }.disposed(by: rx.disposeBag)

        navigationItem.rightBarButtonItems = [
            .init(customView: refreshBtn),
            .init(customView: vipBtn),
            .init(customView: pcBtn),
            .init(customView: copyBtn),
        ]

        // fpc
        fpc = FloatingPanelController()
        fpc.delegate = self

        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.layer.cornerRadius = 9.0

        fpc.surfaceView.shadowHidden = false
        let vipVC = ViewController()

        litterWebView.allowsInlineMediaPlayback = true
        litterWebView.mediaPlaybackRequiresUserAction = false
        litterWebView.tag = 1970
        litterWebView.delegate = self
        litterWebView.scrollView.showsHorizontalScrollIndicator = false
        vipVC.view.addSubview(litterWebView)
        litterWebView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        }

        fpc.set(contentViewController: vipVC)
        fpc.track(scrollView: litterWebView.scrollView)
        fpc.addPanel(toParent: self)
        themeService.rx
            .bind({ $0.textGray }, to: [pcBtn.rx.titleColor(for: []), pcBtn.rx.titleColor(for: .selected), copyBtn.rx.titleColor(for: [])])
            .bind({ $0.secondary }, to: [navibackBtn.rx.tintColor, closeBtn.rx.tintColor, refreshBtn.rx.tintColor,
                                         copyBtn.rx.titleColor(for: []), pcBtn.rx.titleColor(for: []),
                                         pcBtn.rx.titleColor(for: .selected)])
            .bind({ $0.background }, to: [vipVC.view.rx.backgroundColor, litterWebView.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }

    override func adjustLeftBarButtonItem() {}
    @objc func back() {
        if !webView.canGoBack {
            naviBack()
        } else {
            webView.goBack()
        }
    }

    @objc func naviBack() {
        if (navigationController?.children.count ?? 0) > 1 {
            navigationController?.popViewController()
        } else if presentingViewController != nil { // presented
            dismiss(animated: true, completion: nil)
        }
    }

    func show(requestUrl: URL) {
        if isVisible {
            webView.load(URLRequest(url: requestUrl))
        } else {
            requestURL = requestUrl
            UIViewController.currentViewController()?.navigationController?.pushViewController(self)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        litterWebView.stopLoading()
    }
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !(webView.request?.url?.absoluteString ?? "").contains("jx.688ing.com") || didEvaluatedJS { return }
        didEvaluatedJS.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let htmlurl = (self.webView.url?.absoluteString ?? "").nsString
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('movie-text').value = '\(htmlurl)',document.getElementById('movie-btn').click()")
        }
    }
}

extension WebView: WKNavigationDelegate, WKUIDelegate {
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
        // 阻止跳转到第三方视频播放APP
        decisionHandler(.allow)
//        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {}

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}

// MARK: - FPC Delegate

extension WebViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return PanelLandscapeLayout()
    }
}

// MARK: - layout

public class PanelLandscapeLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .hidden
    }

    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip, .half, .hidden]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .half: return min(screenWidth, screenHeight) / 2
        case .tip: return 69.0
        case .hidden: return -1
        default: return nil
        }
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0),
        ]
    }

    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}

// MARK: - Webview

class WebView: UIView {
    var customWebView: UIView!
    init() {
        customWebView = UserDefaults.useWKWebview ? WKWebView() : UIWebView()
        super.init(frame: .zero)
        addSubview(customWebView)
        customWebView.snp.makeConstraints { $0.edges.equalToSuperview() }
        if let webView = customWebView as? WKWebView {
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
            webView.configuration.allowsInlineMediaPlayback = false
            webView.allowsBackForwardNavigationGestures = true
            // 禁用长按弹出框
            let userScript = WKUserScript(source: "document.documentElement.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)

        } else {
            (customWebView as? UIWebView)?.allowsInlineMediaPlayback = true
            (customWebView as? UIWebView)?.mediaPlaybackRequiresUserAction = false
        }
        themeService.attrsStream.bind { [unowned self] theme in
            (self.customWebView as? WKWebView)?.evaluateJavaScript("document.body.style.backgroundColor=\"\(theme.background.hexString)\"", completionHandler: nil)
        }.disposed(by: rx.disposeBag)
        themeService.rx
            .bind({ $0.background }, to: [rx.backgroundColor, customWebView!.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(_ request: URLRequest) {
        if let webView = customWebView as? WKWebView {
            webView.load(request)
        } else if let webView = customWebView as? UIWebView {
            webView.loadRequest(request)
        }
    }

    var url: URL? {
        if let webView = customWebView as? WKWebView {
            return webView.url
        } else if let webView = customWebView as? UIWebView {
            return webView.request?.url
        }
        return nil
    }

    func reload() {
        (customWebView as? UIWebView)?.reload()
        (customWebView as? WKWebView)?.reload()
    }

    var canGoBack: Bool {
        if let webView = customWebView as? WKWebView {
            return webView.canGoBack
        } else if let webView = customWebView as? UIWebView {
            return webView.canGoBack
        }
        return false
    }

    func goBack() {
        (customWebView as? UIWebView)?.goBack()
        (customWebView as? WKWebView)?.goBack()
    }
}
