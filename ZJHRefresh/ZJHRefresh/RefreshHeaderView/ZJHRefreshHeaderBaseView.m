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

@property (nonatomic, weak, nullable, readwrite) UIScrollView *scrollView; // 父控件
@property (nonatomic, assign) UIEdgeInsets originInset;         // scrollview原始contentInset

@property (nonatomic, assign) CGFloat viewHeight;    // 视图高度

@property (nonatomic, assign, readwrite) ZJHRefreshHeaderViewStatus status;
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
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, [self refreshingLimitOffsetY]);
    } completion:^(BOOL finished) {
        [weakSelf updateNewRefreshStatus:ZJHRefreshHeaderViewStatusOnRefresh];
        [self updateAlpha:1];
    }];
}

- (void)endRefresh {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentInset = self.originInset;
        self.alpha = self.isPercentAlpha ? 0 : 1;
    } completion:^(BOOL finished) {
        [weakSelf updateNewRefreshStatus:ZJHRefreshHeaderViewStatusIdle];
        [self updateAlpha:0];
    }];
}

#pragma mark - 初始化控件和数据
- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
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
    return -(self.originInset.top + self.viewHeight + self.bottomMargin);
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
            self.status = ZJHRefreshHeaderViewStatusIdle;
            [self overload_updateViewIdle];
        } break;
        case ZJHRefreshHeaderViewStatusLoosenRefresh: {
            self.status = ZJHRefreshHeaderViewStatusLoosenRefresh;
            [self overload_updateViewLoosenRefresh];
        } break;
        case ZJHRefreshHeaderViewStatusOnRefresh: {
            self.status = ZJHRefreshHeaderViewStatusOnRefresh;
            [self overload_updateViewOnRefresh];
            [UIView animateWithDuration:0.25 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(ABS([self refreshingLimitOffsetY]), 0, 0, 0);
            }];
            if (self.refreshBlock) {
                self.refreshBlock(self);
            }
            if ([self.refreshTarget respondsToSelector:self.refreshAction]) {
                objc_msgSend(self.refreshTarget,self.refreshAction);
            }
        } break;
    }
    [self overload_updateSubviewFrame];
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
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)removeListener {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"contentOffset"]) {return;}
    if (self.scrollView == nil) {return;}
    if (self.status == ZJHRefreshHeaderViewStatusOnRefresh) {return;}
    
    CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGFloat offsetY = offset.y;
    CGFloat refreshingLimitOffsetY = [self refreshingLimitOffsetY];
    
    CGFloat pullLength = ABS(MIN(offsetY + self.originInset.top, 0)); // 下拉距离
    CGFloat pullPercent = pullLength / ABS(self.viewHeight + self.bottomMargin); // 下拉距离到视图顶部的百分比(触发立即刷新状态的百分比)
    
    
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
    [self updateAlpha:pullPercent];
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

@end