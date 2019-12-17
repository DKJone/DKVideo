//
//  UIView+Utils.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/3/21.
//  Copyright © 2019 DKJone. All rights reserved.
//

import ChameleonFramework
import Foundation
extension UILabel {
    convenience init(fontSize: Int = 14, textColor: UIColor? = nil, text: String = "") {
        self.init()
        self.text = text
        font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        if textColor == nil {
            themeService.rx.bind({ $0.text }, to: rx.textColor).disposed(by: rx.disposeBag)
        } else {
            self.textColor = textColor
        }
    }
}

extension UITextField {
    convenience init(placeholder: String = "", placeholderSize: CGFloat = 13, text: String = "", textColor: UIColor = .black, editAble: Bool = true) {
        self.init()
        self.placeholder = placeholder == "" ? nil : placeholder
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: placeholderSize)])
        self.text = text == "" ? nil : text
        self.textColor = textColor
        font = UIFont.systemFont(ofSize: placeholderSize)
        isEnabled = editAble
    }
}

extension UIView {
    /// 设置渐变色(view.frame.size必须已知)
    ///
    /// - Parameters:
    ///   - fromColor: 起始颜色,默认#23BAFF
    ///   - toColor: 结束颜色,默认#3A8EFF
    ///   - from: 起始位置，默认左边中间(left)
    ///   - to: 结束位置,默认右边中间(right)
    func gradientColor(fromColor: UIColor = .lightBlue,
                       toColor: UIColor = .darkBlue,
                       from: GrandientLocation = .left,
                       to: GrandientLocation = .right) {
        // 渐变的颜色
        let gradientColors = [fromColor.cgColor, toColor.cgColor]
        // 创建CAGradientLayer对象并设置参数
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = from.point
        gradientLayer.endPoint = to.point
        // 设置其CAGradientLayer对象的frame，并插入view的layer
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// 位置
    enum GrandientLocation {
        case topLeft
        case bottomLeft
        case topRight
        case bottomRight
        case left
        case right
        case top
        case bottom
        case center

        /// 位置对应的CGPoint
        var point: CGPoint {
            switch self {
            case .topLeft: return CGPoint(x: 0, y: 0)
            case .bottomLeft: return CGPoint(x: 0, y: 1)
            case .topRight: return CGPoint(x: 1, y: 0)
            case .bottomRight: return CGPoint(x: 1, y: 1)
            case .left: return CGPoint(x: 0, y: 0.5)
            case .right: return CGPoint(x: 1, y: 0.5)
            case .top: return CGPoint(x: 0.5, y: 0)
            case .bottom: return CGPoint(x: 0.5, y: 1)
            case .center: return CGPoint(x: 0.5, y: 0.5)
            }
        }
    }
}

// MARK: - 调整label行间距

func getAttributeStringWithString(_ string: String, lineSpace: CGFloat) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: string)
    let paragraphStye = NSMutableParagraphStyle()

    // 调整行间距
    paragraphStye.lineSpacing = lineSpace
    let rang = NSMakeRange(0, CFStringGetLength(string as CFString?))
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStye, range: rang)
    return attributedString
}

