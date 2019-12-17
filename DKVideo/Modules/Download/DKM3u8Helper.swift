//
//  DKM3u8Helper.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/11.
//  Copyright © 2019 DKJone. All rights reserved.
//

import Foundation
class DKM3u8Helper {
    fileprivate var url = ""
    fileprivate var success: ((URL) -> Void)?
    fileprivate var failed: ((M3u8ParaseError) -> Void)?
    var m3u8Data: String = ""
    var tsSegmentArray = [M3u8TsSegmentModel]()
    var tsPlaylist = M3u8Playlist()
    var identifier = ""
    func parser(url: String, name: String, success: ((URL) -> Void)?, failed: ((M3u8ParaseError) -> Void)?) {
        self.url = url
        self.success = success
        self.failed = failed
        self.identifier = name
        do {
            try self.parse(url: url)
        } catch {
            if let aError = error as? M3u8ParaseError {
                failed?(aError)
            } else {
                failed?(.Other)
            }
        }
    }

    fileprivate func parse(url: String) throws {
        self.url = url
        guard let m3u8Url = URL(string: url) else { throw M3u8ParaseError.URLInvalid }
        guard let m3u8Content = try? String(contentsOf: m3u8Url) else {
            throw M3u8ParaseError.EmptyM3u8Content
        }
//        if !(url.hasPrefix("http://") || url.hasPrefix("https://")) {
//            throw M3u8ParaseError.URLInvalid
//        }
        if m3u8Content == "" {
            throw M3u8ParaseError.EmptyM3u8Content
        } else if m3u8Content.contains("EXT-X-STREAM-INF") {
            let arr = m3u8Content.split(separator: "\n").map { String($0) }
            if let preIndex = arr.firstIndex(where: { $0.contains("#EXT-X-STREAM-INF") }) {
                if var newUrl = arr[safe: preIndex + 1] {
                    if !newUrl.hasPrefix("http") {
                        newUrl = url.replacingOccurrences(of: url.split(separator: "/").last ?? "", with: "") + newUrl
                        try self.parse(url: newUrl)
                    }
                }
            }
            throw M3u8ParaseError.NoSteamInfo
        } else {
            guard m3u8Content.range(of: "#EXTINF:") != nil else {
                throw M3u8ParaseError.NoEXTINFinfo
            }

            self.m3u8Data = m3u8Content
            if self.tsSegmentArray.count > 0 { self.tsSegmentArray.removeAll() }

            let segmentRange = m3u8Content.range(of: "#EXTINF:")!
            let segmentsString = String(m3u8Content.suffix(from: segmentRange.lowerBound)).components(separatedBy: "#EXT-X-ENDLIST")
            var segmentArray = segmentsString[0].components(separatedBy: "\n")
            segmentArray = segmentArray.filter { !$0.contains("#EXT-X-DISCONTINUITY") }

            while segmentArray.count > 2 {
                var segmentModel = M3u8TsSegmentModel()

                let segmentDurationPart = segmentArray[0].components(separatedBy: ":")[1]
                var segmentDuration: Float = 0.0

                if segmentDurationPart.contains(",") {
                    segmentDuration = Float(segmentDurationPart.components(separatedBy: ",")[0])!
                } else {
                    segmentDuration = Float(segmentDurationPart)!
                }

                var segmentURL = segmentArray[1]
                if !segmentURL.hasPrefix("http") {
                    segmentURL = url.replacingOccurrences(of: url.split(separator: "/").last ?? "", with: "") + segmentURL
                }
                segmentModel.duration = segmentDuration
                segmentModel.locationURL = segmentURL

                self.tsSegmentArray.append(segmentModel)

                segmentArray.remove(at: 0)
                segmentArray.remove(at: 0)
            }

            self.tsPlaylist.tsSegmentArray = self.tsSegmentArray
            self.tsPlaylist.identifier = self.identifier
            let allts = self.tsSegmentArray.map { "#EXTINF:\($0.duration),\n\($0.locationURL)" }.joined(separator: "\n")
            self.writeToLocalM3U8file(allts: allts)
        }
    }

    func writeToLocalM3U8file(allts: String) {
        self.checkOrCreatedM3u8Directory()

        let filePath = getDocumentsDirectory().appendingPathComponent("m3u8Files").appendingPathComponent("\(self.tsPlaylist.identifier).m3u8")

        var header = "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:15\n"
        header.append(allts)
        header.append("#EXT-X-ENDLIST\n")

        let writeData: Data = header.data(using: .utf8)!
        try! writeData.write(to: filePath)
        self.success?(filePath)
    }

    private func checkOrCreatedM3u8Directory() {
        let filePath = getDocumentsDirectory().appendingPathComponent("m3u8Files")

        if !FileManager.default.fileExists(atPath: filePath.path) {
            try! FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

enum M3u8ParaseError: String, Error {
    /// 非法的url路径
    case URLInvalid = "非法的url路径"
    /// m3u8文件内容获取失败
    case EmptyM3u8Content = "m3u8文件内容获取失败"
    /// 没有获取到对应码率的视频
    case NoSteamInfo = "没有获取到对应码率的视频"
    /// ts文件信息获取失败
    case NoEXTINFinfo = "ts文件信息获取失败"
    case Other = "解析失败,未知错误"
}

struct M3u8TsSegmentModel {
    var duration: Float = 0.0
    var locationURL = ""
    var index: Int = 0
}

class M3u8Playlist {
    var tsSegmentArray = [M3u8TsSegmentModel]()
    var length: Int { self.tsSegmentArray.count }
    var identifier = ""
}

public func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
