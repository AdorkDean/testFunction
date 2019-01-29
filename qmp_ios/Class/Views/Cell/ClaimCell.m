//
//  ClaimCell.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/18.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "ClaimCell.h"

@interface ClaimCell()
@property(nonatomic,strong)UIImageView *bgImgV;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIButton *claimBtn;
@property(nonatomic,copy)NSString *tipInfo;
@property(nonatomic,assign)BOOL showBgImg;

@end

@implementation ClaimCell
+ (instancetype)cellWithTableView:(UITableView*)tableView tipInfo:(NSString*)tipInfo showbgImg:(BOOL)showBgImg{
    ClaimCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClaimCell"];
    if (!cell) {
        cell = [[ClaimCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClaimCell"];
        cell.tipInfo = tipInfo;
        cell.showBgImg = showBgImg;
    }
    [cell refreshContent];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
   
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImage *img = [BundleTool imageNamed:@"company_investorclaimbg"];
        UIImageView *bgImgV = [[UIImageView alloc]initWithFrame:CGRectMake(16, 15, img.size.width*180/img.size.height, 180)];
        bgImgV.image = img;
        bgImgV.tag = 1000;
        bgImgV.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgImgV];
        self.bgImgV = bgImgV;
        self.bgImgV.userInteractionEnabled = YES;
        
        [self.bgImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 67, SCREENW, 18)];
        [titleLab labelWithFontSize:14 textColor:H3COLOR];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.numberOfLines = 2;
        titleLab.tag = 1001;
        [self.bgImgV addSubview:titleLab];
        self.titleLab = titleLab;
        
        UIButton *claimBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 110, 108, 30)];
        [claimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimBtn setTitle:@"立即认证" forState:UIControlStateNormal];
        claimBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        claimBtn.backgroundColor = BLUE_BG_COLOR;
        claimBtn.layer.cornerRadius = 15;
        claimBtn.layer.masksToBounds = YES;
        claimBtn.tag = 1002;
        [self.bgImgV addSubview:claimBtn];
        [claimBtn addTarget:self action:@selector(userClaimBtnClick) forControlEvents:UIControlEventTouchUpInside];
        claimBtn.centerX = SCREENW/2.0;
        self.claimBtn = claimBtn;
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self refreshContent];
}

- (void)refreshContent{
    if (!self.showBgImg) {
        self.bgImgV.image = nil;
    }
    if ([WechatUserInfo shared].claim_type.integerValue == 1 || [WechatUserInfo shared].claim_type.integerValue == 2) { //审核中
        self.claimBtn.hidden = YES;
        self.titleLab.width = 180;
        self.titleLab.height = 45;
        self.titleLab.center = CGPointMake(SCREENW/2.0, self.bgImgV.height/2.0);

        //3. 我正在寻找的问题，并能中心对齐在NSAttributedString的文字是这样的：
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        paragraphStyle.lineSpacing = 5;

        NSString *info = [WechatUserInfo shared].claim_type.integerValue == 1 ? @"您的认证信息正在审核中，暂时无法查看该内容":self.tipInfo;
        
        NSAttributedString *attstr = [info stringWithParagraphlineSpeace:6 textColor:H3COLOR textFont:[UIFont systemFontOfSize:14]];
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithAttributedString:attstr];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attribString length])];
        self.titleLab.attributedText = attribString;
        
    }else{
        
        self.claimBtn.hidden = NO;
        self.titleLab.width = 290;
        self.titleLab.height = 18;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        paragraphStyle.lineSpacing = 5;
        NSAttributedString *attstr = [self.tipInfo stringWithParagraphlineSpeace:6 textColor:H3COLOR textFont:[UIFont systemFontOfSize:14]];
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithAttributedString:attstr];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attribString length])];
        self.titleLab.attributedText = attribString;
        self.titleLab.centerX = SCREENW/2.0;
        self.titleLab.centerY = self.bgImgV.height/2.0-15;
        self.claimBtn.top = self.titleLab.bottom+20;
    }
}

- (void)userClaimBtnClick{
    
    [[AppPageSkipTool shared] appPageSkipToClaimPage];
    if ([self.tipInfo containsString:@"项目投资人"]) {
        [QMPEvent event:@"pro_investor_toclaim_click"];
    }
}


@end
