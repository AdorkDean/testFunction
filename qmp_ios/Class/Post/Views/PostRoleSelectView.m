//
//  PostRoleSelectView.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/9.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "PostRoleSelectView.h"

@interface PostRoleSelectItemView : UIView
@property (nonatomic, strong) UIButton *nameLabel;
- (void)reLayout;
@end


@interface PostRoleSelectView ()
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, weak) PostRoleSelectItemView *currentItemView;
@end
@implementation PostRoleSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.borderColor = [HTColorFromRGB(0xEAEAEA) CGColor];
        self.layer.borderWidth = 1;
        self.clipsToBounds = YES;
        //        [self addSubview:self.bgView];
        
        [self setupItems];
    }
    return self;
}
- (void)setupItems {
    int i = 0;
    CGFloat max = 276;
    CGFloat height = 53;
    for (NSDictionary *dict in self.data) {
        PostRoleSelectItemView *itemView = [[PostRoleSelectItemView alloc] init];
        [itemView.nameLabel setTitle:dict[@"name"] forState:UIControlStateNormal];
        [itemView.nameLabel setImage:[UIImage imageNamed:dict[@"icon"]] forState:UIControlStateNormal];
        
        [itemView reLayout];
        if (itemView.width > max) {
            max = itemView.width;
        }
        itemView.frame = CGRectMake(0, height*i, itemView.width, height);
        itemView.tag = i;
        i++;
        [self addSubview:itemView];
    }
    
    for (int j = 1; j < self.data.count; j++) {
        UIImageView *line = [self lineView];
        line.frame = CGRectMake(0, j*53, max, 1);
        [self addSubview:line];
    }
    
    self.frame = CGRectMake(SCREENW-max-13, -height*3+1, max, height*3);
}

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        //        _popView.image = [UIImage imageNamed:@"activity_role_pop"];
        UIImage *image = [UIImage imageNamed:@"activity_role_pop"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 100, 90) resizingMode:UIImageResizingModeStretch];
        _bgView.image = image;
    }
    return _bgView;
}
- (NSArray *)data {
    if (!_data) {
        NSString *company = [PublicTool isNull:[WechatUserInfo shared].company]?@"":[WechatUserInfo shared].company;
        NSString *zhiwei = [PublicTool isNull:[WechatUserInfo shared].zhiwei]?@"":[WechatUserInfo shared].zhiwei;
        
        NSString *name = [NSString stringWithFormat:@"实名：%@ %@ %@", [WechatUserInfo shared].nickname, company, zhiwei];
        NSString *name2 = [NSString stringWithFormat:@"公司：%@ %@员工",[WechatUserInfo shared].flower_name,company];
        NSString *role = [NSString stringWithFormat:@"身份：%@ %@", [WechatUserInfo shared].flower_name,[PublicTool roleTextWithRequestStr:[WechatUserInfo shared].person_role]];
        _data = @[
                  @{@"name": name, @"anonymous":@"0", @"degree":@"", @"icon":@"activity_comment_role1"},
                  @{@"name": name2, @"anonymous":@"1", @"degree":@"1", @"icon":@"activity_comment_role2"},
                  @{@"name": role, @"anonymous":@"1", @"degree":@"2", @"icon":@"activity_comment_role3"}
                  ];
    }
    return _data;
}

- (UIImageView *)lineView {
    UIImageView *line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 46, 0, 1);
    line.backgroundColor = HTColorFromRGB(0xF5F5F5);
    return line;
}
@end

@implementation PostRoleSelectItemView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.nameLabel];
    }
    return self;
}
- (void)reLayout {
    CGFloat maxW = SCREENW - 26;
    CGFloat maxLabelW = maxW - 26;
    
    [self.nameLabel.titleLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(13, (53-19)/2.0, MIN(self.nameLabel.titleLabel.width+26, maxLabelW), 20);
    CGFloat w = self.nameLabel.width + 26;
    self.width = w;
    [self.nameLabel setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0,5)];
}
- (UIButton *)nameLabel {
    if (!_nameLabel) {
        UIButton *label = [[UIButton alloc] init];
        label.frame = CGRectMake(13, (53-19)/2.0, 0, 19);
        label.titleLabel.font = [UIFont systemFontOfSize:15];
        [label setTitleColor:H3COLOR forState:UIControlStateNormal];
        _nameLabel = label;
    }
    return _nameLabel;
}
@end
