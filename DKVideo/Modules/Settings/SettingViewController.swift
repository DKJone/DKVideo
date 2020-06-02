//
//  SettingViewController.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxDataSources
import UIKit
class SettingViewController: TableViewController {
    var viewModle = SettingViewModel()

    override func makeUI() {
        super.makeUI()
        navigationTitle = "设置"
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }

    override func bindViewModel() {
        super.bindViewModel()
        tableView.register(cellWithClass: TextCell.self)
        tableView.register(cellWithClass: SwitchCell.self)
        let output = viewModle.transform(input: .init())

        let datasource = RxTableViewSectionedReloadDataSource<SettingSection>.init(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case let .text(viewModel: cellModel):
                let cell = tableView.dequeueReusableCell(withClass: TextCell.self, for: indexPath)
                cell.bindViewModel(viewModel: cellModel)
                return cell
            case let .selects(viewModel: cellModel):
                let cell = tableView.dequeueReusableCell(withClass: SwitchCell.self, for: indexPath)
                cell.bindViewModel(viewModel: cellModel)
                return cell
            }

        }, titleForHeaderInSection: { (source, index) -> String? in
            source[index].title
        })
        output.items.drive(tableView.rx.items(dataSource: datasource)).disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(SettingItem.self).bind { [unowned self] item in
            if item.viewModel.title.value == "主题设置" {
                let themes = ColorTheme.allValues.map { CommonListData(id: $0.rawValue.string, text: $0.title, selected: UserDefaults.standard.themeColor == $0.rawValue, icon: UIImage(color: $0.color, size: CGSize(width: 30, height: 30))) }

                showSelectVC(inVC: self, height: CGFloat(themes.count * 44), listDataProvider: { list in
                    list = themes
                }) { list in
                    let theme = ColorTheme(rawValue: Int(list.first!.id)!)!
                    themeService.switch(ThemeType.currentTheme().withColor(color: theme))
                }
            } else if item.viewModel.title.value == "关于" {
                let webVC = WebViewController()
                webVC.requestURL = URL(string: "https://www.jianshu.com/p/f9d06ed27f24")
                self.navigationController?.pushViewController(webVC)
            } else if item.viewModel.title.value == "最大下载线程数" {
                self.changeMaxTs(vm: item.viewModel)
            }
        }.disposed(by: rx.disposeBag)
        tableView.rx.itemSelected.bind { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    func changeMaxTs(vm: SettingCellViewModel) {
        let alert = UIAlertController(title: "最大下载线程数", message: nil, preferredStyle: .alert)
        alert.addTextField(text: UserDefaults.maxDownloadTS.string, placeholder: nil, editingChangedTarget: nil, editingChangedSelector: nil)
        alert.addAction(title: "确定", style: .default, isEnabled: true) { _ in
            UserDefaults.maxDownloadTS = alert.textFields?.first?.text?.int ?? 3
            vm.detail.accept(UserDefaults.maxDownloadTS.string)
        }
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        alert.show()
    }
}
