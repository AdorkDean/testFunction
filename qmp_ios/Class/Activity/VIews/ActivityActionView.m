//
//  ActivityActionView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityActionView.h"

const CGFloat ActivityActionViewWidth = 230;
const CGFloat ActivityActionItemHeight = 50;

@interface ActivityActionView ()
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSArray *items;
@end

@implementation ActivityActionView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    self.backgroundColor = RGBa(0, 0, 0, 0.3);
    
    [self addSubview:self.contentView];
    
}
- (void)hide {
    
}
- (void)show {
    [KEYWindow addSubview:self];
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}
- (NSArray *)items {
    if (!_items) {
        _items = @[];
    }
    return _items;
}
@end
