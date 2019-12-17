//
//  HandyJson+SwiftyJson.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/9.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation

import HandyJSON
import SwiftyJSON

protocol JsonInit {
    static func from(json: JSON) -> Self
}

extension HandyJSON {
    static func from(json: JSON) -> Self {
        return Self.deserialize(from: (json.rawString() ?? "")) ?? Self()
    }
}
