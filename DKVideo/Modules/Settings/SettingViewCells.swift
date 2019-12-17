//
//  SettingViewCells.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit

extension SettingViewController{

    class SwitchCell: BaseTableViewCell {
        let aSwitch = UISwitch()
        override func makeUI() {
            super.makeUI()
        }
    }
}

class SettingSwitchCellViewModel: TableCellViewModel {

    let isEnabled = BehaviorRelay<Bool>(value: false)

    let switchChanged = PublishSubject<Bool>()

    init(with title: String, detail: String?, image: UIImage?, hidesDisclosure: Bool, isEnabled: Bool) {
        super.init()
        self.title.accept(title)
        self.detail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
        self.isEnabled.accept(isEnabled)
    }
}
