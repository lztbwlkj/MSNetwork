//
//  MSHTTPRequest.m
//  MSNetwork
//
//  Created by lztb on 2019/8/29.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "MSHTTPRequest.h"


@implementation MSHTTPRequest
/** 登录*/
+ (void)GET:(NSString *)URL parameters:(id)parameters  cachePolicy:(MSCachePolicy)cachePolicy success:(MSHttpSuccess)success  failure:(MSHttpFail)failure{
    //设置对应接口的Url
    [self requestWithMethod:MSRequestMethodGET url:URL parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}
/** 退出*/
+ (void)POST:(NSString *)URL parameters:(id)parameters cachePolicy:(MSCachePolicy)cachePolicy success:(MSHttpSuccess)success failure:(MSHttpFail)failure{
    //设置对应接口的Url
    [self requestWithMethod:MSRequestMethodPOST url:URL parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


/*
 配置好PPNetworkHelper各项请求参数,封装成一个公共方法,给以上方法调用,
 相比在项目中单个分散的使用PPNetworkHelper/其他网络框架请求,可大大降低耦合度,方便维护
 在项目的后期, 你可以在公共请求方法内任意更换其他的网络请求工具,切换成本小
 */

#pragma mark - 请求的公共方法

+ (void)requestWithMethod:(MSRequestMethod)method url:(NSString *)URL  parameters:(NSDictionary *)parameters cachePolicy:(MSCachePolicy)cachePolicy success:(MSHttpSuccess)success  failure:(MSHttpFail)failure{
    // 在请求之前你可以统一配置你请求的相关参数 ,设置请求头, 请求参数的格式, 返回数据的格式....这样你就不需要每次请求都要设置一遍相关参数
    [MSNetwork closeLog];
    //设置基础的Url
    //最终完整Url为[NSString stringWithFormat:@“%@%@”,_baseURL,URL]
    [MSNetwork setBaseURL:kApiPrefix];

    //设置缓存过滤 设置后会移除该参数进行缓存
    //
    //[MSNetwork setFiltrationCacheKey:@[@"time",@"ts"]];
    //设置超时时间
    //[MSNetwork setRequestTimeoutInterval:15.0f];
    
    // 设置请求头
    //可一次设置多个也可单独设置
    //[MSNetwork setHeadr:@{@"api-version":@"v1.0.0"}];
    [MSNetwork setValue:@"9" forHTTPHeaderField:@"fromType"];

    //设置公用请求参数
//    NSDictionary *dic = @{@"accountToken":@{@"tokenId":@"",@"userId":@"",@"initDate":@"",@"clientType":@"mobilType",@"tokenKey":@""}};
//    [MSNetwork setBaseParameters:dic];
    
    //可以设置全局等待的指示器
//    [MBProgressHUD mb_loading:^{
//        NSLog(@"hud已经隐藏");
//    }];

    
//    [MSNetwork setAFHTTPSessionManagerProperty:^(AFHTTPSessionManager * sessionManager) {
//
//    }];
    
 
    
    // 发起请求
    [MSNetwork HTTPWithMethod:method url:URL parameters:parameters cachePolicy:cachePolicy success:^(id  _Nonnull responseObject) {
        //[MBProgressHUD mb_hide];
        success(responseObject);
    } failure:^(NSError * _Nonnull error) {
        //[MBProgressHUD mb_hide];
        failure(error);
    }];
}
@end
