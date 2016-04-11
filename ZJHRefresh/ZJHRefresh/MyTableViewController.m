//
//  MyTableViewController.m
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/11.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "MyTableViewController.h"
#import "ZJHRefresh.h"
@interface MyTableViewController ()

@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpViews];
}

// 创建视图控件
- (void)setUpViews{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
    
    __weak typeof(self) weakSelf = self;
    ZJHRefreshHeader *header = [ZJHRefreshHeader headerWithRefreshBlock:^{
        NSLog(@"开始刷新2");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"停止刷行2");
            [weakSelf.tableView.zjh_header endRefresh];
        });
    }];
    header.moreInsetTopOffset = 16;
    self.tableView.zjh_header = header;

}


#pragma mark - tableview代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld,%ld",(long)indexPath.section,(long)indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"tap:%@",indexPath);
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.navigationItem.title = [NSString stringWithFormat:@"%ld,%ld",(long)indexPath.section,(long)indexPath.row];
//    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc{
    NSLog(@"zjh %s",__func__);
}
@end
