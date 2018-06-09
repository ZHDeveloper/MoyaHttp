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
        
        let api = ApiRequest.post(baseUrl: Api.kBaseUrl, path: Api.kListPath)
        //        let api = ApiRequest.post(baseUrl: Api.kBaseUrl, path: Api.kListPath, params: nil)
        //        let api = ApiRequest.get(baseUrl: Api.kBaseUrl)
        //        let api = ApiRequest.get(baseUrl: Api.kBaseUrl, path: Api.kListPath, params: nil)
        
        //        _ = HttpProvider.mapRequest(api, type: RootModel<DetailModel>.self).subscribe(onSuccess: { (model) in
        //            print(model)
        //        }, onError: { (error) in
        //            print(error)
        //        })
        
        _ = HttpProvider.validateMapRequest(api, type: RootModel<DetailModel>.self).subscribe(onSuccess: { (model) in
            print(model ?? "")
        }, onError: { (error) in
            print(error)
        })
        
        //        _ = HttpProvider.rx.request(service).map(RootModel<DetailModel>.self).validate().subscribe(onSuccess: { (model) in
        //
        //            print(model ?? "")
        //
        //        }, onError: { (error) in
        //            print(error.localizedDescription)
        //        })
        
    }
}

