//
//  ShareViewController.swift
//  VideoShare
//
//  Created by 朱德坤 on 2019/12/4.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Social
import UIKit

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return false
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.

        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        let item = SLComposeSheetConfigurationItem()
        item?.title = "打开"
        return [item]
    }

    override func viewDidLoad() {
        self.view.backgroundColor = .red
//        extensionContext?.inputItems.forEach { item in
//            print(item)
//            let provider = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first
//            provider?.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { url, _ in
//                let str = (url as? URL)?.absoluteString ?? ""
//                print(str)
//                if let method = extractMethodFrom(owner: try! self.sharedApplication(), selector: NSSelectorFromString("openURL:")) {
//                    _ = method(URL(string: "DKVideo://\(str)"))
//                }
//            })
//        }
    }

    func sharedApplication() throws -> UIApplication {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application
            }

            responder = responder?.next
        }

        throw NSError(domain: "UIInputViewController+sharedApplication.swift", code: 1, userInfo: nil)
    }
}

/// 动态获取方法
/// - Parameters:
///   - owner: 对象或者类对象
///   - selector: 方法选择子
func extractMethodFrom(owner: AnyObject, selector: Selector) -> ((Any?) -> Any)? {
    let method: Method?
    if owner is AnyClass {
        method = class_getClassMethod(owner as? AnyClass, selector)
    } else {
        print(type(of: owner))
        method = class_getInstanceMethod(type(of: owner), selector)
    }

    if let one = method {
        let implementation = method_getImplementation(one)

        typealias Function = @convention(c) (AnyObject, Selector, Any?) -> Void

        let function = unsafeBitCast(implementation, to: Function.self)

        return { userinfo in function(owner, selector, userinfo) }

    } else {
        return nil
    }
}
