//
//  ShareView.m
//  qmp_ios
//
//  Created by QMP on 2017/8/23.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ShareView.h"
//#import "UIButton+ImageTitleStyle.h"

@interface ShareView ()

@property(nonatomic,strong)UIView *platformView;
@property(nonatomic,strong)NSArray *menuTitleArr;


@end
@implementation ShareView

+(ShareView*)showShareViewCanCopyURL:(BOOL)copyURL didTapPlatform:(SelectedPlatform)selectPlayform{
    for (UIView *subViews in KEYWindow.subviews) {
        if ([subViews isKindOfClass:[ShareView class]]) {
            return nil;
        }
    }
    ShareView *shareV = [[ShareView alloc]initWithFrame:KEYWindow.bounds];
    if (copyURL) {
        shareV.menuTitleArr = @[@"微信朋友",@"朋友圈",@"微信收藏",@"复制链接"];
    }else{
        shareV.menuTitleArr = @[@"微信朋友",@"朋友圈",@"微信收藏"];
    }
    [shareV setUI];
    shareV.selectedPlatform = selectPlayform;
    [KEYWindow addSubview:shareV];
    [UIView animateWithDuration:0.3 animations:^{
        shareV.platformView.transform = CGAffineTransformMakeTranslation(0, -shareV.platformView.height);
    }];
    return shareV;
}


+(ShareView*)showShareViewDidTapPlatform:(SelectedPlatform)selectPlayform{
    for (UIView *subViews in KEYWindow.subviews) {
        if ([subViews isKindOfClass:[ShareView class]]) {
            return nil;
        }
    }
    //键盘弹起的情况下不弹出
//    if ([PublicTool findKeyboard]) {
//        return nil;
//    }
    
     ShareView *shareV = [[ShareView alloc]initWithFrame:KEYWindow.bounds];
    shareV.menuTitleArr = @[@"微信朋友",@"朋友圈",@"微信收藏"];
    [shareV setUI];
    shareV.selectedPlatform = selectPlayform;
    [KEYWindow addSubview:shareV];
    [UIView animateWithDuration:0.3 animations:^{
        shareV.platformView.transform = CGAffineTransformMakeTranslation(0, -shareV.platformView.height);
    }];
    return shareV;
}

-(void)setSelectedPlatform:(SelectedPlatform)selectedPlatform{
    _selectedPlatform = selectedPlatform;
}

- (void)setUI{
    
    CGFloat widthRatio = SCREENW / 375;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    
    _platformView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH, SCREENW, 210)];
    _platformView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_platformView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 58)];
    label.textAlignment = NSTextAlignmentCenter;
    [label labelWithFontSize:16 textColor:H3COLOR];
    label.text = @"分享到";
    [_platformView addSubview:label];
    
    NSArray *titles = @[@"微信朋友",@"朋友圈",@"微信收藏"];
    NSArray *images = @[[BundleTool imageNamed:@"umsocial_wechat"],[BundleTool imageNamed:@"umsocial_wechat_timeline"],[BundleTool imageNamed:@"umsocial_wechat_favorite"]];
    if ([self.menuTitleArr containsObject:@"复制链接"]) {
        titles = @[@"微信朋友",@"朋友圈",@"微信收藏",@"复制链接"];
        images = @[[BundleTool imageNamed:@"umsocial_wechat"],[BundleTool imageNamed:@"umsocial_wechat_timeline"],[BundleTool imageNamed:@"umsocial_wechat_favorite"],[BundleTool imageNamed:@"share_copyUrl"]];
    }
    CGFloat width = 55;
    CGFloat height = 55;
    CGFloat leftEdge = self.menuTitleArr.count == 4 ? 34*widthRatio:40*ratioWidth;
    CGFloat imgTop = label.height;
    CGFloat nameTop = label.height + height + 3;
    CGFloat edge = (SCREENW - width*titles.count - leftEdge*2)/(titles.count-1);
    
    for (int i=0; i<titles.count; i++) {

        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(leftEdge + i*(width+edge), imgTop, width, height)];
        [_platformView addSubview:imgV];
        imgV.image = images[i];
        imgV.tag = 10000 + i;

        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nameTop, 100, 20)];
        [nameLabel labelWithFontSize:12 textColor:H6COLOR];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = titles[i];
        [_platformView addSubview:nameLabel];
        nameLabel.centerX = imgV.centerX;

    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 160, SCREENW, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_platformView addSubview:line];
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 160, SCREENW, 49)];
    [cancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitleColor:H3COLOR forState:UIControlStateNormal];
    [_platformView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(disappear) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.anyObject;

    CGPoint point = [touch locationInView:_platformView];
    QMPLog(@"-------%@",NSStringFromCGPoint(point));
    //计算Point.x
    NSInteger menuCount = self.menuTitleArr.count;
    if (point.y < 0) { //点击的黑色背景

    }else{
        if (menuCount == 3) {
            if (point.x <= SCREENW/3.0) {
                self.selectedPlatform(ShareTypeWechatSession);
            }else if (point.x > SCREENW/3.0 && point.x <= SCREENW/3.0*2) {
                self.selectedPlatform(ShareTypeWechatTimeLine);
            }else if (point.x > SCREENW/3.0*2) {
                self.selectedPlatform(ShareTypeWechatFavorite);
            }
        }else{
            if (point.x <= SCREENW/4.0) {
                self.selectedPlatform(ShareTypeWechatSession);
            }else if (point.x > SCREENW/4.0 && point.x <= SCREENW/4.0*2) {
                self.selectedPlatform(ShareTypeWechatTimeLine);
            }else if (point.x > SCREENW/4.0*2 && point.x <= SCREENW/4.0*3) {
                self.selectedPlatform(ShareTypeWechatFavorite);
            }else if (point.x > SCREENW/4.0*3) {
                self.selectedPlatform(ShareTypeCopyURL);
            }
        }
       
    }
    
    [self disappear];

}

-(void)disappear{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.platformView.transform = CGAffineTransformIdentity;;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];

    }];
}




@end
