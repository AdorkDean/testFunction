//
//  PostHeaderSelectView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PostHeaderSelectView.h"
#import <UIButton+WebCache.h>
#import "PostActivityViewModel.h"
#import "ActivityModel.h"
CGFloat const PostHeaderSelectViewHeight = 60.0;

@interface PostHeaderSelectItem : UIButton
@property (nonatomic, weak) UIImageView *deleteView;
@end
@implementation PostHeaderSelectItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
        UIImageView *deleteView = [[UIImageView alloc] init];
        deleteView.image = [BundleTool imageNamed:@"cha_icon"];
        deleteView.bounds = CGRectMake(0, 0, 15, 15);
        [self addSubview:deleteView];
        self.deleteView = deleteView;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.deleteView.center = CGPointMake(self.width, 0);
    self.imageView.frame = self.bounds;
    self.imageView.layer.cornerRadius = 2.0;
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    self.imageView.clipsToBounds = YES;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -7, -7);
    return CGRectContainsPoint(bounds, point);
}

@end

@interface PostHeaderSelectView ()
@property (nonatomic, strong) NSArray *objects;
@end
@implementation PostHeaderSelectView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.leftIconView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowView];
        [self addSubview:self.lineView];
    }
    return self;
}
- (void)buttonClick:(UIButton *)button {
    if (self.didDeleteObject) {
        self.didDeleteObject(self.objects[button.tag], button.tag);
    }
}
- (void)reloadWithSelectedObjects:(NSArray *)objects {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    self.objects = objects;
    int i = 0;
    for (ActivityRelateModel *model in objects) {
        
        PostHeaderSelectItem *button = [[PostHeaderSelectItem alloc] init];
        button.frame = CGRectMake(self.leftIconView.right+10+i*50, (PostHeaderSelectViewHeight-35)/2.0, 35, 35);
        [button sd_setImageWithURL:[NSURL URLWithString:model.image] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self addSubview:button];
        i++;
    }
    
    if (objects.count > 0) {
//        self.titleLabel.text = model.name;
//        [self.titleLabel sizeToFit];
//        self.titleLabel.frame = CGRectMake(button.right+4, 5, self.titleLabel.width, 36);
        self.titleLabel.text = @"";
        if (objects.count == 1) {
            ActivityRelateModel *model = [objects firstObject];
            self.titleLabel.text = model.name;
            self.titleLabel.textColor = COLOR2D343A;
            [self.titleLabel sizeToFit];
            self.titleLabel.frame = CGRectMake(91, (PostHeaderSelectViewHeight-18)/2.0, MIN(self.titleLabel.width, 240), 18);
        }
    } else {
        self.titleLabel.text = @"关联项目/机构/人物";
        self.titleLabel.textColor = COLOR737782;
        self.titleLabel.frame = CGRectMake(38, (PostHeaderSelectViewHeight-18)/2.0, 300, 18);
    }
}

#pragma mark - Getter
- (UIImageView *)leftIconView {
    if (!_leftIconView) {
        _leftIconView = [[UIImageView alloc] init];
        _leftIconView.frame = CGRectMake(15, (PostHeaderSelectViewHeight-19)/2.0, 19, 19);
        _leftIconView.image = [BundleTool imageNamed:@"post_select"];
    }
    return _leftIconView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(38, (PostHeaderSelectViewHeight-18)/2.0, 300, 18);
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = COLOR737782;
        _titleLabel.text = @"关联项目/机构/人物";
    }
    return _titleLabel;
}
- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.frame = CGRectMake(SCREENW-22-17, (PostHeaderSelectViewHeight-22)/2.0, 22, 22);
        _arrowView.image = [BundleTool imageNamed:@"post_select_add"];
    }
    return _arrowView;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, PostHeaderSelectViewHeight-0.5, SCREENW, 0.5);
        _lineView.backgroundColor = HTColorFromRGB(0xeeeeee);
    }
    return _lineView;
}
@end
