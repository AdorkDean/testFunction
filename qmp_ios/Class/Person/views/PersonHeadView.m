//
//  PersonHeadView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonHeadView.h"
#import "InsetsLabel.h"

@interface PersonHeadView()

@property(nonatomic,strong)UILabel *iconLab;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)InsetsLabel *roleLab;
@property(nonatomic,strong)UILabel *companyBtn;
@property(nonatomic,strong)UILabel *zhiweiLab;
@property(nonatomic,strong)UIButton *phoneLab;
@property(nonatomic,strong)UIButton *wechatLab;
@property(nonatomic,strong)UIButton *emailLab;

@property(nonatomic,strong)UIView *cardView;
@property(nonatomic,strong)UIImageView *renzhengImg;

@end

@implementation PersonHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addView];
    }
    return self;
}


- (void)addView{
    
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
   
    UIView *cardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, self.height)];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.masksToBounds = YES;
    cardView.layer.cornerRadius = 10;
    _cardView = cardView;
    [self addSubview:_cardView];
    
    //子视图
    _iconImgV = [[UIImageView alloc]init];
    _iconImgV.backgroundColor = [UIColor whiteColor];
    _iconImgV.contentMode = UIViewContentModeScaleToFill;
    [cardView addSubview:_iconImgV];
    
    _renzhengImg = [[UIImageView alloc]init];
    _renzhengImg.image = [UIImage imageNamed:@"activity_person_claim"];
    [_cardView addSubview:_renzhengImg];
    
    _iconLab = [[UILabel alloc]init];
    _iconLab.layer.masksToBounds = YES;
    _iconLab.textAlignment = NSTextAlignmentCenter;
    _iconLab.layer.cornerRadius = _iconLab.width/2.0;
    _iconLab.textColor = [UIColor whiteColor];
    _iconLab.font = [UIFont systemFontOfSize:32];
    [cardView addSubview:_iconLab];
    
    _nameLab = [[UILabel alloc]init];
    if (@available(iOS 8.2, *)) {
        _nameLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    } else {
        _nameLab.font = [UIFont systemFontOfSize:18];
    }
    _nameLab.textColor = NV_TITLE_COLOR;
    [cardView addSubview:_nameLab];
    _roleLab = [[InsetsLabel alloc]init];
    _roleLab.backgroundColor = BLUE_LIGHT_COLOR;
    [_roleLab labelWithFontSize:12 textColor:BLUE_TITLE_COLOR];
    _roleLab.layer.masksToBounds = YES;
    _roleLab.layer.cornerRadius = 9;
    [cardView addSubview:_roleLab];
    
    _companyBtn = [[UILabel alloc]init];
    _companyBtn.textColor = BLUE_TITLE_COLOR;
    _companyBtn.font = [UIFont systemFontOfSize:13];
    _companyBtn.userInteractionEnabled = YES;
    [_companyBtn addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCompanyDetail)]];
    [cardView addSubview:_companyBtn];

    _zhiweiLab = [[UILabel alloc]init];
    [_zhiweiLab labelWithFontSize:13 textColor:COLOR737782];
    [cardView addSubview:_zhiweiLab];
  
    
    //contact
    _phoneLab = [[UIButton alloc]init];
    [_phoneLab setTitleColor:COLOR737782 forState:UIControlStateNormal];
    [_phoneLab setImage:[UIImage imageNamed:@"contactInfo_phone"] forState:UIControlStateNormal];
    [_phoneLab setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _phoneLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [cardView addSubview:_phoneLab];
    _wechatLab = [[UIButton alloc]init];
    [_wechatLab setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_wechatLab setTitleColor:COLOR737782 forState:UIControlStateNormal];
    [_wechatLab setImage:[UIImage imageNamed:@"contactInfo_wechat"] forState:UIControlStateNormal];
    _wechatLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [cardView addSubview:_wechatLab];
    _emailLab = [[UIButton alloc]init];
    [_emailLab setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_emailLab setTitleColor:COLOR737782 forState:UIControlStateNormal];
    _emailLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [_emailLab setImage:[UIImage imageNamed:@"contactInfo_email"] forState:UIControlStateNormal];
    [cardView addSubview:_emailLab];

    _tipInfoLab = [[UIButton alloc]init];
    [_tipInfoLab setTitleColor:COLOR737782 forState:UIControlStateNormal];
    [_tipInfoLab setTitle:@"交换联系方式后可见" forState:UIControlStateNormal];
    [_tipInfoLab setImage:[UIImage imageNamed:@"contactInfo_phone"] forState:UIControlStateNormal];
    [_tipInfoLab layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:10];
    _tipInfoLab.titleLabel.font = [UIFont systemFontOfSize:13];
    [_tipInfoLab setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    [cardView addSubview:_tipInfoLab];
    
    _cardImgV = [[UIImageView alloc]init];
    _cardImgV.backgroundColor = [UIColor whiteColor];
    _cardImgV.contentMode = UIViewContentModeScaleToFill;
    _cardImgV.image = [UIImage imageNamed:@"person_card"];
    [cardView addSubview:_cardImgV];
    _cardImgV.hidden = YES;
    
    self.editBtn = [[UIButton alloc]init];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [cardView addSubview:self.editBtn];
    
    [self makeConstraints];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:self.cardView.bounds];
    imgV.tag = 1000;
    imgV.backgroundColor = [UIColor whiteColor];
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.image = [UIImage imageNamed:@"detail_placeholder_card"];
    [self.cardView addSubview:imgV];
}

