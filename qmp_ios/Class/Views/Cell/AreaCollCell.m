//
//  AreaCollCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AreaCollCell.h"

@interface AreaCollCell()

@property(nonatomic,strong)UIView *bgView;


@end
@implementation AreaCollCell

-(instancetype)initWithFrame:(CGRect)frame{
   
    if (self = [super initWithFrame:frame]) {
       
        [self addView];
    }
    return self;
}

- (void)addView{
    self.bgView = [[UIView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.bgView];
    self.bgView.backgroundColor = TABLEVIEW_COLOR;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 2;
    
    
    self.titleLab = [[UIButton alloc]initWithFrame:self.contentView.bounds];
    [self.titleLab setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    self.titleLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.titleLab];
    self.titleLab.enabled = NO;

    self.chaIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.contentView.width - 11, -2, 15, 15)];
    self.chaIcon.bounds = CGRectMake(0, 0, 30, 30);
    self.chaIcon.center = CGPointMake(self.contentView.width, 0);
    self.chaIcon.image = [UIImage imageNamed:@"cha_icon"];
    self.chaIcon.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.chaIcon];
    self.chaIcon.userInteractionEnabled = NO;
}

-(void)showAddIcon:(BOOL)show text:(NSString*)text{
    
    self.titleLab.titleLabel.font = [UIFont systemFontOfSize:13];
    
    CGFloat w = (SCREENW - 17*2 - 15*3) / 4;
    CGFloat height = [PublicTool heightOfString:text width:w font:[UIFont systemFontOfSize:12]];
    if (height>18) {
        self.titleLab.titleLabel.font = [UIFont systemFontOfSize:8];
    }
    
    if (show) {
        [self.titleLab setTitle:text forState:UIControlStateDisabled];;
        [self.titleLab setImage:[UIImage imageNamed:@"area_add"] forState:UIControlStateDisabled];
        [self.titleLab layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:2];

    }else{
        
        [self.titleLab setTitle:text forState:UIControlStateDisabled];;
        [self.titleLab setImage:nil forState:UIControlStateDisabled];
    }
  
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint nP = [self.contentView convertPoint:point toView:self.chaIcon];
    if (CGRectContainsPoint(self.chaIcon.bounds, nP)) {
        return self.contentView;
    }
    return [super hitTest:point withEvent:event];
}


@end
