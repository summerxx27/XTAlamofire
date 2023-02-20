//
//  JDNetwork.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation
import Alamofire

open class JDNetwork: NSObject {

}

extension JDNetwork {

    /// 简单的 get 请求
    /// - Parameters:
    ///   - url: 网址
    ///   - params: 参数
    ///   - type: 如果结果是 dict 直接用Model.self, 如果是 array 使用 [Model].self
    ///   - success: 成功
    ///   - failure: 失败
    public static func get<T: Decodable>(
        _ url: String,
        params: [String: Any]?,
        of type: T.Type = T.self,
        success: @escaping (T) -> Void,
        failure: @escaping (NetworkError) -> Void
    ) {

        AF.request(url, method: .get, headers: HTTPHeaders(AppInfo.shared.baseHeaders())).responseDecodable(of: type) { response in

            if (response.error != nil) {
                failure(response.error!)
            } else {

                guard let data = response.value else {
                    return
                }
                success(data)
            }
        }
    }
}


