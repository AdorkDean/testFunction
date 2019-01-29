//
//  UIButton+Indicator.h
//  123
//
//  Created by QMP on 2018/11/24.
//  Copyright © 2018 xiusl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Indicator)
- (void)showIndicator;
- (void)hideIndicator;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

NS_ASSUME_NONNULL_END
