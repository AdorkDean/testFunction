//
//  QMPCreateMoreView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPCreateMoreView.h"
const CGFloat QMPCreateMoreViewWidth = 230;
const CGFloat QMPCreateMoreViewItemHeight = 50;
@interface QMPCreateMoreView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSArray *items;
@end
@implementation QMPCreateMoreView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    self.backgroundColor = RGBa(0, 0, 0, 0.6);
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    
    [self addSubview:self.contentView];
    CGFloat height = self.items.count * (QMPCreateMoreViewItemHeight + 1) - 1;
    self.contentView.frame = CGRectMake((SCREENW-QMPCreateMoreViewWidth)/2.0, (SCREENH-height)/2.0, QMPCreateMoreViewWidth, height);
    
    
    NSInteger index = 0;
    for (NSDictionary *dict in self.items) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, index*QMPCreateMoreViewItemHeight, QMPCreateMoreViewWidth, QMPCreateMoreViewItemHeight);
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitle:dict[@"title"] forState:UIControlStateNormal];
        [button setTitleColor:COLOR737782 forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:dict[@"icon"]] forState:UIControlStateNormal];
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 48, 0, -48);
        button.tag = index;
        [button addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        
        if (index < self.items.count - 1) {
            UIImageView *line = [[UIImageView alloc] init];
            line.frame = CGRectMake(0, button.bottom, QMPCreateMoreViewWidth, 1);
            line.backgroundColor = HTColorFromRGB(0xF5F5F5);
            [self.contentView addSubview:line];
        }
        
        index++;
    }
}
- (void)itemButtonClick:(UIButton *)button {
    [self hide];
    if (self.createMoreViewItemClick) {
        self.createMoreViewItemClick(button.currentTitle);
    }
}
- (void)hide {
    [self removeFromSuperview];
}
- (void)show {
    [KEYWindow addSubview:self];
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 4;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}
- (NSArray *)items {
    if (!_items) {
        _items = @[
                   @{@"title":@"创建项目", @"icon":@"data_create", @"deicon":@"data_create", @"action":@""},
                   @{@"title":@"发布融资需求", @"icon":@"data_publishNeed", @"deicon":@"data_publishNeed", @"action":@""},
                   @{@"title":@"披露融资事件", @"icon":@"data_publishRz", @"deicon":@"data_publishRz", @"action":@""},
                   ];
    }
    return _items;
}
@end
