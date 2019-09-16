//
//  DemoViewController.m
//  MSNetwork
//
//  Created by lztb on 2019/8/30.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "DemoViewController.h"

#import "DemoModel.h"

@interface DemoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, copy) NSMutableArray *dataSource;

@end

@implementation DemoViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"实战应用";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestDemo)];

    [self tableViewConfigration];
    
    [self requestDemo];
}

- (void)tableViewConfigration {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)requestDemo{
    /**
     通过封装好的网络层进行请求配 , 我目前的项目是这样做的,在MSHTTPRequest文件夹中可以看到
     当然,不同的项目可以有不同的做法,没有最好的做法,只有最合适的做法,
     这仅仅是我抛砖引玉, 希望大家能各显神通.
     */
    
    __weak __typeof(&*self)weakSelf = self;
    
    NSDictionary *para = @{@"a":@"list", @"c":@"data",@"client":@"iphone",@"page":@"0",@"per":@"10", @"type":@"29"};
    [MSHTTPRequest POST:@"" parameters:para cachePolicy:MSCachePolicyCacheThenNet success:^(id  _Nonnull responseObject) {
        if (weakSelf.dataSource.count>0){
            [weakSelf.dataSource removeAllObjects];
        }
        
        DemoModel *model = [DemoModel modelWithDictionary:responseObject];
        
        for (List *list in model.list) {
            [weakSelf.dataSource addObject:list];
        }
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD mb_showMidMessage:[error localizedDescription] onView:nil hideBlock:nil];
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    List *listModel = self.dataSource[indexPath.row];
    
    cell.textLabel.text = listModel.text;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

@end
