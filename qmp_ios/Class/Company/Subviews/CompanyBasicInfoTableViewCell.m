//
//  CompanyBasicInfoTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 2016/12/15.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanyBasicInfoTableViewCell.h"
#import "GetSizeWithText.h"
#import "NewsWebViewController.h"
#import "CompanyInfoView.h"

@interface CompanyBasicInfoTableViewCell()
{
    UIView *_bottomLine;
}
@property (strong, nonatomic) UILabel *keyLbl;

@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong,nonatomic)CompanyDetailBasicModel *basicModel;
@end

@implementation CompanyBasicInfoTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanyBasicInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanyBasicInfoTableViewCellID"];
    if (!cell) {
        cell = [[CompanyBasicInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanyBasicInfoTableViewCellID"];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *keyLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 77, 44.f)];
        keyLbl.font = [UIFont systemFontOfSize:14.f];
        keyLbl.textColor = H4COLOR;
        keyLbl.numberOfLines = 1;
        keyLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:keyLbl];
        self.keyLbl = keyLbl;
        
        UILabel *infoLbl = [[UILabel alloc] init];
        infoLbl.numberOfLines = 0;
        infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
        infoLbl.font = [UIFont systemFontOfSize:14.f];
        infoLbl.textColor = H3COLOR;
        infoLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:infoLbl];
        self.infoLbl = infoLbl;
        
        CGFloat searchW = 60;
        SearchButton *searchBtn = [[SearchButton alloc] initWithFrame:CGRectMake(SCREENW - searchW - 17, 0, searchW, 44)];
        [searchBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [searchBtn setTitle:@"百度一下" forState:UIControlStateNormal];
        [self.contentView addSubview:searchBtn];
        searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        searchBtn.centerY = infoLbl.centerY;
        self.searchBtn = searchBtn;
        self.searchBtn.hidden = YES;
        
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, 0, SCREENW-34, 0.5)];
        _bottomLine.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:_bottomLine];
        _bottomLine.hidden = YES;
    }
    return self;
}


// 工商详情
- (void)initDataWithKey:(NSString *)key withValue:(NSString *)value{

    self.searchBtn.hidden = YES;
    self.keyLbl.textColor = H9COLOR;
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];

    _infoLbl.textColor = H3COLOR;
    _bottomLine.hidden = YES;
    _infoLbl.text = value;
    
    if ([key isEqualToString:@"描述"]) {
        _keyLbl.text = @"";
        
        UIFont *jianjieFont = [UIFont systemFontOfSize:15.f];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        [style setLineSpacing:4.f];
        NSDictionary *attribute = @{NSFontAttributeName:jianjieFont,NSParagraphStyleAttributeName:style};
        CGFloat jianjieX = 17.f;
        CGFloat jianjieW = SCREENW - jianjieX - 17;
        CGFloat jianjieH = ceil([self.sizeTool calculateSize:value withDict:attribute withWidth:jianjieW].height);
        _infoLbl.frame = CGRectMake(jianjieX, 18, jianjieW, jianjieH > 120 ? 120 : jianjieH);
        
        _infoLbl.numberOfLines = 0;
        _infoLbl.font = jianjieFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:value];
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, value.length)];
        _infoLbl.attributedText = attStr;
        _infoLbl.lineBreakMode = NSLineBreakByTruncatingTail;
        [_infoLbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDetailInfo)]];
        _bottomLine.hidden = NO;
        _bottomLine.bottom = _infoLbl.bottom + 17;
   
    }else{
        
        for (UITapGestureRecognizer *tap in _infoLbl.gestureRecognizers) {
            if ([tap isKindOfClass:[UITapGestureRecognizer class]]) {
                [_infoLbl removeGestureRecognizer:tap];
            }
        }
        NSString *keyStr = [NSString stringWithFormat:@"%@：",key];
        _keyLbl.text = keyStr;
        CGFloat keyW = 80;
        _keyLbl.frame = CGRectMake(15, 0, keyW, 40.f);
        CGFloat jianjieX = self.keyLbl.frame.origin.x + self.keyLbl.frame.size.width;
        CGFloat jianjieW = SCREENW - jianjieX - 10;
        
        if ([key isEqualToString:@"法人代表"] || [key isEqualToString:@"公司名称"]) {
            _infoLbl.textColor = BLUE_TITLE_COLOR;

        }
        
        _infoLbl.numberOfLines = -1;
        _infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
        self.infoLbl.frame = CGRectMake(jianjieX, _keyLbl.top, jianjieW, 40.f);
        self.searchBtn.centerY = _keyLbl.centerY;
        if ([key isEqualToString:@"公司名称"] || [key isEqualToString:@"注册号"] || [key isEqualToString:@"信用代码"] || [key isEqualToString:@"注册地点"] || [key isEqualToString:@"登记机关"]|| [key isEqualToString:@"机构代码"]) {
            self.infoLbl.text = value;
            self.infoLbl.userInteractionEnabled = YES;
            UILongPressGestureRecognizer * longPGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTarget:)];
            [self.infoLbl addGestureRecognizer:longPGR];
           
        }else if ([key isEqualToString:@"法人代表"]) {
            self.infoLbl.text = value;
            
        }else if ([key isEqualToString:@"成立时间"]) {
            self.infoLbl.text = value;
            
        }else if ([key isEqualToString:@"公司官网"]) {
            self.infoLbl.text = value;
            _infoLbl.textColor = BLUE_TITLE_COLOR;
            
            [_infoLbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterGuanWang)]];
        }else if([key isEqualToString:@"公司估值"]){
            self.infoLbl.text = [NSString stringWithFormat:@"%@",value];
    
        }
        CGFloat width = SCREENW-107;
        CGFloat height = [self.infoLbl.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height+1;
        if (height < 35) {
            self.infoLbl.top = 0;
            self.infoLbl.height = 40;
        }else{
            self.infoLbl.top += 1;
            self.infoLbl.height = 60;
            NSAttributedString *muAtt = [_infoLbl.text stringWithParagraphlineSpeace:4 textColor:_infoLbl.textColor textFont:_infoLbl.font];
            self.infoLbl.attributedText = muAtt;
        }
        
        if ([key isEqualToString:@"公司名称"] || [key isEqualToString:@"法人代表"]) {
            self.searchBtn.hidden = NO;
            self.infoLbl.frame = CGRectMake(jianjieX, _keyLbl.top, jianjieW-70, 40.f);
            self.searchBtn.centerY = self.infoLbl.centerY;
        }
    }
    
}