- (void)makeConstraints{
    
    [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [_iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cardView.mas_left).offset(16);
        make.top.equalTo(_cardView.mas_top).offset(8);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
        
    }];
    
    [_renzhengImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_iconImgV.mas_right);
        make.bottom.equalTo(_iconImgV.mas_bottom);
        make.width.equalTo(@(17));
        make.height.equalTo(@(17));
    }];

    
    [_iconLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cardView.mas_left).offset(16);
        make.top.equalTo(_cardView.mas_top).offset(8);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImgV.mas_right).equalTo(@(14));
        make.top.equalTo(_cardView).equalTo(@(18));
        make.height.equalTo(@(17));
    }];
    
    [_roleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLab.mas_right).offset(8);
        make.right.equalTo(_editBtn).offset(-6).priorityLow();
        make.height.equalTo(@(18));
        make.centerY.equalTo(_nameLab.mas_centerY);
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_cardView).offset(-6);
        make.centerY.equalTo(_nameLab.mas_centerY);
        make.height.equalTo(@(20));
        make.width.equalTo(@(50));
    }];
    
    [_cardImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_cardView.mas_right).offset(-16);
        make.top.equalTo(_cardView.mas_top).offset(88);
        make.width.equalTo(@(80));
        make.height.equalTo(@(50));
    }];
    
    //防扩张
    [_roleLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_roleLab setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];

    [_nameLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_nameLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [_companyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImgV.mas_right).equalTo(@(14));
        make.top.equalTo(_nameLab.mas_bottom).offset(10);
        make.height.equalTo(@(14));
//        make.width.greaterThanOrEqualTo(@(40));
    }];
    
    [_zhiweiLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(14));
        make.left.equalTo(_companyBtn.mas_right);
        make.right.equalTo(_cardView.mas_right).offset(-14);
        make.centerY.equalTo(_companyBtn.mas_centerY);
    }];

    
    [_zhiweiLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_zhiweiLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_companyBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_companyBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [_phoneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImgV.mas_left).offset(5);
        make.top.equalTo(_iconImgV.mas_bottom).offset(6);
        make.width.greaterThanOrEqualTo(@(40));
        make.height.equalTo(@(22));
    }];
    [_wechatLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneLab.mas_left);
        make.top.equalTo(_phoneLab.mas_bottom);
        make.width.greaterThanOrEqualTo(@(40));
        make.height.equalTo(@(22));
    }];
    [_emailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneLab.mas_left);
        make.top.equalTo(_wechatLab.mas_bottom);
        make.height.equalTo(@(22));
        make.right.equalTo(_cardView.mas_right).offset(-10);
    }];

    [_tipInfoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneLab.mas_left);
        make.bottom.equalTo(_cardView.mas_bottom).offset(-14);
        make.height.equalTo(@(17));
        make.width.greaterThanOrEqualTo(@(40));
    }];
    
}

