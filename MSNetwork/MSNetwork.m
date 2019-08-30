//
//  MSNetwork.m
//  MSNetwork
//
//  Created by lztb on 2019/8/27.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "MSNetwork.h"
#import <YYCache/YYCache.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"

#ifdef DEBUG
#define MSLog(FORMAT, ...) fprintf(stderr,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define MSLog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@implementation MSNetwork

static BOOL _isOpenLog;   // 是否已开启日志打印
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

static NSDictionary *_baseParameters;
static NSArray *_filtrationCacheKey;
static NSString *const NetworkResponseCache = @"ATNetworkResponseCache";
static NSString * _baseURL;
static YYCache *_dataCache;

/*所有的请求task数组*/
+ (NSMutableArray *)allSessionTask{
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableArray array];
    }
    return _allSessionTask;
}

/*json转字符串*/
#pragma mark 字典转化字符串
+(NSString*)dictionaryToJson:(id)jsonObject{
    if (!jsonObject) return nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark -- 初始化相关属性
+ (void)initialize{
    _sessionManager = [AFHTTPSessionManager manager];
    //设置请求超时时间
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    //设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",@"multipart/form-data", nil];
    //开始监测网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //打开状态栏菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    _dataCache = [YYCache cacheWithName:NetworkResponseCache];
    _isOpenLog = YES;
}

/// 开启日志打印 (Debug级别)
+ (void)openLog{
    _isOpenLog = YES;
}

/// 关闭日志打印,默认关闭
+ (void)closeLog{
    _isOpenLog = NO;
}

/// 有网YES, 无网:NO
+ (BOOL)isNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

/// 手机网络:YES, 反之:NO
+ (BOOL)isWWANNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

/// WiFi网络:YES, 反之:NO
+ (BOOL)isWiFiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

/// 取消指定URL的HTTP请求
+ (void)cancelRequestWithURL:(NSString *)URL{
    if (!URL) { return; }

    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

/// 取消所有HTTP请求
+ (void)cancelAllRequest{
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

/// 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
+ (void)networkStatusWithBlock:(MSNetworkStatus)networkStatus{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    networkStatus ? networkStatus(MSNetworkStatusUnknown) : nil;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    networkStatus ? networkStatus(MSNetworkStatusNotReachable) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    networkStatus ? networkStatus(MSNetworkStatusReachableWWAN) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    networkStatus ? networkStatus(MSNetworkStatusReachableWiFi) : nil;
                    break;
                default:
                    break;
            }
        }];
//    });
}

/**是否打开网络加载菊花(默认打开)*/
+ (void)openNetworkActivityIndicator:(BOOL)open{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

/**设置请求超时时间(默认30s) */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time{
    _sessionManager.requestSerializer.timeoutInterval = time;
}


/**过滤缓存Key*/
+ (void)setFiltrationCacheKey:(NSArray *)filtrationCacheKey{
    _filtrationCacheKey = filtrationCacheKey;
}

/**设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束*/
+ (void)setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
}

/**设置接口基本参数(如:用户ID, Token)*/
+ (void)setBaseParameters:(NSDictionary *)parameters{
    _baseParameters = parameters;
}

/** 设置接口请求头 */
+ (void)setHeadr:(NSDictionary *)heder{
    for (NSString * key in heder.allKeys) {
        [_sessionManager.requestSerializer setValue:heder[key] forHTTPHeaderField:key];
    }
}


#pragma mark -- 缓存描述文字
+ (NSString *)cachePolicyStr:(MSCachePolicy)cachePolicy
{
    switch (cachePolicy) {
        case MSCachePolicyOnlyNetNoCache:
            return @"只从网络获取数据，且数据不会缓存在本地";
            break;
        case MSCachePolicyCacheElseNet:
            return @"从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据";
            break;
        case MSCachePolicyNetElseCache:
            return @"先从网络获取数据并缓存数据，如果访问网络失败再从缓存读取，失败的Block和成功的Block都会执行";
            break;
        case MSCachePolicyCacheThenNet:
            return @"先从缓存读取数据，然后再从网络获取数据，成功的Block将产生两次调用";
            break;
        default:
            break;
    }
}