//公司详情  wss
- (void)dataWithKey:(NSString *)key withValue:(CompanyDetailBasicModel *)model{
   
    self.basicModel = model;
    self.searchBtn.hidden = YES;
//    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _infoLbl.textColor = H3COLOR;
    _bottomLine.hidden = YES;

    if ([key isEqualToString:@"描述"]) {
        _keyLbl.text = @"";
        
        UIFont *jianjieFont = [UIFont systemFontOfSize:15.f];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        [style setLineSpacing:4.f];
        NSDictionary *attribute = @{NSFontAttributeName:jianjieFont,NSParagraphStyleAttributeName:style};
        CGFloat jianjieX = 17.f;
        CGFloat jianjieW = SCREENW - jianjieX - 15;
        CGFloat jianjieH = ceil([self.sizeTool calculateSize:model.miaoshu withDict:attribute withWidth:jianjieW].height);
        _infoLbl.frame = CGRectMake(jianjieX, 20, jianjieW, jianjieH > 120 ? 120 : jianjieH);
        
        _infoLbl.numberOfLines = 0;
        _infoLbl.font = jianjieFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.miaoshu];
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, model.miaoshu.length)];
        _infoLbl.attributedText = attStr;
        _infoLbl.lineBreakMode = NSLineBreakByTruncatingTail;
        [_infoLbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDetailInfo)]];
        _bottomLine.hidden = NO;
        _bottomLine.bottom = _infoLbl.bottom + 15;
        if (self.justShowDesc) {
            _bottomLine.hidden = YES;
            _infoLbl.height = jianjieH;
        }
    }
    else{
        
        for (UITapGestureRecognizer *tap in _infoLbl.gestureRecognizers) {
            if ([tap isKindOfClass:[UITapGestureRecognizer class]]) {
                [_infoLbl removeGestureRecognizer:tap];
            }
        }

        NSString *keyStr = [NSString stringWithFormat:@"%@：",key];
        _keyLbl.text = keyStr;
        CGFloat keyW = 80;
        _keyLbl.frame = CGRectMake(15, 0, keyW, 30.f);
        CGFloat jianjieX = self.keyLbl.frame.origin.x + self.keyLbl.frame.size.width;
        CGFloat jianjieW = SCREENW - jianjieX - 10;

        if ([key isEqualToString:@"法人代表"]) { //[key isEqualToString:@"公司名称"]) && [model.country isEqualToString:@"CN"]
            _infoLbl.textColor = BLUE_TITLE_COLOR;
    
        }
        
        _infoLbl.numberOfLines = 2;
        _infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
        self.infoLbl.frame = CGRectMake(jianjieX, _keyLbl.top, jianjieW, 40.f);
        self.searchBtn.centerY = _keyLbl.centerY;
        CGFloat width = SCREENW - 107;

        if ([key isEqualToString:@"公司名称"]) {
            self.infoLbl.text = model.company;
            _infoLbl.textColor = BLUE_TITLE_COLOR;

        }else if ([key isEqualToString:@"法人代表"]) {
            self.infoLbl.text = model.faren;
//            self.searchBtn.hidden = NO;
        }else if ([key isEqualToString:@"成立时间"]) {
            self.infoLbl.text = model.open_time;
            
        }else if ([key isEqualToString:@"公司官网"]) {
            self.infoLbl.text = model.gw_link;
            _infoLbl.textColor = BLUE_TITLE_COLOR;

            [_infoLbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterGuanWang)]];
            
        }else if([key isEqualToString:@"公司估值"]){
            width = SCREENW - 107;

            self.infoLbl.text = [NSString stringWithFormat:@"%@(%@)",model.valuations_money,model.valuations_time];
            if (self.model && ![PublicTool isNum:self.model.ziben_jieduan]) {
                self.keyLbl.text = @"公司市值：";
            }
        }else if([key containsString:@"地区"]){
            self.infoLbl.text = model.province;
        }else if([key containsString:@"行业"]){
            self.infoLbl.text = model.hangye1;
        }
    
        CGFloat height = [self.infoLbl.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height+1;
        if (height < 34) {
            self.infoLbl.top = 0;
            self.infoLbl.height = 40;
        }else{
            self.infoLbl.top += 1;
            self.infoLbl.height = 60;
            NSAttributedString *muAtt = [_infoLbl.text stringWithParagraphlineSpeace:4 textColor:_infoLbl.textColor textFont:_infoLbl.font];
            self.infoLbl.attributedText = muAtt;
            
        }
    }

}

