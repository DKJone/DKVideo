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
import Tiercel
import UIKit
import WebKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate {
    var window: UIWindow?
    /* 无声音频播放器 */
    var blankPlayer: AVAudioPlayer?
    /* 后台任务标识符 */
    var bgTaskIdentifier: UIBackgroundTaskIdentifier!
    var bgTaskTimer: Timer?

    var sessionManagerBackground: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = UserDefaults.downloadWithoutWifi
        let manager = SessionManager("com.dkjone.DKVideo.normal", configuration: configuration, operationQueue: DispatchQueue(label: "com.dkjone.DKVideo.Normal"))
        return manager
    }()

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

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        if UserDefaults.backgroundDownload{ enterBackgroundHandler()}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {}

    // 程序进入后台处理
    func enterBackgroundHandler() {
        let app = UIApplication.shared
        bgTaskIdentifier = app.beginBackgroundTask(expirationHandler: {
            app.endBackgroundTask(self.bgTaskIdentifier)
            self.bgTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        })
        bgTaskTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(requestMoreTime), userInfo: nil, repeats: true)
        bgTaskTimer?.fire()
    }

    @objc func requestMoreTime() {
        if UIApplication.shared.backgroundTimeRemaining < 30 {
            playBlankAudio()
            UIApplication.shared.endBackgroundTask(bgTaskIdentifier)
            bgTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                UIApplication.shared.endBackgroundTask(self.bgTaskIdentifier)
                self.bgTaskIdentifier = UIBackgroundTaskIdentifier.invalid
            })
        }
    }

    // 播放无声音频
    func playBlankAudio() {
        playAudio(forResource: "blank", ofType: "caf")
    }

    // 开始播放音频
    func playAudio(forResource resource: String?, ofType: String?) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation) // .setActive(true, error: &activationErr)
        let blankSoundURL = R.file.blankCaf() // URL(string: Bundle.main.path(forResource: resource, ofType: ofType) ?? "")

        if let blankSoundURL = blankSoundURL {
            blankPlayer = try? AVAudioPlayer(contentsOf: blankSoundURL)
            blankPlayer?.play()
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        let downloadManagers = [ sessionManagerBackground]
        for manager in downloadManagers {
            if manager.identifier == identifier {
                manager.completionHandler = completionHandler
                break
            }
        }
    }
}

var waitToPresentVC: UIViewController?
