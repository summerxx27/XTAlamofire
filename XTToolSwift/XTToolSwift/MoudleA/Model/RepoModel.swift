//
//  RepoListModel.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation
import CodableWrapper

struct RepoModel: XTModel {

    @Codec
    var name: String = ""
}
