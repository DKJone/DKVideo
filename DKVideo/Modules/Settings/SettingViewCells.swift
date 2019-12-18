//
//  SettingViewCells.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxRelay
import UIKit
extension SettingViewController {
    class SwitchCell: BaseTableViewCell {
        let aSwitch = UISwitch()
        override func makeUI() {
            super.makeUI()
            leftImageView.contentMode = .center
            leftImageView.snp.remakeConstraints { make in
                make.size.equalTo(35)
            }
            rightImageView.contentMode = .center
            rightImageView.snp.remakeConstraints { make in
                make.size.equalTo(25)
            }
            stackView.insertArrangedSubview(aSwitch, at: 2)

            themeService.rx
                .bind({ $0.secondary }, to: [aSwitch.rx.tintColor, aSwitch.rx.onTintColor])
                .bind({ $0.secondary }, to: leftImageView.rx.tintColor)
                .disposed(by: rx.disposeBag)
        }

        override func bindViewModel<T: SettingSwitchCellViewModel>(viewModel: T) {
            super.bindViewModel(viewModel: viewModel)
            viewModel.isEnabled.asDriver().drive(aSwitch.rx.isOn).disposed(by: rx.disposeBag)
            aSwitch.rx.isOn.bind(to: viewModel.switchChanged).disposed(by: rx.disposeBag)
        }
    }

    class TextCell: BaseTableViewCell {
        override func makeUI() {
            super.makeUI()
            leftImageView.contentMode = .center
            leftImageView.snp.remakeConstraints { make in
                make.size.equalTo(35)
            }
            rightImageView.contentMode = .center
            rightImageView.snp.remakeConstraints { make in
                make.size.equalTo(25)
            }
        }

        override func bindViewModel<T: SettingCellViewModel>(viewModel: T) {
            super.bindViewModel(viewModel: viewModel)
        }
    }
}

class SettingCellViewModel: TableCellViewModel {
    init(with title: String, detail: String?, image: UIImage?, hidesDisclosure: Bool) {
        super.init()
        self.title.accept(title)
        self.detail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
    }
}

class SettingSwitchCellViewModel: SettingCellViewModel {
    let isEnabled = BehaviorRelay<Bool>(value: false)

    let switchChanged: AnyObserver<Bool>
    init(with title: String, detail: String?, image: UIImage?, isEnabled: Bool, valueChanged: @escaping (Bool) -> Void) {
        self.isEnabled.accept(isEnabled)
        self.switchChanged = .init(eventHandler: { event in
            switch event {
            case let .next(value): valueChanged(value)
            case .completed: break
            case .error: break
            }
        })
        super.init(with: title, detail: detail, image: image, hidesDisclosure: true)
    }
}
