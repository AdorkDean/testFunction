//
//  CardListCell.m
//  CommonLibrary
//
//  Created by QMP on 2018/11/19.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "CardListCell.h"

@interface CardListCell()
{
    NSString *_nickName;
    UIImageView *_cardIcon;
    UILabel *_nameLab;
    UILabel *_companyLab;
    UIButton *_phoneBtn;
    UIButton *_wechatBtn;
    UIButton *_emailBtn;
}
@end


@implementation CardListCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    CardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardListCellID"];
    if (!cell) {
        cell = [[CardListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardListCellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addViews];
    }
    return self;
}

- (void)addViews{
    _cardIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 15, 45, 45)];
    _cardIcon.layer.cornerRadius = 22.5;
    _cardIcon.layer.masksToBounds = YES;
    _cardIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _cardIcon.layer.borderWidth = 0.5;
    [self.contentView addSubview:_cardIcon];
//    _cardIcon.userInteractionEnabled = YES;
    
    _nameLab = [[UILabel alloc]initWithFrame:CGRectMake(_cardIcon.right+15, 16, SCREENW-_cardIcon.right-15-135, 18)];
    [_nameLab labelWithFontSize:15 textColor:H3COLOR];
    if (@available(iOS 8.2, *)) {
        _nameLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else{
        _nameLab.font = [UIFont systemFontOfSize:15];
    }
    [self.contentView addSubview:_nameLab];
    
    _companyLab = [[UILabel alloc]initWithFrame:CGRectMake(_nameLab.left, _nameLab.bottom-4, _nameLab.width, 44)];
    [_companyLab labelWithFontSize:14 textColor:H6COLOR];
    [self.contentView addSubview:_companyLab];
    _companyLab.userInteractionEnabled = YES;
    
//    _phoneBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 81, 25, 25, 25)];
//    [self.contentView addSubview:_phoneBtn];
//    
//    _wechatBtn = [[UIButton alloc]initWithFrame:CGRectMake(_phoneBtn.right+15, 25, 25, 25)];
//    [self.contentView addSubview:_wechatBtn];
    
//    _emailBtn = [[UIButton alloc]initWithFrame:CGRectMake(_wechatBtn.right+15, 25, 25, 25)];
//    [self.contentView addSubview:_emailBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(16, 74.5, SCREENW-32, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:line];
}



- (void)setCardItem:(CardItem *)cardItem{
    _cardItem = cardItem;
    
    _nickName = [PublicTool isNull:_cardItem.cardName] ? _cardItem.contacts:_cardItem.cardName;
    _nickName = [PublicTool isNull:_nickName] ? @"":_nickName;
    
}
- (void)setFriendM:(FriendModel *)friendM{
    _friendM = friendM;
    _nickName = [PublicTool isNull:friendM.nickname] ? @"":friendM.nickname;
}

