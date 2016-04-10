//
//  UIView+Extension.h
//  Ayibang
//
//  Created by 阿姨帮 on 15/7/8.
//  Copyright (c) 2015年 ayibang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZJHExtension)

#pragma mark - 便捷修改，访问UIView的frame属性的分类 ConvenienceFrame
@property (nonatomic, assign) CGFloat zjh_x;
@property (nonatomic, assign) CGFloat zjh_y;
@property (nonatomic, assign) CGFloat zjh_width;
@property (nonatomic, assign) CGFloat zjh_height;
@property (nonatomic, assign) CGFloat zjh_centerX;
@property (nonatomic, assign) CGFloat zjh_centerY;
@property (nonatomic, assign) CGSize  zjh_size;
@property (nonatomic, assign) CGPoint zjh_origin;

- (CGFloat)zjh_maxX;
- (CGFloat)zjh_maxY;

// 移除内部所有子控件
- (void)zjh_removeAllSubviews;

@end

