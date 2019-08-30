//
//  DemoModel.m
//  MSNetwork
//
//  Created by lztb on 2019/8/30.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "DemoModel.h"

@implementation Info

@end
@implementation Top_cmt

@end
@implementation Themes

@end
@implementation List
+ (NSDictionary *)modelCustomPropertyMapper {
    // 将personId映射到key为id的数据字段
    return @{@"ID":@"id"};
    // 映射可以设定多个映射字段
    //  return @{@"personId":@[@"id",@"uid",@"ID"]};
}

@end

@implementation DemoModel
// 声明自定义类参数类型
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value使用[List class]或List.class或@"List"没有区别
    return @{@"list" : [List class]};
}
@end
