//
//  DownloadViewController.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/6.
//  Copyright © 2019 DKJone. All rights reserved.
//

import RxCocoa
import RxSwift
import SuperPlayer
import UIKit
class DownloadViewController: TableViewController {
    override func makeUI() {
        super.makeUI()
        navigationTitle = "下载"
    }

    override func bindViewModel() {
        tableView.footRefreshControl = nil
        tableView.headRefreshControl = nil
        tableView.register(cellWithClass: DownlaodCell.self)
        DownLoadManage.shared.downloads.asDriver().drive(tableView.rx.items(cellIdentifier: DownlaodCell.identifier, cellType: DownlaodCell.self)) { _, element, cell in
            cell.setup(info: element)
        }.disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(M3U8Downloader.self).bind { [unowned self] info in
            self.loca(info: info)
        }.disposed(by: rx.disposeBag)
    }

    func loca(info: M3U8Downloader) {
        print(info.downloadStatus.value)
    }

    class DownlaodCell: TableViewCell {
        let stateBtn = UIButton(type: .custom)
        let playBtn = UIButton(type: .custom)
        let deleteBtn = UIButton(type: .custom)
        let shareBtn = UIButton(type: .custom)
        let progressLabel = UILabel(fontSize: 12, textColor: .textGray(), text: "已下载：1.00%")
        let nameLabel = UILabel(fontSize: 14, text: "文件1")
        override func makeUI() {
            super.makeUI()
            containerView.snp.makeConstraints { make in
                make.height.equalTo(65).priority(.high)
            }
            containerView.addSubviews([stateBtn, playBtn, deleteBtn, shareBtn, progressLabel, nameLabel])
            stateBtn.snp.makeConstraints { make in
                make.left.top.equalTo(10)
                make.width.height.equalTo(45)
            }
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.left.equalTo(stateBtn.snp.right).offset(15)
                make.right.equalToSuperview()
            }
            progressLabel.snp.makeConstraints { make in
                make.left.equalTo(nameLabel)
                make.top.equalTo(nameLabel.snp.bottom).offset(10)
            }
            playBtn.snp.makeConstraints { make in
                make.right.equalTo(-150)
                make.top.equalTo(nameLabel.snp.bottom).offset(3)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            shareBtn.snp.makeConstraints { make in
                make.right.equalTo(-80)
                make.top.equalTo(nameLabel.snp.bottom).offset(3)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            shareBtn.setTitle("分享", for: [])
            playBtn.setTitle("播放", for: [])
            deleteBtn.setTitle("删除", for: [])
            deleteBtn.snp.makeConstraints { make in
                make.right.equalTo(-10)
                make.top.equalTo(nameLabel.snp.bottom).offset(3)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            playBtn.borderWidth = 0.5
            shareBtn.borderWidth = 0.5
            deleteBtn.borderWidth = 0.5
            deleteBtn.borderColor = .red
            deleteBtn.setTitleColor(.red, for: [])
            themeService.rx
                .bind({ $0.secondary }, to: [playBtn.rx.titleColor(for: []), playBtn.rx.borderColor,
                                             shareBtn.rx.titleColor(for: []), shareBtn.rx.borderColor])
                .bind({ $0.secondaryDark }, to: stateBtn.rx.titleColor(for: []))
                .bind({ $0.primary }, to: containerView.rx.backgroundColor)
                .disposed(by: rx.disposeBag)
            stateBtn.titleLabel?.font = .systemFont(ofSize: 9)
        }

        func setup(info: M3U8Downloader) {
            info.downloadStatus.map { $0.description }.bind(to: stateBtn.rx.title(for: [])).disposed(by: disposeBag)
            nameLabel.text = info.directoryName
            info.progress.map { "已下载\(Int($0 * 100))%" }.bind(to: progressLabel.rx.text).disposed(by: disposeBag)
            playBtn.rx.tap.bind { _ in
                if let playPath = info.getPlayPath() {
                    VideoPlayerVC.shared.urlStr = playPath
                    VideoPlayerVC.show()
                }
            }.disposed(by: disposeBag)
            stateBtn.rx.tap.bind { _ in
                if info.downloadStatus.value == .started {
                    info.downloader.cancelDownloadSegment()
                } else {
                    info.downloader.startDownload()
                }
            }.disposed(by: disposeBag)
            deleteBtn.rx.tap.bind { _ in
                UIViewController.currentViewController()?.showAlert(title: "确认删除", message: "将要删除下载内容", buttonTitles: ["重新下载", "删除内容", "取消"], highlightedButtonIndex: 0, completion: { index in
                    if index == 0 {
                        DownLoadManage.shared.deleteDownloadContent(fileName: info.fileName) {
                            info.parse()
                        }
                    } else if index == 1 {
                        DownLoadManage.shared.deleteDownload(fileName: info.fileName)
                    }
                })
            }.disposed(by: disposeBag)
            shareBtn.rx.tap.bind { _ in
                var playPath = info.getPlayPath()
                UIViewController.currentViewController()?.showAlert(title: "重要提示", message: "已复制播放地址，您可以发送给局域网(同一WIFI下)的好友，她可以直接播放无需下载，如果您正在使用移动热点，分享及播放不会消耗流量。同一时间您只能分享一集(好友收看期间您可以收看同一集，播放其他视频，好友可能无法继续观看)", buttonTitles: ["确定"], highlightedButtonIndex: 0, completion: { _ in
                    if let ip = VideoPlayServer.currentServer?.serverURL?.absoluteString {
                        playPath = playPath?.replacingOccurrences(of: "http://127.0.0.1:8080/", with: ip)
                    }
                    UIPasteboard.general.string = playPath
                    let url = getDocumentsDirectory()
                        .appendingPathComponent("Downloads")
                        .appendingPathComponent(info.fileName)
                        .appendingPathComponent(info.fileName + ".m3u8")
                    self.shareM3u8(fileUrl: url) // URL(string: playPath!)

                })

            }.disposed(by: disposeBag)
        }

        func shareM3u8(fileUrl: URL?) {
            guard let fileUrl = fileUrl else { return }
            let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.contentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIViewController.currentViewController()!.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
