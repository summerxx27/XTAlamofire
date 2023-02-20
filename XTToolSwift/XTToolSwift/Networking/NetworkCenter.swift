//
//  NetworkCenter.swift
//  Networking
//
//  Created by summerxx on 2020/5/26.
//

import Alamofire

/// 网络中心
/// 提供了最基础的 HTTP 网络请求、文件上传/下载等方法
@objc(XTNetworkCenter)
open class NetworkCenter: NSObject {

    /// 单例对象
    @objc
    public static var center = NetworkCenter()

    /// 使用 path 生成 Alamofire 的 Destination 对象
    private static func destination(for path: String?) -> DownloadRequest.Destination? {
        guard let path = path else { return nil }
        return { _, _ in
            (URL(fileURLWithPath: path), [.removePreviousFile, .createIntermediateDirectories])
        }
    }
}

// MARK: - POST
extension NetworkCenter {
    /// POST 一个请求
    /// - Parameters:
    ///   - url: 请求 URL
    ///   - params: 请求参数
    ///   - headers: HTTP Header
    ///   - interceptor: 拦截器
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 请求任务对象
    @discardableResult
    public static func post(
        _ url: String,
        params: [String: Any]?,
        headers: [String: String] = [:],
        interceptor: NetworkInterceptor? = nil,
        success: @escaping (Any) -> Void,
        failure: @escaping (NetworkError) -> Void
    ) -> RequestTask {

        RequestTask(
            AF.request(url,
                       method: .post,
                       parameters: params,
                       encoding: JSONSortedEncoding.default,
                       headers: HTTPHeaders(headers),
                       interceptor: interceptor)
                .responseJSON { response in
                    performResponseHandler(withUrl: url,
                                           params: params,
                                           response: response,
                                           success: success,
                                           failure: failure)
                }


        )
    }
}

extension NetworkCenter {
    /// GET 一个请求
    /// - Parameters:
    ///   - url: 请求 URL
    ///   - params: 请求参数
    ///   - headers: HTTP Header
    ///   - interceptor: 拦截器
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 请求任务对象
    @discardableResult
    public static func get(
        _ url: String,
        params: [String: Any]?,
        headers: [String: String] = [:],
        interceptor: NetworkInterceptor? = nil,
        success: @escaping (Any) -> Void,
        failure: @escaping (NetworkError) -> Void
    ) -> RequestTask {
        RequestTask(
            AF.request(url,
                       method: .get,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: HTTPHeaders(headers),
                       interceptor: interceptor,
                       requestModifier: nil)
                .responseJSON { response in
                    performResponseHandler(withUrl: url,
                                           params: params,
                                           response: response,
                                           success: success,
                                           failure: failure)
                }
        )
    }
}

// MARK: - 上传
extension NetworkCenter {
    /// 上传数据
    /// - Parameters:
    ///   - data: 需要上传的 Data
    ///   - url: 上传目的地 URL
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 上传任务对象
    @objc
    @discardableResult
    public static func upload(
        _ data: Data,
        to url: String,
        progress: ((Progress) -> Void)? = nil,
        success: ((String) -> Void)?,
        failure: ((Error) -> Void)?
    ) -> RequestTask {

        var req = AF.upload(data, to: url)

        if let progress = progress {
            req = req.uploadProgress { p in
                progress(p)
            }
        }

        req = req.responseString { response in
            #if DEBUG
            performUploadLogging(data, url, response)
            #endif
            switch response.result {
            case .success(let value):
                success?(value)
            case .failure(let error):
                failure?(error)
            }
        }

        return RequestTask(req)
    }
}

// MARK: - 下载
extension NetworkCenter {
    /// 下载数据
    /// - Parameters:
    ///   - url: 下载的 URL
    ///   - path: 下载到本地目的路径
    ///   - progress: 下载进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 下载任务对象
    @objc
    @discardableResult
    public class func download(
        _ url: String,
        to path: String?,
        progress: ((Progress) -> Void)? = nil,
        success: ((URL?) -> Void)?,
        failure: ((Error) -> Void)?
    ) -> RequestTask {

        var req = AF.download(url, to: destination(for: path))

        if let progress = progress {
            req = req.downloadProgress { p in
                progress(p)
            }
        }

        req = req.response { response in
            #if DEBUG
            performDownloadLogging(url, nil, response)
            #endif
            switch response.result {
            case .success(let value):
                success?(value)
            case .failure(let error):
                failure?(error)
            }
        }

        return RequestTask(req)
    }

    /// 使用 POST 形式发起下载请求
    /// - Parameters:
    ///   - url: 下载的 URL
    ///   - path: 下载到本地目的路径
    ///   - parameters: POST 请求参数
    ///   - progress: 下载进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 下载任务对象
    @discardableResult
    public static func downloadByPOST(
        _ url: String,
        to path: String?,
        parameters: [String: Any]?,
        progress: ((Progress) -> Void)? = nil,
        success: ((URL?) -> Void)?,
        failure: ((Error) -> Void)?
    ) -> RequestTask {

        var req = AF.download(url,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONSortedEncoding.default,
                              to: destination(for: path))
            .response { response in
                #if DEBUG
                performDownloadLogging(url, parameters, response)
                #endif
                switch response.result {
                case .success(let value):
                    success?(value)
                case .failure(let error):
                    failure?(error)
                }
            }

        if let progress = progress {
            req = req.downloadProgress { p in
                progress(p)
            }
        }

        return RequestTask(req)
    }
}
