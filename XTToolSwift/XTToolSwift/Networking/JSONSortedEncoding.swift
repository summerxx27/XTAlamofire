//
//  JSONSortedEncoding.swift
//  Networking
//
//  Created by summerxx on 2020/7/13.
//

import Alamofire

/// 负责对请求参数的 JSON 编码，编码时对 JSON 按照 key 进行排序
@objc(XTJSONSortedEncoding)
public class JSONSortedEncoding: NSObject, ParameterEncoding {
    
    /// 单例对象
    static var `default` = JSONSortedEncoding()
    
    /// 编码方法
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters else { return urlRequest }
        
        let data = sortedJSONData(parameters: parameters)
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
    
    /// 返回 params 经过排序的 JSON 字符串
    @objc
    public class func sortedStringify(_ params: Any) -> String {
        var result = ""
        
        if #available(iOS 11.0, *) {
            guard let data = try? JSONSerialization.data(withJSONObject: params, options: [.sortedKeys]) else {
                return ""
            }
            result = String(data: data, encoding: .utf8) ?? ""
        }
        else {
            switch params {
            case let params as [String: Any]:
                result = JSONSortedEncoding.default.sortedStringify(dictionary: params)
            case let params as [Any]:
                result = JSONSortedEncoding.default.sortedStringify(array: params)
            default:
                assertionFailure()
            }
        }
        
        return result
    }
    
    func sortedJSONData(parameters: Any) -> Data? {
        if #available(iOS 11.0, *) {
            return try? JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])
        }
        else {
            var str: String?
            
            switch parameters {
            case let parameters as [String: Any]:
                str = sortedStringify(dictionary: parameters)
            case let parameters as [Any]:
                str = sortedStringify(array: parameters)
            default:
                assertionFailure()
            }
            
            return str?.data(using: .utf8)
        }
    }
    
    // MARK: -
    private func sortedStringify(array: [Any]) -> String {
        guard JSONSerialization.isValidJSONObject(array) else { return "[]" }
        
        if let array = array as? [[Any]] {
            // 数组套数组
            var result = [String]()
            for obj in array {
                result.append(sortedStringify(array: obj))
            }
            return "[\(result.joined(separator: ","))]"
        }
        else if let array = array as? [[String: Any]] {
            // 数组套字典
            var result = [String]()
            for obj in array {
                result.append(sortedStringify(dictionary: obj))
            }
            return "[\(result.joined(separator: ","))]"
        }
        else {
            var str: String?
            if let data = try? JSONSerialization.data(withJSONObject: array, options: []) {
                str = String(data: data, encoding: .utf8)
            }
            return str ?? "[]"
        }
    }
    
    private func sortedStringify(dictionary: [String: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(dictionary) else { return "{}" }
        
        var result = [String]()
        
        for (key, value) in (dictionary.sorted { $0.0 < $1.0 }) {
            if let value = value as? [String: Any] {
                result.append("\"\(key)\":\(sortedStringify(dictionary: value))")
            }
            else if let value = value as? [Any] {
                result.append("\"\(key)\":\(sortedStringify(array: value))")
            }
            else {
                var str = ""
                if let data = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]) {
                    str = String(data: data, encoding: .utf8) ?? ""
                }
                result.append("\"\(key)\":\(str)")
            }
        }
        
        return "{\(result.joined(separator: ","))}"
    }
}
