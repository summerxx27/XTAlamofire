//
//  ViewController.swift
//  XTToolSwift
//
//  Created by summerxx on 2023/2/20.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        RepoDetailApi.fetchRepDetai { resp in
//
//            guard resp.result != nil, let full_name = resp.result?.full_name else {
//                return
//            }
//            print("xttest_full_name === \(full_name)")
//        }
//
//        RepoApi.fetchRepoList { resp in
//
//            if resp.code == 0 {
//                guard let res = resp.result else {
//                    return
//                }
//
//                res.forEach { model in
//                    print("name === \(String(describing: model.name))")
//                }
//                print("count = \(res.count)")
//            }
//        }

        JDNetwork.get("https://api.github.com/repos/mosn/mosn", params: nil, of: XTRepoModel.self) { res in
            print("对象数据类型 \nfull_name = \(res.full_name)")
        } failure: { error in
            print(error)
        }

        JDNetwork.get("https://api.github.com/users/mosn/repos", params: nil, of: [XTRepoListModel].self) { res in

            print("数组数据类型")
            res.forEach { obj in
                print(obj.name)
                print(obj.full_name)
                print(obj.id)
                print(obj.private)
                print(obj.homepage)
                print("第二层数据 type === \(obj.owner?.type)")
                print("\n")
            }
        } failure: { error in
            print(error)
        }
    }
}

