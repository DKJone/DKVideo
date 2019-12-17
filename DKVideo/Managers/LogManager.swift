//
//  LogManager.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/3/20.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
import RxSwift

public func logDebug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    let text = "\n[\(Date()) Debug] \(file.lastPathComponent.deletingPathExtension).\(function.replacingOccurrences(of: "()", with: "")):\(line)" + message()
    #if DEBUG
    print(text)
    #else
    //Log.debug(text)
    #endif
}

public func logError(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    let text = "\n[\(Date()) Error] \(file.lastPathComponent.deletingPathExtension).\(function.replacingOccurrences(of: "()", with: "")):\(line)" + message()
    #if DEBUG
    print(text)
    #else
    //Log.error(text)
    #endif
}

public func logInfo(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    let text = "\n[\(Date()) Info] \(file.lastPathComponent.deletingPathExtension).\(function.replacingOccurrences(of: "()", with: "")):\(line)" + message()
    #if DEBUG
    print(text)
    #else
   // Log.info(text)
    #endif
}

public func logVerbose(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    let text = "\n[\(Date()) Verbose] \(file.lastPathComponent.deletingPathExtension).\(function.replacingOccurrences(of: "()", with: "")):\(line)" + message()
    #if DEBUG
    print(text)
    #else
    //Log.verbose(text)
    #endif
}

public func logWarn(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    let text = "\n[\(Date()) Warn] \(file.lastPathComponent.deletingPathExtension).\(function.replacingOccurrences(of: "()", with: "")):\(line)" + message()
    #if DEBUG
    print(text)
    #else
   // Log.warning(text)
    #endif
}

public func logResourcesCount() {
    #if DEBUG
    logDebug("RxSwift resources count: \(RxSwift.Resources.total)")
    #endif
}
