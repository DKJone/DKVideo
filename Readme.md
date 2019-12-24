DKVideo -  一键VIP视频解析
=====
一键解析各网站VIP视频，去广告播放
解析接口来自网络，本项目只截取解析完成的内容来播放。
项目地址：[https://github.com/DKJone/DKVideo](https://github.com/DKJone/DKVideo)
####1.安装
#####1.1 开发者：
下载[源码](https://github.com/DKJone/DKVideo)
后pod update 更换bundleId,运行到手机/IPad上
或者下载以下ipa后重签名应用：[未签名版](https://ali-fir-pro-binary.fir.im/7e9430a85b84f8a2a69653a3215a91c244eb1001?auth_key=1577169072-0-0-03f51e437338bbaca8aaae81389b53c0) 
注：推荐使用[ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)签名，使用方法自行百度
#####1.2 普通用户：
前往以下地址下载：[未签名](https://ali-fir-pro-binary.fir.im/7e9430a85b84f8a2a69653a3215a91c244eb1001?auth_key=1577169072-0-0-03f51e437338bbaca8aaae81389b53c0) 下载后使用 [Cydia Impactor](http://www.cydiaimpactor.com/)安装

####2.使用
#####2.1 播放vip或超前点映视频
打开APP找到对应网站的视频然后点击右上角VIP按钮即可实现一键解析如下图
![play.gif](https://upload-images.jianshu.io/upload_images/4066843-d68fc91d90c0f271.gif?imageMogr2/auto-orient/strip)
#####2.2 下载视频
在播放页右上角点击下载按钮，输入名称后即可下载
*注意：如果下载提示出错，可以在下载中心点击最前面的下载状态以继续下载*
暂时只支持m3u8点播视频下载，直播流下载可能出错
![download.gif](https://upload-images.jianshu.io/upload_images/4066843-433364520dbf50d7.gif?imageMogr2/auto-orient/strip)

#####2.3 切换VIP接口
长按右上角vip按钮2秒后松开即可切换（第1~3较稳定）

![switchVip.gif](https://upload-images.jianshu.io/upload_images/4066843-d104cc128a9130a4.gif?imageMogr2/auto-orient/strip)

#####2.4 播放下载
在下载中心点击播放
#####2.5 打开浏览器中的网页
可以复制地址到首页的搜索框粘贴后点确定即可
或者点击浏览器分享按钮然后选择DKVIdeo，如下图

#####2.6 更多设置
在设置中心自行设置，
*部分网页无法打开可切换电脑版和手机版*


###本项目如何实现的：
>项目基于Swift5.0,项目源码不适合新手阅读，如想尝试实现本项目，需要具备基础的IOS开发技能，熟悉Swift
>项目中度使用RXSwift，
>使用RXTheme实现主题定制及暗色适配，
>使用SwiftyJSON和HandyJSON解析json数据
>使用SnapKit布局UI
>使用RSwift管理图片和文件
>播放器使用腾讯的SuperPlayer(Ijkplayer和TXLiteAVSDK的封装 )
>使用OBJCRuntime动态调用私有API(上架应用需要将方法名加密处理)

1.[如何拦截并转发APP中的网络请求](https://github.com/DKJone/DKVideo/blob/master/HowToInterceptRequests.md)
2.如何解析M3U8(hls)文件得到下载路径
3.将APP加入到系统分享




###TODO:
* [x] 解析视频地址替换为腾讯的SuperPlayer播放
* [x] 一键解析VIP视频
* [x] 切换解析源
* [x] 视频在线播放
* [x] 获取PC版网页
* [x] 从其他视频APP或网页直接跳转到DKVideo中播放和解析
* [x] 视频下载
* [x] 下载重命名
* [x] 下载列表
* [x] 删除下载
* [x] 边下边播
* [x] 暗色主题
* [x] 自定义主题
* [x] 局域网分享下载
* [x] 后台下载
* [ ] 缓存管理
* [ ] 暴力解析获取所有可用的播放路径

更新内容：
2019-12-24
1.新增后台下载（替换原来下载为Tiercel）
2.新增局域网分享
3.新增使用流量时可选择关闭下载
4.修复综合解析重复弹出播放视图
5.修复iPAD播放页面快进手势与呼出侧边栏手势冲突
6.修复部分视频无法下载，修改错误提示
