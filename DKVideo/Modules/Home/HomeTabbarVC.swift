//
//  HomeTabbarVC.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit

class HomeTabbarVC: UITabBarController {
    let homeVC = NavigationController(rootViewController: HomeViewController())
    let downloadVC = NavigationController(rootViewController: DownloadViewController())
    let settingVC = NavigationController(rootViewController: SettingViewController())
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [homeVC, downloadVC, settingVC]
        homeVC.tabBarItem.image = R.image.icon_navigation_web()
        homeVC.tabBarItem.title = "首页"
        downloadVC.tabBarItem.image = R.image.icon_cell_dir()
        downloadVC.tabBarItem.title = "下载"
        settingVC.tabBarItem.image = R.image.icon_tabbar_settings()
        settingVC.tabBarItem.title = "设置"

//        homeVC.tabBarItem

        themeService.rx
            .bind({ $0.textGray }, to: tabBar.rx.unselectedItemTintColor)
            .bind({ $0.secondary }, to: tabBar.rx.tintColor)
            .bind({ $0.primary }, to: tabBar.rx.barTintColor)
            .disposed(by: rx.disposeBag)
    }
}
