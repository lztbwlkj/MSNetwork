//
//  ViewController.m
//  MSNetwork
//
//  Created by lztb on 2019/8/27.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "ViewController.h"
#import "MSNetwork.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MSNetwork openLog];
    
    [MSNetwork POST:@"http://39.98.98.194/cms/contentApp/getContentWithNum" parameters:[self setpramera:@{@"columnId":@"54156819b2bd4ca49fa18eb0736e2ee5",@"num":@"4"}] cachePolicy:MSCachePolicyNetworkOnly success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

-(id)setpramera:(id)pramer{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:pramer];
    [dic setObject:@{@"tokenId":@"",@"userId":@"",@"initDate":@"",@"clientType":@"mobilType",@"tokenKey":@""} forKey:@"accountToken"];
    return @{@"jsonStr":[self jsonToString:dic]};
}

/**
 *  json转字符串
 */
- (NSString *)jsonToString:(NSDictionary *)dic
{
    if(!dic){
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
