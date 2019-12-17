//
//  PopUpMenu.swift
//   
//
//  Created by 朱德坤 on 2019/8/21.
//  Copyright © 2019 DKJone. All rights reserved.
//


import UIKit

/// 箭头方向
///
/// - up: 朝上
/// - down: 朝下
public enum ArrowDirection {
    case up
    case down
}

/// 菜单配置项
public struct MenuOptions {
    public var tintColor = UIColor.white
    /// 文本颜色，默认为白色
    public var textColor = UIColor.white
    /// 文本字体，默认为14
    public var textFont = UIFont.systemFont(ofSize: 14)
    /// 文本对齐方式
    public var textAlignment = NSTextAlignment.natural
    /// 动画持续时长，默认为0.25
    public var animationDuration = 0.25
    /// 菜单宽度，默认为100
    public var menuWidth: CGFloat = 100
    /// 菜单间距，默认为8
    public var menuMargin: CGFloat = 8
    /// 菜单项高度，默认为40
    public var rowHeight: CGFloat = 40
    /// 箭头宽度，默认为8
    public var arrowWidth: CGFloat = 8
    /// 箭头高度，默认为12
    public var arrowHeight: CGFloat = 12
    /// 是否有选中状态
    public var isSelect = false
    /// 当前选中索引
    public var selectIndex = 0
}

/// 菜单项
public struct MenuItem {
    public let icon: String
    public let name: String

    public init(icon: String, name: String) {
        self.icon = icon
        self.name = name
    }
}

public class PopupMenuView: UIView {
    let menuItems: [MenuItem]
    let menuOptions: MenuOptions
    lazy var menuTableView = UITableView()
    let doneClosure: PopupMenuDoneClosure

    public init(menuItems: [MenuItem], options: MenuOptions, doneClosure: @escaping PopupMenuDoneClosure) {
        self.menuItems = menuItems
        self.menuOptions = options
        self.doneClosure = doneClosure
        super.init(frame: CGRect.zero)

        menuTableView.isScrollEnabled = false
        menuTableView.layer.cornerRadius = 4
        menuTableView.clipsToBounds = true
        menuTableView.backgroundColor = menuOptions.tintColor
        menuTableView.separatorInset = UIEdgeInsets(top: 0, left: menuOptions.menuMargin, bottom: 9, right: menuOptions.menuMargin)
        if menuOptions.isSelect{
            menuTableView.separatorStyle = .none
        }
        menuTableView.rowHeight = menuOptions.rowHeight
        menuTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5))
        menuTableView.dataSource = self
        menuTableView.delegate = self
        addSubview(menuTableView)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func adjustFrame(with arrowPoint: CGPoint, arrowDirection: ArrowDirection) {
        switch arrowDirection {
        case .up:
            menuTableView.frame = CGRect(x: 0, y: menuOptions.arrowHeight, width: frame.size.width, height: frame.size.height - menuOptions.arrowHeight)
        case .down:
            menuTableView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - menuOptions.arrowHeight)
        }

        drawArrow(at: arrowPoint, direction: arrowDirection)
    }

    // 绘制箭头
    func drawArrow(at position: CGPoint, direction: ArrowDirection) {
        let path = UIBezierPath()
        path.move(to: position)
        switch direction {
        case .up:
            path.addLine(to: CGPoint(x: position.x - menuOptions.arrowWidth, y: menuOptions.arrowHeight))
            path.addLine(to: CGPoint(x: position.x + menuOptions.arrowWidth, y: menuOptions.arrowHeight))
        case .down:
            path.move(to: position)
            path.addLine(to: CGPoint(x: position.x - menuOptions.arrowWidth, y: position.y - menuOptions.arrowHeight))
            path.addLine(to: CGPoint(x: position.x + menuOptions.arrowWidth, y: position.y - menuOptions.arrowHeight))
        }
        path.close()

        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = menuOptions.tintColor.cgColor
        backgroundLayer.strokeColor = menuOptions.tintColor.cgColor
        layer.insertSublayer(backgroundLayer, at: 0)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PopupMenuView: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        return menuItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = menuItems[indexPath.row]

        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        //        cell.selectionStyle = .none
        if menuOptions.isSelect && menuOptions.selectIndex == indexPath.row{
            cell.backgroundColor =  themeService.type.associatedObject.background
        }
        let iconView = UIImageView(image:UIImage(named: menuItem.icon))
        iconView.frame = CGRect(x: 8, y: 0, width: 30, height: 30)
        iconView.center.y = cell.contentView.center.y
        iconView.contentMode = .center
        cell.contentView.addSubview(iconView)

        iconView.isHidden = menuItem.icon.isEmpty

        let textLabelX: CGFloat = menuItem.icon.isEmpty ? 8 : 40

        let textLabel = UILabel()
        cell.contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(textLabelX)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        textLabel.text = menuItem.name
        textLabel.textColor = menuOptions.textColor
        textLabel.font = menuOptions.textFont
        textLabel.textAlignment = menuOptions.textAlignment
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        doneClosure(indexPath.row)
    }

}

public typealias PopupMenuDoneClosure = (Int) -> Void
public typealias PopupMenuDismissClosure = () -> Void

