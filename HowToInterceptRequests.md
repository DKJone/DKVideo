如何拦截并转发APP中的网络请求
===
####理论基础：URL Loading System
####主要实现类: [URLProtocol](https://developer.apple.com/documentation/foundation/nsurlprotocol)

>iOS的Foundation框架提供了 URL Loading System 这个库(ULS)，所有应用层的传输协议都可以通过ULS提供的基础类和协议来实现，你也可以你用它自定义自己通讯协议。
>在每一个 HTTP 请求开始时，ULS创建一个合适的 `URLProtocol` 对象处理对应的 URL 请求，而我们需要做的就是写一个继承自 `URLProtocol` 的类，并通过` - registerClass: `方法注册我们的协议类，然后 URL 加载系统就会在请求发出时使用我们创建的协议对象对该请求进行处理。

#`URLProtocol`
一个用于处理特定URL加载的抽象类,定义：
```swift
class URLProtocol : NSObject
```

一个父类是`NSObject`的抽象类，并不是swift中的`Protocol`,
实现此抽象类后理论上可以拦截APP中所有的Cocoa层网络请求，

由此我们定义一个URLProtocol的子类，来拦截处理我们的网络请求，例如截取网络请求中的视频播放地址，为每个请求添加统一的请求头，过滤掉部分网络请求等。

```swift
/// 网络请求拦截器
class URLIntercept: URLProtocol { }
```

我们直接在`XCode`中点开`URLProtocol`
类的定义你主要有以下方法和属性
```swift
    /** 初始化方法 */
    public init(request: URLRequest,...)
    public init(task: URLSessionTask,...)
    /** 用于获取加载结果 */
    open var client: URLProtocolClient? { get }

    /** 当前加载的网络请求 */
    open var request: URLRequest { get }
    
    /** 参数是当前的网络请求，返回是否需要监控此请求 */
    open class func canInit(with request: URLRequest) -> Bool
    open class func canInit(with: URLSessionTask) -> Bool

    /** 根据当前的网络请求，返回一个我们自定义的网络请求 */
    open class func canonicalRequest(for request: URLRequest) -> URLRequest

    /** 调用此方法，应该开始加载网络请求 */
    open func startLoading()
    /** 实现方法以取消网络请求 */
    open func stopLoading()
    
    /** 获取网络请求中的关联属性 */
     open class func property(forKey key: String, in request: URLRequest) -> Any?
    /** 设置网络请求中的关联属性 */
    open class func setProperty(_ value: Any, forKey key: String, in request: NSMutableURLRequest)
    /** 移除网络请求中的关联属性 */
    open class func removeProperty(forKey key: String, in request: NSMutableURLRequest)
    
    /** 注册协议类*/
    open class func registerClass(_ protocolClass: AnyClass) -> Bool
    /** 取消注册 */
    open class func unregisterClass(_ protocolClass: AnyClass)
}
```
从上面也不难看出我们需要重点实现 `canInit`来确定是否监控此条网络请求 ，实现`canonicalRequest`实现拦截的具体处理逻辑。

