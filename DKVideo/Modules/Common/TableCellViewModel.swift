//
//  TableCellViewModel.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
class TableCellViewModel:NSObject{
    let title = BehaviorRelay<String?>(value: nil)
    let detail = BehaviorRelay<String?>(value: nil)
    let image = BehaviorRelay<UIImage?>(value: nil)
    let hidesDisclosure = BehaviorRelay<Bool>(value: false)
}
