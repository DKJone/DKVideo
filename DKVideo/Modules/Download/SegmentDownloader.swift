import Foundation
import Tiercel
protocol SegmentDownloaderDelegate {
    func segmentDownloadSucceeded(with downloader: SegmentDownloader)
    func segmentDownloadFailed(with downloader: SegmentDownloader)
}

class SegmentDownloader: NSObject {
    var fileName: String
    var filePath: String
    var downloadURL: String
    var duration: Float
    var index: Int

    lazy var downloadSession: SessionManager = {
      appDelegate.sessionManagerBackground
    }()

    var downloadTask: DownloadTask?
    var isDownloading = false
    var finishedDownload = false

    var delegate: SegmentDownloaderDelegate?

    init(with url: String, filePath: String, fileName: String, duration: Float, index: Int) {
        downloadURL = url
        self.filePath = filePath
        self.fileName = fileName
        self.duration = duration
        self.index = index
    }

    func startDownload() {
        if checkIfIsDownloaded() {
            finishedDownload = true
            delegate?.segmentDownloadSucceeded(with: self)
        } else {
            let url = downloadURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let taskURL = URL(string: url) else { return }
            isDownloading = true
            downloadTask = downloadSession.download(taskURL, headers: nil, fileName: fileName)
            downloadTask?.success { [weak self] task in
                guard task.status == .succeeded else{return}
                guard let self = self else { return }
                let destinationURL = self.generateFilePath()

                self.finishedDownload = true
                self.isDownloading = false

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    return
                } else {
                    do {
                        let furl = URL(fileURLWithPath: task.filePath)
                        try FileManager.default.moveItem(at: furl, to: destinationURL)
                        self.delegate?.segmentDownloadSucceeded(with: self)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }.failure { [weak self] _ in
                guard let self = self else { return }
                self.finishedDownload = false
                self.isDownloading = false
                self.delegate?.segmentDownloadFailed(with: self)
            }
        }
    }

    func cancelDownload() {
        downloadSession.cancel(downloadURL)
        isDownloading = false
    }

    func pauseDownload() {
        downloadSession.suspend(downloadURL)
        isDownloading = false
    }

    func resumeDownload() {
        downloadSession.start(downloadURL)
        isDownloading = true
    }

    func checkIfIsDownloaded() -> Bool {
        let filePath = generateFilePath().path

        if FileManager.default.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }

    func generateFilePath() -> URL {
        return getDocumentsDirectory().appendingPathComponent("Downloads").appendingPathComponent(filePath).appendingPathComponent(fileName)
    }
}
