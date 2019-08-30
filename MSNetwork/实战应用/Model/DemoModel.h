//
//  DemoModel.h
//  MSNetwork
//
//  Created by lztb on 2019/8/30.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Info :NSObject
@property (nonatomic , copy) NSString              * maxid;
@property (nonatomic , copy) NSString              * vendor;
@property (nonatomic , copy) NSString              * count;
@property (nonatomic , copy) NSString              * maxtime;
@property (nonatomic , copy) NSString              * page;

@end

@interface Top_cmt :NSObject

@end

@interface Themes :NSObject

@end

@interface List :NSObject
@property (nonatomic , copy) NSString              * cache_version;
@property (nonatomic , copy) NSString              * created_at;
@property (nonatomic , copy) NSString              * ID;
@property (nonatomic , copy) NSString              * voicetime;
@property (nonatomic , copy) NSString              * voicelength;
@property (nonatomic , copy) NSArray<Top_cmt *>              * top_cmt;
@property (nonatomic , copy) NSString              * repost;
@property (nonatomic , copy) NSString              * bimageuri;
@property (nonatomic , copy) NSString              * text;
@property (nonatomic , copy) NSString              * theme_type;
@property (nonatomic , copy) NSString              * hate;
@property (nonatomic , copy) NSString              * ding;
@property (nonatomic , copy) NSString              * comment;
@property (nonatomic , copy) NSString              * passtime;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * tag;
@property (nonatomic , copy) NSString              * theme_name;
@property (nonatomic , copy) NSString              * create_time;
@property (nonatomic , copy) NSString              * favourite;
@property (nonatomic , copy) NSArray<Themes *>              * themes;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * height;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              * videotime;
@property (nonatomic , copy) NSString              * bookmark;
@property (nonatomic , copy) NSString              * cai;
@property (nonatomic , copy) NSString              * profile_image;
@property (nonatomic , copy) NSString              * love;
@property (nonatomic , copy) NSString              * original_pid;
@property (nonatomic , copy) NSString              * user_id;
@property (nonatomic , copy) NSString              * screen_name;
@property (nonatomic , copy) NSString              * t;
@property (nonatomic , copy) NSString              * theme_id;
@property (nonatomic , copy) NSString              * weixin_url;
@property (nonatomic , copy) NSString              * voiceuri;
@property (nonatomic , copy) NSString              * videouri;
@property (nonatomic , copy) NSString              * width;

@end

@interface DemoModel :NSObject
@property (nonatomic , strong) Info              * info;
@property (nonatomic , copy) NSArray<List *>              * list;

@end


NS_ASSUME_NONNULL_END
