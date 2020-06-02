//
//  VideoPlayerVC.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/9.
//  Copyright © 2019 DKJone. All rights reserved.
//

import SuperPlayer
import UIKit

class VideoPlayerVC: ViewController {
    static let shared: VideoPlayerVC = {
        let vc = VideoPlayerVC()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()

    var urlStr = "" {
        didSet {
            isDownloaded = urlStr.contains(".mp4")
        }
    }

    let playerView = SuperPlayerView()
    let downloadBtn = UIButton()
    var isDownloaded = false {
        didSet {
            downloadBtn.isHidden = urlStr.starts(with: "http://127.0.0.1") || isDownloaded
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置代理，用于接受事件
        playerView.delegate = self
        // 设置父View，_playerView会被自动添加到下面
        playerView.fatherView = contentView
        view.backgroundColor = .black
        downloadBtn.setTitle("下载", for: [])
        downloadBtn.titleLabel?.font = .systemFont(ofSize: 14)
        downloadBtn.setTitleColor(.white, for: [])

        playerView.controlView.addSubview(downloadBtn)
        downloadBtn.snp.makeConstraints { make in
            make.right.top.equalTo(-safeAreaTopHeight)
            make.size.equalTo(CGSize(width: 80, height: 50))
        }
        downloadBtn.rx.tap.bind { [unowned self] in
            let defaultName = Date().string(withFormat: "yyyyMMddHHmmss")
            let alert = UIAlertController(title: "下载", message: "请输入下载名称", defaultActionButtonTitle: "取消", tintColor: nil)
            alert.addTextField { textfiled in
                textfiled.placeholder = "请输入下载名称"
                textfiled.text = defaultName
                textfiled.clearButtonMode = .always
            }
            alert.addAction(title: "确定", style: .default, isEnabled: true) { [unowned self] _ in
                DownLoadManage.shared.addDownload(fileName: alert.textFields?.first?.text ?? defaultName, path: self.playerView.playerModel.playingDefinitionUrl, autoStart: true)
                self.isDownloaded = true
            }
            self.present(alert, animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)
    }

    class func show() {
//        let vc = NavigationController(rootViewController: shared)
//        vc.navigationBar.isHidden = true
//        currentViewController()?.present(vc, animated: true, completion: nil)
        currentViewController()?.navigationController?.pushViewController(shared)
    }
}

extension VideoPlayerVC: SuperPlayerDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let playerModel = SuperPlayerModel()
        // 设置播放地址，直播、点播都可以
        playerModel.videoURL = urlStr
        let playurl = SuperPlayerUrl()
        playurl.title = "原始"
        playurl.url = urlStr
        playerModel.multiVideoURLs = [playurl]
        // 开始播放
        playerView.play(with: playerModel)
        playerView.playerConfig.hwAcceleration = false
        navigationController?.navigationBar.isHidden = true
        (keyWindow.rootViewController as? UISplitViewController)?.presentsWithGesture = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        (keyWindow.rootViewController as? UISplitViewController)?.presentsWithGesture = true
        playerView.resetPlayer()
    }

    func superPlayerBackAction(_ player: SuperPlayerView!) {
//        player.resetPlayer()
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController()
    }

    func superPlayerFullScreenChanged(_ player: SuperPlayerView!) {
        (player.controlView as? SPDefaultControlView)?.danmakuBtn.isHidden = true

        downloadBtn.snp.remakeConstraints { make in
            make.top.equalTo(0)
            make.right.equalTo(player.isFullScreen ? -100 : -15)
            make.size.equalTo(CGSize(width: 80, height: 50))
        }
    }
}
