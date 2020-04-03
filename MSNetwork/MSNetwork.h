//
//  MSNetwork.h
//  MSNetwork
//
//  Created by lztb on 2019/8/27.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef kIsNetwork
#define kIsNetwork     [MSNetwork isNetwork]  // 一次性判断是否有网的宏
#endif

#ifndef kIsWWANNetwork
#define kIsWWANNetwork [MSNetwork isWWANNetwork]  // 一次性判断是否为手机网络的宏
#endif

#ifndef kIsWiFiNetwork
#define kIsWiFiNetwork [MSNetwork isWiFiNetwork]  // 一次性判断是否为WiFi网络的宏
#endif

@class YYCache, AFHTTPSessionManager;
/**
 这是我目前能想到的几个缓存场景
 * 只从网络获取数据，且数据不会缓存在本地（一般情况）
 * 从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据
 * 先从网络获取数据并缓存数据，如果访问网络失败再从缓存读取，失败的Block和成功的Block都会执行
 * 先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用
 **/

typedef NS_ENUM(NSUInteger, MSCachePolicy){
    /**只从网络获取数据，且数据不会缓存在本地**/
    MSCachePolicyOnlyNetNoCache = 0,
    /** 从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据 这种一般用于广告页面加载模式**/
    MSCachePolicyCacheElseNet,
    /** 先从网络获取数据并缓存数据，如果访问网络失败再从缓存读取，失败的Block和成功的Block都会执行*/
    MSCachePolicyNetElseCache,
    /**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，缓存数据与网络数据不一致Block将产生两次调用*/
    MSCachePolicyCacheThenNet
};

/**请求方式*/
typedef NS_ENUM(NSUInteger, MSRequestMethod){
    /**GET请求方式*/
    MSRequestMethodGET = 0,
    /**POST请求方式*/
    MSRequestMethodPOST,
    /**HEAD请求方式*/
    MSRequestMethodHEAD,
    /**PUT请求方式*/
    MSRequestMethodPUT,
    /**PATCH请求方式*/
    MSRequestMethodPATCH,
    /**DELETE请求方式*/
    MSRequestMethodDELETE
};

typedef NS_ENUM(NSUInteger, MSNetworkStatusType){
    /**未知网络*/
    MSNetworkStatusUnknown,
    /**无网路*/
    MSNetworkStatusNotReachable,
    /**手机网络*/
    MSNetworkStatusReachableWWAN,
    /**WiFi网络*/
    MSNetworkStatusReachableWiFi,
    
};

typedef NS_ENUM(NSUInteger, MSRequestSerializer){
    /**设置请求数据为JSON格式*/
    MSRequestSerializerJSON,
    /**设置请求数据为二进制格式*/
    MSRequestSerializerHTTP
};

typedef NS_ENUM(NSUInteger, MSResponseSerializer) {
    /**设置响应数据为JSON格式*/
    MSResponsetSerializerJSON,
    /**设置响应数据为二进制格式*/
    MSResponseSerializerHTTP
};

/**请求的成功Block*/
typedef void(^MSHttpSuccess)(id responseObject);

/**请求的失败Block*/
typedef void(^MSHttpFail)(NSError *error);

/**下载的Block*/
typedef void(^MSHttpDownload)(NSString *path);

/**上传或者下载的进度**/
typedef void(^MSHttpProgress)(NSProgress *progress);

/**网络状态Block*/
typedef void(^MSNetworkStatus)(MSNetworkStatusType status);

@interface MSNetwork : NSObject

/// 开启日志打印 默认打开(Debug级别)
+ (void)openLog;

/// 关闭日志打印,
+ (void)closeLog;

/// 有网YES, 无网:NO
+ (BOOL)isNetwork;

/// 手机网络:YES, 反之:NO
+ (BOOL)isWWANNetwork;

/// WiFi网络:YES, 反之:NO
+ (BOOL)isWiFiNetwork;

/// 取消指定URL的HTTP请求
+ (void)cancelRequestWithURL:(NSString *)URL;

/// 取消所有HTTP请求
+ (void)cancelAllRequest;

//开启网络监听
+ (void)startMonitoring;

/// 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)，内部已默认开启网络监听
/// @param networkStatus 返回当前网络类型的枚举
+ (void)networkStatusWithBlock:(MSNetworkStatus)networkStatus;
    
