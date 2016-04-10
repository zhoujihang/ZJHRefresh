//
//  UIScrollView+ZJHExtension.m
//  ZJHRefresh
//
//  Created by 周际航 on 16/4/10.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "UIScrollView+ZJHExtension.h"
#import <objc/runtime.h>
#import "ZJHRefreshHeader.h"

@implementation UIScrollView (ZJHExtension)

static const char ZJHRefreshHeaderKey;
- (ZJHRefreshHeader *)zjh_header{
    return objc_getAssociatedObject(self, &ZJHRefreshHeaderKey);
}
- (void)setZjh_header:(ZJHRefreshHeader *)zjh_header{
    
    if (self.zjh_header != zjh_header) {
        [self.zjh_header removeFromSuperview];
        [self insertSubview:zjh_header atIndex:0];
        
        [self willChangeValueForKey:@"zjh_header"];
        objc_setAssociatedObject(self, &ZJHRefreshHeaderKey, zjh_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"zjh_header"];
    }
}

- (CGFloat)zjh_insetT{
    return self.contentInset.top;
}
- (void)setZjh_insetT:(CGFloat)zjh_insetT{
    UIEdgeInsets inset = self.contentInset;
    inset.top = zjh_insetT;
    self.contentInset = inset;
}
- (CGFloat)zjh_insetL{
    return self.contentInset.left;
}
- (void)setZjh_insetL:(CGFloat)zjh_insetL{
    UIEdgeInsets inset = self.contentInset;
    inset.left = zjh_insetL;
    self.contentInset = inset;
}
- (CGFloat)zjh_insetR{
    return self.contentInset.right;
}
- (void)setZjh_insetR:(CGFloat)zjh_insetR{
    UIEdgeInsets inset = self.contentInset;
    inset.right = zjh_insetR;
    self.contentInset = inset;
}
- (CGFloat)zjh_insetB{
    return self.contentInset.bottom;
}
- (void)setZjh_insetB:(CGFloat)zjh_insetB{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = zjh_insetB;
    self.contentInset = inset;
}

@end
