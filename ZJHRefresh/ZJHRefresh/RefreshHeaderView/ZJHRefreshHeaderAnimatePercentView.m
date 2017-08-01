//
//  ZJHRefreshHeaderAnimatePercentView.m
//  ZJHRefresh
//
//  Created by 周际航 on 2017/8/1.
//  Copyright © 2017年 zjh. All rights reserved.
//

#import "ZJHRefreshHeaderAnimatePercentView.h"

@interface ZJHRefreshHeaderAnimatePercentView ()

@property (nonatomic, strong, nullable) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZJHRefreshHeaderAnimatePercentView

- (void)endRefresh {
    [super endRefresh];
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.imgView.layer removeAllAnimations];
    });
}

- (CGFloat)overload_viewHeight {
    return 60;
}

- (void)overload_setupView {
    self.backgroundColor = [UIColor cyanColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = @"没有更多数据";
    
    self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_animate_percent_loading"]];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.imgView];

    [self setupFrame];
}

- (void)setupFrame {
    CGSize size = self.bounds.size;
    self.imgView.frame = CGRectMake(ceilf((size.width-18)*0.5), ceilf((size.height-18)*0.5), 18, 18);
    self.titleLabel.frame = self.bounds;
}

- (void)overload_updateViewIdle {
    self.titleLabel.hidden = YES;
    self.imgView.hidden = NO;
}

- (void)overload_updateViewLoosenRefresh {
    self.titleLabel.hidden = YES;
    self.imgView.hidden = NO;
}

- (void)overload_updateViewOnRefresh {
    self.titleLabel.hidden = YES;
    self.imgView.hidden = NO;
    
    CABasicAnimation *anm = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anm.fromValue = @0;
    anm.toValue = @(M_PI);
    anm.duration = 0.25;
    anm.repeatCount = CGFLOAT_MAX;
    anm.fillMode = kCAFillModeForwards;
    anm.removedOnCompletion = NO;
    anm.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.imgView.layer addAnimation:anm forKey:@"anm"];
}

- (void)overload_updateViewNoMore {
    self.titleLabel.hidden = NO;
    self.imgView.hidden = YES;
}

- (void)overload_scrollViewDidChangeOffset:(CGPoint)offset pullPercent:(CGFloat)percent {
    CGFloat angle = 360.0*MAX(MIN(percent, 1), 0);
    if (self.status == ZJHRefreshHeaderViewStatusIdle) {
        self.imgView.transform = CGAffineTransformMakeRotation(M_PI*2*angle/360.0);
    } else if (self.status == ZJHRefreshHeaderViewStatusLoosenRefresh) {
        self.imgView.transform = CGAffineTransformMakeRotation(M_PI*2*360/360.0);
    }
}

@end
