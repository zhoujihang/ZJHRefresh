//
//  ZJHRefreshHeader.m
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "ZJHRefreshHeader.h"
#import "UIView+ZJHExtension.h"
#import "UIScrollView+ZJHExtension.h"
#import <objc/message.h>

static NSString *const ZJHUIScrollViewContentOffsetKey = @"contentOffset";
const NSKeyValueObservingOptions ZJHObserveOptions = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;

@interface ZJHRefreshHeader()

@property (nonatomic, copy) ZJHRefreshBlock refreshBlock;
@property (nonatomic, weak) id refreshTarget;
@property (nonatomic, assign) SEL refreshAction;


@property (nonatomic, assign) ZJHRefreshState refreshState;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets scrollViewOriginContentInset;

// 下拉时的图片
@property (nonatomic, weak) UIImageView *stateImgView;
// 刷新时的图片
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
// 下拉时的状态文字
@property (nonatomic, weak) UILabel *stateTitleLabel;

// 不同状态下的标题
@property (nonatomic, strong) NSMutableDictionary *stateTitleMDic;

@end

@implementation ZJHRefreshHeader

+ (instancetype)headerWithRefreshBlock:(ZJHRefreshBlock)block{
    ZJHRefreshHeader *refreshView = [[self alloc] init];
    refreshView.refreshBlock = block;
    return refreshView;
}
+ (instancetype)headerWithRefreshTarget:(id)target action:(SEL)action{
    ZJHRefreshHeader *refreshView = [[self alloc] init];
    refreshView.refreshTarget = target;
    refreshView.refreshAction = action;
    return refreshView;
}
#pragma mark - 初始化方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
- (void)setUp{
    [self setUpViews];
    [self setUpData];
}
// 创建视图控件
- (void)setUpViews{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor cyanColor];
    self.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    
    UIImageView *titleImgView = [[UIImageView alloc] init];
    [self addSubview:titleImgView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.stateTitleLabel = titleLabel;
}
- (void)setUpData{
    
    self.refreshState = ZJHRefreshStateIdle;
}
// 加入到父控件或者从父控件中移除时会掉用此方法
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    // 从父控件移除时
    if (!newSuperview) {
        [self removeListener];
        return;
    }
    
    // 不是scrollview时 直接退出
    if (![newSuperview isKindOfClass:[UIScrollView class]]) {return;}
    
    if (newSuperview) {
        // 记录父控件信息 布局自己的位置
        self.scrollView = (UIScrollView *)newSuperview;
        self.scrollViewOriginContentInset = self.scrollView.contentInset;
        
        [self placeSelfPosition];
        
        [self setUpListener];
    }
}
- (void)setMoreInsetTopOffset:(CGFloat)moreInsetTopOffset{
    _moreInsetTopOffset = moreInsetTopOffset;
    
    [self placeSelfPosition];
}
#pragma mark - 布局子控件位置
- (void)placeSelfPosition{
    self.zjh_x = 0;
    self.zjh_y = -self.zjh_height-self.moreInsetTopOffset;
    self.zjh_width = self.scrollView.zjh_width;
}
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self placeSubviewsPosition];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self placeSubviewsPosition];
}
// 设置子控件的位置
- (void)placeSubviewsPosition{
    
    [self.stateTitleLabel sizeToFit];
    CGFloat titleWidth = self.stateTitleLabel.zjh_width;
    CGFloat activityWidth = self.activityIndicatorView.zjh_width;
    CGFloat stateImgWidth = self.stateImgView.zjh_width;
    CGFloat padding = 20;
    
    CGFloat totalWidthWithActivity = activityWidth + padding + titleWidth;
    CGFloat totalWidthWithStateImg = stateImgWidth + padding + titleWidth;
    
    CGFloat titleCenterXWithActivity = self.zjh_width/2 + (padding+activityWidth)/2;
    CGFloat titleCenterXWidthStateImg = self.zjh_width/2 + (padding+stateImgWidth)/2;
    CGFloat activityCenterX = self.zjh_width/2 - totalWidthWithActivity/2 + activityWidth/2;
    CGFloat stateImgCenterX = self.zjh_width/2 - totalWidthWithStateImg/2 + stateImgWidth/2;
    
    if (self.refreshState == ZJHRefreshStateOnRefresh) {
        // 正在刷新
        self.stateTitleLabel.center = CGPointMake(titleCenterXWithActivity, self.zjh_height/2);
    }else{
        // 没有刷新
        self.stateTitleLabel.center = CGPointMake(titleCenterXWidthStateImg, self.zjh_height/2);
    }
    self.activityIndicatorView.center = CGPointMake(activityCenterX, self.zjh_height/2);
    self.stateImgView.center = CGPointMake(stateImgCenterX, self.zjh_height/2);
}

