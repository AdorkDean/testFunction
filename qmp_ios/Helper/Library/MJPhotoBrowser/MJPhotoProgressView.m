//
//  MJPhotoProgressView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoProgressView.h"

#define kDegreeToRadian(x) (M_PI/180.0 * (x))

@implementation MJPhotoProgressView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat pathWidth = 1;//radius * 0.3f;
    
    CGPoint centerPoint = CGPointMake(rect.size.height / 2, rect.size.width / 2);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2 - pathWidth;
    
    // 1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.拼接路径
   
    CGFloat startA = -M_PI/2.0;
    CGFloat endA = -M_PI/2.0 + M_PI * 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:startA endAngle:endA clockwise:YES];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetLineWidth(ctx, pathWidth);
    // 3.把路径添加到上下文
    [self.trackTintColor set];
    CGContextAddPath(ctx, path.CGPath);
    // 4.把上下文渲染到视图
    CGContextStrokePath(ctx);
    
    
    [self.progressTintColor set];
    CGFloat startS = -M_PI/2.0;
    CGFloat endS = -M_PI/2.0 + _progress * M_PI * 2;
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius-2, startS, endS, NO);
    CGPathCloseSubpath(progressPath);
    CGContextAddPath(ctx, progressPath);
    CGContextFillPath(ctx);
}

#pragma mark - Property Methods

- (UIColor *)trackTintColor
{
    if (!_trackTintColor)
    {
        _trackTintColor = [UIColor whiteColor];//[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    }
    return _trackTintColor;
}

- (UIColor *)progressTintColor
{
    if (!_progressTintColor)
    {
        _progressTintColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.6f];//[UIColor whiteColor];
    }
    return _progressTintColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

@end
