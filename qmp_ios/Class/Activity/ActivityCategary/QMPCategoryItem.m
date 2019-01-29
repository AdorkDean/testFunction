//
//  QMPCategoryItem.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/6.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "QMPCategoryItem.h"

@implementation QMPCategoryItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.deleteView];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.deleteView.center = CGPointMake(self.frame.size.width-2, 2);
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
- (UIImageView *)deleteView {
    if (!_deleteView) {
        _deleteView = [UIImageView new];
        _deleteView.image = [UIImage imageNamed:@"category_delete"];
        _deleteView.bounds = CGRectMake(0, 0, 15, 15);
        _deleteView.hidden = YES;
    }
    return _deleteView;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -5, -5);
    return CGRectContainsPoint(bounds, point);
}

@end
