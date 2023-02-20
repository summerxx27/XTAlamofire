//
//  NetworkInterceptor.swift
//  Networking
//
//  Created by summerxx on 2020/6/2.
//

import Alamofire

/// 网络拦截器
@objc(XTNetworkInterceptor)
open class NetworkInterceptor: NSObject {

    /// 拦截操作完毕的回调类型
    public typealias NetworkInterceptorCompletion = () -> Void

    /// 是否需要拦截本次请求
    open func shouldIntercept(_ urlRequest: URLRequest) -> Bool {
        false
    }

    /// 拦截操作
    open func intercepting(completion: @escaping NetworkInterceptorCompletion) {
        completion()
    }
}

/// 实现 Alamofire.RequestInterceptor 拦截器协议
extension NetworkInterceptor: RequestInterceptor {

    public func adapt(_ urlRequest: URLRequest,
                      for session: Session,
                      completion: @escaping (Result<URLRequest, Error>) -> Void) {

        guard shouldIntercept(urlRequest) else {
            completion(.success(urlRequest))
            return
        }

        intercepting {
            completion(.success(urlRequest))
        }
    }
}

extension NetworkInterceptor {
    /// 同步并发拦截的信号量
    @objc
    public static var semophore = DispatchSemaphore(value: 1)
}
