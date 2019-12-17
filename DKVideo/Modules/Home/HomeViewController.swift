//
//  HomeViewController.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit
class HomeViewController: ViewController {
    lazy var searchBar: UIView = {
        let searchBar = UIView()
        let textView = UITextField(placeholder: "请输入地址", placeholderSize: 14)
        searchBar.backgroundColor = UIColor.white
        searchBar.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
        let imgV = UIImageView(image: R.image.icon_tabbar_search())
        textView.leftView = imgV
        textView.clearButtonMode = .whileEditing
        textView.leftViewMode = .always
        imgV.frame = CGRect(x: 10, y: 10, width: 34, height: 14)
        textView.font = UIFont.systemFont(ofSize: 14)
        imgV.contentMode = .center
        textView.rx.controlEvent(.editingDidEndOnExit).bind(onNext: { [unowned self] _ in
            if let url = URL(string: textView.text!) {
                let webVC = WebViewController()
                webVC.requestURL = url
                self.navigationController?.pushViewController(webVC)
            } else {
                showMessage(message: "请输入正确的地址")
            }
        }).disposed(by: rx.disposeBag)
        themeService.rx
            .bind({ $0.background }, to: textView.rx.backgroundColor)
            .disposed(by: self.rx.disposeBag)
        return searchBar
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: screenWidth / 2 - 1, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellWithClass: MenuItem.self)
        return collectionView
    }()

    override func makeUI() {
        super.makeUI()
        navigationTitle = "首页"
        contentView.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(50)
            make.left.right.equalToSuperview()
        }
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0))
        }
        themeService
            .rx
            .bind({ $0.background }, to: collectionView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }

    override func bindViewModel() {
        let subject = PublishSubject<[SubMenu]>()
        let str = (try? String(contentsOf: R.file.platformJson()!)) ?? ""
        let arr = JSON(parseJSON: str).arrayValue
        let menus = arr.map(SubMenu.from(json:))

        subject
            .bind(to: collectionView.rx.items(cellIdentifier: String(describing: MenuItem.self), cellType: MenuItem.self)) { _, model, cell in
                cell.setup(data: model)
            }.disposed(by: rx.disposeBag)
        subject.onNext(menus)
        collectionView.rx.modelSelected(SubMenu.self).bind { [unowned self] item in
            let webVC = WebViewController()
            webVC.requestURL = item.url
            self.navigationController?.pushViewController(webVC)
        }.disposed(by: rx.disposeBag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if waitToPresentVC != nil{
            present(waitToPresentVC!, animated: true, completion: nil)
            waitToPresentVC = nil
        }
    }

}

extension HomeViewController {
    struct SubMenu: HandyJSON {
        var url: URL?
        var image: URL?
        static func from(json: JSON) -> SubMenu {
            var menu = SubMenu()
            menu.url = json["url"].url
            menu.image = json["image"].url
            return menu
        }
    }

    /// 菜单cell
    class MenuItem: UICollectionViewCell {
        let titleLab = UILabel(fontSize: 16, textColor: .darkGray)
        let imageView = UIImageView(frame: .zero)

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubviews([titleLab, imageView])
            themeService.rx
                .bind({ $0.primary }, to: rx.backgroundColor)
                .bind({ $0.text }, to: titleLab.rx.textColor)
                .disposed(by: rx.disposeBag)
            imageView.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
            }
            imageView.contentMode = .scaleAspectFit

            titleLab.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }

        func setup(data: SubMenu) {
            imageView.sd_setImage(with: data.image, completed: nil)
            //titleLab.text = String(data.url?.absoluteString.dropLast(5).dropFirst(11) ?? "")
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}
