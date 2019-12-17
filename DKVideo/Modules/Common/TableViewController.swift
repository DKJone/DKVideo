//
//  TableViewController.swift
//  szwhExpressway
//
//  Created by 朱德坤 on 2019/3/22.
//  Copyright © 2019 DKJone. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KafkaRefresh

class TableViewController: ViewController, UIScrollViewDelegate {

    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()

    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)

    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect(), style: .plain)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 50
        view.tableFooterView = UIView()
        view.rx.setDelegate(self).disposed(by: rx.disposeBag)
        view.cellLayoutMarginsFollowReadableWidth = false
        return view
    }()

    var clearsSelectionOnViewWillAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if clearsSelectionOnViewWillAppear == true {
            deselectSelectedRow()
        }
    }

    override func makeUI() {
        super.makeUI()

        stackView.spacing = 0
        stackView.insertArrangedSubview(tableView, at: 0)
//        tableView.snp.makeConstraints{ $0.edges.equalToSuperview()}

        tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
            self?.tableView.footRefreshControl.resumeRefreshAvailable()
        })

        tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
         tableView.footRefreshControl.setAlertBackgroundColor( themeService.type.associatedObject.background)

        isHeaderLoading.bind(to: tableView.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        isFooterLoading.bind(to: tableView.footRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)

        tableView.footRefreshControl.autoRefreshOnFoot = true

        let updateEmptyDataSet = Observable.of(isLoading.mapToVoid().asObservable(), emptyDataSetImageTintColor.mapToVoid()).merge()
        updateEmptyDataSet.subscribe(onNext: { [weak self] () in
            self?.tableView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)
        themeService
            .rx
            .bind({ $0.background }, to: tableView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }

    override func updateUI() {
        super.updateUI()
    }
}

extension TableViewController {

    func deselectSelectedRow() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            selectedIndexPaths.forEach({ (indexPath) in
                tableView.deselectRow(at: indexPath, animated: false)
            })
        }
    }
}

extension TableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = UIFont(name: ".SFUIText-Bold", size: 15.0)!
            themeService.rx
                .bind({ $0.text }, to: view.textLabel!.rx.textColor)
                .bind({ $0.primaryDark }, to: view.contentView.rx.backgroundColor)
                .disposed(by: rx.disposeBag)
        }
    }
}
