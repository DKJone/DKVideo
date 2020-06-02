//
//  LibsManager.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/3/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

//import Bugly
@_exported import ChameleonFramework

@_exported import HandyJSON
import IQKeyboardManagerSwift
@_exported import KafkaRefresh
@_exported import NSObject_Rx
import NVActivityIndicatorView
@_exported import Rswift
@_exported import RxCocoa
@_exported import RxOptional
@_exported import RxSwift
@_exported import SwifterSwift
@_exported import SwiftyJSON
@_exported import SDWebImage

#if DEBUG
     import FLEX
#endif

/// 配置各框架
class LibsManager: NSObject {
    static let shared = LibsManager()

    override init() {
        super.init()
        self.setBugly()
        self.setupActivityView()
        self.setupKafkaRefresh()
        self.setupKeyboardManager()
        // 加载下载项
        DispatchQueue.global().async {
           print(DownLoadManage.shared)
        }
        if !UserDefaults.defaultConfig{
            UserDefaults.useWKWebview = true
            UserDefaults.showVipWebView = true
            UserDefaults.isPCAgent = true
            UserDefaults.defaultConfig = true
        }

    }

    func showFlex() {
        #if DEBUG
             FLEXManager.shared.showExplorer()
        #endif
    }

    func setBugly() {
//        var config = BuglyConfig()
//        config.reportLogLevel = .error
//        Bugly.start(withAppId: "8096bc4c87", config: config)
    }

    func configTheme() {
        var theme = ThemeType.currentTheme()
//        theme = theme.toggled()
        themeService.switch(theme)
        
        if #available(iOS 13.0, *) {
            globalStatusBarStyle.accept(.default)
        } else {
            globalStatusBarStyle.accept(.default)
        }
    }

    func setupKafkaRefresh() {
        if let defaults = KafkaRefreshDefaults.standard() {
            defaults.headDefaultStyle = .replicatorAllen
            defaults.footDefaultStyle = .native
            defaults.backgroundColor = .clear
            themeService.rx
                .bind({ $0.secondary }, to: defaults.rx.themeColor)
                .disposed(by: rx.disposeBag)
        }
    }

    func setupActivityView() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballRotateChase
        NVActivityIndicatorView.DEFAULT_COLOR = .secondary()
    }

    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

}
