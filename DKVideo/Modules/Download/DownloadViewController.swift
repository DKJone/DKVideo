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
        let progressLabel = UILabel(fontSize: 12, textColor: .textGray(), text: "已下载：1.00%")
        let nameLabel = UILabel(fontSize: 14, text: "文件1")
        override func makeUI() {
            super.makeUI()
            containerView.snp.makeConstraints { make in
                make.height.equalTo(65).priority(.high)
            }
            containerView.addSubviews([stateBtn, playBtn, deleteBtn, progressLabel, nameLabel])
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
                make.right.equalTo(-80)
                make.top.equalTo(nameLabel.snp.bottom).offset(3)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            playBtn.setTitle("播放", for: [])
            deleteBtn.setTitle("删除", for: [])
            deleteBtn.snp.makeConstraints { make in
                make.right.equalTo(-10)
                make.top.equalTo(nameLabel.snp.bottom).offset(3)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            playBtn.borderWidth = 0.5
            deleteBtn.borderWidth = 0.5
            deleteBtn.borderColor = .red
            deleteBtn.setTitleColor(.red, for: [])
            themeService.rx
                .bind({ $0.secondary }, to: [playBtn.rx.titleColor(for: []), playBtn.rx.borderColor])
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
                UIViewController.currentViewController()?.showAlert(title: "确认删除", message: "将要删除下载内容", buttonTitles: ["重新下载", "删除内容"], highlightedButtonIndex: 0, completion: { index in
                    if index == 0 {
                        DownLoadManage.shared.deleteDownloadContent(fileName: info.fileName)
                        info.parse()
                    } else {
                        DownLoadManage.shared.deleteDownload(fileName: info.fileName)
                    }
                })

            }.disposed(by: disposeBag)
        }
    }
}
