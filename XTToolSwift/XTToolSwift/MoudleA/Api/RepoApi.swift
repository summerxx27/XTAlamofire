//
//  RepoApi.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation

enum RepoApi {

    /// https://api.github.com/users/mosn/repos?per_page=100&page=1
    static func fetchRepoList(result: @escaping (ApiResponse<[RepoModel]>) -> Void) {
        ApiClient.request("users/mosn/repos",
                          params: ["per_page": 100, "page": 1],
                          result: result)
    }
}


