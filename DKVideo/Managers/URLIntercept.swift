//
//  URLIntercept.swift
//  DKVideo
//
//  Created by 朱德坤 on 2019/12/4.
//  Copyright © 2019 DKJone. All rights reserved.
//

import SuperPlayer
import SwifterSwift
import RxRelay
let URLInterceptKey = "Intercepted"
/// 网络请求拦截器
class URLIntercept: URLProtocol {
    static let videoUrl = BehaviorRelay<String>(value: "")
    var newTask: URLSessionTask?
    /// 返回是否监控此条网络请求
    /// - Parameter request: 网络请求
    override class func canInit(with request: URLRequest) -> Bool {
        print("--caninit--" + (request.url?.absoluteString ?? ""))
        // 如果是已经拦截过的就放行，避免出现死循环
        if URLProtocol.property(forKey: URLInterceptKey, in: request) as? Bool ?? false {
            return false
        }
        if request.allHTTPHeaderFields.isNilOrEmpty {
            print("##########\(request.description)")
            return false
        }
        // 不是网络请求，不处理
        if let urlScheme = request.url?.scheme?.lowercased() {
            if ["http", "https", "ftp"].contains(urlScheme) {
                return true
            }
        }

        // 不拦截其他
        return false
    }

    /// 设置我们自己的自定义请求
    /// - Parameter request: 当前的网络请求
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var mutableReqeust: URLRequest = request
        guard let urlStr = request.url?.absoluteString else { return request }
        // 视频播放拦截
        print("+++++++++++++" + urlStr.pathExtension)
        if urlStr.pathExtension.hasPrefix("m3u8") && !urlStr.contains("jx.688ing"){
//            mutableReqeust.url = nil
            print("=========video=======\(urlStr)")
            videoUrl.accept(urlStr)
//            DispatchQueue.main.async {
//                let vc = VideoPlayerVC.shared
//                if !vc.isVisible {
//                    vc.urlStr = urlStr
//                    VideoPlayerVC.show()
//                }
//            }
        }
        return mutableReqeust
    }

    override func startLoading() {
        // 给我们处理过的请求设置一个标识符, 防止无限循环,
        var request = self.request
        URLProtocol.setProperty(true, forKey: URLInterceptKey, in: request as! NSMutableURLRequest)

        // 广告拦截标识字符
        var isAD = false
        adString.forEach { str in
            if (request.url?.absoluteString ?? "").contains(str) { isAD = true; return }
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        if UserDefaults.isPCAgent {
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        } else {
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        }
        if isAD {} else {
            self.newTask = session.dataTask(with: request)
            print("====REQUEST:====\(request.url?.absoluteString ?? "")")
            self.newTask?.resume()
        }
    }

    override func stopLoading() {
        self.newTask?.cancel()
    }
}

extension URLIntercept: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
