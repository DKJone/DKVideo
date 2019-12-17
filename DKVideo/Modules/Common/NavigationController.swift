//
//  NavigationController.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/3/20.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit
import AttributedLib

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        hero.isEnabled = true
//        hero.navigationAnimationType = .fade
//        hero.modalAnimationType = .autoReverse(presenting: .fade)
//        hero.navigationAnimationType = .autoReverse(presenting: .slide(direction: .left))
        if #available(iOS 13.0, *) {
            if self.modalPresentationStyle == .pageSheet{
                self.modalPresentationStyle = .fullScreen
            }
            overrideUserInterfaceStyle = .light
        }
        navigationBar.isTranslucent = false
        navigationBar.backIndicatorImage = R.image.icon_navigation_back()
        navigationBar.backIndicatorTransitionMaskImage = R.image.icon_navigation_back()

        themeService.rx
            .bind({ $0.text }, to: navigationBar.rx.tintColor)
            .bind({ $0.primary}, to: navigationBar.rx.barTintColor)
            .bind({  [NSAttributedString.Key.foregroundColor: $0.text] }, to: navigationBar.rx.titleTextAttributes)
            .disposed(by: rx.disposeBag)
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
         if (self.children.count==1) {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