- (void)enterGuanWang{
    URLModel *urlModel = [[URLModel alloc] init];
    urlModel.url = _infoLbl.text;
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"Homes"];
    webView.fromVC = @"官网";
    webView.hidesBottomBarWhenPushed = YES;
    [[PublicTool topViewController].navigationController pushViewController:webView animated:YES];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _infoLbl.height = self.height;
    _keyLbl.height = self.height;
    if (_infoLbl.height > 40) {
        _keyLbl.height = 34;
        _keyLbl.top = 0;
    }else{
        _keyLbl.centerY = self.height/2.0;
    }
    _infoLbl.centerY = self.height/2.0;
    _bottomLine.bottom = self.height;
}
#pragma mark --event--
- (void)showDetailInfo{
    
    NSString *info = self.basicModel.miaoshu;
    
    CompanyInfoView *alertV = [CompanyInfoView instanceCompanyInfoView:CGRectMake(0, 0, SCREENW, SCREENH) withName:self.basicModel.product withInfo:info];
    alertV.shortUrlStr = self.basicModel.short_url;
    [KEYWindow addSubview:alertV];
}


- (void)searchBtnClick{ //百度
    
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.title = @"百度一下";
    urlModel.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",[_infoLbl.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    webView.fromVC = @"baidu";
    [[PublicTool topViewController].navigationController pushViewController:webView animated:YES];
    if ([_keyLbl.text containsString:@"公司名称"]) {
        [QMPEvent event:@"regist_name_baiduclick"];
    }else if([_keyLbl.text containsString:@"法人"]){
        [QMPEvent event:@"regist_faren_baiduclick"];
    }

}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}
#pragma mark 公司名称长按复制
- (void)longPressTarget:(UILongPressGestureRecognizer *)longPgr{
    UILabel * infoLbl = (UILabel *)longPgr.view;
    NSString * copyTxt = infoLbl.text;

    UIPasteboard * pbd = [UIPasteboard generalPasteboard];
    pbd.string = copyTxt;
    [PublicTool showMsg:@"复制成功"];
}

@end
