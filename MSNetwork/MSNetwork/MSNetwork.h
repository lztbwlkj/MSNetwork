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

@class YYCache, AFHTTPSessionManager;

typedef NS_ENUM(NSUInteger, MSCachePolicy){
    /**只从网络获取数据，且数据不会缓存在本地**/
            MSCachePolicyOnlyNetNoCache = 0,
    /**只从缓存读数据，如果缓存没有数据，返回一个nil**/
            MSCachePolicyOnlyCache = 1,
    /**先从网络获取数据，同时会在本地缓存数据*/
            MSCachePolicyNetworkOnly = 2,
    /**先从缓存读取数据，如果没有再从网络获取*/
            MSCachePolicyCacheElseNetwork = 3,
    /**先从网络获取数据，如果没有在从缓存获取，此处的没有可以理解为访问网络失败，再从缓存读取*/
            MSCachePolicyNetworkElseCache = 4,
    /**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用*/
            MSCachePolicyCacheThenNetwork = 5
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
            MSNetworkStatusReachableWiFi
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

/// 开启日志打印 (Debug级别)
+ (void)openLog;

/// 关闭日志打印,默认关闭
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

/// 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
+ (void)networkStatusWithBlock:(MSNetworkStatus)networkStatus;

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
+ (void)setHeadr:(NSDictionary *)heder;

#pragma mark -- 网络请求 --

#pragma mark -- GET请求
+ (void)GET:(NSString *)URL
               parameters:(NSDictionary *)parameters
              cachePolicy:(MSCachePolicy)cachePolicy
                  success:(MSHttpSuccess)success
                  failure:(MSHttpFail)failure;


#pragma mark -- POST请求
+ (void)POST:(NSString *)URL
                parameters:(NSDictionary *)parameters
               cachePolicy:(MSCachePolicy)cachePolicy
                   success:(MSHttpSuccess)success
                   failure:(MSHttpFail)failure;

#pragma mark -- HEAD请求
+ (void)HEAD:(NSString *)url
  parameters:(NSDictionary *)parameters
 cachePolicy:(MSCachePolicy)cachePolicy
     success:(MSHttpSuccess)success
     failure:(MSHttpFail)failure;


#pragma mark -- PUT请求
+ (void)PUT:(NSString *)url
 parameters:(NSDictionary *)parameters
cachePolicy:(MSCachePolicy)cachePolicy
    success:(MSHttpSuccess)success
    failure:(MSHttpFail)failure;

#pragma mark -- PATCH请求
+ (void)PATCH:(NSString *)url
   parameters:(NSDictionary *)parameters
  cachePolicy:(MSCachePolicy)cachePolicy
      success:(MSHttpSuccess)success
      failure:(MSHttpFail)failure;


#pragma mark -- DELETE请求
+ (void)DELETE:(NSString *)url
    parameters:(NSDictionary *)parameters
   cachePolicy:(MSCachePolicy)cachePolicy
       success:(MSHttpSuccess)success
       failure:(MSHttpFail)failure;

#pragma mark -- 上传文件
+ (void)uploadFileWithURL:(NSString *)url
               parameters:(NSDictionary *)parameters
                     name:(NSString *)name
                 filePath:(NSString *)filePath
                 progress:(MSHttpProgress)progress
                  success:(MSHttpSuccess)success
                  failure:(MSHttpFail)failure;

#pragma mark -- 上传多张图片文件
+ (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                images:(NSArray<UIImage *> *)images
                  name:(NSString *)name
             fileNames:(NSString *)fileName
            imageScale:(CGFloat)imageScale
             imageType:(NSString *)imageType
              progress:(MSHttpProgress)progress
               success:(MSHttpSuccess)success
               failure:(MSHttpFail)failure;

#pragma mark -- 下载文件
+(void)downloadWithURL:(NSString *)url
               fileDir:(NSString *)fileDir
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

/**
 *  获取AFHTTPSessionManager对象
 */
+ (AFHTTPSessionManager *)getAFHTTPSessionManager;

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
