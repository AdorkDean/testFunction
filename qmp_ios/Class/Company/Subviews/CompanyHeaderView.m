//
//  CompanyHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2017/10/12.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyHeaderView.h"
#import "CopyLabel.h"
#import "InsetsLabel.h"

@interface CompanyHeaderView()
{
    __weak IBOutlet UIImageView *iconImgV;
    __weak IBOutlet UIImageView *_renzhengIcon;
    __weak IBOutlet UILabel *_productName;
    
    __weak IBOutlet InsetsLabel *_lunci;
    __weak IBOutlet UILabel *hangyeLabel;
//    __weak IBOutlet UILabel *generalLabel;
    
    __weak IBOutlet NSLayoutConstraint *nameLeadingEdge;
    UILabel *_statusLbl;
    
    __weak IBOutlet UIButton *claimButton;
}
@property (nonatomic, strong) NSArray *hsArr;//A股
@property (nonatomic, strong) NSArray *sbArr;//新三板
@property (nonatomic, strong) NSArray *hkArr;//港股
@property (nonatomic, strong) NSArray *usaArr;//美股

@end

@implementation CompanyHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    iconImgV.layer.masksToBounds = YES;
    iconImgV.layer.cornerRadius = 5;
    iconImgV.layer.borderWidth = 0.5;
    iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, iconImgV.height - 23, iconImgV.width, 23)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    [_statusLbl labelWithFontSize:12 textColor:[UIColor whiteColor]];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [iconImgV addSubview:_statusLbl];
    
    [_lunci labelWithFontSize:12 textColor:BLUE_TITLE_COLOR cornerRadius:1.5 borderWdith:0.5 borderColor:RGBBlueColor];
    _lunci.edgeInsets = UIEdgeInsetsMake(3, 8, 3, 8);
    _lunci.backgroundColor = [UIColor whiteColor];
    
    [self.noteBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    self.noteBtn.layer.masksToBounds = YES;
    self.noteBtn.layer.cornerRadius = 12;
    self.noteBtn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.noteBtn.layer.borderWidth = 0.5;
    
    _lunci.userInteractionEnabled = YES;
    _productName.userInteractionEnabled = YES;
    hangyeLabel.userInteractionEnabled = YES;
//    generalLabel.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [_productName addGestureRecognizer:gesture];
    UILongPressGestureRecognizer *gesture1 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [_lunci addGestureRecognizer:gesture1];
    UILongPressGestureRecognizer *gesture2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [hangyeLabel addGestureRecognizer:gesture2];
//    UILongPressGestureRecognizer *gesture3 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
//
//    [generalLabel addGestureRecognizer:gesture3];
    
    [_cauwuBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [_baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [_feedBackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    _feedBackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    claimButton.layer.cornerRadius = 4;
    claimButton.layer.borderWidth = 0.5;
    claimButton.clipsToBounds = YES;
    [claimButton addTarget:self action:@selector(claimButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setBasicModel:(CompanyDetailBasicModel *)basicModel{

    _basicModel = basicModel;
    
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:_basicModel.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    _productName.text = _basicModel.product.length ? _basicModel.product:_basicModel.company;
    _statusLbl.hidden = _basicModel.need_flag.integerValue == 0;
   
    nameLeadingEdge.constant = 17;
    _renzhengIcon.hidden = YES;
    if (_basicModel.lunci.length) {
        _lunci.text = _basicModel.lunci;
        _lunci.hidden = NO;
        
    }else{
        _lunci.text = @"";
        _lunci.hidden = YES;
    }
    
    
    hangyeLabel.text = [_basicModel.yewu isEqualToString:@""] ? _basicModel.miaoshu : _basicModel.yewu;
    
    if (_basicModel.allipo.count > 1) {
        
        self.cauwuBtn.hidden = YES;
        
    }else{
        NSString *ipo_type = _basicModel.ziben_jieduan;
        if([PublicTool isNull:ipo_type]){
            self.cauwuBtn.hidden = YES;
        }else if([self.sbArr containsObject:ipo_type]||[self.hsArr containsObject:ipo_type]||[self.hkArr containsObject:ipo_type]||[self.usaArr containsObject:ipo_type]){
            self.cauwuBtn.hidden = NO;
        }else{
            
            self.cauwuBtn.hidden = YES;
        }
    }
    
    NSInteger claim = [self.claim_type integerValue];
    claimButton.hidden = NO;
    if (claim == 1) {
        claimButton.backgroundColor = BLUE_TITLE_COLOR;
        claimButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        [claimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimButton setTitle:@"审核中" forState:UIControlStateNormal];
        claimButton.userInteractionEnabled = NO;
    } else if (claim == 2) {
        claimButton.backgroundColor = HTColorFromRGB(0x3F83DC);
        claimButton.layer.borderColor = [HTColorFromRGB(0x3F83DC) CGColor];
        [claimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimButton setTitle:@"已认领" forState:UIControlStateNormal];
        claimButton.userInteractionEnabled = YES;
        if ([self.detailModel.company_basic.claim_unionid isEqualToString:[WechatUserInfo shared].unionid]) {
            [claimButton setTitle:@"编辑" forState:UIControlStateNormal];
        }
    } else {
        claimButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        [claimButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [claimButton setTitle:@"认领" forState:UIControlStateNormal];
        claimButton.userInteractionEnabled = YES;
    }
    
    claimButton.hidden = !self.needClaimButton;
}


- (void)setDetailModel:(CompanyDetailModel *)detailModel{
    _detailModel = detailModel;
    self.claim_type = _detailModel.claim_type;
    self.basicModel = detailModel.company_basic;
}

- (void)setOp_flag:(NSNumber *)op_flag {
    _op_flag = op_flag;
    // 1 拒绝 2 审核中 3 通过
    NSInteger claim = [self.op_flag integerValue];
    claimButton.hidden = NO;
    if (claim == 2) {
        claimButton.backgroundColor = BLUE_TITLE_COLOR;
        claimButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        [claimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimButton setTitle:@"审核中" forState:UIControlStateNormal];
        claimButton.userInteractionEnabled = NO;
    } else if (claim == 3) {
        claimButton.backgroundColor = HTColorFromRGB(0x3F83DC);
        claimButton.layer.borderColor = [HTColorFromRGB(0x3F83DC) CGColor];
        [claimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimButton setTitle:@"已认领" forState:UIControlStateNormal];
        if ([self.detailModel.company_basic.claim_unionid isEqualToString:[WechatUserInfo shared].unionid]) {
            [claimButton setTitle:@"编辑" forState:UIControlStateNormal];
        }
        claimButton.userInteractionEnabled = NO;
    } else {
        claimButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        [claimButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [claimButton setTitle:@"认领失败" forState:UIControlStateNormal];
        claimButton.userInteractionEnabled = NO;
    }
}

- (void)copyContent:(UILongPressGestureRecognizer*)press{
    UILabel *label = (UILabel*)press.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [label.text stringByAppendingString:[NSString stringWithFormat:@" 来自@企名片%@",_detailModel.company_basic.short_url]];
    
    NSString *info = @"复制成功";
    
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}
- (void)claimButtonClick:(UIButton *)button {
    if (self.ClaimButtonClick) {
        self.ClaimButtonClick(button);
    }
}
- (void)setNeedClaimButton:(BOOL)needClaimButton {
    _needClaimButton = needClaimButton;
    claimButton.hidden = !needClaimButton;
}

- (NSArray *)hsArr{
    
    if (!_hsArr) {
        _hsArr = @[@"上证A股",@"深交所中小板",@"深交所主板",@"深交所创业板",@"上海证券交易所"];
    }
    return _hsArr;
}

- (NSArray *)sbArr{
    
    if (!_sbArr) {
        _sbArr = @[@"新三板"];
    }
    return _sbArr;
}

- (NSArray *)hkArr{
    
    if (!_hkArr) {
        _hkArr = @[@"港股",@"香港交易所主板",@"香港交易所创业板"];
    }
    return _hkArr;
}

- (NSArray *)usaArr{
    
    if (!_usaArr) {
        _usaArr = @[@"美股",@"美交所",@"纽交所",@"纳斯达克"];
    }
    return _usaArr;
}

@end

