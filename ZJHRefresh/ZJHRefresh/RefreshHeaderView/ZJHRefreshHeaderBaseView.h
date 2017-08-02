//
//  ZJHRefreshHeaderBaseView.h
//  Mara
//
//  Created by 周际航 on 2017/8/1.
//  Copyright © 2017年 com.maramara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJHRefreshHeaderBaseView;

typedef void(^ZJHRefreshHeaderViewRefreshingBlock)(ZJHRefreshHeaderBaseView * _Nullable view);

typedef NS_ENUM(NSUInteger, ZJHRefreshHeaderViewStatus) {
    ZJHRefreshHeaderViewStatusIdle = 1,                 // 下拉刷新
    ZJHRefreshHeaderViewStatusLoosenRefresh = 2,        // 松开立即刷新
    ZJHRefreshHeaderViewStatusOnRefresh = 3,            // 正在刷新
};

@interface UIScrollView (ZJHRefreshHeaderBaseView)

@property (nonatomic, strong, nullable) ZJHRefreshHeaderBaseView * zjh_header;

@end


@interface ZJHRefreshHeaderBaseView : UIView

@property (nonatomic, weak, nullable, readonly) UIScrollView *scrollView; // 父控件
@property (nonatomic, assign) CGFloat bottomMargin;  // 下拉刷新视图的底部距离scrollView顶部的距离
@property (nonatomic, assign) BOOL isPercentAlpha;   // 根据百分比修改透明度

@property (nonatomic, assign, readonly) ZJHRefreshHeaderViewStatus status;

+ (instancetype _Nonnull )headerWithRefreshBlock:(ZJHRefreshHeaderViewRefreshingBlock _Nonnull )block;
+ (instancetype _Nonnull )headerWithRefreshTarget:(id _Nonnull )target action:(SEL _Nonnull )action;

- (void)beginRefresh;
- (void)endRefresh;
#pragma mark - 子类可以重载的方法
/** 返回视图高度 */
- (CGFloat)overload_viewHeight;
/** 创建子控件，调用一次 */
- (void)overload_setupView;
/** 更新子控件位置，多次调用 */
- (void)overload_updateSubviewFrame;
/** 下拉偏移量和偏移百分比 */
- (void)overload_scrollViewDidChangeOffset:(CGPoint)offset pullPercent:(CGFloat)percent;
/** 更新视图 下拉可刷新状态 */
- (void)overload_updateViewIdle;
/** 更新视图 松手立即刷新状态 */
- (void)overload_updateViewLoosenRefresh;
/** 更新视图 正在刷新状态 */
- (void)overload_updateViewOnRefresh;

@end
