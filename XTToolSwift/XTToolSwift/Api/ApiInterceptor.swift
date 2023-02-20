//
//  ApiInterceptor.swift
//  Api
//
//  Created by summerxx on 2020/6/2.
//

import Foundation

/// API 拦截器
public class ApiInterceptor: NetworkInterceptor {

    public static var shared = ApiInterceptor()
    
    public var exceptPathes: [String]?
    
    public var interceptingHandler: ((@escaping NetworkInterceptorCompletion) -> Void)?
    
    /// 对 exceptPaths 之外的所有 API 请求进行拦截
    public override func shouldIntercept(_ urlRequest: URLRequest) -> Bool {
        
        guard let excepts = exceptPathes,
            let path = urlRequest.url?.absoluteString else {
            return super.shouldIntercept(urlRequest)
        }
        
        return !excepts.contains { path.contains($0) }
    }
    
    public override func intercepting(completion: @escaping () -> Void) {
        
        guard let interceptingHandler = interceptingHandler else {
            super.intercepting(completion: completion)
            return
        }

        _ = NetworkInterceptor.semophore.wait(timeout: .distantFuture)

        interceptingHandler {
            NetworkInterceptor.semophore.signal()
            completion()
        }
    }
}
