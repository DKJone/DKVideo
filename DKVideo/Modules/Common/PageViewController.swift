//
//  PageViewController.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/4/10.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit
import XLPagerTabStrip
class PageViewController: ButtonBarPagerTabStripViewController {
    /// viewControllers
    var pages = [UIViewController]()
    var automaticallyAdjustsLeftBarButtonItem = true
    lazy var barTitleColor = UIColor.textGray()
    lazy var selectTitleColor = UIColor.secondary()
    lazy var backBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = ""
        return view
    }()

    lazy var closeBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: R.image.icon_navigation_back(),
                                   style: .plain,
                                   target: self,
                                   action: nil)
        return view
    }()

    var navigationTitle = "" {
        didSet { navigationItem.title = navigationTitle }
    }

    var hasRedPointIndexs = [Int]() {
        didSet {
            buttonBarView.reloadData()
        }
    }

    lazy var setting: ButtonBarPagerTabStripSettings = {
        settings.style.buttonBarBackgroundColor = .primary()
        settings.style.buttonBarHeight = 40
        settings.style.buttonBarItemBackgroundColor = .primary()
        settings.style.selectedBarBackgroundColor = selectTitleColor
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = barTitleColor
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 15
        settings.style.buttonBarRightContentInset = 15
        var setting = settings
        return setting
    }()

    override func viewDidLoad() {
        // settings 设置要在 viewDidLoad前设置
        settings = setting

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, _: CGFloat, changeCurrentIndex: Bool, _: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = self?.barTitleColor
            newCell?.label.textColor = self?.selectTitleColor
        }

        super.viewDidLoad()
        makeUI()
    }

    func makeUI() {
//        hero.isEnabled = true
        navigationItem.backBarButtonItem = backBarButton
        closeBarButton.rx.tap.bind { [weak self] () in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)
        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
            .bind({ $0.primary }, to: buttonBarView.rx.backgroundColor)
            .bind({ $0.secondaryDark }, to: [backBarButton.rx.tintColor, closeBarButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
        themeService.attrsStream.bind { [unowned self] theme in
            self.settings.style.buttonBarItemBackgroundColor = theme.primary
            self.barTitleColor = theme.textGray
            self.selectTitleColor = theme.secondary
            self.settings.style.selectedBarBackgroundColor = self.selectTitleColor
            self.settings.style.buttonBarItemTitleColor = self.barTitleColor
            self.buttonBarView.reloadData()
        }.disposed(by: rx.disposeBag)
        buttonBarView.shadowOffset = CGSize(width: 0, height: 0.3)
        buttonBarView.shadowOpacity = 0.3
        buttonBarView.shadowRadius = 0.3
        buttonBarView.clipsToBounds = false
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logResourcesCount()
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }

    func adjustLeftBarButtonItem() {
        if navigationController?.viewControllers.count ?? 0 > 1 { // Pushed
            navigationItem.leftBarButtonItem = nil
        } else if presentingViewController != nil { // presented
            navigationItem.leftBarButtonItem = closeBarButton
        }
    }

    @objc func closeAction(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return pages
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        guard let label = (cell as? ButtonBarViewCell)?.label else { return cell }
        if let redPoint = cell.contentView.viewWithTag(10010) {
            redPoint.isHidden = !hasRedPointIndexs.contains(indexPath.row)
        } else {
            let contenntV = cell.contentView
            let redPoint = UIView()
            redPoint.tag = 10010
            contenntV.addSubview(redPoint)
            redPoint.snp.makeConstraints { make in
                make.centerY.equalTo(label.snp.top)
                make.centerX.equalTo(label.snp.right)
                make.width.height.equalTo(10)
            }
            redPoint.cornerRadius = 5
            redPoint.backgroundColor = .red
            redPoint.isHidden = !hasRedPointIndexs.contains(indexPath.row)
        }
        cell.clipsToBounds = false
        return cell
    }
}
