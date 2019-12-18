//
//  DownLoadManage.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/16.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxRelay
import UIKit
class DownLoadManage {
    let downloads: BehaviorRelay<[M3U8Downloader]> = .init(value: [])
    static let shared = DownLoadManage()

    init() {
        let m3u8Dir = getDocumentsDirectory().appendingPathComponent("m3u8Files")
        if let enums = FileManager.default.enumerator(atPath: m3u8Dir.path) {
            enums.forEach { path in
                if let fileName = path as? String {
                    if fileName.hasSuffix(".m3u8") {
                        addDownload(fileName: fileName.replacingOccurrences(of: ".m3u8", with: ""),
                                    path: m3u8Dir.appendingPathComponent(fileName).absoluteString,
                                    autoStart: UserDefaults.autoStartDownload)
                    }
                }
            }
        }
    }

    func addDownload(fileName: String, path: String, autoStart: Bool = false) {
        let newDownload = M3U8Downloader(fileName: fileName, m3u8URL: path)
        if (downloads.value.map { $0.directoryName }.contains(fileName)) {
            UIViewController.currentViewController()?.showAlert(title: "提示", message: "下载任务已存在", buttonTitles: ["继续下载", "重新下载"], highlightedButtonIndex: 0, completion: { [unowned self] index in
                if index == 1 {
                    self.deleteDownload(fileName: fileName)
                    newDownload.downloadStatus.filter { $0 == .started }.take(1).bind { [unowned self] _ in
                        self.downloads.accept(self.downloads.value.filter { $0.directoryName != fileName } + [newDownload])
                    }
                    newDownload.parse()

                } else {
                    self.downloads.value.first(where: { $0.directoryName == fileName })?.parse()
                }
            })
        } else {
            newDownload.downloadStatus.filter { $0 == .started }.take(1).bind { [unowned self] _ in
                self.downloads.accept(self.downloads.value.filter { $0.directoryName != fileName } + [newDownload])
            }
            newDownload.parse()
            if !autoStart {
                newDownload.downloader.cancelDownloadSegment()
            }
        }
    }

    func deleteDownload(fileName: String) {
        let filePath = getDocumentsDirectory()
            .appendingPathComponent("m3u8Files")
            .appendingPathComponent(fileName + ".m3u8")
            .path

        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }

        deleteDownloadContent(fileName: fileName)
        downloads.accept(downloads.value.filter { $0.fileName != fileName })
    }

    func deleteDownloadContent(fileName: String) {
        let filePath = getDocumentsDirectory()
            .appendingPathComponent("Downloads")
            .appendingPathComponent(fileName.replacingOccurrences(of: ".m3u8", with: ""))
            .path

        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
    }
}
