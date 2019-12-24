//
//  SettingViewModel.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/18.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxCocoa
import RxDataSources

enum SettingSection: SectionModelType {
    case detail(title: String, items: [SettingItem])

    typealias Item = SettingItem

    var title: String {
        switch self {
        case .detail(let title, _): return title
        }
    }

    var items: [SettingItem] {
        switch self {
        case .detail(_, let items): return items.map { $0 }
        }
    }

    init(original: SettingSection, items: [Item]) {
        switch original {
        case .detail(let title, let items): self = .detail(title: title, items: items)
        }
    }
}

enum SettingItem {
    case text(viewModel: SettingCellViewModel)
    case selects(viewModel: SettingSwitchCellViewModel)

    var viewModel: SettingCellViewModel {
        switch self {
        case .text(let viewModel): return viewModel
        case .selects(let viewModel): return viewModel
        }
    }
}

class SettingViewModel: ViewModel {
    struct Input {}

    struct Output {
        let items: Driver<[SettingSection]>
        // ["夜间模式","主题设置","开启时自动下载","使用WKWebview","浏览桌面版网页","显示解析视图","清除缓存","移动网络下载","关于"]
    }

    func transform(input: Input) -> Output {
        let items: [SettingSection] = [
            .detail(title: "主题设置", items: [
                .text(viewModel: .init(with: "主题设置", detail: nil, image: R.image.icon_cell_theme()?.template, hidesDisclosure: false)),
                .selects(viewModel: .init(with: "夜间模式", detail: nil, image: R.image.icon_cell_night_mode()?.template, isEnabled: ThemeType.currentTheme().isDark, valueChanged: { isDark in
                    if ThemeType.currentTheme().isDark != isDark {
                        themeService.switch(ThemeType.currentTheme().toggled())
                    }
                }))
            ]),
            .detail(title: "网页设置", items: [
                .selects(viewModel: .init(with: "使用WKWebview", detail: "性能好，兼容差", image: R.image.icon_navigation_web()?.template, isEnabled: UserDefaults.useWKWebview, valueChanged: { UserDefaults.useWKWebview = $0 })),
                .selects(viewModel: .init(with: "浏览桌面版网页", detail: "", image: R.image.icon_navigation_web()?.template, isEnabled: UserDefaults.isPCAgent, valueChanged: { UserDefaults.isPCAgent = $0 })),
                .selects(viewModel: .init(with: "显示解析视图", detail: "", image: R.image.icon_navigation_web()?.template, isEnabled: UserDefaults.showVipWebView, valueChanged: { UserDefaults.showVipWebView = $0 }))
            ]),
            .detail(title: "其他", items: [
                .text(viewModel: .init(with:
                    "清除缓存", detail: "", image: R.image.icon_cell_dir()?.template, hidesDisclosure: false)),
                .selects(viewModel: .init(with: "打开APP时自动下载", detail: nil, image: R.image.icon_navigation_refresh()?.template, isEnabled: UserDefaults.autoStartDownload, valueChanged: { UserDefaults.autoStartDownload = $0 })),
                .selects(viewModel: .init(with: "后台时下载", detail: "下次启动生效", image: R.image.icon_navigation_refresh()?.template, isEnabled: UserDefaults.backgroundDownload, valueChanged: { UserDefaults.backgroundDownload = $0 })),
                .selects(viewModel: .init(with: "使用流量下载", detail: "下次启动生效", image: R.image.icon_navigation_refresh()?.template, isEnabled: UserDefaults.downloadWithoutWifi, valueChanged: { UserDefaults.downloadWithoutWifi = $0 })),
                .text(viewModel: .init(with:
                    "关于", detail: "", image: R.image.icon_cell_dir()?.template, hidesDisclosure: false))
            ])
        ]
        return Output(items: Driver.just(items))
    }
}
