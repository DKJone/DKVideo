

import Foundation
import RxRelay
public enum Status: CustomStringConvertible {
    case started
    case paused
    case canceled
    case finished
    case failed

    public var description: String {
        switch self {
        case .started: return "下载中"
        case .paused: return "已暂停"
        case .canceled: return "已取消"
        case .finished: return "下载完成"
        case .failed: return "已停止"
        }
    }
}

open class VideoDownloader {
    public var downloadStatus: BehaviorRelay<Status> = .init(value: .paused)
    public var progress: BehaviorRelay<Float> = .init(value: 0)

    var m3u8Data: String = ""
    var tsPlaylist = M3u8Playlist()
    var segmentDownloaders = [SegmentDownloader]()
//    {
//        willSet{
//            segmentDownloaders.forEach{ $0.cancelDownload()}
//        }
//    }
    var tsFilesIndex = 0
    var neededDownloadTsFilesCount = 0
    var downloadURLs = [String]()
    var downloadingProgress: Float {
        let finishedDownloadFilesCount = segmentDownloaders.filter { $0.finishedDownload == true }.count
        let fraction = Float(finishedDownloadFilesCount) / Float(neededDownloadTsFilesCount)
        let roundedValue = round(fraction * 100) / 100
        return roundedValue
    }

    fileprivate var startDownloadIndex = 2

    open func startDownload() {
        checkOrCreatedM3u8Directory()

        var newSegmentArray = [M3u8TsSegmentModel]()

        let notInDownloadList = tsPlaylist.tsSegmentArray.filter { !downloadURLs.contains($0.locationURL) }
        neededDownloadTsFilesCount = tsPlaylist.length

        for i in 0 ..< notInDownloadList.count {
            let fileName = "\(tsFilesIndex).ts"

            let segmentDownloader = SegmentDownloader(with: notInDownloadList[i].locationURL,
                                                      filePath: tsPlaylist.identifier,
                                                      fileName: fileName,
                                                      duration: notInDownloadList[i].duration,
                                                      index: tsFilesIndex)
            segmentDownloader.delegate = self

            segmentDownloaders.append(segmentDownloader)
            downloadURLs.append(notInDownloadList[i].locationURL)

            var segmentModel = M3u8TsSegmentModel()
            segmentModel.duration = segmentDownloaders[i].duration
            segmentModel.locationURL = segmentDownloaders[i].fileName
            segmentModel.index = segmentDownloaders[i].index
            newSegmentArray.append(segmentModel)

            tsPlaylist.tsSegmentArray = newSegmentArray

            tsFilesIndex += 1
        }

        segmentDownloaders[0].startDownload()
        segmentDownloaders[1].startDownload()
        segmentDownloaders[2].startDownload()

        downloadStatus.accept(.started)
    }

    func checkDownloadQueue() {}

    func updateLocalM3U8file() {
        checkOrCreatedM3u8Directory()

        let filePath = getDocumentsDirectory().appendingPathComponent("Downloads").appendingPathComponent(tsPlaylist.identifier).appendingPathComponent("\(tsPlaylist.identifier).m3u8")

        var header = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:15\n"
        var content = ""

        for i in 0 ..< tsPlaylist.tsSegmentArray.count {
            let segmentModel = tsPlaylist.tsSegmentArray[i]

            let length = "#EXTINF:\(segmentModel.duration),\n"
            let fileName = "http://127.0.0.1:8080/\(segmentModel.index).ts\n"
            content += (length + fileName)
        }

        header.append(content)
        header.append("#EXT-X-ENDLIST\n")

        let writeData: Data = header.data(using: .utf8)!
        if !FileManager.default.fileExists(atPath: filePath.path) {
            try! writeData.write(to: filePath)
        }
    }

    private func checkOrCreatedM3u8Directory() {
        let filePath = getDocumentsDirectory()
            .appendingPathComponent("Downloads")
            .appendingPathComponent(tsPlaylist.identifier)

        if !FileManager.default.fileExists(atPath: filePath.path) {
            try! FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    open func pauseDownloadSegment() {
        segmentDownloaders.forEach { $0.pauseDownload() }
        downloadStatus.accept(.paused)
    }

    open func cancelDownloadSegment() {
        segmentDownloaders.forEach { $0.cancelDownload() }
        downloadStatus.accept(.canceled)
    }

    open func resumeDownloadSegment() {
        segmentDownloaders.forEach { $0.resumeDownload() }
        downloadStatus.accept(.started)
    }
}

extension VideoDownloader: SegmentDownloaderDelegate {
    func segmentDownloadSucceeded(with downloader: SegmentDownloader) {
        let finishedDownloadFilesCount = segmentDownloaders.filter { $0.finishedDownload == true }.count
        progress.accept(downloadingProgress)
        updateLocalM3U8file()

        let downloadingFilesCount = segmentDownloaders.filter { $0.isDownloading == true }.count

        if finishedDownloadFilesCount == neededDownloadTsFilesCount {
            downloadStatus.accept(.finished)
        } else if startDownloadIndex == neededDownloadTsFilesCount - 1 {
            if segmentDownloaders[startDownloadIndex].isDownloading == true { return }
        } else if downloadingFilesCount < 3 || finishedDownloadFilesCount != neededDownloadTsFilesCount {
            if startDownloadIndex < neededDownloadTsFilesCount - 1 {
                startDownloadIndex += 1
            }
            segmentDownloaders[startDownloadIndex].startDownload()
        }
    }

    func segmentDownloadFailed(with downloader: SegmentDownloader) {
        downloadStatus.accept(.failed)
    }
}
