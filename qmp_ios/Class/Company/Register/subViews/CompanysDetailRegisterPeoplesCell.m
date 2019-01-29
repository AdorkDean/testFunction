//
//  CompanysDetailRegisterPeoplesCell.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterPeoplesCell.h"
#import "CompanysDetailRegisterPeoplesModel.h"
#import "SearchButton.h"
#import "FactoryUI.h"

@interface CompanysDetailRegisterPeoplesCell ()
@property (nonatomic,strong) UILabel *xingLabel;

@property (nonatomic,strong) CopyLabel *nameLbl;
@property (nonatomic,strong) UILabel *jobLab;
@end
@implementation CompanysDetailRegisterPeoplesCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanysDetailRegisterPeoplesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanysDetailRegisterPeoplesCellID"];
    if (!cell) {
        cell = [[CompanysDetailRegisterPeoplesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanysDetailRegisterPeoplesCellID"];
    }
    return cell;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI{
    
    CGFloat searchW = 70.f;
//    SearchButton *searchBtn = [[SearchButton alloc] initWithFrame:CGRectMake(SCREENW - searchW - 17, 17.f, searchW, searchW)];
//    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [searchBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
//    [searchBtn setTitle:@"百度一下" forState:UIControlStateNormal];
//    [searchBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [self.contentView addSubview:searchBtn];
//    self.searchBtn = searchBtn;
    
    CGFloat imgW = 40.f;
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(17.f, 0.f, imgW, imgW)];
    [imgV setImage:[BundleTool imageNamed:@"person"]];
    imgV.layer.cornerRadius = 5;
    imgV.layer.masksToBounds = YES;
    imgV.layer.borderWidth = 0.5;
    imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    [self.contentView addSubview:imgV];
    self.xingLabel = [[UILabel alloc]initWithFrame:imgV.bounds];
    [_xingLabel labelWithFontSize:18 textColor:[UIColor whiteColor]];
    _xingLabel.textAlignment = NSTextAlignmentCenter;
    [imgV addSubview:_xingLabel];
    
    CGFloat nameX = imgV.right + 15.f;
    
    _nameLbl = [[CopyLabel alloc]initWithFrame:CGRectMake( nameX, 0, SCREENW- nameX - 17 ,35)];
    //设置标题颜色
    _nameLbl.textColor = COLOR737782;
    _nameLbl.font = [UIFont systemFontOfSize:15];
    _nameLbl.lineBreakMode = NSLineBreakByCharWrapping;
    _nameLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLbl];
    
    _nameLbl.centerY = imgV.centerY;
}
-(void)refreshUI:(CompanysDetailRegisterPeoplesModel *)model nameColor:(UIColor *)nameColor{
    
    NSString *name =  [PublicTool isNull:model.name] ? @"-":model.name;
    NSString *job =  [PublicTool isNull:model.zhiwu] ? @"-":model.zhiwu;
    NSString *text = [NSString stringWithFormat:@"%@ | %@",name,job];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:text];
    UIFont *font;
    if (@available(iOS 8.2, *)) {
        font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        font = [UIFont systemFontOfSize:15];
    }
    [attText addAttributes:@{NSForegroundColorAttributeName:COLOR2D343A,NSFontAttributeName:font} range:NSMakeRange(0, name.length)];
    _nameLbl.attributedText = attText;
    
    _xingLabel.backgroundColor = nameColor;
    if (model.name && model.name.length>0 ) {
        _xingLabel.text = [model.name substringWithRange:NSMakeRange(0, 1)];
        _xingLabel.hidden = NO;

    }else{
        _xingLabel.hidden = YES;
    }
}
@end