///停止网络监听
+ (void)stopMonitoring;



/**是否打开网络加载菊花(默认打开)*/
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**设置请求超时时间(默认30s) */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**过滤缓存Key*/
+ (void)setFiltrationCacheKey:(NSArray *)filtrationCacheKey;

/**设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束*/
+ (void)setBaseURL:(NSString *)baseURL;

/**设置接口基本参数(如:用户ID, Token)*/
+ (void)setBaseParameters:(NSDictionary *)parameters;

/** 预设接口请求头 */
+ (void)setHeader:(NSDictionary *)header;

#pragma mark -- 网络请求 --

#pragma mark -- GET请求
/**
 GET请求
 
 @param URL 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */

+ (void)GET:(NSString *)URL
 parameters:(NSDictionary *)parameters
    headers:(nullable NSDictionary<NSString *,NSString *>*)headers
cachePolicy:(MSCachePolicy)cachePolicy
    success:(MSHttpSuccess)success
    failure:(MSHttpFail)failure;


#pragma mark -- POST请求
/**
 POST请求
 
 @param URL 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)POST:(NSString *)URL
  parameters:(NSDictionary *)parameters
     headers:(nullable NSDictionary<NSString *,NSString *>*)headers
 cachePolicy:(MSCachePolicy)cachePolicy
     success:(MSHttpSuccess)success
     failure:(MSHttpFail)failure;

#pragma mark -- HEAD请求
/**
 HEAD请求
 
 @param url 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)HEAD:(NSString *)url
  parameters:(NSDictionary *)parameters
     headers:(nullable NSDictionary<NSString *,NSString *>*)headers
 cachePolicy:(MSCachePolicy)cachePolicy
     success:(MSHttpSuccess)success
     failure:(MSHttpFail)failure;


#pragma mark -- PUT请求
/**
 PUT请求
 
 @param url 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)PUT:(NSString *)url
 parameters:(NSDictionary *)parameters
    headers:(nullable NSDictionary<NSString *,NSString *>*)headers
cachePolicy:(MSCachePolicy)cachePolicy
    success:(MSHttpSuccess)success
    failure:(MSHttpFail)failure;

#pragma mark -- PATCH请求
/**
 PATCH请求
 
 @param url 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)PATCH:(NSString *)url
   parameters:(NSDictionary *)parameters
      headers:(nullable NSDictionary<NSString *,NSString *>*)headers
  cachePolicy:(MSCachePolicy)cachePolicy
      success:(MSHttpSuccess)success
      failure:(MSHttpFail)failure;


#pragma mark -- DELETE请求
/**
 DELETE请求
 
 @param url 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */

+ (void)DELETE:(NSString *)url
    parameters:(NSDictionary *)parameters
       headers:(nullable NSDictionary<NSString *,NSString *>*)headers
   cachePolicy:(MSCachePolicy)cachePolicy
       success:(MSHttpSuccess)success
       failure:(MSHttpFail)failure;
/**
 自定义请求方式
 
 @param method 请求方式(GET, POST, HEAD, PUT, PATCH, DELETE)
 @param url 请求地址
 @param parameters 请求参数
 @param headers 附加到默认请求header的headers
 @param cachePolicy 缓存策略
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)HTTPWithMethod:(MSRequestMethod)method
                   url:(NSString *)url
            parameters:(NSDictionary *)parameters
               headers:(nullable NSDictionary<NSString *,NSString *>*)headers
           cachePolicy:(MSCachePolicy)cachePolicy
               success:(MSHttpSuccess)success
               failure:(MSHttpFail)failure;

#pragma mark -- 上传文件

/**
 上传文件
 
 @param url 服务器地址
 @param parameters 上传参数
 @param headers 附加到默认请求header的headers
 @param name 与服务器对应的字段
 @param filePath 文件对应本地的路径
 @param progress 上传进度
 @param success  上传成功
 @param failure  上传失败
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)url parameters:(NSDictionary *)parameters
                                headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                                   name:(NSString *)name filePath:(NSString *)filePath
                               progress:(MSHttpProgress)progress
                                success:(MSHttpSuccess)success
                                failure:(MSHttpFail)failure;

#pragma mark -- 上传多张图片文件

/**
 上传单/多张图片文件
 
 @param url 服务器地址
 @param parameters 上传参数
 @param headers 附加到默认请求header的headers
 @param images 图片数组
 @param name 与服务器对应的字段
 @param fileName 文件名 最终结果处理为文件名+文件在数组中的index
 @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 @param imageType 图片的类型,png,jpeg
 @param progress  上传进度
 @param success  上传成功
 @param failure  上传失败
 @return NSURLSessionTask
 */

