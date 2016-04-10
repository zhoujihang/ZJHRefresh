//
//  UIView+Extension.m
//  Ayibang
//
//  Created by 阿姨帮 on 15/7/8.
//  Copyright (c) 2015年 ayibang. All rights reserved.
//

#import "UIView+ZJHExtension.h"
@implementation UIView (ZJHExtension)

#pragma mark - 便捷修改，访问UIView的frame属性的分类 ConvenienceFrame
- (void)setZjh_x:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setZjh_y:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)zjh_x
{
    return self.frame.origin.x;
}

- (CGFloat)zjh_y
{
    return self.frame.origin.y;
}

- (void)setZjh_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)zjh_centerX
{
    return self.center.x;
}

- (void)setZjh_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)zjh_centerY
{
    return self.center.y;
}

- (void)setZjh_width:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setZjh_height:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)zjh_height
{
    return self.frame.size.height;
}

- (CGFloat)zjh_width
{
    return self.frame.size.width;
}

- (void)setZjh_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)zjh_size
{
    return self.frame.size;
}

- (void)setZjh_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)zjh_origin
{
    return self.frame.origin;
}
- (CGFloat)zjh_maxX{
    return CGRectGetMaxX(self.frame);
}
- (CGFloat)zjh_maxY{
    return CGRectGetMaxY(self.frame);
}

- (void)zjh_removeAllSubviews{
    NSInteger count = self.subviews.count;
    for (int i=0; i<count; i++) {
        UIView *subview = [self.subviews firstObject];
        [subview removeFromSuperview];
    }
}
@end