- (void)setArea:(CardStyleFrom)area{
    _area = area;
    if (area == CardStyleFromExchange) {
        [self setFriendInfo];
    }else{
        [self setCardMsg];
    }
}
//上传的名片  e和 委托联系
- (void)setCardMsg{
    
    _companyLab.userInteractionEnabled = NO;

    NSString *phone = [PublicTool isNull:_cardItem.phone] ? _cardItem.telephone:_cardItem.phone;
    [_phoneBtn setImage:[PublicTool isNull:phone] ? [BundleTool imageNamed:@"card_phone_disabled"]:[BundleTool imageNamed:@"card_phone_enabled"] forState:UIControlStateNormal];
    [_wechatBtn setImage:[PublicTool isNull:_cardItem.wechat] ? [BundleTool imageNamed:@"card_wechat_disabled"]:[BundleTool imageNamed:@"card_wechat_enabled"] forState:UIControlStateNormal];
    [_emailBtn setImage:[PublicTool isNull:_cardItem.email] ? [BundleTool imageNamed:@"card_email_disabled"]:[BundleTool imageNamed:@"card_email_enabled"] forState:UIControlStateNormal];
    NSString *icon = [PublicTool isNull:_cardItem.icon] ? _cardItem.imgUrl:_cardItem.icon;
    [_cardIcon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    
    NSString *name = [PublicTool isNull:_cardItem.cardName] ? _cardItem.contacts:_cardItem.cardName;
    name = [PublicTool nilStringReturn:name];
    _nameLab.text = name;
    
    NSString *zhiwei = [PublicTool isNull:_cardItem.zhiwu]? ([PublicTool isNull:_cardItem.zhiwei]?@"":_cardItem.zhiwei):_cardItem.zhiwu;
    zhiwei = [PublicTool isNull:zhiwei]?@"":zhiwei;
    if (self.area == CardStyleFromUpload) { //上传的职位跟在名字后边
        _cardIcon.layer.cornerRadius = 4;

        NSMutableAttributedString *nameText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  %@",name,zhiwei]];
        [nameText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:H6COLOR} range:NSMakeRange(nameText.length-zhiwei.length, zhiwei.length)];
        if (@available(iOS 8.2, *)) {
            [nameText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]} range:NSMakeRange(0, name.length)];
        } else {
            [nameText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, name.length)];
        }
        _nameLab.text = @"";
        _nameLab.attributedText = nameText;
        zhiwei = @"";
        _companyLab.font = [UIFont systemFontOfSize:14];
    }
    NSString *company = [_cardItem.type containsString:@"person"]?_cardItem.company : _cardItem.entrust_project;
    if ([PublicTool isNull:company]) {
        _companyLab.attributedText = nil;
        _companyLab.text = [PublicTool nilStringReturn:zhiwei];
        _companyLab.textColor = H6COLOR;
    }else{
        _companyLab.text = @"";
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  %@",company,zhiwei]];
        if (![PublicTool isNull:_cardItem.detail]) {
            [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(0, company.length)];
            _companyLab.userInteractionEnabled = YES;
        }
        _companyLab.attributedText = attText;
    }
    
    [_companyLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(companyBtnClick:)]];
    CGFloat width = [PublicTool widthOfString:_companyLab.text height:CGFLOAT_MAX fontSize:_companyLab.font.pointSize];
    _companyLab.width = MIN(width+10,SCREENW-76-16);
    [self addTROnCell];
}

