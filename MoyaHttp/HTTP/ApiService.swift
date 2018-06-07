//
//  Api.swift
//  YueTao
//
//  Created by ZhiHua Shen on 2017/5/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit
import Foundation
import Moya

public var HttpProvider: MoyaProvider<ApiService> = MoyaProvider<ApiService>()

public enum ApiService {
    
    case request(baseUrl:String, path: String?, params: [String:Any]?, method: Moya.Method)
    case upload(baseUrl:String, path: String?, params: [String:Any]?, files:[FileModel], method: Moya.Method)
    case download(baseUrl:String, path: String?, params: [String:Any]?)
    
    public struct FileModel {
        var data: Data
        var fileName: String
        var fileKey: String
        var mimeType: String
    }
    
}

extension ApiService: TargetType {
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL: URL {
        switch self {
        case .request(let baseUrl,_,_,_):
            return URL(string: baseUrl)!
        case .upload(let baseUrl,_,_,_,_):
            return URL(string: baseUrl)!
        case .download(let baseUrl,_,_):
            return URL(string: baseUrl)!
        }
    }
    
    public var path: String {
        switch self {
        case .request(_,let urlPath,_,_):
            return urlPath ?? ""
        case .upload(_,let urlPath,_,_,_):
            return urlPath ?? ""
        case .download(_,let urlPath,_):
            return urlPath ?? ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .request(_,_,_,let method):
            return method
        case .upload(_,_,_,_,let method):
            return method
        case .download:
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .request(_,_,let params,_):
            return params
        case .upload(_,_,let params,_,_):
            return params
        case .download(_,_,let params):
            return params
        }
    }
    
    public var task: Task {
        switch self {
        case .request(_,_,let params,_):
            if let params = params {
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            }
            else {
                return .requestPlain
            }
            
        case .upload(_,_,let params,let files,_):
            var array: [Moya.MultipartFormData] = []
            files.forEach({ (model) in
                let formData = MultipartFormData(provider: .data(model.data), name: model.fileKey, fileName: model.fileName, mimeType: model.mimeType)
                array.append(formData)
            })
            if let params = params {
                return .uploadCompositeMultipart(array, urlParameters: params)
            }
            else {
                return .uploadMultipart(array)
            }
            
        case .download(_,_,let params):
            if let params = params {
                return .downloadParameters(parameters: params, encoding: URLEncoding.default, destination: defaultDownloadDestination)
            }
            else {
                return .downloadDestination(defaultDownloadDestination)
            }
            
        }
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
}

private let defaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    
    let directoryURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    
    if !directoryURLs.isEmpty {
        return (directoryURLs.first!.appendingPathComponent(response.suggestedFilename!), [])
    }
    
    return (temporaryURL, [])
}




