//
//  ViewController.swift
//  MoyaHttp
//
//  Created by ZhiHua Shen on 2018/6/7.
//  Copyright © 2018年 ZhiHua Shen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service = ApiService.request(baseUrl: API.kBaseUrl, path: API.kListPath, params: nil, method: .post)

        _ = HttpProvider.rx.request(service).map(RootModel<DetailModel>.self).validate().subscribe(onSuccess: { (model) in

            print(model ?? "")

        }, onError: { (error) in
            print(error.localizedDescription)
        })
    }
}

