//
//  RepoDetailApi.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation

enum RepoDetailApi {

    /// https://api.github.com/repos/mosn/mosn
    static func fetchRepDetai(result: @escaping (ApiResponse<RepoDetailModel>) -> Void) {
        ApiClient.request("repos/mosn/mosn",
                          params: nil,
                          result: result)
    }
}
