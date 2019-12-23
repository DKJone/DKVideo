//
//  AppDelegate.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/3.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Aspects
import RxSwift
import SuperPlayer
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
        URLIntercept.videoUrl.filterEmpty().distinctUntilChanged {
            $1.contains("127.0.0.1") || $0 == $1
        }.throttle(.seconds(2), scheduler: MainScheduler.asyncInstance).observeOn(MainScheduler.asyncInstance).bind { urlStr in
            let videoVC = VideoPlayerVC.shared
            if videoVC.isVisible {
                let playerModel = videoVC.playerView.playerModel
                let playurl = SuperPlayerUrl()
                playurl.title = Date().string(withFormat: "yyyyMMddHHmmss1")
                playurl.url = urlStr
                playerModel?.multiVideoURLs.append(playurl)
                videoVC.playerView.play(with: playerModel!)
                print("----------\(playurl)------")
            } else {
                videoVC.urlStr = urlStr
                VideoPlayerVC.show()
            }
        }.disposed(by: rx.disposeBag)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if !url.absoluteString.contains("DKVideo://") { return false }
        let videoUrl = url.absoluteString.removingPrefix("DKVideo://")
        print("openUrl:\(videoUrl)")
        let webvc = WebViewController()
        webvc.requestURL = URL(string: videoUrl)
        if let navc = UINavigationController.currentViewController()?.navigationController {
            navc.pushViewController(webvc)
        } else {
            waitToPresentVC = nil
        }
        return true
    }
}

var waitToPresentVC: UIViewController?