#pragma mark -- GET请求
+ (void)GET:(NSString *)URL
        parameters:(NSDictionary *)parameters
       cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{
    [self HTTPWithMethod:MSRequestMethodGET url:URL parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


#pragma mark -- POST请求
+ (void)POST:(NSString *)URL
         parameters:(NSDictionary *)parameters
        cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{
    [self HTTPWithMethod:MSRequestMethodPOST url:URL parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}

#pragma mark -- HEAD请求
+ (void)HEAD:(NSString *)url
         parameters:(NSDictionary *)parameters
        cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{
    [self HTTPWithMethod:MSRequestMethodHEAD url:url parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


#pragma mark -- PUT请求
+ (void)PUT:(NSString *)url
        parameters:(NSDictionary *)parameters
       cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{
    [self HTTPWithMethod:MSRequestMethodPUT url:url parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


#pragma mark -- PATCH请求
+ (void)PATCH:(NSString *)url
          parameters:(NSDictionary *)parameters
         cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{
    [self HTTPWithMethod:MSRequestMethodPATCH url:url parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


#pragma mark -- DELETE请求
+ (void)DELETE:(NSString *)url
           parameters:(NSDictionary *)parameters
          cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure {
    [self HTTPWithMethod:MSRequestMethodDELETE url:url parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}

#pragma mark -- 上传文件
+ (void)uploadFileWithURL:(NSString *)url parameters:(NSDictionary *)parameters name:(NSString *)name filePath:(NSString *)filePath
                 progress:(MSHttpProgress)progress
                  success:(MSHttpSuccess)success
                  failure:(MSHttpFail)failure{
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //添加-文件
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [[self allSessionTask] removeObject:task];
        failure? failure(error) : nil;
    }];
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}

#pragma mark -- 上传图片文件
+ (void)uploadImageURL:(NSString *)url parameters:(NSDictionary *)parameters images:(NSArray<UIImage *> *)images
                  name:(NSString *)name
             fileNames:(NSString *)fileName
            imageScale:(CGFloat)imageScale
             imageType:(NSString *)imageType
              progress:(MSHttpProgress)progress
               success:(MSHttpSuccess)success
               failure:(MSHttpFail)failure{

    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);

            NSString *imageFileName = fileName;
            if (!imageFileName) {
                // 默认图片的文件名, 若fileNames为nil就使用
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                imageFileName = NSStringFormat(@"%@%lu.%@", str, idx, imageType ?: @"jpg");
            }

            [formData appendPartWithFileData:imageData name:name fileName:NSStringFormat(@"%@%lu.%@",fileName,(unsigned long)idx,imageType ? imageType : @"jpeg")
                                    mimeType:NSStringFormat(@"image/%@",imageType ? imageType : @"jpeg")];
        }];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        if (_isOpenLog) {
            MSLog(@"上传进度:%.2f%%",100.0*uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [[self allSessionTask] removeObject:task];
        failure? failure(error) : nil;
    }];
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

};

#pragma mark -- 下载文件
+(void)downloadWithURL:(NSString *)url fileDir:(NSString *)fileDir progress:(MSHttpProgress)progress success:(MSHttpDownload)success
                                                                                                     failure:(MSHttpFail)failure{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (_isOpenLog) {
            MSLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];

        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建DownLoad目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        if (_isOpenLog) {
            MSLog(@"DownLoad filePath = %@",filePath);
        }
        return [NSURL fileURLWithPath:filePath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (failure && error) {
            failure ? failure(error) : nil;
            return;
        }
        success ? success(filePath.absoluteString) : nil;
    }];
    //开始下载
    [downloadTask resume];

    //添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;
}




+ (void)HTTPWithMethod:(MSRequestMethod)method
                   url:(NSString *)url
            parameters:(NSDictionary *)parameters
           cachePolicy:(MSCachePolicy)cachePolicy
        success:(MSHttpSuccess)success
        failure:(MSHttpFail)failure{

    if (_baseURL.length) {
        url = NSStringFormat(@"%@%@",_baseURL,url);
    }

    if (_baseParameters.count) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }

    if (_isOpenLog) {
        MSLog(@"\n请求参数 = %@\n 请求URL = %@\n 请求方式 = %@\n 缓存策略 = %@\n",parameters ? parameters:@"", url, [self getMethodStr:method], [self cachePolicyStr:cachePolicy]);
    }

    switch (cachePolicy) {
        case MSCachePolicyOnlyNetNoCache:{
            //只从网络获取数据，且数据不会缓存在本地
            [self httpWithMethod:method url:url parameters:parameters success:success failure:failure];
        }
            break;
        case  MSCachePolicyCacheElseNet:{
            //从缓存读取数据并返回，再从网络获取并缓存，每次只读取缓存数据
            [self httpCacheForURL:url parameters:parameters withBlock:^(id<NSCoding> object) {
                success ? success(object) : nil;
                [self httpWithMethod:method url:url parameters:parameters success:^(id responseObject) {
                    [self setHttpCache:responseObject url:url parameters:parameters];
                } failure:failure];
            }];
        }
            break;
        case MSCachePolicyNetElseCache:{
            //先从网络获取数据，同时会在本地缓存数据，如果没有（此处的没有可以理解为访问网络失败）再从缓存读取，并且返回Error
            [self httpWithMethod:method url:url parameters:parameters success:^(id responseObject) {
                success ? success(responseObject) : nil;
                [self setHttpCache:responseObject url:url parameters:parameters];
            } failure:^(NSError *error) {
                [self httpCacheForURL:url parameters:parameters withBlock:^(id<NSCoding> object) {
                    success ? success(object) : nil;
                }];
                failure(error);
            }];
        }
            break;
        case MSCachePolicyCacheThenNet:{
            //先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用
            [self httpCacheForURL:url parameters:parameters withBlock:^(id<NSCoding> object) {
                if (object) {
                    success ? success(object) : nil;
                }
                [self httpWithMethod:method url:url parameters:parameters success:^(id responseObject) {
                    //尽量避免多次调用Block
                    if (object != responseObject && responseObject) {
                        [self setHttpCache:responseObject url:url parameters:parameters];
                        success ? success(responseObject) : nil;
                    }
                } failure:failure];
            }];
        }
            break;

        default:
            break;
    }


//    if (cachePolicy == MSCachePolicyOnlyNetNoCache) {
//
//    }else if (cachePolicy == MSCachePolicyOnlyCache){
//        //只从缓存读数据，如果缓存没有数据，返回一个空。
//        [self httpCacheForURL:url parameters:parameters withBlock:success];
//
//    }else if (cachePolicy == MSCachePolicyNetCacheBoth){
//        //先从网络获取数据，同时会在本地缓存数据
//        [self httpWithMethod:method url:url parameters:parameters success:^(id responseObject) {
//            [self setHttpCache:responseObject url:url parameters:parameters];
//            success ? success(responseObject) : nil;
//        } failure:failure];
//
//    }else if (cachePolicy == MSCachePolicyCacheElseNet){
//        //先从缓存读取数据，如果没有再从网络获取
//        [self httpCacheForURL:url parameters:parameters withBlock:^(id<NSCoding> object) {
//            if (object) {
//                success ? success(object) : nil;
//            }else{
//                [self httpWithMethod:method url:url parameters:parameters success:success failure:failure];
//            }
//        }];
//    }else if (cachePolicy == MSCachePolicyNetElseCache){
//
//
//    }else if (cachePolicy == MSCachePolicyCacheThenNet){
//        //先从缓存读取数据，然后在本地缓存数据，无论结果如何都会再次从网络获取数据，在这种情况下，Block将产生两次调用
//        [self httpCacheForURL:url parameters:parameters withBlock:^(id<NSCoding> object) {
//            success ? success(object) : nil;
//            [self httpWithMethod:method url:url parameters:parameters success:^(id responseObject) {
//                [self setHttpCache:responseObject url:url parameters:parameters];
//                success ? success(responseObject) : nil;
//            } failure:failure];
//        }];
//    }else{
//        //缓存策略错误，将采取 MSCachePolicyOnlyNetNoCache 策略
//        MSLog(@"缓存策略错误");
//        [self httpWithMethod:method url:url parameters:parameters success:success failure:failure];
//    }
}


#pragma mark -- 网络请求处理
+(void)httpWithMethod:(MSRequestMethod)method url:(NSString *)url parameters:(NSDictionary *)parameters success:(MSHttpSuccess)success failure:(MSHttpFail)failure{

    [self dataTaskWithHTTPMethod:method url:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (_isOpenLog) {
            MSLog(@"请求结果 = %@",[self dictionaryToJson:responseObject]);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            MSLog(@"错误内容 = %@",error);
        }
        failure ? failure(error) : nil;
        [[self allSessionTask] removeObject:task];
    }];
    
}


+(void)dataTaskWithHTTPMethod:(MSRequestMethod)method url:(NSString *)url parameters:(NSDictionary *)parameters
                     success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURLSessionTask *sessionTask;
    
    switch (method) {
        case MSRequestMethodGET:{
            sessionTask = [_sessionManager GET:url parameters:parameters progress:nil success:success failure:failure];
        }
            break;
        case MSRequestMethodPOST:{
            sessionTask = [_sessionManager POST:url parameters:parameters progress:nil success:success failure:failure];
        }
            break;
        case MSRequestMethodHEAD:{
            sessionTask = [_sessionManager HEAD:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                success(task,nil);
            } failure:failure];
        }
            break;
        case MSRequestMethodPUT:{
            sessionTask = [_sessionManager PUT:url parameters:parameters success:success failure:failure];
        }
            break;
        case MSRequestMethodPATCH:{
            sessionTask = [_sessionManager PATCH:url parameters:parameters success:success failure:failure];
        }
            break;
        case MSRequestMethodDELETE:{
            sessionTask = [_sessionManager DELETE:url parameters:parameters success:success failure:failure];
        }
        default:
            break;
    }
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}


