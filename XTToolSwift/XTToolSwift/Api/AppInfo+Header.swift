//
//  AppInfo.swift
//  Api
//
//  Created by summerxx on 2020/6/1.
//

import Foundation

extension AppInfo {
    
    /// 构建一个 API 请求头
    /// 这里可以进行一些自定义包装
    func baseHeaders() -> [String: String] {
        
        let header = [
            "Authorization": "token "
        ]
        
        return header
    }
}