//交换的名片
- (void)setFriendInfo{
    
    _nickName = _friendM.nickname;

    [_phoneBtn setImage:(_friendM.type.integerValue == 1||_friendM.type.integerValue == 3) ? [BundleTool imageNamed:@"card_phone_enabled"]:[BundleTool imageNamed:@"card_phone_disabled"] forState:UIControlStateNormal];
    [_wechatBtn setImage:(_friendM.type.integerValue == 2||_friendM.type.integerValue == 3) ? [BundleTool imageNamed:@"card_wechat_enabled"]:[BundleTool imageNamed:@"card_wechat_disabled"] forState:UIControlStateNormal];
    [_emailBtn setImage:[PublicTool isNull:_friendM.email] ? [BundleTool imageNamed:@"card_email_disabled"]:[BundleTool imageNamed:@"card_email_enabled"] forState:UIControlStateNormal];
    
    [_cardIcon sd_setImageWithURL:[NSURL URLWithString:_friendM.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    
    NSString *name = [PublicTool isNull:_friendM.nickname] ? @"-":_friendM.nickname;
    _nameLab.text = name;
    
    NSString *zhiwei = _friendM.position;
    if ([PublicTool isNull:_friendM.company]) {
        _companyLab.attributedText = nil;
        _companyLab.text = [PublicTool nilStringReturn:zhiwei];
        _companyLab.textColor = H6COLOR;
        _companyLab.userInteractionEnabled = NO;
    }else{
        _companyLab.text = @"";
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  %@",_friendM.company,zhiwei]];
        if (![PublicTool isNull:_friendM.detail]) {
            [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(0, _friendM.company.length)];
            _companyLab.userInteractionEnabled = YES;
        }
        _companyLab.attributedText = attText;
    }
    
    CGFloat width = [PublicTool widthOfString:_companyLab.text height:CGFLOAT_MAX fontSize:_companyLab.font.pointSize];
    _companyLab.width = MIN(width+10,SCREENW-76-16);

    [_companyLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(companyBtnClick:)]];
//    [_cardIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterPersonDetail)]];
    [self addTROnCell];
}

- (void)addTROnCell{
    
    [_phoneBtn addTarget:self action:@selector(tapedPhone) forControlEvents:UIControlEventTouchUpInside];
    [_wechatBtn addTarget:self action:@selector(tapedWechat) forControlEvents:UIControlEventTouchUpInside];
    [_emailBtn addTarget:self action:@selector(tapedEmail) forControlEvents:UIControlEventTouchUpInside];
}

- (void)companyBtnClick:(UITapGestureRecognizer*)tap {
    CGPoint point = [tap locationInView:_companyLab];
    CGFloat width = [PublicTool widthOfString:[_companyLab.text componentsSeparatedByString:@"  "].firstObject height:CGFLOAT_MAX fontSize:_companyLab.font.pointSize];
    if (point.x > width+10) {
        return;
    }
    NSString *detail = (self.area == CardStyleFromExchange ? _friendM.detail:_cardItem.detail);
    if ([PublicTool isNull:detail]) {
        return;
    }
    [self toDetailVC:detail];
}

- (void)tapedPhone{
    
    NSString *phone = @"";

    if (self.area == CardStyleFromExchange) {
        phone = _friendM.bind_phone;
    }else{
        if (self.area == CardStyleFromUpload) {
            phone = _cardItem.phone;
        }else{
            phone = _cardItem.telephone;
        }
    }

    if (self.area == CardStyleFromExchange) {
        if ((_friendM.type.integerValue != 1)&& (_friendM.type.integerValue != 3)) {
            [PublicTool alertVCWithTitle:@"提示" message:@"您未与对方交换手机号，请前往该人物主页进行私信交换" defaultTitle:@"前往" defaultAction:^{
                [self gotoChat];
            } cancelTitle:@"取消" cancelAction:nil];
            return;
        }
    }
   
    if (![PublicTool isNull:phone]) {
        [PublicTool dealPhone:phone message:[NSString stringWithFormat:@"%@的手机",_nickName]];
    }else{
        [PublicTool alertActionWithTitle:@"提示" message:@"对方暂无手机号" btnTitle:@"我知道了" action:nil];
    }
    
}


- (void)tapedWechat{
    
    NSString *wechat;
    if (self.area == CardStyleFromExchange) {
        wechat = _friendM.wechat;
    }else{
        wechat = _cardItem.wechat;
    }
    
    if (self.area == CardStyleFromExchange) {
        if ((_friendM.type.integerValue != 2)&& (_friendM.type.integerValue != 3)) {
            [PublicTool alertVCWithTitle:@"提示" message:@"您未与对方交换微信号，请前往该人物主页进行私信交换" defaultTitle:@"前往" defaultAction:^{
                [self gotoChat];
                
            } cancelTitle:@"取消" cancelAction:nil];
            return;
        }
    }
    
    if (![PublicTool isNull:wechat]) {
        [PublicTool dealWechat:wechat message:[NSString stringWithFormat:@"%@的微信",_nickName]];
    }else{
        [PublicTool alertActionWithTitle:@"提示" message:@"对方暂无微信号" btnTitle:@"我知道了" action:nil];
    }
}

- (void)tapedEmail{
    
    NSString *email;
    if (self.area == CardStyleFromExchange) {
        email = _friendM.email;
    }else{
        email = _cardItem.wechat;
    }
    if (![PublicTool isNull:email]) {
        [PublicTool dealEmail:email message:[NSString stringWithFormat:@"%@的邮箱",_nickName]];
    }else{
        [PublicTool alertActionWithTitle:@"提示" message:@"对方暂无邮箱" btnTitle:@"我知道了" action:nil];
    }
}


- (void)gotoChat{
    

    if ([WechatUserInfo shared].claim_type.integerValue == 2){
        if (![PublicTool isNull:_friendM.person_id]) { //已入驻
            [[AppPageSkipTool shared] appPageSkipToChatView:[NSString stringWithFormat:@"%@",self.friendM.usercode]];
        }else{
            [PublicTool alertActionWithTitle:@"提示" message:@"对方还未入驻" btnTitle:@"我知道了" action:nil];
        }

    }else  if ([WechatUserInfo shared].claim_type.integerValue == 1) {
        [PublicTool alertActionWithTitle:@"提示" message:@"您的认证信息正在审核，认证后才能私信交换" btnTitle:@"我知道了" action:nil];

    }else{ //审核中和失败
        [PublicTool alertVCWithTitle:@"提示" message:@"认证后才能私信交换" defaultTitle:@"去认证" defaultAction:^{
            
        } cancelTitle:@"取消" cancelAction:nil];

    }
}

- (void)enterPersonDetail{
    if (self.friendM) {
        if (![PublicTool isNull:self.friendM.person_id]) {
            [[AppPageSkipTool shared]appPageSkipToPersonDetail:self.friendM.person_id];
        }else if (![PublicTool isNull:self.friendM.unionid]) {
            [[AppPageSkipTool shared]appPageSkipToUserDetail:self.friendM.unionid];
        }
    }
}

#pragma mark 点击项目名称跳转
- (void)toDetailVC:(NSString*)detail{
    
    if ([PublicTool isNull:detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToDetail:detail];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
