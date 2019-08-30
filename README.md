# MSNetwork
基于AFNetworking 3.x与YYCache的二次封装,包括网络请求、文件上传、文件下载这三个方法。并且支持RESTful API,GET、POST、HEAD、PUT、DELETE、PATCH的请求,方法接口简洁明了,并结合YYYCache做了网络数据的缓存策略。简单易用,一句代码搞定网络数据的请求与缓存,控制台可直接打印json中文字符,调试更方便

## 效果图

[image](https://note.youdao.com/favicon.ico)
[image](https://note.youdao.com/favicon.ico)

## Requirements 要求

- iOS 8+
- Xcode 8+

## 安装!

### Cocoapods安装

```objc
暂不支持Cocoapods安装
```
### 手动安装

```objc
1、将MSNetwork文件夹添加到项目目录中
2、创建PrefixHeader.pch文件
3、在Build Setting搜索prefix,
4、设置Apple Clang - Language ->Precompile Prefix Header为YES；
5、设置Apple Clang - Language ->Prefix Header的路径；
```

## Usage 使用方法

**所有方法都可以直接看 MSNetwork.h 中的声明以及注释。**

### MSNetwork 的全局配置

#### 设置请求根路径

具体可查看Demo中的MSHTTPRequest.m方法实现
```objc
//最终完整Url为[NSString stringWithFormat:@“%@%@”,_baseURL,URL]，
[MSNetwork setBaseURL:@"https://www.baidu.com/"];
```
#### 设置缓存过滤参数key(如时间戳，随机数)否则会导致无法得到缓存数据

```objc
[MSNetwork setFiltrationCacheKey:@[@"2",@"3"]];
```

#### 设置日志

##### 关于日志打印

```objc
//开启日志打印 默认打开(Debug级别)
[MSNetwork openLog];

//关闭日志打印,
[MSNetwork closeLog];
```

### 网络状态

#### 网络状态监听

```objc
[MSNetwork networkStatusWithBlock:^(MSNetworkStatusType status) {
switch (status) {
case MSNetworkStatusUnknown:
//未知网络
break;
case MSNetworkStatusNotReachable:
//无网路
break;
case MSNetworkStatusReachableWWAN:
//手机网络
break;
case MSNetworkStatusReachableWiFi:
//WiFi网络
break;
default:
break;
}
}];
```
<br /> 

### 网络请求

#### 缓存策略

这是我目前能想到的几个缓存场景
* 只从网络获取数据，且数据不会缓存在本地（一般情况）
* 从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据
* 先从网络获取数据并缓存数据，如果访问网络失败再从缓存读取，失败的Block和成功的Block都会执行（如果有更好的建议可以告诉我）
* 先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用（如果有更好的建议可以告诉我）


```objc
typedef NS_ENUM(NSUInteger, MSCachePolicy){
/**只从网络获取数据，且数据不会缓存在本地**/
MSCachePolicyOnlyNetNoCache = 0,
/** 从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据**/
MSCachePolicyCacheElseNet,
/** 先从网络获取数据并缓存数据，如果访问网络失败再从缓存读取，失败的Block和成功的Block都会执行*/
MSCachePolicyNetElseCache,
/**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，缓存数据与网络数据不一致Block将产生两次调用*/
MSCachePolicyCacheThenNet
};
```