+ (NSURLSessionTask *)uploadImageURL:(NSString *)url
                          parameters:(NSDictionary *)parameters
                             headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                              images:(NSArray<UIImage *> *)images
                                name:(NSString *)name
                            fileName:(NSString *)fileName
                          imageScale:(CGFloat)imageScale
                           imageType:(NSString *)imageType
                            progress:(MSHttpProgress)progress
                             success:(MSHttpSuccess)success
                             failure:(MSHttpFail)failure;

#pragma mark -- 下载文件

/**
 下载文件
 
 @param url 服务器地址
 @param fileDir 文件本地的沙盒路径（默认为DownLoad文件夹）
 @param progress 上传进度
 @param success  上传成功
 @param failure  上传失败
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *) downloadWithURL:(NSString *)url
                               fileDir:(nullable NSString *)fileDir
                              progress:(MSHttpProgress)progress
                               success:(MSHttpDownload)success
                               failure:(MSHttpFail)failure;

/**
 下载文件
 
 @param resumeData 用于继续下载的数据
 @param fileDir 文件本地的沙盒路径（默认为DownLoad文件夹）
 @param progress 上传进度
 @param success  上传成功
 @param failure  上传失败
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *) downloadTaskWithResumeData:(NSData *)resumeData
                                          fileDir:(nullable NSString *)fileDir
                                         progress:(MSHttpProgress)progress
                                          success:(MSHttpDownload)success
                                          failure:(MSHttpFail)failure;



#pragma mark -- 网络缓存

/**
 *  获取YYCache对象
 */
+ (YYCache *)getYYCache;

/**
 *  异步缓存网络数据,根据请求的 URL与parameters
 *  做Key存储数据, 这样就能缓存多级页面的数据
 *
 *  @param httpData   服务器返回的数据
 *  @param url        请求的URL地址
 *  @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData url:(NSString *)url parameters:(NSDictionary *)parameters;

/**
 *  根据请求的 URL与parameters 异步取出缓存数据
 *
 *  @param url        请求的URL
 *  @param parameters 请求的参数
 *  @param block      异步回调缓存的数据
 *
 */
+ (void)httpCacheForURL:(NSString *)url parameters:(NSDictionary *)parameters withBlock:(void(^)(id responseObject))block;


/**
 *  磁盘最大缓存开销大小 bytes(字节)
 */
+ (void)setCostLimit:(NSInteger)costLimit;

/**
 *  获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;

/**
 *  获取网络缓存的总大小 bytes(字节)
 *  推荐使用该方法 不会阻塞主线程，通过block返回
 */
+ (void)getAllHttpCacheSizeBlock:(void(^)(NSInteger totalCount))block;

/**
 *  删除所有网络缓存
 */
+ (void)removeAllHttpCache;

/**
 *  删除所有网络缓存
 *  推荐使用该方法 不会阻塞主线程，同时返回Progress
 */
+ (void)removeAllHttpCacheBlock:(void(^)(int removedCount, int totalCount))progress
                       endBlock:(void(^)(BOOL error))end;


#pragma mark -- 重置AFHTTPSessionManager相关属性

#pragma mark - 设置AFHTTPSessionManager相关属性
#pragma mark 注意: 因为全局只有一个AFHTTPSessionManager实例,所以以下设置方式全局生效

/**
 在开发中,如果以下的设置方式不满足项目的需求,就调用此方法获取AFHTTPSessionManager实例进行自定义设置
 (注意: 调用此方法时在要导入AFNetworking.h头文件,否则可能会报找不到AFHTTPSessionManager的❌)
 @param sessionManager AFHTTPSessionManager的实例
 */

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager;
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

@end

NS_ASSUME_NONNULL_END
