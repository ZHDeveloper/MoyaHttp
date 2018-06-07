## MoyaHttp

Swift开发了两个项目，趁现在有闲余时间把项目中用到的网络请求提取出来，方便以后的使用。顺便将在封装过程中遇到的问题进行总结。

## 序列化与反序列

> 常见的场景：当我们发起网络请求，到服务器响应json数据，客户端拿到数据。如果不对数据进行解析，直接使用，业务变得复杂，代码就变得难以维护，显然是不符合MVC架构的思想。Swift4.0以前的json序列化库有：ObjectMapper、SwiftyJSON、HandyJSON。笔者在Swift4.0以前使用HandyJSON将JSON转换为模型。但是Swift4.0中的Codable协议，让我抛弃其他的第三方库JSON转模型库。主要是因为Codable使用起来方便简单。

```
struct FeedModel: Codable {
    var  author: String?
    var  fid: String?
    var  platform: String?
    var  postdate: String?
    var  title: String?
    var  url: String?
}

let string = """
{
    "fid": "148",
    "author": "知识小集",
    "title": "关于我们",
    "url": "https://github.com/awesome-tips/iOS-Tips",
    "platform": "4",
    "postdate": "2018-06-07"
}
"""
    
let data = string.data(using: .utf8)!
let obj = try! JSONDecoder().decode(FeedModel.self, from: data)
    
let strData = try! JSONEncoder().encode(obj)
let str = String(data: strData, encoding: .utf8)

```

## Moya封装

* 接口请求，比如：GET、POST、PUT、DELETE等。在与后台协调开发过程中，删除操作的接口用DELETE请求方式、PUT方式上传文件，这主要看后端的开发习惯。
* 请求参数，每个接口有自己独特的请求参数，或者为空。
* 请求路径，后端注册路由。

基于以上几点考虑，再考虑到网络请求功能有上传、下载、请求，定义枚举类ApiService并且实现Moya的TargetType协议：

```
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

```

## Moya/Rxswift


```
public let HttpProvider: MoyaProvider<ApiService> = MoyaProvider<ApiService>()
```

考虑到`HttpProvider`不需要每次请求发生变化，所以定义为全局常量。每次网络请求可以通过`HttpProvider`调起网络请求。

```
let service = ApiService.request(baseUrl: API.kBaseUrl, path: API.kListPath, params: nil, method: .post)

HttpProvider.rx.request(service).subscribe(onSuccess: { (response) in
            
}) { (error) in
    
}
```

函数调用 `HttpProvider.rx.request(service)`返回`Observable`
对象，通过订阅`subscribe`监听对象的变化，来处理数据。当时回调的数据是`Moya.Response`，并非我们想要的模型类数据,通过map函数将转换为我们需要的模型类`RootModel`：

```
HttpProvider.rx.request(service).map(RootModel<DetailModel>.self).subscribe(onSuccess: { (model) in
    
}) { (error) in
    
}

```

## 模型类的定义

```
// 服务器返回的数据
{
	"code": 0,
	"msg": "SUCCESS",
	"data": {
		"feeds": [{
			"fid": "148",
			"author": "知识小集",
			"title": "关于我们",
			"url": "https://github.com/awesome-tips/iOS-Tips",
			"platform": "4",
			"postdate": "2018-06-07"
		}]
	}
}
```

观察服务器返回的数据结构，`code`和`msg`类型是固定的，`data`结构是多变的。通过传入Target类型来确定整个RootModel最终的类型。

```
public struct RootModel<Target: Codable>: Codable {
    public var code: Int?
    public var msg: String?
    public var data: Target?
}
//使用
RootModel<DetailModel>
```

更多情况下我们使用的是`data`数据，然而`code`和`msg`也不能忽视。
例如，当`code`不为0时，显示`msg`的提示。

```

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

```

定义ModelVerifiable协议，并且让RootModel实现协议。在`validate`函数中定义自己的校验规则。

```
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType: ModelVerifiable {
    func validate() -> Single<ElementType.Model?> {
        return flatMap({ Single.just( try $0.validate() ) })
    }
}
```

给PrimitiveSequence方法拓展，先调用我们的校验函数，然后返回我们的` data `模型，并且包装成`Observable`。最终的效果如下：

```
let service = ApiService.request(baseUrl: API.kBaseUrl, path: API.kListPath, params: nil, method: .post)

_ = HttpProvider.rx.request(service).map(RootModel<DetailModel>.self).validate().subscribe(onSuccess: { (model) in
	//model的类型：DetailModel？
	print(model ?? "")

}, onError: { (error) in
	print(error.localizedDescription)
})

```

## 后续

* 测试使用知识小集的接口
* 如果您有更好的优化方案，请[issues](https://github.com/ZHDeveloper/MoyaHttp/issues)讨论





