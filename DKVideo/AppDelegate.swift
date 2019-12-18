//
//  AppDelegate.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/3.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Aspects
import UIKit
import WebKit
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let browCont = WKWebView().value(forKey: "browsingContextController")
        let classType = type(of: browCont!) as! AnyClass
        if let method = extractMethodFrom(owner: classType, selector: NSSelectorFromString("registerSchemeForCustomProtocol:")) {
            _ = method("http")
            _ = method("https")
        }
        
        URLProtocol.registerClass(URLIntercept.self)
        LibsManager.shared.configTheme()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if !url.absoluteString.contains("DKVideo://"){return false}
        let videoUrl = url.absoluteString.removingPrefix("DKVideo://")
        print("openUrl:\(videoUrl)")
        let webvc = WebViewController()
        webvc.requestURL = URL(string:  videoUrl)
        if let navc = UINavigationController.currentViewController()?.navigationController{
            navc.pushViewController(webvc)
        }else{
            waitToPresentVC = nil
        }
        return true
    }
}

var waitToPresentVC :UIViewController?
