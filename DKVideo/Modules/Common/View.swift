//
//  View.swift
//   
//
//  Created by 朱德坤 on 2019/4/16.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation

class View: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeUI(){
        themeService.rx
            .bind({ $0.background }, to: rx.backgroundColor)
            .disposed(by: self.rx.disposeBag)
    }
}
