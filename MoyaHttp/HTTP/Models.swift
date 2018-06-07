//
//  File.swift
//  SwiftHttpPackage
//
//  Created by ZhiHua Shen on 2018/6/7.
//  Copyright © 2018年 ZhiHua Shen. All rights reserved.
//

import Foundation

public protocol ModelVerifiable {
    
    associatedtype Model
    
    var code: Int? { get }
    var msg: String? { get }
    var data: Model? { get }
    
    func validate() throws -> Model?
}

public extension ModelVerifiable {
    
    func validate() throws -> Model? {
        
        if let code = code,code == 0 {
            return data
        }
        else {
            let message = msg ?? "服务器繁忙！"
            let eCode = code ?? 800
            throw NSError(domain: message, code: eCode, userInfo: nil)
        }
    }
}

public struct RootModel<Target: Codable>: Codable,ModelVerifiable {
    public typealias Model = Target
    public var code: Int?
    public var msg: String?
    public var data: Target?
}

struct DetailModel: Codable {
    var feeds: [FeedModel]?
}

struct FeedModel: Codable {
    var  author: String?
    var  fid: String?
    var  platform: String?
    var  postdate: String?
    var  title: String?
    var  url: String?
}
