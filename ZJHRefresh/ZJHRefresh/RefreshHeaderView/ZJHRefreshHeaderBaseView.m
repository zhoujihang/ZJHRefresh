//
//  ZJHRefreshHeaderBaseView.m
//  Mara
//
//  Created by 周际航 on 2017/8/1.
//  Copyright © 2017年 com.maramara. All rights reserved.
//

#import "ZJHRefreshHeaderBaseView.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIScrollView (ZJHRefreshHeaderBaseView)

static const char ZJHRefreshHeaderBaseViewKey;
- (ZJHRefreshHeaderBaseView *)zjh_header{
    return objc_getAssociatedObject(self, &ZJHRefreshHeaderBaseViewKey);
}
- (void)setZjh_header:(ZJHRefreshHeaderBaseView *)zjh_header{
    
    if (self.zjh_header != zjh_header) {
        [self.zjh_header removeFromSuperview];
        [self insertSubview:zjh_header atIndex:0];
        
        [self willChangeValueForKey:@"zjh_header"];
        objc_setAssociatedObject(self, &ZJHRefreshHeaderBaseViewKey, zjh_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"zjh_header"];
    }
}
@end

@interface ZJHRefreshHeaderBaseView ()

@property (nonatomic, weak, nullable, readwrite) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets originInset;
@property (nonatomic, assign) UIEdgeInsets originAdjustedContentInset;
@property (nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, assign, readwrite) ZJHRefreshHeaderViewStatus status;
@property (nonatomic, assign) BOOL isOriginInsetIgnoreChange; // 为yes时，originInset不需要同步scrollView.contentInset的值

@property (nonatomic, copy, nullable) ZJHRefreshHeaderViewRefreshingBlock refreshBlock;
@property (nonatomic, weak) id refreshTarget;
@property (nonatomic, assign) SEL refreshAction;
@end

@implementation ZJHRefreshHeaderBaseView

+ (instancetype)headerWithRefreshBlock:(ZJHRefreshHeaderViewRefreshingBlock)block {
    ZJHRefreshHeaderBaseView *view = [[self alloc] init];
    view.refreshBlock = block;
    return view;
}
+ (instancetype)headerWithRefreshTarget:(id)target action:(SEL)action{
    ZJHRefreshHeaderBaseView *view = [[self alloc] init];
    view.refreshTarget = target;
    view.refreshAction = action;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self removeListener];
}

- (void)beginRefresh {
    if (self.isNoMoreData) {return;}
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, [self refreshingLimitOffsetY]);
    } completion:^(BOOL finished) {
        if (weakSelf.isNoMoreData) {return;}
        [weakSelf updateNewRefreshStatus:ZJHRefreshHeaderViewStatusOnRefresh];
        [self updateAlpha:1];
    }];
}

- (void)endRefresh {
    if (self.isNoMoreData) {return;}
    __weak typeof (self) weakSelf = self;
    CGFloat alpha = self.isPercentAlpha ? 0 : 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentInset = self.originInset;
        self.alpha = alpha;
    } completion:^(BOOL finished) {
        if (weakSelf.isNoMoreData) {return;}
        [weakSelf updateNewRefreshStatus:ZJHRefreshHeaderViewStatusIdle];
        [self updateAlpha:alpha];
    }];
}
- (void)setIsNoMoreData:(BOOL)isNoMoreData {
    _isNoMoreData = isNoMoreData;
    CGFloat alpha = self.isPercentAlpha ? 0 : 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentInset = self.originInset;
        [self updateAlpha:alpha];
        if (self.isNoMoreData) {
            [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusNoMoreData];
        } else {
            [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusIdle];
        }
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - 初始化控件和数据
- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    self.isOriginInsetIgnoreChange = NO;
    self.isPercentAlpha = NO;
    self.viewHeight = [self overload_viewHeight];
    [self sizeToFit];
    [self overload_setupView];
    [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusIdle];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        [self removeListener];
        return;
    }
    if (![newSuperview isKindOfClass:[UIScrollView class]]) {return;}
    
    UIScrollView *superScrollView = (UIScrollView *)newSuperview;
    self.scrollView = superScrollView;
    self.originInset = superScrollView.contentInset;
    self.originAdjustedContentInset = superScrollView.contentInset;
    if (@available(iOS 11.0, *)) {
        self.originAdjustedContentInset = superScrollView.adjustedContentInset;
    }
    
    [self setupViewFrame];
    [self setupListener];
}

/** 设置自己的位置 */
- (void)setupViewFrame {
    if (self.scrollView == nil) {return;}
    [self sizeToFit];
    CGFloat originY = -self.frame.size.height - self.bottomMargin;
    CGFloat width = self.scrollView.frame.size.width;
    self.frame = CGRectMake(0, originY, width, self.viewHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self overload_updateSubviewFrame];
}

// 刷新临界点
- (CGFloat)refreshingLimitOffsetY {
    return -(self.originAdjustedContentInset.top + self.viewHeight + self.bottomMargin);
}

#pragma mark - 内容宽高
- (CGSize)sizeThatFits:(CGSize)size {
    return self.intrinsicContentSize;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, self.viewHeight);
}