+ (NSString *)getMethodStr:(MSRequestMethod)method{
    switch (method) {
        case MSRequestMethodGET:
            return @"GET";
            break;
        case MSRequestMethodPOST:
            return @"POST";
            break;
        case MSRequestMethodHEAD:
            return @"HEAD";
            break;
        case MSRequestMethodPUT:
            return @"PUT";
            break;
        case MSRequestMethodPATCH:
            return @"PATCH";
            break;
        case MSRequestMethodDELETE:
            return @"DELETE";
            break;

        default:
            break;
    }
}

#pragma mark -- 网络缓存
+ (YYCache *)getYYCache
{
    return _dataCache;
}

+ (void)setHttpCache:(id)httpData url:(NSString *)url parameters:(NSDictionary *)parameters{
    if (httpData) {
        NSString *cacheKey = [self cacheKeyWithURL:url parameters:parameters];
//        NSString *cacheTime = NSStringFormat(@"%@Time",cacheKey);//缓存时间
//        [_dataCache setObject:[NSDate date] forKey:cacheTime];
        [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
    }
}

+ (void)httpCacheForURL:(NSString *)url parameters:(NSDictionary *)parameters withBlock:(void(^)(id responseObject))block
{
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:parameters];
   // NSString *cacheTime = NSStringFormat(@"%@Time",cacheKey);//缓存时间
  
    [_dataCache objectForKey:cacheKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isOpenLog) {
                MSLog(@"缓存结果 = %@",[self dictionaryToJson:object]);
            }
            block(object);
        });
    }];
   
}


