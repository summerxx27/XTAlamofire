//
//  RequestTask.swift
//  Networking
//
//  Created by summerxx on 2020/5/26.
//

import Foundation
import Alamofire

/// 请求任务
@objc(XTNetworkRequestTask)
public class RequestTask: NSObject {
    
    private var request: Request
    
    init(_ request: Request) {
        self.request = request
    }
    
    /// 取消本次请求
    @objc
    public func cancel() {
        request.cancel()
    }
    
    /// 继续本次请求
    @objc
    public func resume() {
        request.resume()
    }
    
    /// 请求的 URL
    @objc
    public var requestingUrl: String? {
        guard let dataRequest = request as? DataRequest else {
            return nil
        }
        guard let url = dataRequest.convertible.urlRequest?.url else {
            return nil
        }
        return url.absoluteString
    }
    
    @objc
    public var isCancelled: Bool {
        request.isCancelled
    }
    
    /// 请求是否已结束
    @objc
    public var isFinished: Bool {
        request.isFinished
    }
    
    /// 响应状态码
    @objc
    public var responseStatusCode: Int {
        request.response?.statusCode ?? 0
    }
}
