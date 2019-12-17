//
//  CommonSelectVC.swift
//  roadbed
//
//  Created by 朱德坤 on 2018/11/2.
//  Copyright © 2018 DKJone. All rights reserved.
//
import ChameleonFramework
import UIKit
protocol ListAble {
    var text: String { get }
    var id: String { get }
    var selected: Bool { get set }
}

extension ListAble {
    func toCommon() -> CommonListData {
        return .init(id: id, text: text, selected: selected)
    }
}

/// 默认的列表协议数据实现
struct CommonListData: ListAble {
    var text: String

    var id: String

    var selected: Bool
    init(id: String = "", text: String = "", selected: Bool = false) {
        self.id = id
        self.text = text
        self.selected = selected
    }
}

/// 通用列表选择界面
class CommonSelectVC<T: ListAble>: ViewController, UITableViewDelegate, UITableViewDataSource {
    /// 是否可以多选
    var shouldMutableSelect = false
    let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    /// 列表数据源
    var listDataProvider: ((inout [T]) -> Void)!
    /// 列表数据
    var listData = [T]() {
        didSet {
            tableView.reloadData()
        }
    }

    /// 选择完成的回调
    var commitHandle: (([T]) -> Void)!
    /// 返回时是否需要动画
    var animate = true
    override func viewDidLoad() {
        super.viewDidLoad()

        let bgView = UIVisualEffectView(frame: view.frame)
        bgView.effect = UIBlurEffect(style: .dark)
        bgView.alpha = 0.5
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelect)))
        view.addSubviews([bgView, tableView])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets.zero) }
        if shouldMutableSelect {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(commit))
            navigationItem.setRightBarButton(item, animated: true)
        }
        themeService.rx
            .bind({ $0.background }, to: tableView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDataProvider?(&listData)
    }

    @objc func commit() {
        let selectedList = (listData.filter { $0.selected })
        commitHandle(selectedList)
        dismissSelect()
    }

    @objc func dismissSelect() {
        dismiss(animated: true)
    }

    public convenience init(title: String = "请选择", shouldMutableSelect: Bool = false, listDataProvider: @escaping (inout [T]) -> Void, commitHandle: @escaping (([T]) -> Void)) {
        self.init()
//        self.init(title: title)
        self.title = title
        self.shouldMutableSelect = shouldMutableSelect
        self.listDataProvider = listDataProvider
        self.commitHandle = commitHandle
    }

    func showSelect(in vc: UIViewController, frame: CGRect = CGRect(x: 20, y: 60, width: screenWidth - 40, height: screenHeight - 120)) {
        tableView.frame = frame
        view.backgroundColor = .clear
        modalPresentationStyle = .custom
        vc.present(self, animated: false) {}
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // listData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CommonSelectCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CommonSelectCell")
        }
        cell?.textLabel?.text = listData[indexPath.row].text
        //        cell?.imageView?.image = listData[indexPath.row].icon
        cell?.accessoryView = listData[indexPath.row].selected ? UIImageView(image: R.image.icon_common_select()) : nil
        cell?.textLabel?.textColor = listData[indexPath.row].selected ? .flatBlue : .darkGray
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = .text()
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if !shouldMutableSelect {
            for i in 0..<listData.count { listData[i].selected = false }
            listData[indexPath.row].selected = true
            commit()
            return
        }
        if listData[indexPath.row].selected {
            listData[indexPath.row].selected = false
            cell?.accessoryType = .none
        } else {
            listData[indexPath.row].selected = true
            cell?.accessoryType = .checkmark
        }
    }
}

/// 统一的弹出式列表选择
///
/// - Parameters:
///   - title: 选择的标题
///   - isMutableSelect: 是否需要多选
///   - height: 选择列表内容的高度
///   - listDataProvider: 选择列表内容提供者
///   - commitHandle: 选择完成回调
func showSelectVC<T: ListAble>(inVC: UIViewController, title: String = "请选择", isMutableSelect: Bool = false, height: CGFloat = screenHeight - 200, listDataProvider: @escaping ((inout [T]) -> Void), commitHandle: @escaping (([T]) -> Void)) {
    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
    let vc = CommonSelectVC<T>(listDataProvider: listDataProvider, commitHandle: commitHandle)
    alert.setValue(vc, forKey: "contentViewController")

    vc.preferredContentSize.height = height
    alert.preferredContentSize.height = height
    vc.shouldMutableSelect = isMutableSelect
    if isMutableSelect {
        alert.addAction(title: "确定", style: .default, isEnabled: true) { _ in
            vc.commit()
        }
    } else {
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
    }

    inVC.present(alert, animated: true, completion: nil)
}

