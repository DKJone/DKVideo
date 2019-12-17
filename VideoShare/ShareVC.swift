//
//  ShareVC.swift
//  VideoShare
//
//  Created by 朱德坤 on 2019/12/4.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit
class ShareVC: UIViewController {
    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        btn.center = view.center
        btn.setTitle("使用DKVideo打开", for: [])
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(open), for: .touchUpInside)

    }

    @objc func open() {
        var urlStr = ""
        extensionContext?.inputItems.forEach { item in
            for provider in (item as? NSExtensionItem)?.attachments ?? [] {
                provider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { [unowned self] url, _ in
                    let str = (url as? URL)?.absoluteString ?? ""
                    if !str.isEmpty {
                        print(str)
                        urlStr = str
                        self.openMainAPP(url: str)
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                        return
                    }
                })
            }
        }
//        if urlStr.isEmpty {
//            btn.setTitle("没有获取到视频链接", for: [])
//        }
    }

    func openMainAPP(url: String) {
        if let method = extractMethodFrom(owner: try! self.sharedApplication(), selector: NSSelectorFromString("openURL:")) {
            _ = method(URL(string: "DKVideo://\(url)"))
        }
    }

    func sharedApplication() throws -> UIApplication {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application
            }
            responder = responder?.next
        }

        throw NSError(domain: "sharedApplication not found", code: 1, userInfo: nil)
    }
}
