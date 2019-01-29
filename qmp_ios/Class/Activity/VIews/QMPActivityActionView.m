//
//  QMPActivityActionView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPActivityActionView.h"
#import "ActivityModel.h"
const CGFloat QMPActivityActionViewWidth = 230;
const CGFloat QMPActivityActionItemHeight = 50;
@interface QMPActivityActionView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) ActivityModel *activity;
@end

@implementation QMPActivityActionView

- (instancetype)initWithActivity:(ActivityModel *)activity {
    self = [super init];
    if (self) {
        self.activity = activity;
        [self setupViews];
    }
    return self;
}
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
    
    self.items = [self fixItemsWithActivity:self.activity];
    
    [self addSubview:self.contentView];
    CGFloat height = self.items.count * (QMPActivityActionItemHeight + 1) - 1;
    self.contentView.frame = CGRectMake((SCREENW-QMPActivityActionViewWidth)/2.0, (SCREENH-height)/2.0, QMPActivityActionViewWidth, height);
    
    NSInteger index = 0;
    for (NSDictionary *dict in self.items) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, index*QMPActivityActionItemHeight, QMPActivityActionViewWidth, QMPActivityActionItemHeight);
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [button setTitleColor:COLOR737782 forState:UIControlStateNormal];
        
        BOOL state = [self stateWithTitle:dict[@"title"]];
        if (state) {
            [button setTitle:dict[@"detitle"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:dict[@"deicon"]] forState:UIControlStateNormal];
        } else {
            [button setTitle:dict[@"title"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:dict[@"icon"]] forState:UIControlStateNormal];
        }
        
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 48, 0, -48);
        [button addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        
        if (index < self.items.count - 1) {
            UIImageView *line = [[UIImageView alloc] init];
            line.frame = CGRectMake(0, button.bottom, QMPActivityActionViewWidth, 1);
            line.backgroundColor = HTColorFromRGB(0xF5F5F5);
            [self.contentView addSubview:line];
        }
        
        index++;
    }
}


- (void)hide {
    [self removeFromSuperview];
}
- (void)show {
    [KEYWindow addSubview:self];
}
- (void)itemButtonClick:(UIButton *)button {
    if (self.activityActionItemTap) {
        [self hide];
        self.activityActionItemTap(button.currentTitle);
    }
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
- (NSArray *)fixItemsWithActivity:(ActivityModel *)a {
    if (a.isAnonymous) {
        ActivityRelateModel *m = a.headerRelate;
        if ([m.name isEqualToString:@"匿名用户"]) {
            return @[
                     @{@"title":[NSString stringWithFormat:@"投币%@",a.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(a.coinCount)]], @"detitle":[NSString stringWithFormat:@"投币%@",a.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(a.coinCount)]], @"icon":@"activity_action_coin", @"deicon":@"activity_action_coinsel", @"action":@""},
                     @{@"title":@"收藏", @"detitle":@"已收藏", @"icon":@"activity_action_favor", @"deicon":@"activity_action_favorb", @"action":@""},
                     @{@"title":@"举报", @"detitle":@"已举报", @"icon":@"activity_action_report", @"deicon":@"activity_action_reportb", @"action":@""},
                     ];
        }
    }
    return @[
             @{@"title":[NSString stringWithFormat:@"投币%@",a.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(a.coinCount)]], @"detitle":[NSString stringWithFormat:@"投币%@",a.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(a.coinCount)]], @"icon":@"activity_action_coin", @"deicon":@"activity_action_coinsel", @"action":@""},
             @{@"title":@"收藏", @"detitle":@"已收藏", @"icon":@"activity_action_favor", @"deicon":@"activity_action_favorb", @"action":@""},
             @{@"title":@"举报", @"detitle":@"已举报", @"icon":@"activity_action_report", @"deicon":@"activity_action_reportb", @"action":@""},
             ];
}
- (NSArray *)items {
    if (!_items) {
        _items = @[
                   @{@"title":[NSString stringWithFormat:@"投币%@",self.activity.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(self.activity.coinCount)]], @"detitle":[NSString stringWithFormat:@"投币%@",self.activity.coinCount==0?@"":[NSString stringWithFormat:@"(%@)",@(self.activity.coinCount)]], @"icon":@"activity_action_coin", @"deicon":@"activity_action_coinsel", @"action":@""},
                   @{@"title":@"收藏", @"detitle":@"已收藏", @"icon":@"activity_action_favor", @"deicon":@"activity_action_favorb", @"action":@""},
                   @{@"title":@"举报", @"detitle":@"已举报", @"icon":@"activity_action_report", @"deicon":@"activity_action_reportb", @"action":@""},
                   ];
    }
    return _items;
}
- (BOOL)stateWithTitle:(NSString *)title {
    if ([title containsString:@"收藏"]) {
        return self.activity.isCollected;
    } else if ([title containsString:@"投币"]) {
        return NO;
    } else if ([title containsString:@"举报"]) {
        return self.activity.isReported;
    }
    return NO;
}
@end
