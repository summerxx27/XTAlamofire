//
//  NetworkManager+Reachability.swift
//  Networking
//
//  Created by summerxx on 2020/7/8.
//

import Foundation
import Alamofire

/// 网络状态改变通知
public let NetworkReachabilityStatusDidChangeNotification =
    NSNotification.Name(rawValue: "NetworkReachabilityStatusDidChangeNotification")

extension NetworkManager {

    /// 网络是否可用
    @objc
    public var isReachable: Bool {
        reachabilityStatus == .reachableViaWiFi || reachabilityStatus == .reachableViaCellular
    }

    var reachabilityManager: NetworkReachabilityManager? {
        guard let manager = getAssociatedObject() as? NetworkReachabilityManager else {
            let manager = NetworkReachabilityManager()
            startReachabilityListening(withManager: manager)
            setAssociatedObject(manager)
            return manager
        }
        return manager
    }

    private func startReachabilityListening(withManager manager: NetworkReachabilityManager?) {

        manager?.startListening { [weak self] status in

            switch status {
            case .unknown:
                self?.reachabilityStatus = .unknown
            case .notReachable:
                self?.reachabilityStatus = .notReachable
            case .reachable(.ethernetOrWiFi):
                self?.reachabilityStatus = .reachableViaWiFi
            case .reachable(.cellular):
                self?.reachabilityStatus = .reachableViaCellular
            @unknown default:
                assertionFailure()
            }

            if let status = self?.reachabilityStatus {
                NotificationCenter.default.post(name: NetworkReachabilityStatusDidChangeNotification,
                                                object: nil,
                                                userInfo: ["status": status.rawValue])
            }
        }
    }
}

extension NetworkManager {

    /// 网络状态改变通知
    @objc
    @available(swift, obsoleted: 1.0)
    public class var reachabilityStatusDidChangeNotification: NSString {
        NetworkReachabilityStatusDidChangeNotification as NSString
    }
}
