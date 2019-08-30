//
//  MSHTTPRequest.h
//  MSNetwork
//
//  Created by lztb on 2019/8/29.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSNetwork.h"

NS_ASSUME_NONNULL_BEGIN



@interface MSHTTPRequest : NSObject

/**
 
 通过封装好的网络层进行请求配 , 我目前的项目是这样做的,
 当然,不同的项目可以有不同的做法,没有最好的做法,只有最合适的做法,
 这仅仅是我抛砖引玉, 希望大家能各显神通.
 */

#pragma mark - 登陆退出
/** 登录*/
+ (void)GET:(NSString *)URL parameters:(id)parameters  cachePolicy:(MSCachePolicy)cachePolicy success:(MSHttpSuccess)success  failure:(MSHttpFail)failure;
/** 退出*/
+ (void)POST:(NSString *)URL parameters:(id)parameters cachePolicy:(MSCachePolicy)cachePolicy success:(MSHttpSuccess)success failure:(MSHttpFail)failure;

@end

NS_ASSUME_NONNULL_END
