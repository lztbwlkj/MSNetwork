# MSNetwork
![](https://img.shields.io/badge/platform-iOS-red.svg) ![](https://img.shields.io/badge/language-Objective--C-orange.svg) 


基于AFNetworking 3.x与YYCache的二次封装,包括网络请求、文件上传、文件下载这三个方法。并且支持RESTful API,GET、POST、HEAD、PUT、DELETE、PATCH的请求,方法接口简洁明了,并结合YYCache做了网络数据的缓存策略。简单易用,一句代码搞定网络数据的请求与缓存,控制台可直接打印json中文字符,调试更方便

## 效果图

<table>
<tr>
<th>请求方式</th>
<th>缓存策略</th>
<th>文件下载</th>
<th>文件上传</th>
</tr>

<tr>
<td><img src="https://github.com/lztbwlkj/MSNetwork/blob/master/Example/IMG_1786.PNG" width="300" height="500"></td>
<td><img src="https://github.com/lztbwlkj/MSNetwork/blob/master/Example/IMG_1790.PNG" width="300" height="500"></td>
<td><img src="https://github.com/lztbwlkj/MSNetwork/blob/master/Example/未命名.gif" width="300" height="500"></td>
<td > <p>暂未测试</p> </td>
</tr>

</table>


## Requirements 要求

- iOS 8+
- Xcode 8+

## 安装!

### Cocoapods安装

```objc
 pod 'MSNetwork'
```
### 手动安装
注意: 项目中需要有AFN3.x , YYCache第三方库! 在工程中链接sqlite3依赖库
```objc
1、下载Demo后将MSNetwork文件夹添加到项目目录中;
2、创建并配置PrefixHeader.pch文件或者导入头文件MSNetwork.h开始使用即可;
```

## Usage 使用方法

#### **所有方法都可以直接看 MSNetwork.h 中的声明以及注释。**

### MSNetwork 的全局配置
#### 设置日志

##### 关于日志打印

```objc
//开启日志打印 默认打开(Debug级别)
[MSNetwork openLog];

//关闭日志打印,
[MSNetwork closeLog];
```

#### 设置请求根路径

```objc
//最终完整Url为[NSString stringWithFormat:@“%@%@”,_baseURL,URL]，
[MSNetwork setBaseURL:@"https://www.baidu.com/"];
```
#### 设置缓存过滤参数key(如时间戳，随机数)否则会导致无法得到缓存数据

```objc
[MSNetwork setFiltrationCacheKey:@[@"2",@"3"]];
```
#### 设置全局请求参数

```objc
NSDictionary *dic = @{@"accountToken":@{@"clientType":@"",@"tokenKey":@""}};
[MSNetwork setBaseParameters:dic];
```

#### 设置网络请求超时时间
```objc
[MSNetwork setRequestTimeoutInterval:15.0f];

```
#### 设置网络请求头
```objc
//可一次设置多个也可单独设置
//[MSNetwork setHeadr:@{@"api-version":@"v1.0.0"}];
[MSNetwork setValue:@"9" forHTTPHeaderField:@"fromType"];
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

#### 判断有无网络
```objc
if (kIsNetwork) {
NSLog(@"有网络");
if (kIsWWANNetwork) {
NSLog(@"手机网络");
}else if (kIsWiFiNetwork){
NSLog(@"WiFi网络");
}
} else {
NSLog(@"无网络");
}
// 或
//    if ([MSNetwork isNetwork]) {
//        NSLog(@"有网络");
//        if ([MSNetwork isWWANNetwork]) {
//            NSLog(@"手机网络");
//        }else if ([MSNetwork isWiFiNetwork]){
//            NSLog(@"WiFi网络");
//        }
//    } else {
//        NSLog(@"无网络");
//    }
```

### 网络缓存

#### 缓存策略

这是我目前能想到的几个缓存场景
* 只从网络获取数据，且数据不会缓存在本地（一般情况）
* 从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据（一般用于广告页面可提高加载速度）
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
#### 缓存大小
```objc
CGFloat totalBytes = [MSNetwork getAllHttpCacheSize]/1024.f;
NSLog(@"网络缓存大小cache = %fKB",totalBytes);
//或者
[MSNetwork getAllHttpCacheSizeBlock:^(NSInteger totalCount) {
NSLog(@"网络缓存大小cache = %.2fMB",totalCount/1024/1024.f);
}];
```
#### 删除网络缓存

```objc
__weak __typeof(&*self)weakSelf = self;
[MSNetwork removeAllHttpCacheBlock:^(int removedCount, int totalCount) {
NSLog(@"cache progress = %d",removedCount/totalCount);
} endBlock:^(BOOL error) {
//通知主线程刷新
dispatch_async(dispatch_get_main_queue(), ^{
});
}];  

//或者
// [MSNetwork removeAllHttpCache];
```

### 网络请求
#### GET
```objc
__weak __typeof(&*self)weakSelf = self;

NSDictionary *para = @{@"a":@"list", @"c":@"data",@"client":@"iphone",@"page":@"0",@"per":@"10", @"type":@"29"};
[MSHTTPRequest GET:@"" parameters:para cachePolicy:MSCachePolicyCacheThenNet success:^(id  _Nonnull responseObject) {

} failure:^(NSError * _Nonnull error) {

}];
```

#### POST

```objc
__weak __typeof(&*self)weakSelf = self;

[MSHTTPRequest POST:@"" parameters:@{} cachePolicy:MSCachePolicyCacheThenNet success:^(id  _Nonnull responseObject) {

} failure:^(NSError * _Nonnull error) {

}];
```
#### 其他请求方式（HEAD、PUT、DELETE、PATCH）

HEAD、PUT、DELETE、PATCH请求方式和GET、POST方式类似，请前往MSNetwork.h文件中查看对应方法（相信聪明的你一看就明白了！~ Q.Q ~）

#### 自定义请求方式
```objc
[MSNetwork HTTPWithMethod:@"" url:@"" parameters:@{} cachePolicy:设置缓存策略的枚举 success:^(id  _Nonnull responseObject) {

} failure:^(NSError * _Nonnull error) {

}];
```

#### 文件下载
```objc
- (void)downLoadFiles {
MBProgressHUD *hud = [MBProgressHUD mb_showBar:@"正在下载..." detailMsg:@"请不要退出程序,以免下载失败！" onView:nil hideBlock:^{
NSLog(@"hud已经隐藏");
}];

NSURLSessionTask *task = [MSNetwork downloadWithURL:@"" fileDir:@"下载至沙盒中的制定文件夹(默认为Download)" progress:^(NSProgress * _Nonnull progress) {
CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
CGFloat pro = stauts/100.f;

NSLog(@"pro = %.2f",pro);
hud.progress = pro;
//此处只用于Demo演示，展示不同状态的hud
if (pro >= 0.5) {
hud.mode = MBProgressHUDModeAnnularDeterminate;
}

if (pro == 1.0) {
UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
hud.customView = imageView;
hud.mode = MBProgressHUDModeCustomView;
hud.label.text = NSLocalizedString(@"下载完成", @"HUD completed title");
hud.detailsLabel.text = @"";
[hud hideAnimated:YES afterDelay:1.5];
}

} success:^(NSString * _Nonnull path) {

} failure:^(NSError * _Nonnull error) {

}];
}

//暂停下载,暂不支持断点下载
[task suspend];
//开始下载
[task resume];

```

#### 文件上传
```objc
NSURLSessionTask *task = [MSNetwork uploadFileWithURL:@""
parameters:@{@"参数":@"参数"}
name:@"文件对应服务器上的字段"
filePath:@"文件本地的沙盒路径"
progress:^(NSProgress *progress) {
//上传进度
NSLog(@"上传进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
} success:^(id responseObject) {
//上传成功
} failure:^(NSError *error) {
//上传失败
}];

```


#### 单/多图上传

```objc
NSURLSessionTask *task = [MSNetwork uploadImageURL:@"" parameters:@{} images:@[@"图片类型数组"] name:@"文件对应服务器上的字段" fileName:@"图片名称" imageScale:0.5 imageType:@"png\jpg\jpeg..." progress:^(NSProgress * _Nonnull progress) {
//上传进度
NSLog(@"上传进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);

} success:^(id  _Nonnull responseObject) {
//上传成功

} failure:^(NSError * _Nonnull error) {
//上传失败

}];


```

### 重置AFHTTPSessionManager相关属性

```objc

#pragma mark - 设置AFHTTPSessionManager相关属性
#pragma mark 注意: 因为全局只有一个AFHTTPSessionManager实例,所以以下设置方式全局生效

/**
在开发中,如果以下的设置方式不满足项目的需求,就调用此方法获取AFHTTPSessionManager实例进行自定义设置
(注意: 调用此方法时在要导入AFNetworking.h头文件,否则可能会报找不到AFHTTPSessionManager的❌)
@param sessionManager AFHTTPSessionManager的实例
*/
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
设置网络请求参数的格式:默认为JSON格式

@param requestSerializer MSRequestSerializerJSON---JSON格式  MSRequestSerializerHTTP--HTTP
*/
+ (void)setRequestSerializer:(MSRequestSerializer)requestSerializer;

/**
设置服务器响应数据格式:默认为JSON格式

@param responseSerializer MSResponseSerializerJSON---JSON格式  MSResponseSerializerHTTP--HTTP

*/
+ (void)setResponseSerializer:(MSResponseSerializer)responseSerializer;

/**
设置请求头
*/
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
配置自建证书的Https请求，参考链接:http://blog.csdn.net/syg90178aw/article/details/52839103

@param cerPath 自建https证书路径
@param validatesDomainName 是否验证域名(默认YES) 如果证书的域名与请求的域名不一致，需设置为NO
服务器使用其他信任机构颁发的证书也可以建立连接，但这个非常危险，建议打开 .validatesDomainName=NO,主要用于这种情况:客户端请求的是子域名，而证书上是另外一个域名。因为SSL证书上的域名是独立的
For example:证书注册的域名是www.baidu.com,那么mail.baidu.com是无法验证通过的
*/
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;
```

MSNetwork全部以类方法调用,使用简单,麻麻再也不用担心我一句一句地写SQLite啦~~~
<br />
### 如果关于缓存策略你有更好的建议或者思路,希望留言告知！不吝赐教!


### 万水千山总是情，给个Start行不行！！！~ Q.Q ~
