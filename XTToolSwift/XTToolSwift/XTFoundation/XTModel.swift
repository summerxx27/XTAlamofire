//
//  XTModel.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation

/// 基础模型协议
public protocol XTModel: Codable {
    /// 完成解码的回调
    static func didDecode(model: Self?, from object: Any, error: Error?)
}

extension XTModel where Self: Any {
    /// 完成解码的回调
    public static func didDecode(model: Self?, from object: Any, error: Error?) {
        // do nothing by default
    }
}

/// 模型集合
extension Array: XTModel where Element: XTModel {
    /// 完成解码的回调
    public static func didDecode(model: Self?, from object: Any, error: Error?) {
        guard let models = model,
              let objects = object as? [[String: Any]],
              models.count == objects.count
        else {
            return
        }

        models.enumerated().forEach {
            Element.didDecode(model: $0.element, from: objects[$0.offset], error: error)
        }
    }
}

/// 解码：数组/字典 --> 模型
extension XTModel {
    /// 使用 JSON 对象进行解码
    public static func jsonDecode(_ jsonObject: Any?) -> Self? {
        guard let jsonObject = jsonObject else {
            return nil
        }
        var model: Self?
        do {
            model = try jsonDecode(by: JSONSerialization.data(withJSONObject: jsonObject, options: []))
            didDecode(model: model, from: jsonObject, error: nil)
        } catch {
            didDecode(model: nil, from: jsonObject, error: error)
        }
        return model
    }

    /// 使用 JSON Data 进行解码
    private static func jsonDecode(by data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

/// 编码：模型 --> 数组/字典
extension XTModel {
    /// 使用 JSON 编码后的对象
    public func jsonEncoded() -> Any? {
        try? JSONSerialization.jsonObject(with: jsonEncodedData(), options: [])
    }

    /// 获得 JSON 编码后的 Data
    private func jsonEncodedData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

extension XTModel {
    /// 深复制
    public func deepCopy() -> Self? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

