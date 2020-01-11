//
//  ViewController.m
//  MSNetwork
//
//  Created by lztb on 2019/8/27.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "ViewController.h"
#import "ReqViewController.h"
#import "DemoViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, copy) NSMutableArray *dataSource;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *arr = self.dataSource[indexPath.section];
    cell.textLabel.text = arr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        ReqViewController *vc = [[ReqViewController alloc] init];
        vc.method = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }else if (indexPath.section == 1){
        DemoViewController *vc = [[DemoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@[@"GET",@"POST",@"HEAD",@"PUT",@"PATCH",@"DELETE"],@[@"实战应用"]].mutableCopy;
    }
    return _dataSource;
}


@end
