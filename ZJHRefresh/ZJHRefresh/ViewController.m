//
//  ViewController.m
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "ViewController.h"
#import "ZJHRefreshView.h"
#import <Masonry/Masonry.h>
#import "SimpleStatusRefreshViewController.h"
#import "AnimatePercentRefreshViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, nullable) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpConstraints];
}
// 创建视图控件
- (void)setUpViews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    tableView.contentOffset = CGPointMake(0, -64);
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startRefresh:)];
    tableView.mj_header.backgroundColor = [UIColor redColor];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

// 设置控件约束关系
- (void)setUpConstraints{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)startRefresh:(MJRefreshNormalHeader *)view {
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView.mj_header endRefreshing];
    });
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *text = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
    if (indexPath.row == 0) {
        text = @"文本变化下拉刷新";
    } else if (indexPath.row == 1) {
        text = @"动画渐变下拉刷新";
    } else if (indexPath.row == 2) {
        text = @"修改contentInset.top=300";
    }
    cell.textLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self test0];
    } else if (indexPath.row == 1) {
        [self test1];
    } else if (indexPath.row == 2) {
        NSLog(@"修改前 top:%f", self.tableView.contentInset.top);
        self.tableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0);
        NSLog(@"修改后 top:%f", self.tableView.contentInset.top);
        self.tableView.contentOffset = CGPointMake(0, -300);
    }
}

- (void)test0 {
    UIViewController *vc = [[SimpleStatusRefreshViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)test1 {
    UIViewController *vc = [[AnimatePercentRefreshViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
