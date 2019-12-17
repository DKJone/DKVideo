//
//  TableViewCell.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/3/25.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxSwift
import UIKit
class TableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()

    static var identifier: String {
        return String(describing: self)
    }

    var isSelection = false
    var selectionColor: UIColor? {
        didSet {
            setSelected(isSelected, animated: true)
        }
    }

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy var stackView: UIStackView = {
        let subviews: [UIView] = []
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = .horizontal
        view.alignment = .center
        self.containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = selected ? selectionColor : .clear
    }

    func makeUI() {
        layer.masksToBounds = true
        selectionStyle = .none
        backgroundColor = .clear

        themeService.rx
            .bind({ $0.primaryDark }, to: rx.selectionColor)
            .bind({ $0.textGray }, to: textLabel!.rx.textColor)
            .bind({ $0.text }, to: detailTextLabel!.rx.textColor)
            .disposed(by: rx.disposeBag)

        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}

extension Reactive where Base: TableViewCell {
    var selectionColor: Binder<UIColor?> {
        return Binder(base) { view, attr in
            view.selectionColor = attr
        }
    }
}

class TableViewHeaderFooter: UITableViewHeaderFooterView {
    var disposeBag = DisposeBag()
    let bgView = UIView()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func makeUI() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        themeService.rx
            .bind({ $0.primary }, to: bgView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
}
