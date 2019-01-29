//
//  MyPageControl.m
//  qmp_ios
//
//  Created by QMP on 2018/2/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyPageControl.h"

@implementation MyPageControl

- (void)layoutSubviews
{
    [super layoutSubviews];

    //计算圆点间距
    CGFloat dotW = self.pointWidth > 0 ? self.pointWidth : 5;
    CGFloat magrin = self.pointMargin > 0 ? self.pointMargin : 8;
    CGFloat marginX = dotW + magrin;

    //计算整个pageControll的宽度
    CGFloat newW = (self.subviews.count - 1 ) * marginX;

    //设置新frame
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newW, self.frame.size.height);

    //设置居中
    CGPoint center = self.center;
    center.x = self.superview.width/2.0;
    self.center = center;

    //遍历subview,设置圆点frame
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];

        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotW)];
        }else {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotW)];
        }
        dot.layer.cornerRadius = dotW/2.0;

    }
}


//重写setCurrentPage方法，可设置圆点大小
//- (void) setCurrentPage:(NSInteger)page {
//    [super setCurrentPage:page];
//
//    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
//
//        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
//
//        CGSize size;
//        if (subviewIndex == page)
//
//        {
//            size.height = 5;
//
//            size.width = 5;
//
//
//        }else{
//
//            size.height = 5;
//
//            size.width = 5;
//        }
//
//        subview.layer.cornerRadius = 2.5;
//
//        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
//
//                                         size.width,size.height)];
//    }
//
//}

@end