#pragma mark - 逻辑方法
- (void)beginRefresh{
    self.refreshState = ZJHRefreshStateOnRefresh;
}
- (void)endRefresh{
    CGFloat originInsetT = self.scrollViewOriginContentInset.top;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.scrollView.zjh_insetT = originInsetT;
    } completion:^(BOOL finished) {
        weakSelf.refreshState = ZJHRefreshStateIdle;
    }];
}
- (void)setRefreshState:(ZJHRefreshState)refreshState{
    if (_refreshState == refreshState) {return;}
    _refreshState = refreshState;
    
    self.stateTitleLabel.text = self.stateTitleMDic[@(_refreshState)];
    
    if (_refreshState == ZJHRefreshStateIdle) {
        // 下拉刷新
        [self setRefreshStateToIdle];
    }else if(_refreshState == ZJHRefreshStateLoosenToRefresh){
        // 松开立即刷新
        [self setRefreshStateToLoosenToRefresh];
    }else if(_refreshState == ZJHRefreshStateOnRefresh){
        // 正在刷新
        [self setRefreshStateToOnRefresh];
    }
    [self setNeedsDisplay];
}
// 设置状态为空闲
- (void)setRefreshStateToIdle{
    [self.activityIndicatorView stopAnimating];
    self.stateImgView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.stateImgView.transform = CGAffineTransformMakeRotation(0);
    }];
}
// 设置为松开即可刷新
- (void)setRefreshStateToLoosenToRefresh{
    [self.activityIndicatorView stopAnimating];
    self.stateImgView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.stateImgView.transform = CGAffineTransformMakeRotation(-M_PI*2*179/360.0);
    }];
}
// 设置为正在刷行
- (void)setRefreshStateToOnRefresh{
    [self.activityIndicatorView startAnimating];
    self.stateImgView.hidden = YES;
    CGFloat newOffsetT = self.scrollViewOriginContentInset.top+self.zjh_height;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.scrollView.zjh_insetT = newOffsetT;
    }];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    if ([self.refreshTarget respondsToSelector:self.refreshAction]) {
        objc_msgSend(self.refreshTarget,self.refreshAction);
    }
}
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitleMDic{
    if (!_stateTitleMDic) {
        NSDictionary *dic = @{
                              @(ZJHRefreshStateIdle) : @"下拉可以刷新",
                              @(ZJHRefreshStateLoosenToRefresh) : @"松开立即刷新",
                              @(ZJHRefreshStateOnRefresh) : @"正在刷新数据"
                              };
        _stateTitleMDic = [dic mutableCopy];
    }
    return _stateTitleMDic;
}
- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        activityView.color = [UIColor grayColor];
        [activityView hidesWhenStopped];
        [activityView stopAnimating];
        [self addSubview:activityView];
        _activityIndicatorView = activityView;
    }
    return _activityIndicatorView;
}
- (UIImageView *)stateImgView{
    if (!_stateImgView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"arrow@2x.png"];
        [imgView sizeToFit];
        [self addSubview:imgView];
        _stateImgView = imgView;
    }
    return _stateImgView;
}
#pragma mark - 设置监听者
- (void)setUpListener{
    [self.scrollView addObserver:self forKeyPath:ZJHUIScrollViewContentOffsetKey options:ZJHObserveOptions context:nil];
}
- (void)removeListener{
    // 此处只能使用 superview，不能使用scrollview
    [self.superview removeObserver:self forKeyPath:ZJHUIScrollViewContentOffsetKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:ZJHUIScrollViewContentOffsetKey]) {
        [self scrollViewContentOffsetDidChange:change];
    }
    
}
#pragma mark - 处理监听事件
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    
    if (self.refreshState == ZJHRefreshStateOnRefresh) {
        // 正在刷新
        return;
    }
    
    // scrollview的inset随时可能变化，需要记录
    self.scrollViewOriginContentInset = self.scrollView.contentInset;
    
    CGPoint newOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGFloat offsetY = newOffset.y;
    
    // 即将刷新的偏移零界点
    CGFloat idle2refreshOffset = -self.scrollViewOriginContentInset.top-self.zjh_height;
    
    if (self.scrollView.isDragging) {           // 正在拖动
        if (offsetY>=idle2refreshOffset) {
            self.refreshState = ZJHRefreshStateIdle;
        }else if(offsetY<idle2refreshOffset){
            self.refreshState = ZJHRefreshStateLoosenToRefresh;
        }
    }else{
        if(self.refreshState == ZJHRefreshStateLoosenToRefresh){
            // 松开就会刷新
            self.refreshState = ZJHRefreshStateOnRefresh;
        }
    }
}


@end
