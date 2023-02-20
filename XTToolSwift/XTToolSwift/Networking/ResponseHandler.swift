//
//  ResponseHandler.swift
//  Networking
//
//  Created by summerxx on 2020/7/14.
//

import Alamofire
import Foundation

/// 处理接口响应
func performResponseHandler(withUrl url: String,
                            params: Any?,
                            response: AFDataResponse<Any>,
                            success: @escaping (Any) -> Void,
                            failure: @escaping (NetworkError) -> Void) {
    
    #if DEBUG
    performApiLogging(url, params: params, response: response)
    #endif
    
    switch response.result {
    case .success(var value):
        
        value = JSONObjectByRemovingKeysWithNullValues(value)
        
        success(value)
        
    case .failure(let error):
        
        failure(error)
    }
}

/// 从 JSON 对象中移除所有 NSNull
/// 作用同 - [AFJSONResponseSerializer removesKeysWithNullValues]
private func JSONObjectByRemovingKeysWithNullValues(_ JSONObject: Any) -> Any {
    switch JSONObject {
    case let JSONObject as [Any]:
        return JSONObject.map { JSONObjectByRemovingKeysWithNullValues($0) }
    case let JSONObject as [String: Any]:
        var mutableDictionary = JSONObject
        for (key, value) in JSONObject {
            switch value {
            case _ as NSNull:
                mutableDictionary.removeValue(forKey: key)
            default:
                mutableDictionary[key] = JSONObjectByRemovingKeysWithNullValues(value)
            }
        }
        return mutableDictionary
    default:
        return JSONObject
    }
}

#if DEBUG

/// 将 value 转换为 JSON 格式字符串
private func jsonFormatString(_ value: Any?) -> Any? {
    guard let value = value else {
        return nil
    }
    
    var options: JSONSerialization.WritingOptions = [.prettyPrinted]
    if #available(iOS 11.0, *) {
        options.formUnion(.sortedKeys)
    }
    
    var result = value
    
    if let data = try? JSONSerialization.data(withJSONObject: value, options: options),
       let json = String(data: data, encoding: .utf8) {
        result = json
    }
    
    if let str = result as? String {
        result = str.replacingOccurrences(of: "\\/", with: "/")
    }
    
    return result
}

private func logPrint(_ str: String) {
    print(str)
}

private func performApiLogging(_ url: String,
                               params: Any?,
                               response: AFDataResponse<Any>) {
    let metricsDescription = response.metrics.map {
        String(format: "%.3f ms", $0.taskInterval.duration * 1000)
    } ?? "None"
    
    var str = String(repeating: "-", count: 80) + "\n"
        + "Url = [\(url)]\n"
        + "Network duration = \(metricsDescription)\n"
        + "PostData = \(jsonFormatString(params) ?? "None")\n"
    
    switch response.result {
    case .success(var value):
        value = JSONObjectByRemovingKeysWithNullValues(value)
        str += "ReceiveData = \(jsonFormatString(value) ?? "None")\n"
    case .failure(let error):
        let responseBody = response.data.map { String(decoding: $0, as: UTF8.self) } ?? "None"
        str += "ReceiveData = \(responseBody)"
        if !str.hasSuffix("\n") {
            str += "\n"
        }
        if response.response?.statusCode != 200 {
            str += "Error = \(error)\n"
        }
    }
    
    logPrint(str)
}

/// 控制台输出上传日志
func performUploadLogging(_ data: Data, _ url: String, _ response: AFDataResponse<String>) {
    let metricsDescription = response.metrics.map {
        String(format: "%.3f ms", $0.taskInterval.duration * 1000)
    } ?? "None"
    
    var str = String(repeating: "-", count: 80) + "\n"
        + "Url = [\(url)]\n"
        + "Network duration = \(metricsDescription)\n"
        + "Upload size = \(data.count) bytes\n"
    
    switch response.result {
    case .success(let value):
        str += "ReceiveData = \(value)\n"
    case .failure(let error):
        str += "Error = \(error)\n"
    }
    logPrint(str)
}

/// 控制台输出下载日志
func performDownloadLogging(_ url: String, _ params: [String: Any]?, _ response: AFDownloadResponse<URL?>) {
    let metricsDescription = response.metrics.map {
        String(format: "%.3f ms", $0.taskInterval.duration * 1000)
    } ?? "None"

    var fileSize = 0
    if let path = response.fileURL?.path {
        let attr = try? FileManager.default.attributesOfItem(atPath: path)
        fileSize = attr?[.size] as? Int ?? 0
    }

    var str = String(repeating: "-", count: 80) + "\n"
        + "Url = [\(url)]\n"
        + "Network duration = \(metricsDescription)\n"

    str += "PostData = \(jsonFormatString(params) ?? "None")\n"

    switch response.result {
    case .success(let value):
        str += "Download to = \(value?.path ?? "None")\n"
        if fileSize > 1024 {
            str += "File size = \(fileSize) bytes\n"
        } else {
            if let fileURL = response.fileURL,
               let content = try? String(contentsOf: fileURL) {
                str += "File content = \(content)"
            }
        }
    case .failure(let error):
        str += "Error = \(error)\n"
    }
    logPrint(str)
}

#endif