+ (void)setCostLimit:(NSInteger)costLimit{
    [_dataCache.diskCache setCostLimit:costLimit];//磁盘最大缓存开销
}

+ (NSInteger)getAllHttpCacheSize{
    return [_dataCache.diskCache totalCost];
}

+ (void)getAllHttpCacheSizeBlock:(void(^)(NSInteger totalCount))block{
    return [_dataCache.diskCache totalCountWithBlock:block];
}

+ (void)removeAllHttpCache{
    [_dataCache.diskCache removeAllObjects];
}

+ (void)removeAllHttpCacheBlock:(void(^)(int removedCount, int totalCount))progress
                       endBlock:(void(^)(BOOL error))end{
    [_dataCache.diskCache removeAllObjectsWithProgressBlock:progress endBlock:end];
}

+ (NSString *)cacheKeyWithURL:(NSString *)url parameters:(NSDictionary *)parameters
{
    if(!parameters){return url;};

    if (_filtrationCacheKey.count) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableParameters removeObjectsForKeys:_filtrationCacheKey];
        parameters =  [mutableParameters copy];
    }

    /// 将URL与转换好的参数字符串拼接在一起,成为最终存储的KEY值
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",url,[self dictionaryToJson:parameters]];

    return cacheKey;
}


/************************************重置AFHTTPSessionManager相关属性**************/
#pragma mark -- 重置AFHTTPSessionManager相关属性

+ (AFHTTPSessionManager *)getAFHTTPSessionManager
{
    return _sessionManager;
}

+ (void)setRequestSerializer:(MSRequestSerializer)requestSerializer{
    _sessionManager.requestSerializer = requestSerializer== MSRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(MSResponseSerializer)responseSerializer{
    _sessionManager.responseSerializer = responseSerializer== MSResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}


+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}


+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName{

    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    //使用证书验证模式
    AFSecurityPolicy *securitypolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //如果需要验证自建证书(无效证书)，需要设置为YES
    securitypolicy.allowInvalidCertificates = YES;
    //是否需要验证域名，默认为YES
    securitypolicy.validatesDomainName = validatesDomainName;
    securitypolicy.pinnedCertificates = [[NSSet alloc]initWithObjects:cerData, nil];
    [_sessionManager setSecurityPolicy:securitypolicy];
}


@end






#pragma mark -- NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文
 ************************************************************************************
 */
//#ifdef DEBUG
@implementation NSArray (AT)

- (NSString *)descriptionWithLocale:(id)locale{

    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@,\n",obj];
    }];
    [strM appendString:@")\n"];
    return  strM;
}
@end

@implementation NSDictionary (AT)

- (NSString *)descriptionWithLocale:(id)locale{

    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@ = %@,\n",key,obj];
    }];
    [strM appendString:@"}\n"];
    return  strM;
}

@end
