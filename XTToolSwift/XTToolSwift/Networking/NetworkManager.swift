//
//  NetworkManager.swift
//  Networking
//
//  Created by summerxx on 2020/7/7.
//

import Foundation
import Alamofire

/// 网络可用性状态
@objc(XTNetworkReachabilityStatus)
public enum NetworkReachabilityStatus: Int {
    
    /// 网络状态未知
    @objc(XTNetworkReachabilityStatusUnknown)
    case unknown = -1
    
    /// 网络不可用
    @objc(XTNetworkReachabilityStatusNotReachable)
    case notReachable = 0
    
    /// 通过 WiFi 连接
    @objc(XTNetworkReachabilityStatusReachableViaWiFi)
    case reachableViaWiFi = 1
    
    /// 通过蜂窝网络连接
    @objc(XTNetworkReachabilityStatusReachableViaCellular)
    case reachableViaCellular = 2
}

/// 网络管理器
@objc(XTNetworkManager)
public class NetworkManager: NSObject {
    
    override init() {
        super.init()
        _ = reachabilityManager
    }
    
    /// 单例对象
    @objc
    public static let manager = NetworkManager()
    
    /// 网络可用性状态
    @objc
    public var reachabilityStatus: NetworkReachabilityStatus = .unknown
    
    /// 网络可用性状态的文案（"WWAN" / "Wi-Fi" / "Not Reachable" / "Unknown"）
    @objc
    public var reachabilityStatusString: String {
        switch reachabilityStatus {
        case .notReachable:
            return "Not Reachable"
        case .reachableViaWiFi:
            return "Wi-Fi"
        case .reachableViaCellular:
            return "WWAN"
        default:
            return "Unknown"
        }
    }
}
