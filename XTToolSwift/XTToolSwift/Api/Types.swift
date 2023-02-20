//
//  Types.swift
//  Api
//
//  Created by summerxx on 2020/5/28.
//

/// res 对应模型的类型
public typealias ResponseResType = Any

/// 模型转换器
public typealias ResponseResolver = (ResponseResType?) -> Any?

/// 不处理返回结果
public class IgnoredRes {}

extension IgnoredRes: ApiResponseResolvable {}
