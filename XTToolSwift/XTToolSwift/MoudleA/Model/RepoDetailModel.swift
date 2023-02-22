//
//  RepoDetailModel.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation
import CodableWrapper

struct RepoDetailModel: XTModel {

    @Codec
    var full_name: String = ""
}