- (void)addCopyGesture{
    [_phoneLab addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [_phoneLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyPhone)]];
    [_wechatLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyWechat)]];
    [_emailLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyEmail)]];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    [_iconImgV cornerRadius:_iconImgV.width/2.0 borderWidth:0.5 borderColor:BORDER_LINE_COLOR];
    _iconLab.layer.masksToBounds = YES;
    _iconLab.layer.cornerRadius = _iconLab.width/2.0;
    
    [_phoneLab layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:10];
    [_wechatLab layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:10];
    [_emailLab layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:10];
   
    //来自人物主页
    if (!self.infoDic) {
        if ( !self.viewModel.person) {
            UIImageView *imgV = [self.cardView viewWithTag:1000];
            imgV.frame = self.cardView.bounds;
        }else{
            [[self.cardView viewWithTag:1000] removeFromSuperview];
        }
    }else{
        [[self.cardView viewWithTag:1000] removeFromSuperview];
    }
        
}


- (void)setPerson:(PersonModel *)person{
    if (!person) {
        self.height = 150;
        return;
    }
    _person = person;
    
    if ([PublicTool isNull:_person.icon] ||  [_person.icon containsString:@"img.798youxi.com/product/upload/5a265f11811c9.png"]) {
        _iconImgV.hidden = YES;
        _iconLab.hidden = NO;
        NSArray * arcRandomColorArr = @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)];
        _iconLab.backgroundColor = self.iconLabColor ? :arcRandomColorArr[arc4random()%6];
        if (![PublicTool isNull:_person.name] && [_person.name length] >= 1) {
            _iconLab.text = [_person.name substringToIndex:1];
        }else{
            _iconLab.text = @"";
        }
    }else{
        _iconLab.hidden = YES;
        _iconImgV.hidden = NO;
        [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_person.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    }
    
    NSString *name = [PublicTool isNull:person.name] ? @"-":person.name;
    
    if (person.ename.length && ![person.name containsString:@"("] && ![person.name containsString:@"（"]) {
        name = [NSString stringWithFormat:@"%@(%@)",person.name,person.ename];
        
    }
    
    if (person.name && [name containsString:@"("]) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:name];
        NSRange range = [name rangeOfString:@"("];
        [attText addAttributes:@{NSForegroundColorAttributeName:H5COLOR,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(range.location, name.length - range.location)];
        _nameLab.attributedText = attText;
        
    }else{
        _nameLab.text = name;
    }
    
    ZhiWeiModel *zhiwei;
    NSString *zhiwu;
    if (person.work_exp.count) {
        zhiwei = person.work_exp[0];
        _companyBtn.text = [NSString stringWithFormat:@"%@",zhiwei.name];
        _zhiweiLab.text = [@" | " stringByAppendingString:[NSString stringWithFormat:@"%@",zhiwei.zhiwu]];
        zhiwu = zhiwei.zhiwu;
        if ([PublicTool isNull:zhiwei.detail]) {
            _companyBtn.textColor = COLOR737782;
        }else{
            _companyBtn.textColor = BLUE_TITLE_COLOR;
        }
    }else{
        _companyBtn.text = @"-";
        _companyBtn.textColor = H9COLOR;
        _zhiweiLab.text = @" | -";
    }
    
    //角色 cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
    NSMutableString *roleString = [NSMutableString string];
    
    for (NSString *roleStr in person.role) {
        if ([roleStr isEqualToString:@"cyz"]) {
            [roleString appendString:@"创业者 "];
        }else if ([roleStr isEqualToString:@"investor"]) {
            [roleString appendString:@"投资人 "];
        }else if ([roleStr isEqualToString:@"FA"]) {
            [roleString appendString:@"FA "];
        }else if ([roleStr isEqualToString:@"specialist"]) {
            [roleString appendString:@"专家 "];
        }else if ([roleStr isEqualToString:@"media"]) {
            [roleString appendString:@"媒体 "];
        }else if ([roleStr isEqualToString:@"other"]) {
            
        }else{
            
        }
    }
    
    if (roleString.length) {
        [roleString deleteCharactersInRange:NSMakeRange(roleString.length-1, 1)];
        if(roleString.length > 6){
            [roleString stringByReplacingCharactersInRange:NSMakeRange(5, roleString.length-6) withString:@"..."];
        }
        _roleLab.text = roleString;
        
    }else{
        _roleLab.text = @"";
        _roleLab.hidden = YES;
    }
    
    //赋值
    [_wechatLab setTitle:[PublicTool nilStringReturn:person.wechat] forState:UIControlStateNormal];
    [_emailLab setTitle:[PublicTool nilStringReturn:person.email] forState:UIControlStateNormal];
    [_phoneLab setTitle:[PublicTool nilStringReturn:person.phone] forState:UIControlStateNormal];
    
    if ([PublicTool isNull:person.phone]) {
        [_phoneLab setTitleColor:H9COLOR forState:UIControlStateNormal];
    }else{
        [_phoneLab setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    }
    
    //名片
    if (self.isMy) {
        self.cardImgV.hidden = NO;
        if (![PublicTool isNull:person.cardurl]) {
            [self.cardImgV sd_setImageWithURL:[NSURL URLWithString:person.cardurl] placeholderImage:[UIImage imageNamed:@"person_card"]];
        }
    }else{
        self.cardImgV.hidden = YES;
    }
    [self refreshCardChangeStatusOfPerson];
    
    [self setNeedsLayout];
}


