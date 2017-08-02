//
//  ZJHRefreshHeaderSimpleStatusView.m
//  ZJHRefresh
//
//  Created by 周际航 on 2017/8/1.
//  Copyright © 2017年 zjh. All rights reserved.
//

#import "ZJHRefreshHeaderSimpleStatusView.h"

@interface ZJHRefreshHeaderSimpleStatusView ()

@property (nonatomic, strong, nullable) UIImageView *arrowImgView;
@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIActivityIndicatorView *indicatorView;

@end

@implementation ZJHRefreshHeaderSimpleStatusView

- (NSMutableDictionary *)titleMDic{
    if (!_titleMDic) {
        NSDictionary *dic = @{
                              @(ZJHRefreshHeaderViewStatusIdle) : @"下拉可以刷新",
                              @(ZJHRefreshHeaderViewStatusLoosenRefresh) : @"立即刷新",
                              @(ZJHRefreshHeaderViewStatusOnRefresh) : @"正在刷新"
                              };
        _titleMDic = [dic mutableCopy];
    }
    return _titleMDic;
}

- (CGFloat)overload_viewHeight {
    return 60;
}

- (void)overload_setupView {
    self.backgroundColor = [UIColor cyanColor];
    self.arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_blackArrow_down"]];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor blackColor];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicatorView.color = [UIColor grayColor];
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView stopAnimating];
    
    [self addSubview:self.arrowImgView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.indicatorView];
}

- (void)overload_updateSubviewFrame {
    CGSize size = self.bounds.size;
    NSString *text = self.titleLabel.text;
    CGSize textSize = [text boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:NULL].size;
    
    CGFloat arrowImgViewX = ceilf((size.width-(15+10+textSize.width))*0.5);
    CGFloat arrowImgViewY = ceilf((size.height-40)*0.5);
    CGFloat titleX = arrowImgViewX+15+10;
    CGFloat titleY = ceilf((size.height-textSize.height)*0.5);
    
    self.arrowImgView.frame = CGRectMake(arrowImgViewX, arrowImgViewY, 15, 40);
    self.titleLabel.frame = CGRectMake(titleX, titleY, ceilf(textSize.width), ceilf(textSize.height));
    self.indicatorView.center = CGPointMake(ceilf(size.width * 0.5), ceilf(size.height*0.5));
}

- (void)overload_updateViewIdle {
    self.titleLabel.text = self.titleMDic[@(ZJHRefreshHeaderViewStatusIdle)];
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImgView.transform = CGAffineTransformMakeRotation(0);
    }];
    [self.indicatorView stopAnimating];
    
    self.titleLabel.hidden = NO;
    self.arrowImgView.hidden = NO;
}

- (void)overload_updateViewLoosenRefresh {
    self.titleLabel.text = self.titleMDic[@(ZJHRefreshHeaderViewStatusLoosenRefresh)];
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImgView.transform = CGAffineTransformMakeRotation(-M_PI*2*179/360.0);
    }];
    [self.indicatorView stopAnimating];
    
    self.titleLabel.hidden = NO;
    self.arrowImgView.hidden = NO;
}

- (void)overload_updateViewOnRefresh {
    self.titleLabel.text = self.titleMDic[@(ZJHRefreshHeaderViewStatusOnRefresh)];
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImgView.transform = CGAffineTransformMakeRotation(0);
    }];
    [self.indicatorView startAnimating];
    
    self.titleLabel.hidden = YES;
    self.arrowImgView.hidden = YES;
}



@end
