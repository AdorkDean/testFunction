//
//  TagShowCell.m
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import "TagShowCell.h"


@interface TagShowCell ()

@property(nonatomic,strong)UILabel  *titleLabel;
@property(nonatomic,strong)UIButton  *deleteBtn;


@end

@implementation TagShowCell

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 35)];
        UIImage *img = [BundleTool imageNamed:@"tag_delete"];
        _deleteBtn.size = img.size;
        [_deleteBtn setImage:img forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = H5COLOR;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:label];
        self.titleLabel = label;
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

-(void)setTextColor:(UIColor *)textColor{
    
    self.titleLabel.textColor = textColor;

}
- (void)showDeleteBtn{
    
    CGPoint center = CGPointMake(self.centerX, self.top-self.deleteBtn.height/2.0-5);
    
    CGPoint point = [self.superview convertPoint:center toView:KEYWindow];
    self.deleteBtn.center = point;

    self.deleteBtn.centerX = self.centerX;
    
    [KEYWindow addSubview:self.deleteBtn];

}

- (void)hideDeleteBtn{
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[UIButton class]]) {
            [subV removeFromSuperview];
        }
    }

}


- (void)deleteBtnClick{
    
    self.deleteCell();
    [self hideDeleteBtn];
}


@end
