//
//  File.swift
//  SwiftHttpPackage
//
//  Created by ZhiHua Shen on 2018/6/7.
//  Copyright © 2018年 ZhiHua Shen. All rights reserved.
//

import Foundation

public protocol ModelVerifiable: Codable {
    
    associatedtype DataModel
    
    var code: Int? { get }
    var msg: String? { get }
    var data: DataModel? { get }
    
    func validate() throws -> DataModel?
}

public extension ModelVerifiable {
    
    func validate() throws -> DataModel? {
        
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

public struct RootModel<Target: Codable>:ModelVerifiable {
    public typealias DataModel = Target
    public var code: Int?
    public var msg: String?
    public var data: DataModel?
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