- (void)setInfoDic:(NSDictionary *)infoDic{
    
    _infoDic = infoDic;

    [self refreshPersonInfoView];
    
}

- (void)refreshPersonInfoView{
    
    _renzhengImg.hidden = YES;
    _roleLab.hidden = YES;
    _tipInfoLab.hidden = YES;
    _phoneLab.hidden = NO;
    _wechatLab.hidden = NO;
    _emailLab.hidden = NO;
    if ([PublicTool isNull:self.infoDic[@"headimgurl"]]) {
        _iconImgV.hidden = YES;
        _iconLab.hidden = NO;
        NSArray * arcRandomColorArr = @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)];
        _iconLab.backgroundColor = self.iconLabColor ? :arcRandomColorArr[arc4random()%6];
        if (![PublicTool isNull:self.infoDic[@"nickname"]] && [self.infoDic[@"nickname"] length] >= 1) {
            _iconLab.text = [self.infoDic[@"nickname"] substringToIndex:1];
        }else{
            _iconLab.text = @"";
        }
    }else{
        _iconLab.hidden = YES;
        _iconImgV.hidden = NO;
        [_iconImgV sd_setImageWithURL:[NSURL URLWithString:self.infoDic[@"headimgurl"]] placeholderImage:[UIImage imageNamed:@"heading"]];
    }
    
    _nameLab.text = self.infoDic[@"nickname"];
    
    _companyBtn.text = [PublicTool isNull:self.infoDic[@"company"]] ? @"-":self.infoDic[@"company"];
    if ([PublicTool isNull:_companyBtn.text]) {
        _companyBtn.textColor = H9COLOR;
    }else{
        if (![PublicTool isNull:self.infoDic[@"detail_link"]]) {
            _companyBtn.textColor = BLUE_TITLE_COLOR;
        }else{
            _companyBtn.textColor = H9COLOR;
        }
    }
    _zhiweiLab.text = [PublicTool isNull:self.infoDic[@"zhiwei"]] ? @" | -":[NSString stringWithFormat:@" | %@",self.infoDic[@"zhiwei"]];

    
    [_wechatLab setTitle:[PublicTool isNull:self.infoDic[@"wechat"]] ? @"-":self.infoDic[@"wechat"] forState:UIControlStateNormal];
    [_emailLab setTitle:[PublicTool isNull:self.infoDic[@"email"]] ? @"-":self.infoDic[@"email"] forState:UIControlStateNormal];
    [_phoneLab setTitle:[PublicTool isNull:self.infoDic[@"bind_phone"]] ? ([PublicTool isNull:self.infoDic[@"phone"]] ? @"-":self.infoDic[@"phone"]):self.infoDic[@"bind_phone"] forState:UIControlStateNormal];
    
    if ([_phoneLab.titleLabel.text isEqualToString:@"-"] || [PublicTool isNull:_phoneLab.titleLabel.text]) {
        [_phoneLab setTitleColor:H9COLOR forState:UIControlStateNormal];
    }else{
        [_phoneLab setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    }
    
    [self refreshCardChangeStatusOfUser];

}

