//
//  ApiClient.swift
//  Api
//
//  Created by summerxx on 2020/5/26.
//

import Foundation

// swiftlint:disable convenience_type

/// API 请求类
open class ApiClient<ResultType> where ResultType: Any {}

// swiftlint:enable convenience_type

extension ApiClient {
    /// 接口响应结果的闭包类型
    public typealias ApiResultType = (ApiResponse<ResultType>) -> Void

    /// 发起请求
    /// - Parameters:
    ///   - url: API 地址
    ///   - params: 请求参数
    ///   - resolver: 模型转换器
    ///   - result: 完成回调
    /// - Returns: 请求任务对象
    @discardableResult
    public static func request(_ url: String,
                               params: [String: Any]? = nil,
                               resolver: ResponseResolver?,
                               result: @escaping ApiResultType) -> RequestTask {

        let parameters = params ?? [:]

        let fullUrl = concatUrl(url)

        let headers = AppInfo.shared.baseHeaders()

        let success: (Any?) -> Void = {
            result(onSuccess($0, resolver: resolver))
        }

        let failure = {
            result(onError($0))
        }

        return NetworkCenter.get(fullUrl,
                                  params: parameters,
                                  headers: headers,
                                  interceptor: ApiInterceptor.shared,
                                  success: success,
                                  failure: failure)
    }

    /// 创建请求成功响应
    private static func onSuccess<ResultType: Any>(_ res: Any?,
                                                   resolver: ResponseResolver?) -> ApiResponse<ResultType> {
        var resp = ApiResponse<ResultType>()
        if let res = res as? Array<Any> {
            resp.code = 0
            resp.res = res
            if let resolver = resolver {
                resp._result = resolver(resp.res) as? ResultType
            }
            else {
                resp._result = resp.res as? ResultType
            }
        }
        else if let res = res as? [AnyHashable: Any] {
            resp.code = 0
            resp.res = res
            if let resolver = resolver {
                resp._result = resolver(resp.res) as? ResultType
            }
            else {
                resp._result = resp.res as? ResultType
            }
        }
        else {
            resp.code = -1
            resp.msg = "数据格式错误"
        }

        handleGlobalErrors(withResp: resp)

        return resp
    }

    /// 创建请求失败响应
    private static func onError<ResultType: Any>(_ error: NetworkError) -> ApiResponse<ResultType> {
        var resp = ApiResponse<ResultType>()
        resp.code = error.responseCode ?? -1
        resp.msg = error.localizedDescription
        return resp
    }

    /// 拼接完整的 API 地址
    private static func concatUrl(_ url: String) -> String {
        return AppInfo.shared.baseUrl.appending(url)
    }

    /// 处理全局的错误代码
    private static func handleGlobalErrors<ResultType: Any>(withResp resp: ApiResponse<ResultType>) {
        if resp.code == -404 {
            print("Not Found")
        }
    }
}

extension ApiClient where ResultType: ApiResponseResolvable {

    /// 发起请求
    /// - Parameters:
    ///   - url: API 地址
    ///   - params: 请求参数
    ///   - result: 完成回调
    /// - Returns: 请求任务对象
    @discardableResult
    public static func request(_ url: String,
                               params: [String: Any]? = nil,
                               result: @escaping ApiResultType) -> RequestTask {

        request(url, params: params, resolver: ResultType.responseResolver, result: result)
    }
}

extension ApiClient where ResultType: XTModel {

    /// 发起请求
    /// - Parameters:
    ///   - url: API 地址
    ///   - params: 请求参数
    ///   - result: 完成回调
    /// - Returns: 请求任务对象
    @discardableResult
    public static func request(_ url: String,
                               params: [String: Any]? = nil,
                               result: @escaping ApiResultType) -> RequestTask {

        request(url, params: params, resolver: ResultType.responseResolver, result: result)
    }
}
