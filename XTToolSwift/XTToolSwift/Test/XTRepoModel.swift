//
//  XTModel1.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation
import CodableWrapper

struct XTRepoModel: XTProtocol {

    @Codec
    var full_name: String = ""
}

struct XTOwnerModel: XTProtocol {

    @Codec
    var type: String = "summerxx"
}

struct XTRepoListModel: XTProtocol {

    @Codec
    var name: String = ""

    @Codec
    var full_name: String = ""

    @Codec
    var id: Int = 0

    @Codec
    var `private`: Bool = true

    /// null
    @Codec
    var homepage: String = "null"

    var owner: XTOwnerModel?
}