/// 弹出菜单
public class PopupMenu: NSObject {
    public static let shared = PopupMenu()

    var contentView: UIView!
    var menuView: PopupMenuView!

    var menuOptions: MenuOptions!
    var referenceView: UIView!
    var menuItems: [MenuItem]!
    var doneClosure: PopupMenuDoneClosure!
    var dismissClosure: PopupMenuDismissClosure?
    var selectedIndex = -1

    func initializeView(with options: MenuOptions = MenuOptions()) {
        menuOptions = options
        contentView = UIView(frame: keyWindow.bounds)
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        gestureRecognizer.delegate = self
        contentView.addGestureRecognizer(gestureRecognizer)

        menuView = PopupMenuView(menuItems: menuItems, options: options) { [unowned self] selectedIndex in
            self.selectedIndex = selectedIndex
            self.dismiss()
        }
        contentView.addSubview(menuView)

        adjustPosition()
    }

    @objc public func dismiss() {
        //        UIView.animate(withDuration: menuOptions.animationDuration,
        //                       animations: {
        //                           self.menuView.alpha = 0
        //                       },
        //                       completion: { _ in
        //                           if self.selectedIndex != -1 {
        //                               self.thenClosure(self.selectedIndex)
        //                           } else {
        //                               self.dismissClosure?()
        //                           }
        //
        //                           self.contentView.removeFromSuperview()
        //                           self.selectedIndex = -1
        //        })
        if selectedIndex != -1 {
            doneClosure(selectedIndex)
        } else {
            dismissClosure?()
        }

        contentView.removeFromSuperview()
        selectedIndex = -1
    }

    func adjustPosition() {
        let menuWidth = menuOptions.menuWidth
        let menuMargin = menuOptions.menuMargin
        let rowHeight = menuOptions.rowHeight
        let arrowWidth = menuOptions.arrowWidth
        let arrowHeight = menuOptions.arrowHeight

        let refRect = referenceView.superview!.convert(referenceView.frame, to: contentView)
        var menuHeight = rowHeight * CGFloat(menuItems.count) + arrowHeight
        let tableViewH = rowHeight * CGFloat(menuItems.count)
        menuHeight = screenHeight > menuHeight ? menuHeight : screenHeight - (refRect.minY + refRect.height + menuMargin)
        var arrowPoint = CGPoint(x: refRect.origin.x + refRect.size.width / 2, y: 0)

        var menuX: CGFloat
        var menuY: CGFloat
        var arrowDirection: ArrowDirection

        if arrowPoint.x + menuWidth / 2 + menuMargin > screenWidth { // 视图位于最左侧
            arrowPoint.x = min(arrowPoint.x - (screenWidth - menuWidth - menuMargin), arrowPoint.x)
            menuX = screenWidth - menuWidth - menuMargin
        } else if arrowPoint.x - menuWidth / 2 - menuMargin < 0 { // 视图位于最右侧
            arrowPoint.x = max(arrowWidth, arrowPoint.x - menuMargin)
            menuX = menuMargin
        } else { // 其他位置
            arrowPoint.x = menuWidth / 2
            menuX = refRect.origin.x + (refRect.size.width - menuWidth) / 2
        }

        if (refRect.origin.y + refRect.size.height + tableViewH) < screenHeight {

            menuView.menuTableView.isScrollEnabled = false

        } else { // 视图位于底部
            //            if arrowPoint.x + menuWidth / 2 + menuMargin > screenWidth { // 视图位于最左侧
            //                arrowPoint.x = min(arrowPoint.x - (screenWidth - menuWidth - menuMargin), arrowPoint.x)
            //                menuX = screenWidth - menuWidth - menuMargin
            //            } else if arrowPoint.x - menuWidth / 2 - menuMargin < 0 { // 视图位于最右侧
            //                arrowPoint.x = max(arrowWidth, arrowPoint.x - menuMargin)
            //                menuX = menuMargin
            //            } else { // 其他位置
            //                arrowPoint.x = menuWidth / 2
            //                menuX = refRect.origin.x + (refRect.size.width - menuWidth) / 2
            //            }
            //
            //            menuY = refRect.origin.y - menuHeight
            //            arrowPoint.y = menuHeight
            //            arrowDirection = .up
            menuView.menuTableView.isScrollEnabled = true
        }
        menuY = refRect.origin.y + refRect.size.height
        arrowPoint.y = 0
        arrowDirection = .up

        menuView.frame = CGRect(x: menuX, y: menuY, width: menuWidth, height: menuHeight)
        menuView.adjustFrame(with: arrowPoint, arrowDirection: arrowDirection)
    }

    public static func show(at view: UIView, withMenu items: [MenuItem], and options: MenuOptions?, done: @escaping PopupMenuDoneClosure, dismiss: PopupMenuDismissClosure? = nil) {
        let popupMenu = PopupMenu.shared
        popupMenu.referenceView = view
        popupMenu.menuItems = items
        popupMenu.doneClosure = done
        popupMenu.dismissClosure = dismiss
        popupMenu.initializeView(with: options ?? MenuOptions())
        keyWindow.addSubview(popupMenu.contentView)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PopupMenu: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return type(of: touch.view!) != NSClassFromString("UITableViewCellContentView")
    }
}
