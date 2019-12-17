//
//  VipWebsites.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/9.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
import HandyJSON
struct VipAnalysis: HandyJSON, ListAble {
    var text: String {
        return title
    }

    var id: String {
        return url
    }

    var selected = false
    var title = ""
    var url = ""

    static var vips: [VipAnalysis] = {
        let str = (try? String(contentsOf: R.file.vipwebsitesJson()!)) ?? ""
        return JSON(parseJSON: str).arrayValue.map(VipAnalysis.from(json:))
    }()
}
