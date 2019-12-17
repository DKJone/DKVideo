//
//  ThemeManager.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/3/7.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTheme
import UIKit
import ChameleonFramework


let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)

let themeService = ThemeType.service(initial: ThemeType.currentTheme())

protocol Theme {

    /// 白背景色
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    /// 导航栏颜色- 主题色
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    /// 分割线颜色
    var separator: UIColor { get }
    /// 文字颜色 - 黑色
    var text: UIColor { get }
    /// 文字颜色 - 灰色
    var textGray: UIColor { get }
    /// 背景色
    var background: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }

    init(colorTheme: ColorTheme)
}

struct LightTheme: Theme {
    let primary = UIColor.white
    let primaryDark = UIColor.flatWhite
    var secondary = UIColor(hex: 0x24a2fd)!
    var secondaryDark = UIColor.white
    let separator = UIColor(hexString: "#dbdbdd")!
    let text = UIColor.flatBlack
    let textGray = UIColor(hex: 0x98999a)!//UIColor.flatGray
    let background = UIColor(hexString: "#F5F7FA")!
    let statusBarStyle = UIStatusBarStyle.default
    let barStyle = UIBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight

    init(colorTheme: ColorTheme) {
        self.secondary = colorTheme.color
        self.secondaryDark = colorTheme.colorDark
    }
}

struct DarkTheme: Theme {
    let primary = UIColor.flatBlack
    let primaryDark = UIColor.flatBlackDark
    var secondary = UIColor(hex: 0x24a2fd)!.darken()
    var secondaryDark = UIColor.flatWhiteDark
    let separator = UIColor.flatWhite
    let text = UIColor.flatWhite
    let textGray = UIColor.flatGray
    let background = UIColor.flatBlackDark
    let statusBarStyle = UIStatusBarStyle.lightContent
    let barStyle = UIBarStyle.black
    let keyboardAppearance = UIKeyboardAppearance.dark
    let blurStyle = UIBlurEffect.Style.dark

    init(colorTheme: ColorTheme) {
        self.secondary = colorTheme.color
        self.secondaryDark = colorTheme.colorDark
    }
}

enum ColorTheme: Int {
    case red, green, blue, skyBlue, magenta, purple, watermelon, lime, pink

    static let allValues = [red, green, blue, skyBlue, magenta, purple, watermelon, lime, pink]

    var color: UIColor {
        switch self {
        case .red: return UIColor.flatRed
        case .green: return UIColor.flatGreen
        case .blue: return UIColor.flatBlue
        case .skyBlue: return UIColor.flatSkyBlue
        case .magenta: return UIColor.flatMagenta
        case .purple: return UIColor.flatPurple
        case .watermelon: return UIColor.flatWatermelon
        case .lime: return UIColor.flatLime
        case .pink: return UIColor.flatPink
        }
    }

    var colorDark: UIColor {
        switch self {
        case .red: return UIColor.flatRedDark()
        case .green: return UIColor.flatGreenDark()
        case .blue: return UIColor.flatBlueDark()
        case .skyBlue: return UIColor.flatSkyBlueDark()
        case .magenta: return UIColor.flatMagentaDark()
        case .purple: return UIColor.flatPurpleDark()
        case .watermelon: return UIColor.flatWatermelonDark()
        case .lime: return UIColor.flatLimeDark()
        case .pink: return UIColor.flatPinkDark()
        }
    }

    var title: String {
        switch self {
        case .red: return "Red"
        case .green: return "Green"
        case .blue: return "Blue"
        case .skyBlue: return "Sky Blue"
        case .magenta: return "Magenta"
        case .purple: return "Purple"
        case .watermelon: return "Watermelon"
        case .lime: return "Lime"
        case .pink: return "Pink"
        }
    }
}

enum ThemeType: ThemeProvider {
    case light(color: ColorTheme)
    case dark(color: ColorTheme)

    var associatedObject: Theme {
        switch self {
        case .light(let color): return LightTheme(colorTheme: color)
        case .dark(let color): return DarkTheme(colorTheme: color)
        }
    }

    var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }

    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light(let color):
            theme = ThemeType.dark(color: color)
            globalStatusBarStyle.accept(.lightContent)
        case .dark(let color):
            theme = ThemeType.light(color: color)
            if #available(iOS 13.0, *) {
                globalStatusBarStyle.accept(.darkContent)
            } else {
               globalStatusBarStyle.accept(.default)
            }
        }
        theme.save()
        return theme
    }

    func withColor(color: ColorTheme) -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = ThemeType.light(color: color)
        case .dark: theme = ThemeType.dark(color: color)
        }
        theme.save()
        return theme
    }
}

extension ThemeType {
    static func currentTheme() -> ThemeType {
        let isDark = UserDefaults.standard.isDark

        let colorTheme = ColorTheme(rawValue: UserDefaults.standard.themeColor) ?? ColorTheme.red
        let theme = isDark ? ThemeType.dark(color: colorTheme) : ThemeType.light(color: colorTheme)
        theme.save()
        return theme
    }

    func save() {
        UserDefaults.standard.isDark = isDark
        switch self {
        case .light(let color): UserDefaults.standard.themeColor = color.rawValue
        case .dark(let color): UserDefaults.standard.themeColor = color.rawValue
        }
    }
}

extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }
}

extension Reactive where Base: UITextField {
    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}


extension Reactive where Base: TextView {
    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.placeholderColor = color
            }
        }
    }
}

extension Reactive where Base: UITableView {
    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}

//extension Reactive where Base: UITabBarItem {
//    var iconColor: Binder<UIColor> {
//        return Binder(self.base) { view, attr in
//            view.imagec
//            view.image = view.image?.filled(withColor: attr)
//        }
//    }
//
//    var textColor: Binder<UIColor> {
//        return Binder(self.base) { view, attr in
//            view.titl  = attr
//            view.deselectAnimation()
//        }
//    }
//}
//
//extension Reactive where Base: RAMItemAnimation {
//    var iconSelectedColor: Binder<UIColor> {
//        return Binder(self.base) { view, attr in
//            view.iconSelectedColor = attr
//        }
//    }
//
//    var textSelectedColor: Binder<UIColor> {
//        return Binder(self.base) { view, attr in
//            view.textSelectedColor = attr
//        }
//    }
//}

extension Reactive where Base:UITabBar{
    var unselectedItemTintColor: Binder<UIColor> {
        return Binder(self.base){bar,color in
            bar.unselectedItemTintColor = color
        }
    }
}

extension Reactive where Base: UINavigationBar {
    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

extension Reactive where Base: UIApplication {
    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { _, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}

extension Reactive where Base: KafkaRefreshDefaults {
    var themeColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.themeColor = attr
        }
    }
}

public extension Reactive where Base: UISwitch {
    var onTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.onTintColor = attr
        }
    }

    var thumbTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.thumbTintColor = attr
        }
    }
}
