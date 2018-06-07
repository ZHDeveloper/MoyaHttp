## MoyaHttp

Swift开发了两个项目，趁现在有闲余时间把项目中用到的网络请求提取出来，方便以后的使用。顺便将在封装过程中遇到的问题进行总结。

## 序列化与反序列

常见的场景：当我们发起网络请求，到服务器响应json数据，客户端拿到数据。如果不对数据进行解析，直接使用，业务变得复杂，代码就变得难以维护，显然是不符合MVC架构的思想。Swift4.0以前的json序列化库有：ObjectMapper、SwiftyJSON、HandyJSON。笔者在Swift4.0以前使用HandyJSON将JSON转换为模型。但是Swift4.0中的Codable协议，让我抛弃其他的第三方库JSON转模型库。主要是因为Codable使用起来方便简单。

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



