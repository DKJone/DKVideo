DKVideo -  一键VIP视频解析
=====
一键解析各网站VIP视频，去广告播放
解析接口来自网络，本项目只截取解析完成的内容来播放。

###本项目如何实现的：
>项目基于Swift5.0,项目源码不适合新手阅读，如想尝试实现本项目，需要具备基础的IOS开发技能，熟悉Swift
>项目中度使用RXSwift，
>使用RXTheme实现主题定制及暗色适配，
>使用SwiftyJSON和HandyJSON解析json数据
>使用SnapKit布局UI
>使用RSwift管理图片和文件
>播放器使用腾讯的SuperPlayer(Ijkplayer和TXLiteAVSDK的封装 )
>使用OBJCRuntime动态调用私有API(上架应用需要将方法名加密处理)

1.[如何拦截并转发APP中的网络请求](./HowToInterceptRequests.md)
2.如何解析M3U8(hls)文件得到下载路径
3.将APP加入到系统分享




###TODO:
* [x] 解析视频地址替换为腾讯的SuperPlayer播放
* [x] 一键解析VIP视频
* [x] 切换解析源
* [x] 视频在线播放
* [x] 获取PC版网页
* [ ] 从其他视频APP或网页直接跳转到DKVideo中播放和解析
* [ ] 视频下载
* [ ] 下载重命名
* [ ] 下载列表
* [ ] 删除下载
* [ ] 边下边播
* [ ] 暗色主题
* [ ] 自定义主题
* [ ] 缓存管理
* [ ] 暴力解析获取所有可用的播放路径