#pragma mark - 状态修改
- (void)updateNewRefreshStatus:(ZJHRefreshHeaderViewStatus) newStatus {
    if (self.status == newStatus) {return;}
    switch (newStatus) {
        case ZJHRefreshHeaderViewStatusIdle: {
            [self updateRefreshStatusToIdle];
        } break;
        case ZJHRefreshHeaderViewStatusLoosenRefresh: {
            [self updateRefreshStatusToLoosenRefresh];
        } break;
        case ZJHRefreshHeaderViewStatusOnRefresh: {
            [self updateRefreshStatusToOnRefresh];
        } break;
        case ZJHRefreshHeaderViewStatusNoMoreData: {
            [self updateRefreshStatusToNoMoreData];
        } break;
    }
    [self overload_updateSubviewFrame];
}
- (void)updateRefreshStatusToIdle {
    self.status = ZJHRefreshHeaderViewStatusIdle;
    [self overload_updateViewIdle];
}
- (void)updateRefreshStatusToLoosenRefresh {
    self.status = ZJHRefreshHeaderViewStatusLoosenRefresh;
    [self overload_updateViewLoosenRefresh];
}
- (void)updateRefreshStatusToOnRefresh {
    self.status = ZJHRefreshHeaderViewStatusOnRefresh;
    [self overload_updateViewOnRefresh];
    [UIView animateWithDuration:0.25 animations:^{
        self.isOriginInsetIgnoreChange = YES;
        CGFloat newContentInsetTop = self.originInset.top + self.viewHeight + self.bottomMargin;
        self.scrollView.contentInset = UIEdgeInsetsMake(newContentInsetTop, 0, 0, 0);
        self.isOriginInsetIgnoreChange = NO;
    }];
    if (self.refreshBlock) {
        self.refreshBlock(self);
    }
    if ([self.refreshTarget respondsToSelector:self.refreshAction]) {
        objc_msgSend(self.refreshTarget, self.refreshAction, self);
    }
}
- (void)updateRefreshStatusToNoMoreData {
    self.status = ZJHRefreshHeaderViewStatusNoMoreData;
    [self overload_updateViewNoMoreData];
}
- (void)updateAlpha:(CGFloat)percent {
    if (!self.isPercentAlpha) {return;}
    self.alpha = MAX(MIN(percent, 1), 0);
}

#pragma mark - 监听者
- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    [self setupViewFrame];
}

- (void)setupListener {
    [self removeListener];
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"safeAreaInsets" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
}

- (void)removeListener {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self forKeyPath:@"contentInset"];
    [self.superview removeObserver:self forKeyPath:@"safeAreaInsets"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.scrollView == nil) {return;}
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        [self scrollViewContentOffsetDidChange:offset];
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        [self scrollViewContentInsetDidChange];
    } else if ([keyPath isEqualToString:@"safeAreaInsets"]) {
        [self scrollViewContentInsetDidChange];
    }
}
- (void)scrollViewContentInsetDidChange {
    if (self.isOriginInsetIgnoreChange) {return;}
    self.originInset = self.scrollView.contentInset;
    self.originAdjustedContentInset = self.scrollView.contentInset;
    if (@available(iOS 11.0, *)) {
        self.originAdjustedContentInset = self.scrollView.adjustedContentInset;
    }
}
- (void)scrollViewContentOffsetDidChange:(CGPoint)offset {
    if (self.status == ZJHRefreshHeaderViewStatusOnRefresh) {return;}
    CGFloat offsetY = offset.y;
    CGFloat refreshingLimitOffsetY = [self refreshingLimitOffsetY];
    CGFloat insetTop = self.originAdjustedContentInset.top;
    CGFloat pullLength = ABS(MIN(offsetY + insetTop, 0)); // 下拉距离
    CGFloat pullPercent = pullLength / ABS(self.viewHeight + self.bottomMargin); // 下拉距离到视图顶部的百分比(触发立即刷新状态的百分比)
    
    [self updateAlpha:pullPercent];
    if (self.isNoMoreData == YES) {return;}
    if (self.scrollView.isDragging) {
        if (offsetY >= refreshingLimitOffsetY) {
            // 进入下拉可刷新状态
            [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusIdle];
        } else {
            // 进入松开立即刷新状态
            [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusLoosenRefresh];
        }
    } else {
        if (self.status == ZJHRefreshHeaderViewStatusLoosenRefresh) {
            // 进入正在刷新状态
            [self updateNewRefreshStatus:ZJHRefreshHeaderViewStatusOnRefresh];
        }
    }
    [self overload_scrollViewDidChangeOffset:offset pullPercent:pullPercent];
}

#pragma mark - 子类可以重载的方法
/** 返回视图高度 */
- (CGFloat)overload_viewHeight {
    return 40;
}
/** 创建子控件 */
- (void)overload_setupView {
    
}
/** 设置子控件位置，layoutSubviews 中会调用多次 */
- (void)overload_updateSubviewFrame {
    
}
/** 下拉偏移量和偏移百分比 */
- (void)overload_scrollViewDidChangeOffset:(CGPoint)offset pullPercent:(CGFloat)percent {
    
}
/** 更新视图 下拉可刷新状态 */
- (void)overload_updateViewIdle {
    
}
/** 更新视图 松手立即刷新状态 */
- (void)overload_updateViewLoosenRefresh {
    
}
/** 更新视图 正在刷新状态 */
- (void)overload_updateViewOnRefresh {
    
}
/** 更新视图 设置了当前无更多数据 */
- (void)overload_updateViewNoMoreData {
    
}

@end
