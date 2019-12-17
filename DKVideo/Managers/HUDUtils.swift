//
//  HUDUtils.swift
//   DKVideo
//
//  Created by 朱德坤 on 2019/3/20.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
import Toast_Swift
//
func showLoadHud(inView: UIView = keyWindow) {
    inView.makeToastActivity(.center)
}

func hideAllHud(inView: UIView = keyWindow) {
    inView.hideAllToasts(includeActivity: true, clearQueue: true)

}

func showMessage(message: String,
                 inView: UIView = keyWindow,
                 duration: TimeInterval = 1.5,
                 position: ToastPosition = .center,
                 title: String? = nil,
                 image: UIImage? = nil,
                 style: ToastStyle = ToastStyle(),
                 completion: ((Bool) -> Void)? = nil) {

    keyWindow.makeToast(message, duration: duration, position: position, title: title, image:image, style: style, completion: completion)
}

var keyWindow: UIWindow {
    return UIApplication.shared.keyWindow!
}