首先我们需要确定哪些球球需要处理，注意：在我们发起一个网络请求的时候，首先会调用`canInitWithRequest:`方法，询问是否对该请求进行处理，接着会调用`canonicalRequestForRequest:`来自定义一个`request`，新的请求(request)又会去调用`canInitWithRequest:`询问自定义的`request`是否需要处理，如果我们又返回`true`，然后又去调用了`canonicalRequestForRequest:`这样，就形成了一个死循环了，为了打破这种循环，我们给处理过的网络请求设置一个标识，再次检测到此标识就不在处理这条请求。
```swift
    let URLInterceptKey = "Intercepted"
    /// 返回是否监控此条网络请求
    /// - Parameter request: 网络请求
    override class func canInit(with request: URLRequest) -> Bool {
        print(request.url?.absoluteString ?? "")
        // 如果是已经拦截过的就放行，避免出现死循环
        if URLProtocol.property(forKey: URLInterceptKey, in: request) as? Bool ?? false {
            return false
        }
        // 不是网络请求，不处理
        if let urlScheme = request.url?.scheme?.lowercased() {
            if ["http", "https", "ftp"].contains(urlScheme) {
                return true
            }
        }
        // 不拦截其他
        return false
    }

    /// 设置我们自己的自定义请求
    /// - Parameter request: 当前的网络请求
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var mutableReqeust: URLRequest = request
        guard let urlStr = request.url?.absoluteString else { return request }
        // 广告拦截标识字符
        let adStrings = ["img.09mk.cn", "img.xiaohui2.cn", ".xiaohui", ".apple.com", "img2.", "sysapr.cn"]
        adStrings.forEach { str in
            if urlStr.contains(str) { mutableReqeust.url = nil }
        }
        // 视频播放拦截
        if urlStr.pathExtension.hasPrefix("m3u8") {
            print("=====video获取到视频路径===\n\(urlStr)")
            DispatchQueue.main.async {
                //调用视频播放器播放拦截到的视频地址    
            }
        }
        return mutableReqeust
    }

```
然后我们需要实现发起和取消网络请求的方法,可以再此对拦截到的网络请求做统一的处理，如修改请求头信息，设置处理标识符等
```swift
// 由于默认的task是只读属性，所以我们用newTask属性记录新发起的请求
var newTask: URLSessionTask?
override func startLoading() {
        // 给我们处理过的请求设置一个标识符, 防止无限循环,
        var request = self.request
        URLProtocol.setProperty(true, forKey: URLInterceptKey, in: request as! NSMutableURLRequest)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        //模拟PC版浏览器请求
        if UserDefaults.isPCAgent{
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", forHTTPHeaderField:"User-Agent" )
        }else{
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        }
        self.newTask = session.dataTask(with: request)
        self.newTask?.resume()
    }

    override func stopLoading() {
        self.newTask?.cancel()
    }

```
我们创建`URLSession`时将代理设为了`self`，所以还要实现代理方法
```swift
extension URLIntercept: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //这里可以拦截返回的数据`data`
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
```

到此我们已经完成了这个拦截类的实现，将其注册后就可以实现请求拦截了，我们直接在APPdelegate中进行注册
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        URLProtocol.registerClass(URLIntercept.self)
        LibsManager.shared.configTheme()
        return true
    }
}
```
运行程序后就可以拦截到网络请求了，但是到此还没有结束，我们在拦截`WKWebView`的请求时发现，只能拦截到第一条，之后的都不在被拦截处理。
主要是由于WKWebView为内部调用请求对应的scheme注册了对应的URLProtocol，所以我们的`URLProtocol`实现无法拦截到这些请求，于是我们需要把这些注册了的scheme `unregister`掉，具体可以参考[webkit-TestProtocol.mm](https://github.com/WebKit/webkit/blob/master/Tools/TestWebKitAPI/cocoa/TestProtocol.mm)中的单元测试代码（60-73行）。
其中调用的 `unregisterSchemeForCustomProtocol`为私有API
所以我们需要借助运行时，去动态调用，在swift5中，我们已经不再能够使用`performSelector`方法，我们也不准备使用OC去调用这些私有api，关于swift调用运行时方法将在另一篇文章中介绍这里直接写结果代码
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let browCont = WKWebView().value(forKey: "browsingContextController")didFinishLaunchingWithOptions
        //获取类，你也可以直接使用NSClassFromString("WKBrowsingContextController")获取
        let classType = type(of: browCont!) as! AnyClass
        //获取注册scheme方法
        if let method = extractMethodFrom(owner: classType, selector: NSSelectorFromString("registerSchemeForCustomProtocol:")) {   
        //反向注册http和https两个scheme
            _ = method("http")
            _ = method("https")
        }
        URLProtocol.registerClass(URLIntercept.self)
        LibsManager.shared.configTheme()

        return true
    }
}

```
反向注册scheme后,WKWebView中的http和https请求就会被我们实现的`URLIntercept`拦截到了

如果需要拦截其他网络框架的请求需要替换掉`URLSessionConfiguration`中的`protocolClasses`，在其中添加我们的拦截类，在APPdelegate中的`didFinishLaunchingWithOptions`中使用[Aspects](https://github.com/steipete/Aspects) 去Swizzle原获取方法(也可以使用MethodSwizzling)
```swift
        let rblock: @convention(block) (AspectInfo)-> Void = { info in
            let invocation =  info.originalInvocation()
            var pros = [URLProtocol.Type]()
            invocation?.invoke()
            invocation?.getReturnValue(&pros)
            pros.append(URLIntercept.self)
            invocation?.setReturnValue(&pros)
        }
        try! type(of: URLSession.shared.configuration).aspect_hook(NSSelectorFromString("protocolClasses"), with: .positionInstead, usingBlock: rblock)
```
