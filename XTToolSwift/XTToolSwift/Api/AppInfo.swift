//
//  AppInfo.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import Foundation

public class AppInfo: NSObject {

    var baseUrl = "https://api.github.com/"

    /// 单例对象
    @objc(shareInstance)
    public static var shared = AppInfo()
}
