//
//  PostBarView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/1.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PostBarView.h"
#import "PostRoleSelectView.h"
@interface PostBarView ()
@property (nonatomic, strong, readwrite) UIButton *addRelateButton;
@property (nonatomic, strong, readwrite) UIButton *addImageButton;
@property (nonatomic, strong, readwrite) UIButton *addLinkButton;
@property (nonatomic, strong, readwrite) UIButton *anonymousButton;

@property (nonatomic, strong) UIView *roleView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *arrowView;

@property (nonatomic, strong) PostRoleSelectView *roleSelectView;
@end
@implementation PostBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.addRelateButton];
    [self addSubview:self.addImageButton];
    [self addSubview:self.addLinkButton];
//    [self addSubview:self.anonymousButton];
    [self addSubview:self.roleView];
    
    UIImageView *line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 0, SCREENW, 1);
    line.backgroundColor = HTColorFromRGB(0xEDEEF0);
    [self addSubview:line];

    self.nameLabel.text = @"显示实名";
    self.roleView.frame = CGRectMake(SCREENW-86-13, 10, 86, 31);
    self.anonymous2 = @"0";
    self.degree2 = @"";
}
- (void)anonymousButtonClick:(UIButton *)button {
    button.selected = !button.selected;
}
- (void)roleViewTap {
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
    
    if (self.roleSelectView.superview) {
        [self.roleSelectView removeFromSuperview];
    } else {
        [self addSubview:self.roleSelectView];
    }
}
- (void)updateRoleShow {
    if ([self.anonymous2 isEqualToString:@"1"]) {
        if ([self.degree2 isEqualToString:@"2"]) {
            self.nameLabel.text = @"显示公司";
        } else {
            self.nameLabel.text = @"显示身份";
        }
    } else {
        self.nameLabel.text = @"显示实名";
    }
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
}
- (void)showAuthorIfAnonymous:(BOOL)isAnonymous{
    
    if (!isAnonymous) {
        self.roleView.hidden = YES;
//        self.nameLabel.text = @"显示实名";
//        self.arrowView.hidden = YES;
//        self.nameLabel.centerX = self.roleView.width/2.0;
//        self.nameLabel.textColor = HCCOLOR;
//        self.roleView.layer.borderColor = [HTColorFromRGB(0xEAEAEA) CGColor];
//        self.roleView.userInteractionEnabled = NO;
        self.anonymous = 0;
    }else{
        
    }
}

- (void)roleSelectViewTap:(UITapGestureRecognizer *)tapGest {
    UIView *view = tapGest.view;
    CGFloat height = view.height / 3;
    
    CGPoint p = [tapGest locationInView:view];
    
    self.anonymous2 = p.y > height ? @"1" : @"0";
    self.degree2 = p.y > height *2 ? @"1" : (p.y>height?@"2":@"0");

    if (self.roleSelectView.superview) {
        [self.roleSelectView removeFromSuperview];
    }
    [self updateRoleShow];
}
#pragma mark - Getter
- (UIButton *)addRelateButton {
    if (!_addRelateButton) {
        UIButton *addRelateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addRelateButton.frame = CGRectMake(8, 0, 78, 50);
        [addRelateButton setImage:[BundleTool imageNamed:@"post_bar_add_relate"] forState:UIControlStateNormal];
        [addRelateButton setImage:[BundleTool imageNamed:@"post_bar_add_relate"] forState:UIControlStateHighlighted];
        [addRelateButton setImage:[BundleTool imageNamed:@"post_bar_add_relate_n"] forState:UIControlStateDisabled];
        [addRelateButton setTitle:@"关联" forState:UIControlStateNormal];
        addRelateButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addRelateButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
        [addRelateButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateDisabled];
        addRelateButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        addRelateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        _addRelateButton = addRelateButton;
    }
    return _addRelateButton;
}

- (UIButton *)addImageButton {
    if (!_addImageButton) {
        UIButton *addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addImageButton.frame = CGRectMake(self.addRelateButton.right, 0, 78, 50);
        [addImageButton setImage:[BundleTool imageNamed:@"post_bar_add_photo"] forState:UIControlStateNormal];
        [addImageButton setImage:[BundleTool imageNamed:@"post_bar_add_photo"] forState:UIControlStateHighlighted];
        [addImageButton setImage:[BundleTool imageNamed:@"post_bar_add_photo_n"] forState:UIControlStateDisabled];
        [addImageButton setTitle:@"图片" forState:UIControlStateNormal];
        addImageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addImageButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
        [addImageButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateDisabled];
        addImageButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        addImageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        _addImageButton = addImageButton;
    }
    return _addImageButton;
}
- (UIButton *)addLinkButton {
    if (!_addLinkButton) {
        UIButton *addLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addLinkButton.frame = CGRectMake(self.addImageButton.right, 0, 78, 50);
        [addLinkButton setImage:[BundleTool imageNamed:@"post_bar_add_link"] forState:UIControlStateNormal];
        [addLinkButton setImage:[BundleTool imageNamed:@"post_bar_add_link"] forState:UIControlStateHighlighted];
        [addLinkButton setImage:[BundleTool imageNamed:@"post_bar_add_link_n"] forState:UIControlStateDisabled];
        [addLinkButton setTitle:@"链接" forState:UIControlStateNormal];
        addLinkButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addLinkButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
        [addLinkButton setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateDisabled];
        addLinkButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        addLinkButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        _addLinkButton = addLinkButton;
    }
    return _addLinkButton;
}
- (UIButton *)anonymousButton {
    if (!_anonymousButton) {
        _anonymousButton = [[UIButton alloc] init];
        _anonymousButton.frame = CGRectMake(SCREENW-62-17, 0, 62, 50);
        _anonymousButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_anonymousButton setTitle:@"匿名" forState:UIControlStateNormal];
        [_anonymousButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_anonymousButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
        [_anonymousButton setImage:[BundleTool imageNamed:@"post_bar_anonymous"] forState:UIControlStateNormal];
        [_anonymousButton setImage:[BundleTool imageNamed:@"post_bar_anonymousb"] forState:UIControlStateSelected];
        [_anonymousButton addTarget:self action:@selector(anonymousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_anonymousButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        [_anonymousButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    }
    return _anonymousButton;
}

- (UIView *)roleView {
    if (!_roleView) {
        _roleView = [[UIView alloc] init];
        _roleView.frame = CGRectMake(0, 0, 86, 31);
        _roleView.layer.cornerRadius = 15.5;
        _roleView.layer.borderWidth = 1;
        _roleView.layer.borderColor = [HTColorFromRGB(0xEEEEEE) CGColor];
        _roleView.clipsToBounds = YES;
        _roleView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, (31-13)/2.0, 54, 13);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = H3COLOR;
        [_roleView addSubview:label];
        self.nameLabel = label;
        
        UIImageView *arrowView = [[UIImageView alloc] init];
        arrowView.frame = CGRectMake(65, 12.5, 11, 6);
        arrowView.image = [BundleTool imageNamed:@"activity_role_arrow"];
        [_roleView addSubview:arrowView];
        self.arrowView = arrowView;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleViewTap)];
        [_roleView addGestureRecognizer:tapGest];
    }
    return _roleView;
}

- (PostRoleSelectView *)roleSelectView {
    if (!_roleSelectView) {
        _roleSelectView = [[PostRoleSelectView alloc] init];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleSelectViewTap:)];
        [_roleSelectView addGestureRecognizer:tapGest];
    }
    return _roleSelectView;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}

@end
