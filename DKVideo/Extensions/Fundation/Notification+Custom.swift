//
//  Notification+Custom.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/5/31.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// 接收推送消息
    struct Message {
        /// 预警消息
        static let warning = Notification.Name(rawValue: "sjzx.notifications.earlyWarning")

        /// 通知消息
        static let msg = Notification.Name(rawValue: "sjzx.notifications.msg")
    }
    static let ProjectSeted = Notification.Name(rawValue: "sjzx.notifications.project")
     static let UserInfoChanged = Notification.Name(rawValue: "sjzx.notifications.UserInfoChanged")
}
