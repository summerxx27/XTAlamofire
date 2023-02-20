//
//  ApiResponse.swift
//  Api
//
//  Created by summerxx on 2020/5/28.
//

import Foundation

/// API 响应
public struct ApiResponse<ResultType> {
    
    /// 返回的 code
    public var code: Int = -1
    
    /// 返回的描述
    public var msg: String?
    
    /// 返回的数据
    public var res: ResponseResType?
    
    /// 转换器处理后的模型数据
    public var result: ResultType? {
        _result
    }
    
    /// 初始化
    public init() {}
    
    internal var _result: ResultType?
}

extension ApiResponse {
    /// 请求是否成功
    public var isSuccess: Bool {
        code == 0
    }
}