func imageFromColor(color: UIColor) -> UIImage {
    let rect: CGRect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

    UIGraphicsBeginImageContext(rect.size)

    let context: CGContext = UIGraphicsGetCurrentContext()!

    context.setFillColor(color.cgColor)

    context.fill(rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsGetCurrentContext()

    return image!
}

enum ButtonEdgeInsetsStyle {
    case imageTop // image在上，label在下
    case imageLeft // image在左，label在右
    case imageBottom // image在下，label在上
    case imageRight // image在右，label在左
}

extension UIButton {
    /// 设置按钮图片和文字为止(需要先设置button布局或frame)
    ///
    /// - Parameters:
    ///   - style: 位置样式
    ///   - space: 间距
    func layoutButtonEdgeInsets(style: ButtonEdgeInsetsStyle, space: CGFloat) {
        var labelWidth: CGFloat = 0.0
        var labelHeight: CGFloat = 0.0
        var imageEdgeInset = UIEdgeInsets.zero
        var labelEdgeInset = UIEdgeInsets.zero
        let imageWith = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        if (Double(UIDevice.current.systemVersion) ?? 8.0) >= 8.0 {
            labelWidth = (self.titleLabel?.intrinsicContentSize.width)!
            labelHeight = (self.titleLabel?.intrinsicContentSize.height)!
        } else {
            labelWidth = (self.titleLabel?.frame.size.width)!
            labelHeight = (self.titleLabel?.frame.size.height)!
        }
        switch style {
        case .imageTop:
            imageEdgeInset = UIEdgeInsets(top: -labelHeight - space / 2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInset = UIEdgeInsets(top: 0, left: -imageWith!, bottom: -imageHeight! - space / 2.0, right: 0)
        case .imageLeft:
            imageEdgeInset = UIEdgeInsets(top: 0, left: -space / 2.0, bottom: 0, right: space / 2.0)
            labelEdgeInset = UIEdgeInsets(top: 0, left: space / 2.0, bottom: 0, right: -space / 2.0)
        case .imageBottom:
            imageEdgeInset = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight - space / 2.0, right: -labelWidth)
            labelEdgeInset = UIEdgeInsets(top: -imageHeight! - space / 2.0, left: -imageWith!, bottom: 0, right: 0)
        case .imageRight:
            imageEdgeInset = UIEdgeInsets(top: 0, left: labelWidth + space / 2.0, bottom: 0, right: -labelWidth - space / 2.0)
            labelEdgeInset = UIEdgeInsets(top: 0, left: -imageWith! - space / 2.0, bottom: 0, right: imageWith! + space / 2.0)
        }
        self.titleEdgeInsets = labelEdgeInset
        self.imageEdgeInsets = imageEdgeInset
    }
}

extension UIColor {
    open class var lightBlue: UIColor {
        return UIColor(hexString: "#23BAFF")!
    }

    open class var darkBlue: UIColor {
        return UIColor(hexString: "#3A8EFF")!
    }

    static func primary() -> UIColor {
        return themeService.type.associatedObject.primary
    }

    static func text() -> UIColor {
        return themeService.type.associatedObject.text
    }

    static func textGray() -> UIColor {
        return themeService.type.associatedObject.textGray
    }

    static func primaryDark() -> UIColor {
        return themeService.type.associatedObject.primaryDark
    }

    static func secondary() -> UIColor {
        return themeService.type.associatedObject.secondary
    }

    static func secondaryDark() -> UIColor {
        return themeService.type.associatedObject.secondaryDark
    }

    static func separator() -> UIColor {
        return themeService.type.associatedObject.separator
    }
}

// Chameleon support
extension UIColor {
    open class var flatBlue: UIColor {
        return UIColor.flatBlue()
    }

    open class var flatGreen: UIColor {
        return UIColor.flatGreen()
    }

    open class var flatBlack: UIColor {
        return UIColor.flatBlack()
    }

    open class var flatWhite: UIColor {
        return UIColor.flatWhite()
    }

    open class var flatGray: UIColor {
        return UIColor.flatGray()
    }

    open class var flatBlackDark: UIColor {
        return UIColor.flatBlackDark()
    }

    open class var flatRed: UIColor {
        return UIColor.flatRed()
    }

    open class var flatLime: UIColor {
        return UIColor.flatLime()
    }

    open class var flatPink: UIColor {
        return UIColor.flatPink()
    }

    open class var flatWhiteDark: UIColor {
        return UIColor.flatWhiteDark()
    }

    open class var flatPurple: UIColor {
        return UIColor.flatPurple()
    }

    open class var flatSkyBlue: UIColor {
        return UIColor.flatSkyBlue()
    }

    open class var flatMagenta: UIColor {
        return UIColor.flatMagenta()
    }

    open class var flatWatermelon: UIColor {
        return UIColor.flatWatermelon()
    }

//    open class var flatBlackDark: UIColor {
//           return UIColor.flatBlackDark()
//       }
}
