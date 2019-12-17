//
//  ViewController.swift
//   
//
//  Created by 朱德坤 on 2019/3/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import DZNEmptyDataSet
//import Hero
import NVActivityIndicatorView
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import XLPagerTabStrip
class ViewController: UIViewController, NVActivityIndicatorViewable {
    let isLoading = BehaviorRelay(value: false)

    var automaticallyAdjustsLeftBarButtonItem = true
    var canOpenFlex = true
    fileprivate var  indicatorInfo  = IndicatorInfo(title: "")
    var navigationTitle = "" {
        didSet {
            navigationItem.title = navigationTitle
            indicatorInfo.title = navigationTitle
        }
    }

    let spaceBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

    let emptyDataSetButtonTap = PublishSubject<Void>()
    var emptyDataSetTitle = ""
    var emptyDataSetDescription = "暂无数据"//"出错啦！\n没有你要访问的页面~\n\n"
    var emptyDataSetImage = R.image.pic_common_404()!
    var emptyDataSetImageTintColor = BehaviorRelay<UIColor?>(value: nil)

    let motionShakeEvent = PublishSubject<Void>()

    lazy var contentView: UIView = {
        let view = UIView()
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        return view
    }()

    lazy var stackView: UIStackView = {
        let subviews: [UIView] = []
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = .vertical
        view.spacing = 0
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

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

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        bindViewModel()

        closeBarButton.rx.tap.bind { [weak self] () in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)
        // Observe application did become active notification
        NotificationCenter.default
            .rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe { [weak self] _ in
                self?.didBecomeActive()
            }.disposed(by: rx.disposeBag)
        // Observe device orientation change
        NotificationCenter.default
            .rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe { [weak self] _ in
                self?.orientationChanged()
            }.disposed(by: rx.disposeBag)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
        updateUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        logResourcesCount()
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        logDebug("\(type(of: self)): Received Memory Warning")
    }

    func makeUI() {
//        hero.isEnabled = true
        navigationItem.backBarButtonItem = backBarButton
        motionShakeEvent.subscribe(onNext: { () in
            //FIXME: - not complete
//            let theme = themeService.type.toggled()
//            themeService.switch(theme)
        }).disposed(by: rx.disposeBag)
        if #available(iOS 13.0, *) {
            if self.modalPresentationStyle == .pageSheet{
                self.modalPresentationStyle = .fullScreen
            }
            overrideUserInterfaceStyle = .light
        }
        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
            .bind({ $0.secondaryDark }, to: [backBarButton.rx.tintColor, closeBarButton.rx.tintColor])
            .disposed(by: rx.disposeBag)

        updateUI()
    }

    func bindViewModel() {
        emptyDataSetButtonTap.bind { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)

        }.disposed(by: rx.disposeBag)
    }

    func updateUI() {
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            motionShakeEvent.onNext(())
        }
    }

    func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateUI()
        }
    }

    func didBecomeActive() {
        updateUI()
    }

    // MARK: Adjusting Navigation Item

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
}

extension ViewController {
    func emptyView(withHeight height: CGFloat) -> UIView {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return view
    }

    public var emptyTableFooterView: UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.01))
    }

    @objc func handleThreeFingerSwipe(swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .recognized {
            LibsManager.shared.showFlex()

        }
    }
}

extension Reactive where Base: ViewController {
    /// Bindable sink for `backgroundColor` property
    var emptyDataSetImageTintColorBinder: Binder<UIColor?> {
        return Binder(base) { view, attr in
            view.emptyDataSetImageTintColor.accept(attr)
        }
    }
}

extension ViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetTitle)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetDescription)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyDataSetImage
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return emptyDataSetImageTintColor.value
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60
    }
}

extension ViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !isLoading.value
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        emptyDataSetButtonTap.onNext(())
    }
}

extension ViewController: IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return self.indicatorInfo
    }
}
