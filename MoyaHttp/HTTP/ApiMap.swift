//
//  ApiMap.swift
//  SwiftHttpPackage
//
//  Created by ZhiHua Shen on 2018/6/7.
//  Copyright © 2018年 ZhiHua Shen. All rights reserved.
//

import Foundation
import RxSwift
import Moya

extension Response {
    
    func gbkEncodingMap<T:Codable>(_ type:T.Type) throws -> T {
        
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        
        let str = String(data: self.data, encoding: String.Encoding(rawValue: enc)) ?? ""
        let data = str.data(using: .utf8)!
        
        do {
            let obj = try JSONDecoder().decode(T.self, from: data)
            return obj
        }
        catch {
            throw error
        }
    }
    
}

public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    func gbkEncodingMap<T: Codable>(_ type: T.Type) -> Single<T> {
        return flatMap({ Single.just(try $0.gbkEncodingMap(T.self)) })
    }
}

public extension PrimitiveSequence where TraitType == SingleTrait, ElementType: ModelVerifiable {
    func validate() -> Single<ElementType.DataModel?> {
        return flatMap({ Single.just( try $0.validate() ) })
    }
}

public extension MoyaProvider where Target == ApiRequest {
    
    func mapRequest<T:Codable>(_ req: ApiRequest, type: T.Type) -> Single<T> {
        return HttpProvider.rx.request(req).map(T.self)
    }
    
    func validateMapRequest<T:ModelVerifiable>(_ req: ApiRequest, type: T.Type) -> Single<T.DataModel?> {
        return HttpProvider.rx.request(req).map(T.self).validate()
    }
    
}
