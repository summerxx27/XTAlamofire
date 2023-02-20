//
//  ApiResolver.swift
//  Api
//
//  Created by summerxx on 2020/5/28.
//

import Foundation

/// 响应可以被转换的协议
public protocol ApiResponseResolvable {
    /// 获取模型转换器
    static var responseResolver: ResponseResolver { get }
}

extension ApiResponseResolvable {
    /// 默认实现
    public static var responseResolver: ResponseResolver {
        // 不做转换，返回原始数据
        { $0 }
    }
}

extension Bool: ApiResponseResolvable {}
extension Int: ApiResponseResolvable {}
extension Double: ApiResponseResolvable {}
extension String: ApiResponseResolvable {}

private func GetRes(res: ResponseResType?, keyPath: String?) -> ResponseResType? {
    guard let keyPath = keyPath,
          let resObj = res as? NSObject else {
        return res
    }
    return resObj.value(forKeyPath: keyPath)
}

/// 直接将 keyPath 对应的数据返回
/// 假设 res: {"foo": {"bar": 123}}
/// 经过 pluck(@"foo.bar") 处理后，返回的结果是 123 的 NSNumber
/// 转换失败会返回 nil
public func ResolvePluck(_ keyPath: String) -> ResponseResolver {
    { GetRes(res: $0, keyPath: keyPath) }
}

extension XTModel {
    /// 从 keyPath 中获取数据并转为当前模型数据
    public static func responseResolver(_ keyPath: String?) -> (ResponseResType?) -> Self? {
        {
            var value: Self?
            if let res = GetRes(res: $0, keyPath: keyPath), JSONSerialization.isValidJSONObject(res) {
                if let resData = try? JSONSerialization.data(withJSONObject: res, options: []) {
                    value = try? JSONDecoder().decode(Self.self, from: resData)
                }
            }
            return value
        }
    }

    /// 将字典数据转为模型
    public static var responseResolver: (ResponseResType?) -> Self? {
        responseResolver(nil)
    }
}
