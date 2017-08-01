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
    NSLog(@"开始刷新");
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"刷新完成");
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
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
    [self.tableView.zjh_header beginRefresh];
}

@end
