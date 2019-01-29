//
//  UIButton+Indicator.m
//  123
//
//  Created by QMP on 2018/11/24.
//  Copyright © 2018 xiusl. All rights reserved.
//

#import "UIButton+Indicator.h"
#import <objc/runtime.h>

static char *IndicatorKey = "IndicatorKey";
@implementation UIButton (Indicator)
- (void)setIndicatorView:(UIActivityIndicatorView *)indicatorView {
    objc_setAssociatedObject(self, IndicatorKey, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIActivityIndicatorView *)indicatorView {
    return objc_getAssociatedObject(self, IndicatorKey);
}

- (void)showIndicator {
    self.titleLabel.alpha = 0;
    self.userInteractionEnabled = NO;
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGAffineTransform transform = CGAffineTransformMakeScale(.6f, .6f);
    self.indicatorView.transform = transform;
    self.indicatorView.userInteractionEnabled = NO;
    [self.indicatorView startAnimating];
    self.indicatorView.color = [UIColor blackColor];
    [self addSubview:self.indicatorView];
}
- (void)hideIndicator {
    self.titleLabel.alpha = 1;
    self.userInteractionEnabled = YES;
    [self.indicatorView removeFromSuperview];
}

@end
