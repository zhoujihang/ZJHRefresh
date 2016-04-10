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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpConstraints];
    
}

// 创建视图控件
- (void)setUpViews{
    
    UIScrollView *backgroundScrollView = [[UIScrollView alloc] init];
    backgroundScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:backgroundScrollView];
    self.backgroundScrollView = backgroundScrollView;
    
    __weak typeof(self) weakSelf = self;
    self.backgroundScrollView.zjh_header = [ZJHRefreshHeader headerWithRefreshBlock:^{
        NSLog(@"开始刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"停止刷行");
            [weakSelf.backgroundScrollView.zjh_header endRefresh];
        });
    }];
    
}

// 设置控件约束关系
- (void)setUpConstraints{
    
    __weak typeof(self) weakSelf = self;
    [self.backgroundScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
    }];
    
}



@end
