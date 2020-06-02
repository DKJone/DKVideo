//
//  BaseTableViewCell.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation

class BaseTableViewCell: TableViewCell {
    var viewModel = TableCellViewModel()

    func bindViewModel(viewModel: TableCellViewModel) {
        self.viewModel = viewModel

        viewModel.title.asDriver().drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.title.asDriver().replaceNilWith("").map { $0.isEmpty }.drive(titleLabel.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.detail.asDriver().drive(detailLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.detail.asDriver().replaceNilWith("").map { $0.isEmpty }.drive(detailLabel.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.hidesDisclosure.asDriver().drive(rightImageView.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.image.asDriver().filterNil()
            .drive(leftImageView.rx.image).disposed(by: rx.disposeBag)
    }

    lazy var leftImageView: UIImageView = {
        let view = UIImageView(frame: CGRect())
        view.contentMode = .scaleAspectFit
        view.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        return view
    }()

    lazy var textsStackView: UIStackView = {
        let views: [UIView] = [self.titleLabel, self.detailLabel]
        let view = UIStackView(arrangedSubviews: views)
        view.spacing = 2
        return view
    }()

    let titleLabel: UILabel = UILabel(fontSize: 14, text: "")

    let detailLabel: UILabel = UILabel(fontSize: 12, text: "")

    lazy var rightImageView: UIImageView = {
        let view = UIImageView(frame: CGRect())
        view.image = R.image.icon_cell_disclosure()?.template
        view.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        return view
    }()

    override func makeUI() {
        super.makeUI()

        themeService.rx
            .bind({ $0.text }, to: titleLabel.rx.textColor)
            .bind({ $0.textGray }, to: detailLabel.rx.textColor)
            .bind({ $0.secondary }, to: [leftImageView.rx.tintColor, rightImageView.rx.tintColor])
            .disposed(by: rx.disposeBag)

        stackView.addArrangedSubview(leftImageView)
        stackView.addArrangedSubview(textsStackView)
        stackView.addArrangedSubview(rightImageView)
        stackView.snp.remakeConstraints { make in
            let inset: CGFloat = 15
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: inset / 2, left: inset, bottom: inset / 2, right: inset))
            make.height.greaterThanOrEqualTo(45)
        }
    }
}
