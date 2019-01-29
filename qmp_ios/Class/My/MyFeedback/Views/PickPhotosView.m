//
//  PickPhotosView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PickPhotosView.h"

@implementation PickPhotosView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.photoView];
        [self addSubview:self.deleteButton];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewClick)];
        [self addGestureRecognizer:tapGest];
    }
    return self;
}
- (void)photoViewClick {
    if ([self.delegate respondsToSelector:@selector(pickPhotosView:photoViewClick:)]) {
        [self.delegate pickPhotosView:self photoViewClick:self.tag];
    }
}
- (void)deleteButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(pickPhotosView:deleteButtonClick:)]) {
        [self.delegate pickPhotosView:self deleteButtonClick:self.tag];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoView.frame = self.bounds;
    self.deleteButton.center = CGPointMake(self.width-10, 10);
}

#pragma mark - Getter
- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
    }
    return _photoView;
}
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.bounds = CGRectMake(0, 0, 20, 20);
        _deleteButton.tag = 10086;
        [_deleteButton setImage:[UIImage imageNamed:@"post_photo_delete"] forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        // 转换坐标系
        CGPoint newPoint = [self.deleteButton convertPoint:point fromView:self];
        // 判断触摸点是否在button上
        if (CGRectContainsPoint(self.deleteButton.bounds, newPoint)) {
            view = self.deleteButton;
        }
    }
    return view;
}

@end
