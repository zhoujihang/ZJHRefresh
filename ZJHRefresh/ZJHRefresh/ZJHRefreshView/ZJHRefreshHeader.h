//
//  ZJHRefreshHeader.h
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZJHRefreshState) {
    ZJHRefreshStateIdle = 1,                 // 下拉即可刷新
    ZJHRefreshStateLoosenToRefresh,          // 松开立即刷新
    ZJHRefreshStateOnRefresh,                // 正在刷新数据
};

typedef void(^ZJHRefreshBlock)();

@interface ZJHRefreshHeader : UIView

+ (instancetype)headerWithRefreshBlock:(ZJHRefreshBlock)block;

+ (instancetype)headerWithRefreshTarget:(id)target action:(SEL)action;
// 控件额外的向上偏移量，控制自己的位置
@property (nonatomic, assign) CGFloat moreInsetTopOffset;

// 开始刷新
- (void)beginRefresh;
// 结束刷新
- (void)endRefresh;

@end
