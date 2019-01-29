//
//  OrganizeDetailHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/7/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OrganizeDetailHeaderView.h"
#import "OrganizeItem.h"
@interface OrganizeDetailHeaderView ()
@property (nonatomic, strong) UIView *contentCardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *serviceLabel;

@property (nonatomic, strong) UIImageView *phoneView;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UIImageView *emailView;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UIImageView *addressView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *placeholderImgV;

@end

@implementation OrganizeDetailHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.contentCardView];
        
        [self.contentCardView addSubview:self.avatarView];
        
        [self.contentCardView addSubview:self.nameLabel];
        [self.contentCardView addSubview:self.serviceLabel];
        [self.contentCardView addSubview:self.phoneView];
        [self.contentCardView addSubview:self.phoneLabel];
        [self.contentCardView addSubview:self.emailView];
        [self.contentCardView addSubview:self.emailLabel];
        [self.contentCardView addSubview:self.addressView];
        [self.contentCardView addSubview:self.addressLabel];
        [self.contentCardView addSubview:self.placeholderImgV];
        
    }
    return self;
}
- (void)setOrganize:(OrganizeItem *)organize {
    if (organize) {
        [self.placeholderImgV removeFromSuperview];
    }
    _organize = organize;
    
    self.avatarLabel.hidden = YES;
    if ([PublicTool isNull:organize.icon]) {
        self.avatarLabel.text = [organize.name substringToIndex:1];
        self.avatarLabel.backgroundColor = RANDOM_COLORARR[arc4random()%5];
        self.avatarLabel.hidden = NO;
    } else {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:organize.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
    }
    
    self.nameLabel.text = organize.name;
    if (organize.fa_renzheng.integerValue == 1) {
        self.serviceLabel.hidden = NO;
        [self.nameLabel sizeToFit];
        self.nameLabel.frame = CGRectMake(self.avatarView.right+12, self.avatarView.top+6, MIN(self.nameLabel.width, SCREENW-32-88-76-40), 22);
        self.serviceLabel.left = self.nameLabel.right+2;
    } else {
        self.serviceLabel.hidden = YES;
        self.nameLabel.width = SCREENW-32-88-76;
    }
    
    if ([organize.jg_type containsString:@"知名企业"] && ![organize.name containsString:@"基金"] && ![organize.name containsString:@"投资"]) {
        self.serviceLabel.hidden = NO;
        [self.nameLabel sizeToFit];
        
        self.serviceLabel.text = @"投资部门";
        [self.serviceLabel sizeToFit];
        CGFloat w = self.serviceLabel.width + 12;
        
        self.nameLabel.frame = CGRectMake(self.avatarView.right+12, self.avatarView.top+6, MIN(self.nameLabel.width, SCREENW-32-88-76-w), 22);
        self.serviceLabel.frame = CGRectMake(self.nameLabel.right+4, 0, w, 16);
        self.serviceLabel.centerY = self.avatarView.centerY;
        
    } else {
        self.serviceLabel.hidden = YES;
    }
    
    
    self.nameLabel.centerY = self.avatarView.centerY;
    
    self.phoneLabel.hidden = YES;
    self.phoneView.hidden = YES;
    self.emailView.hidden = YES;
    self.emailLabel.hidden = YES;
    self.addressView.hidden = YES;
    self.addressLabel.hidden = YES;
    
    if (![self.lianxi isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if (![PublicTool isNull:self.lianxi[@"phone"]]) {
        self.phoneLabel.hidden = NO;
        self.phoneView.hidden = NO;
        self.phoneLabel.text = [PublicTool isNull:self.lianxi[@"phone"]]? @"-" : self.lianxi[@"phone"];
        
        self.emailView.top = self.phoneView.bottom+8;
        self.emailLabel.top  = self.emailView.top;
        
        self.addressView.top = self.emailView.bottom+8;
        self.addressLabel.top  = self.addressView.top+1;
        
    } else {
        self.emailView.top = self.avatarView.bottom+14;
        self.emailLabel.top  = self.emailView.top;
        
        self.addressView.top = self.emailView.bottom+8;
        self.addressLabel.top  = self.addressView.top+1;
    }

    if (![PublicTool isNull:self.lianxi[@"email"]]) {
        self.emailLabel.hidden = NO;
        self.emailView.hidden = NO;
        self.emailLabel.text = [PublicTool isNull:self.lianxi[@"email"]]? @"-" : self.lianxi[@"email"];
        self.addressView.top = self.emailLabel.bottom+8;
        self.addressLabel.top  = self.addressView.top+1;
        
    } else {
        self.addressView.top = self.phoneView.hidden ? self.avatarView.bottom+14 : self.phoneView.bottom+6;
        self.addressLabel.top  = self.addressView.top+1;
    }
    
    if (![PublicTool isNull:self.lianxi[@"address"]]) {
        self.addressView.hidden = NO;
        self.addressLabel.hidden = NO;
        self.addressLabel.text = [PublicTool isNull:self.lianxi[@"address"]]? @"-" : self.lianxi[@"address"];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentCardView.height = self.height;
    if (![PublicTool isNull:self.lianxi[@"email"]]) {
        [self.emailLabel sizeToFit];
        self.emailLabel.frame = CGRectMake(self.emailView.right+10, self.emailView.top+1, SCREENW-55, self.emailLabel.height);
        self.addressView.top = self.emailLabel.bottom+8;
    }
    if (![PublicTool isNull:self.lianxi[@"address"]]) {
        [self.addressLabel sizeToFit];
        self.addressLabel.frame = CGRectMake(self.addressView.right+10, self.addressView.top+1, SCREENW-55, self.addressLabel.height);
    }
    
    if (!self.organize) {
        self.placeholderImgV.frame = self.contentCardView.bounds;
    }
}

- (void)infoLabelLongTap:(UILongPressGestureRecognizer *)gest {
    if (![gest.view isKindOfClass:[UILabel class]]) {
        return;
    }
    UILabel *label = (UILabel *)gest.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = label.text;
    [ShowInfo showInfoOnView:KEYWindow withInfo:@"复制成功"];
}
#pragma mark - Getter

- (UIView *)contentCardView {
    if (!_contentCardView) {
        _contentCardView = [[UIView alloc] init];
        _contentCardView.frame = CGRectMake(0, 0, SCREENW, 0);
        _contentCardView.backgroundColor = [UIColor whiteColor];
    }
    return _contentCardView;
}
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.frame = CGRectMake(16, 8, 60, 60);
        _avatarView.layer.cornerRadius = 4;
        _avatarView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        _avatarView.layer.borderWidth = 0.5;
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarView;
}
- (UILabel *)avatarLabel {
    if (!_avatarLabel) {
        _avatarLabel = [[UILabel alloc] init];
        _avatarLabel.frame = CGRectMake(0, 0, 60, 60);
        _avatarLabel.textColor = [UIColor whiteColor];
        _avatarLabel.font = [UIFont systemFontOfSize:18];
        _avatarLabel.textAlignment = NSTextAlignmentCenter;
        _avatarLabel.hidden = YES;
        int y = (arc4random() % 1) + 4;
        _avatarLabel.backgroundColor = [RANDOM_COLORARR objectAtIndex:y];
    }
    return _avatarLabel;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(self.avatarView.right+12, self.avatarView.top+6, 0, 22);
        if (@available(iOS 8_2, *)) {
            _nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        } else {
            _nameLabel.font = [UIFont systemFontOfSize:18];
        }
        _nameLabel.textColor = COLOR2D343A;
        self.nameLabel.centerY = self.avatarLabel.centerY;
    }
    return _nameLabel;
}
- (UILabel *)serviceLabel {
    if (!_serviceLabel) {
        _serviceLabel = [[UILabel alloc] init];
        _serviceLabel.frame = CGRectMake(0, 0, 40, 16);
        _serviceLabel.font = [UIFont systemFontOfSize:11];
        _serviceLabel.text = @"在服";
        _serviceLabel.textAlignment = NSTextAlignmentCenter;
        _serviceLabel.textColor = BLUE_TITLE_COLOR;
        _serviceLabel.backgroundColor = [UIColor colorWithRed:40/255.0 green:122/255.0 blue:233/255.0 alpha:0.11];
        _serviceLabel.layer.cornerRadius = 2;
        _serviceLabel.clipsToBounds = YES;
    }
    return _serviceLabel;
}

- (UIImageView *)phoneView {
    if (!_phoneView) {
        _phoneView = [[UIImageView alloc] init];
        _phoneView.frame = CGRectMake(16, self.avatarView.bottom+14, 14, 14);
        _phoneView.image = [UIImage imageNamed:@"contactInfo_phone"];
    }
    return _phoneView;
}
- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.frame = CGRectMake(self.phoneView.right+10, self.phoneView.top, SCREENW-55, 14);
        _phoneLabel.font = [UIFont systemFontOfSize:12];
        _phoneLabel.textColor = COLOR737782;
        
        _phoneLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelLongTap:)];
        [_phoneLabel addGestureRecognizer:longGest];
    }
    return _phoneLabel;
}
- (UIImageView *)emailView {
    if (!_emailView) {
        _emailView = [[UIImageView alloc] init];
        _emailView.frame = CGRectMake(16, self.phoneView.bottom+8, 14, 14);
        _emailView.image = [UIImage imageNamed:@"contactInfo_email"];
    }
    return _emailView;
}
- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] init];
        _emailLabel.frame = CGRectMake(self.emailView.right+8, self.emailView.top, SCREENW-55, 14);
        _emailLabel.font = [UIFont systemFontOfSize:12];
        _emailLabel.textColor = COLOR737782;
        _emailLabel.userInteractionEnabled = YES;
        _emailLabel.numberOfLines = 0;
        UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelLongTap:)];
        [_emailLabel addGestureRecognizer:longGest];
    }
    return _emailLabel;
}
- (UIImageView *)addressView {
    if (!_addressView) {
        _addressView = [[UIImageView alloc] init];
        _addressView.frame = CGRectMake(15, self.emailView.bottom+7, 16, 16);
        _addressView.image = [UIImage imageNamed:@"contactInfo_address"];
        _addressView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _addressView;
}
- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.frame = CGRectMake(self.addressView.right+8, self.addressView.top, SCREENW-55, 12);
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textColor = COLOR737782;
        _addressLabel.numberOfLines = 0;
        
        _addressLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelLongTap:)];
        [_addressLabel addGestureRecognizer:longGest];
    }
    return _addressLabel;
}


- (UIImageView *)placeholderImgV{
    if (!_placeholderImgV) {
        _placeholderImgV = [[UIImageView alloc] init];
        _placeholderImgV.frame = self.contentCardView.bounds;
        _placeholderImgV.image = [UIImage imageNamed:@"detail_placeholder_card"];
        _placeholderImgV.backgroundColor = [UIColor whiteColor];
    }
    return _placeholderImgV;
}
@end
