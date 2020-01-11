//
//  ReqViewController.m
//  MSNetwork
//
//  Created by lztb on 2019/8/29.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "ReqViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ReqViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusDesc;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextView *pramet;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *cacheDesc;

@property(nonatomic, assign) MSCachePolicy cachePolicy;
@property(nonatomic, assign) int blockSuccessCount;

@end

@implementation ReqViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.blockSuccessCount = 0;
    
    NSLog(@"网络缓存大小cache = %fKB",[MSNetwork getAllHttpCacheSize]/1024.f);
    
    self.cacheDesc.text = [self getCacheStr:_cachePolicy];
    
    //开启控制台log
    //[MSNetwork openLog];

    //网络状态
    __weak __typeof(&*self)weakSelf = self;
    [MSNetwork networkStatusWithBlock:^(MSNetworkStatusType status) {
        weakSelf.statusDesc.text = [NSString stringWithFormat:@"当前网络:%@",[weakSelf getStateStr:status]];
    }];
    
    /*
     * 一次性获取当前网络状态
     这里延时0.1s再执行是因为程序刚刚启动,可能相关的网络服务还没有初始化完成(也有可能是AFN的BUG),
     导致此demo检测的网络状态不正确,这仅仅只是为了演示demo的功能性, 在实际使用中可直接使用一次性网络判断,不用延时
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getCurrentNetworkStatus];
    });
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载文件" style:UIBarButtonItemStylePlain target:self action:@selector(downLoadFiles)];
}

#pragma mark - 一次性获取当前最新网络状态
- (void)getCurrentNetworkStatus
{
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
}


//下载文件
- (void)downLoadFiles {
    MBProgressHUD *hud = [MBProgressHUD mb_showBar:@"正在下载..." detailMsg:@"请不要退出程序,以免下载失败！" onView:nil hideBlock:^{
        NSLog(@"hud已经隐藏");
    }];
    
    [MSNetwork downloadWithURL:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4" fileDir:@"Download" progress:^(NSProgress * _Nonnull progress) {
        CGFloat stauts = 100.f * progress.completedUnitCount/progress.totalUnitCount;
        CGFloat pro = stauts/100.f;
        
        NSLog(@"pro = %.2f",pro);
        hud.progress = pro;
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


- (IBAction)reqMethodClick:(UISegmentedControl *)sender {
    _cachePolicy = sender.selectedSegmentIndex;
    self.cacheDesc.text = [self getCacheStr:_cachePolicy];
}

- (IBAction)reqClick:(UIButton *)sender {
    self.blockSuccessCount = 0;
    
    sender.enabled = NO;
    //默认参数在AppDelegaate.m中，该接口需要以参数jsonStr为固定键，值为字符串的字典类型
    //强烈建议在该方法上再封装一次自己公司接口的请求参数配置和请求方式
    __weak __typeof(&*self)weakSelf = self;
    NSDictionary *para = @{ @"a":@"list", @"c":@"data",@"client":@"iphone",@"page":@"0",@"per":@"10", @"type":@"29"};
    NSLog(@"parameters = %@",[self jsonToString:para]);
//    [MSNetwork setValue:@"9" forHTTPHeaderField:@"fromType"];
//    [MSNetwork setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [MSNetwork setBaseURL:@"https://www.easy-mock.com/mock/5cac59ca8c8da20d0362099d/example"];
    [MSNetwork setBaseURL:@"http://192.168.10.58:8080/"];
//    [MSNetwork setResponseSerializer:MSResponseSerializerHTTP];
//    NSDictionary *parameters = [self dictionaryWithJsonString:_pramet.text];
    [MSNetwork HTTPWithMethod:self.method url:@"testPut" parameters:@{@"type":@"100",@"pageSize":@"10",@"page":@"1"} cachePolicy:self.cachePolicy success:^(id  _Nonnull responseObject) {
        sender.enabled = YES;
        weakSelf.contentView.text = [NSString stringWithFormat:@"%@",responseObject];
        NSLog(@"block调用次数 %d",self.blockSuccessCount++);
    } failure:^(NSError * _Nonnull error) {
        sender.enabled = YES;
        [MBProgressHUD mb_showMidMessage:[error localizedDescription] onView:nil hideBlock:nil];
        weakSelf.contentView.text = [error localizedDescription];
    }];
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer.timeoutInterval = 30.f;
////    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager PUT:@"https://www.easy-mock.com/mock/5cac59ca8c8da20d0362099d/example/service/dabaojian" parameters:@{@"name":@"ceshi"} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        // 1.先加载缓存数据
//        weakSelf.contentView.text = [NSString stringWithFormat:@"%@",responseObject];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        weakSelf.contentView.text = [error localizedDescription];
//
//    }];
    
 
//    [MSNetwork uploadImageURL:@"" parameters:@{} images:@[] name:@"" fileName:@"" imageScale:0.5 imageType:@"" progress:^(NSProgress * _Nonnull progress) {
//        //上传进度
//        NSLog(@"上传进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
//
//    } success:^(id  _Nonnull responseObject) {
//        //上传成功
//
//    } failure:^(NSError * _Nonnull error) {
//        //上传失败
//
//    }];
    

 
}

- (IBAction)cancel:(UIButton *)sender {
    [MSNetwork cancelRequestWithURL:_urlTextField.text];
}

- (IBAction)clearUpClick:(UIButton *)sender {
    _contentView.text = @"";
}


- (IBAction)clearCacheClick:(UIButton *)sender {
    sender.enabled = NO;
    __weak __typeof(&*self)weakSelf = self;
    [MSNetwork removeAllHttpCacheBlock:^(int removedCount, int totalCount) {
        NSLog(@"cache progress = %d",removedCount/totalCount);
    } endBlock:^(BOOL error) {
        if (error) {
            NSLog(@"cache清理出错");
            return ;
        }
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            weakSelf.contentView.text = @"";
        });
    }];
}


/**获取网络状态*/
- (NSString *)getStateStr:(MSNetworkStatusType)status {
    switch (status) {
        case MSNetworkStatusUnknown:
            return @"未知网络";
            break;
        case MSNetworkStatusNotReachable:
            return @"无网路";
            break;
        case MSNetworkStatusReachableWWAN:
            return @"手机网络";
            break;
        case MSNetworkStatusReachableWiFi:
            return @"WiFi网络";
            break;
        default:
            break;
    }
}
/**获取网络状态*/
- (NSString *)getCacheStr:(MSCachePolicy)cache {
    switch (self.cachePolicy) {
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
  
}


#pragma mark - 私有方法
/**
 *  json转字符串
 */
- (NSString *)jsonToString:(NSDictionary *)dic{
    if(!dic){
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
