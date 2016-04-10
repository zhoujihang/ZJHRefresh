//
//  UIScrollView+ZJHExtension.h
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJHRefreshHeader;
@interface UIScrollView (ZJHExtension)

@property (nonatomic, strong) ZJHRefreshHeader *zjh_header;

@property (nonatomic, assign) CGFloat zjh_insetT;
@property (nonatomic, assign) CGFloat zjh_insetL;
@property (nonatomic, assign) CGFloat zjh_insetR;
@property (nonatomic, assign) CGFloat zjh_insetB;

@end
