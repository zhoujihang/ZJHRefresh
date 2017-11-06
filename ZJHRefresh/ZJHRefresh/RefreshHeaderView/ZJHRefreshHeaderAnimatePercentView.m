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
@property (nonatomic, strong, nullable) UILabel *noMoreDataLabel;

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
    return 22 + 12;
}

- (void)overload_setupView {
    self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_animate_percent_loading"]];
    self.noMoreDataLabel = [[UILabel alloc] init];
    self.noMoreDataLabel.font = [UIFont systemFontOfSize:12];
    self.noMoreDataLabel.textColor = [UIColor blackColor];
    self.noMoreDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noMoreDataLabel.text = @"已无更多消息";
    self.noMoreDataLabel.hidden = YES;
    
    [self addSubview:self.imgView];
    [self addSubview:self.noMoreDataLabel];
    
    [self setupFrame];
}

- (void)setupFrame {
    CGSize size = self.bounds.size;
    self.isPercentAlpha = YES;
    self.imgView.frame = CGRectMake(ceilf((size.width-18)*0.5), ceilf(12+(size.height-12-18)*0.5), 18, 18);
    self.noMoreDataLabel.frame = CGRectMake(0, 12, [UIScreen mainScreen].bounds.size.width, 22);
}

- (void)overload_scrollViewDidChangeOffset:(CGPoint)offset pullPercent:(CGFloat)percent {
    CGFloat angle = 360.0*MAX(MIN(percent, 1), 0);
    if (self.status == ZJHRefreshHeaderViewStatusIdle) {
        self.imgView.transform = CGAffineTransformMakeRotation(M_PI*2*angle/360.0);
    } else if (self.status == ZJHRefreshHeaderViewStatusLoosenRefresh) {
        self.imgView.transform = CGAffineTransformMakeRotation(M_PI*2*360/360.0);
    }
}

- (void)overload_updateViewIdle {
    self.imgView.hidden = NO;
    self.noMoreDataLabel.hidden = YES;
}

- (void)overload_updateViewLoosenRefresh {
    self.imgView.hidden = NO;
    self.noMoreDataLabel.hidden = YES;
}

- (void)overload_updateViewOnRefresh {
    self.imgView.hidden = NO;
    self.noMoreDataLabel.hidden = YES;
    CABasicAnimation *anm = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anm.fromValue = @0;
    anm.toValue = @(M_PI);
    anm.duration = 0.25;
    anm.repeatCount = MAXFLOAT;
    anm.fillMode = kCAFillModeForwards;
    anm.removedOnCompletion = NO;
    anm.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.imgView.layer addAnimation:anm forKey:@"anm"];
}

- (void)overload_updateViewNoMoreData {
    self.imgView.hidden = YES;
    self.noMoreDataLabel.hidden = NO;
}
@end

