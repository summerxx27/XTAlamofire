//
//  NetworkError.swift
//  Networking
//
//  Created by summerxx on 2020/6/1.
//

import Alamofire

/// 网络请求出错
public protocol NetworkError: Error {
    var responseCode: Int? { get }
}

extension AFError: NetworkError {}
