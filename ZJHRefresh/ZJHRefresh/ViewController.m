//
//  ViewController.m
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "ViewController.h"
#import "ZJHRefresh.h"
#import <Masonry/Masonry.h>
@interface ViewController ()

@property (nonatomic, weak) UIScrollView *backgroundScrollView;

@property (nonatomic, weak) UIView *topView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpConstraints];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"zjh contentSize:%@",NSStringFromCGSize(self.backgroundScrollView.contentSize));
}
// 创建视图控件
- (void)setUpViews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *backgroundScrollView = [[UIScrollView alloc] init];
    backgroundScrollView.contentInset = UIEdgeInsetsMake(84, 0, 0, 0);
    backgroundScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:backgroundScrollView];
    self.backgroundScrollView = backgroundScrollView;
    
    __weak typeof(self) weakSelf = self;
    ZJHRefreshHeader *header = [ZJHRefreshHeader headerWithRefreshBlock:^{
        NSLog(@"开始刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"停止刷行");
            [weakSelf.backgroundScrollView.zjh_header endRefresh];
        });
    }];
    header.moreInsetTopOffset = 20;
    self.backgroundScrollView.zjh_header = header;
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor greenColor];
    [self.backgroundScrollView addSubview:topView];
    self.topView = topView;
    
}

// 设置控件约束关系
- (void)setUpConstraints{
    
    __weak typeof(self) weakSelf = self;
    [self.backgroundScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakSelf.backgroundScrollView);
        make.height.equalTo(@(44));
        make.centerX.equalTo(weakSelf.backgroundScrollView);
    }];
    
}



@end
