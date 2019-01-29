//
//  CompanyPersonCell.m
//  qmp_ios
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyPersonCell.h"
#import "InsetsLabel.h"

@interface CompanyPersonCell()
{
    
    __weak IBOutlet UIImageView *_headerIcon;
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_zhiwuLab;
    __weak IBOutlet UILabel *_iconLab;
    
    __weak IBOutlet InsetsLabel *_statusLabel;
    
}
@end

@implementation CompanyPersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _headerIcon.layer.masksToBounds = YES;
    _headerIcon.layer.cornerRadius = 21.5;
    _headerIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _headerIcon.layer.borderWidth = 0.5;
    
    _iconLab.layer.masksToBounds = YES;
    _iconLab.layer.cornerRadius = 21.5;
    _iconLab.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconLab.layer.borderWidth = 0.5;
    
    _statusLabel.layer.masksToBounds = YES;
    _statusLabel.layer.cornerRadius = 10;
    _statusLabel.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _statusLabel.layer.borderWidth = 0.5;
    _statusLabel.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    
    //私信
    UIButton *chatBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 16-60, 0, 60, 28)];
    [chatBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    if (@available(iOS 8.2, *)) {
        chatBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    } else {
        chatBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    [chatBtn setTitle:@"私信" forState:UIControlStateNormal];
    chatBtn.backgroundColor = [BLUE_TITLE_COLOR colorWithAlphaComponent:0.08];
    chatBtn.layer.cornerRadius = 14;
    chatBtn.layer.masksToBounds = YES;
    [self.contentView addSubview:chatBtn];
    chatBtn.hidden = YES;
    self.chatBtn = chatBtn;
    
}


- (void)setManager:(ManagerItem *)manager{
    _manager = manager;
    if (manager.is_dimission.intValue == 1) {
        _statusLabel.hidden = NO;
    }else{
        _statusLabel.hidden = YES;
        
    }
    if (manager.claim_type.integerValue == 2) { //加V
      
    }else{
        
    }
    
    
    [_headerIcon sd_setImageWithURL:[NSURL URLWithString:manager.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    
    _nameLab.text = [PublicTool isNull:manager.name]?([PublicTool isNull:manager.ename]?@"-":manager.ename):manager.name;
    _zhiwuLab.text = manager.zhiwu;
    
}

- (void)setPerson:(SearchPerson *)person{
    
    _person = person;
    _statusLabel.hidden = YES;
    if (person.claim_type.integerValue == 2) { //加V
       

    }else{
    }
    
    [_headerIcon sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[UIImage imageNamed:@"heading"]];

//    _nameLab.text = [PublicTool isNull:person.name]?@"-":person.name;
    
    if (![PublicTool isNull:person.name]) {
        _nameLab.text = person.name;
    }else {
        _nameLab.text = @"-";
    }
    
    if (person.zhiwei.count) {
        ZhiWeiModel *zhiweiM = person.zhiwei[0];
        _zhiwuLab.text = [NSString stringWithFormat:@"%@ | %@",[PublicTool nilStringReturn:zhiweiM.company],[PublicTool nilStringReturn:zhiweiM.zhiwei]];
    }else{
        _zhiwuLab.text = @"";
    }
    
}

- (void)setIconColor:(UIColor *)iconColor{
    
    if (self.manager) {
        
        if ([PublicTool isNull:_manager.icon] || [_manager.icon containsString:@"5a265f11811c9.png"]) {
            _iconLab.hidden = NO;
            _iconLab.backgroundColor = iconColor;
            if (_nameLab.text.length > 1) {
                _iconLab.text = [_nameLab.text substringToIndex:1];
            }else{
                _iconLab.text = @"-";
            }
        }else{
            _iconLab.hidden = YES;
        }
        
    }else if(self.person){
        
        if ([PublicTool isNull:_person.icon] || [_manager.icon containsString:@"5a265f11811c9.png"]) {
            _iconLab.hidden = NO;
            _iconLab.backgroundColor = iconColor;
            if (_nameLab.text.length > 1) {
                _iconLab.text = [_nameLab.text substringToIndex:1];
            }else{
                _iconLab.text = @"-";
            }
        }else{
            _iconLab.hidden = YES;
        }
    }
   
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.chatBtn.centerY = self.contentView.centerY-2;
}

@end