- (void)refreshCardChangeStatusOfPerson{
    
    _tipInfoLab.hidden = YES;
    _phoneLab.hidden = YES;
    _wechatLab.hidden = YES;
    _emailLab.hidden = YES;
    [self addCopyGesture];
    
    _renzhengImg.hidden = self.viewModel.person.claim_type.integerValue != 2;

    if (self.isMy) {
        _phoneLab.hidden = NO;
        _wechatLab.hidden = NO;
        _emailLab.hidden = NO;
        self.height = 68+6+22*3+13;
        return;
    }
    self.height = 68+13;
    return;
}

- (void)refreshCardChangeStatusOfUser{
    
    _tipInfoLab.hidden = YES;
    _phoneLab.hidden = YES;
    _wechatLab.hidden = YES;
    _emailLab.hidden = YES;
    
    //好友关系
    // 我自己
    if ([_infoDic[@"usercode"] isEqualToString:[WechatUserInfo shared].usercode]) {
        _phoneLab.hidden = NO;
        _wechatLab.hidden = NO;
        _emailLab.hidden = NO;
        [self addCopyGesture];
        self.height = 68+6+22*3+13;
        return;
    }

    _phoneLab.hidden = YES;
    _wechatLab.hidden = YES;
    _emailLab.hidden = YES;
    self.height = 68+13;
    [self updateConstraints];
    
}

- (void)enterCompanyDetail{
    if (self.person) { //人物
        if (self.person.work_exp.count == 0) {
            return;
        }
        ZhiWeiModel *zhiwei = self.person.work_exp[0];
        [self toDetailVC:zhiwei.detail];
        
    }else if(self.infoDic){ //个人
        [self toDetailVC:self.infoDic[@"detail_link"]];
    }
}

- (void)toDetailVC:(NSString*)detail{
    
    if ([PublicTool isNull:detail]) {
        return;
    }
    NSString *jump_type = self.infoDic[@"jump_type"];
    if (self.person) {
        jump_type = [self.person.work_exp.firstObject jump_type];
    }
    NSDictionary *dic = [PublicTool toGetDictFromStr:detail];
    if ([ jump_type containsString:@"product"]) {
        [[AppPageSkipTool shared] appPageSkipToProductDetail:dic];
    }else if([jump_type containsString:@"jigou"]){
        [[AppPageSkipTool shared] appPageSkipToJigouDetail:dic];
    }else if([jump_type containsString:@"register"]){
        [[AppPageSkipTool shared] appPageSkipToRegisterDetail:dic];
    }
}


- (void)phoneClick:(UIButton*)btn{
    if (self.person && ![PublicTool isNull:self.person.phone]) {
        
        [PublicTool dealPhone:self.person.phone];
        
    }else  if(self.infoDic && ![PublicTool isNull:self.infoDic[@"phone"]]){
        [PublicTool dealPhone:self.infoDic[@"phone"]];
    }
}

- (void)copyPhone{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.person && ![PublicTool isNull:self.person.phone]) {
        board.string = self.person.phone;
        [PublicTool showMsg:@"复制成功"];
        return;
    }else if(self.infoDic && ![PublicTool isNull:self.infoDic[@"phone"]]){
        board.string = self.infoDic[@"phone"];
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}
- (void)copyWechat{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.person && ![PublicTool isNull:self.person.wechat]) {
        board.string = self.person.wechat;
        [PublicTool showMsg:@"复制成功"];
        return;
    }else if(self.infoDic && ![PublicTool isNull:self.infoDic[@"wechat"]]){
        board.string = self.infoDic[@"wechat"];
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}
- (void)copyEmail{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.person && ![PublicTool isNull:self.person.email]) {
        board.string = self.person.email;
        [PublicTool showMsg:@"复制成功"];
        return;
    }else if(self.infoDic && ![PublicTool isNull:self.infoDic[@"email"]]){
        board.string = self.infoDic[@"email"];
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}
@end
