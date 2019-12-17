//
//  UIViewController+Utils.swift
//  DKVideo 
//
//  Created by 朱德坤 on 2019/3/28.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit

let safeAreaBottomHeight = CGFloat(UIApplication.shared.statusBarFrame.height == 44 ? 34 : 0)
let safeAreaTopHeight = UIApplication.shared.statusBarFrame.height
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height


extension UIViewController{
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
           if let nav = base as? UINavigationController {
               return currentViewController(base: nav.visibleViewController)
           }
           if let tab = base as? UITabBarController {
               return currentViewController(base: tab.selectedViewController)
           }
           if let presented = base?.presentedViewController {
               return currentViewController(base: presented)
           }
           return base
       }
}
