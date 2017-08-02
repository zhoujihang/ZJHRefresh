//
//  AnimatePercentRefreshViewController.m
//  ZJHRefresh
//
//  Created by 周际航 on 2017/8/1.
//  Copyright © 2017年 zjh. All rights reserved.
//

#import "AnimatePercentRefreshViewController.h"
#import "ZJHRefreshView.h"
#import <Masonry/Masonry.h>
@interface AnimatePercentRefreshViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, nullable) UITableView *tableView;

@end

@implementation AnimatePercentRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpConstraints];
}
// 创建视图控件
- (void)setUpViews{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(164, 0, 0, 0);
    tableView.contentOffset = CGPointMake(0, -164);
    tableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.tableView.zjh_header = [ZJHRefreshHeaderAnimatePercentView headerWithRefreshTarget:self action:@selector(startRefresh)];
    self.tableView.zjh_header.isPercentAlpha = YES;
    self.tableView.zjh_header.bottomMargin = 0;
}

// 设置控件约束关系
- (void)setUpConstraints{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)startRefresh {
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView.zjh_header endRefresh];
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
        text = @"立即刷新";
    } else if (indexPath.row == 1) {
        text = @"修改contentInset.top 为 300";
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
        [self.tableView.zjh_header beginRefresh];
    } else if (indexPath.row == 1) {
        self.tableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, -300);
        NSLog(@"修改contentInset top：%f", self.tableView.contentInset.top);
    } else {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
