//
//  RuntimeExtension.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/4.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation

/*: Example
 if let method = extractMethodFrom(owner: classOrObject, selector:    NSSelectorFromString("methodName")) {
    method("Object")
 }
 */


/// 动态获取方法
/// - Parameters:
///   - owner: 对象或者类对象
///   - selector: 方法选择子
func extractMethodFrom(owner: AnyObject, selector: Selector) -> ((Any?) -> Any)? {
    let method: Method?
    if owner is AnyClass {
        method = class_getClassMethod(owner as? AnyClass, selector)
    } else {
        method = class_getInstanceMethod(type(of: owner), selector)
    }

    if let one = method {
        let implementation = method_getImplementation(one)

        typealias Function = @convention(c) (AnyObject, Selector, Any?) -> Void

        let function = unsafeBitCast(implementation, to: Function.self)

        return { userinfo in function(owner, selector, userinfo) }

    } else {
        return nil
    }
}
