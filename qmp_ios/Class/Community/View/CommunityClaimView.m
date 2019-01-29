//
//  CommunityClaimView.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/24.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "CommunityClaimView.h"
@interface CommunityClaimView()
@property (weak, nonatomic) IBOutlet UIView *centerView;

@end

@implementation CommunityClaimView

+ (void)showClaimView{
    CommunityClaimView *claimV = [nilloadNibNamed:@"CommunityClaimView" owner:nil options:nil].lastObject;
    claimV.frame = KEYWindow.bounds;
    [KEYWindow addSubview:claimV];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.65];
    self.centerView.layer.cornerRadius = 5;
    self.centerView.clipsToBounds = YES;

    //去认证
    if ([WechatUserInfo shared].claim_type.integerValue == 0 || [WechatUserInfo shared].claim_type.integerValue == 3) {
        [self.claimBtn setTitle:@"立即认证" forState:UIControlStateNormal];
    }else{
        [self.claimBtn setTitle:@"知道了" forState:UIControlStateNormal];
    }
    [self.claimBtn addTarget:self action:@selector(claimBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)claimBtnClick:(UIButton*)btn{
    NSString *title = btn.titleLabel.text;
    [self removeFromSuperview];
    if ([title containsString:@"知道了"]) {
    }else{
        [[AppPageSkipTool shared]appPageSkipToClaimPage];
    }
}

- (IBAction)closeBtnClick:(id)sender {
    [self removeFromSuperview];
}


@end
