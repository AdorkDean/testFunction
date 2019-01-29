//
//  VSTabBarFix.m
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "VSTabBarFix.h"

@implementation VSTabBarFix {
    UIEdgeInsets oldSafeAreaInsets;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    oldSafeAreaInsets = UIEdgeInsetsZero;
}


- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(oldSafeAreaInsets, self.safeAreaInsets)) {
        [self invalidateIntrinsicContentSize];
        
        if (self.superview) {
            [self.superview setNeedsLayout];
            [self.superview layoutSubviews];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    
    if (@available(iOS 11.0, *)) {
        float bottomInset = self.safeAreaInsets.bottom;
        if (bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90)) {
            size.height += bottomInset;
        }
    }
    
    return size;
}


- (void)setFrame:(CGRect)frame {
    if (self.superview) {
        if (frame.origin.y + frame.size.height != self.superview.frame.size.height) {
            frame.origin.y = self.superview.frame.size.height - frame.size.height;
        }
    }
    [super setFrame:frame];
}


@end
