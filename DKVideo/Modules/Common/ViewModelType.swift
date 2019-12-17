//
//  ViewModelType.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/3/20.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class ViewModel: NSObject {
    var page = 1

//    let loading = ActivityIndicator()
//    let headerLoading = ActivityIndicator()
//    let footerLoading = ActivityIndicator()
        let loading = BehaviorRelay<Bool>(value:false)
        let headerLoading = BehaviorRelay<Bool>(value:false)
        let footerLoading = BehaviorRelay<Bool>(value:false)

        /// 无更多数据 ：false ，重置：true
        let noMoreDate = BehaviorRelay<Bool>(value:false)
    override init() {
        super.init()
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
}
