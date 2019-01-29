//
//  MemberPersonCell2.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MemberPersonCell2.h"
#import "InsetsLabel.h"

@interface MemberPersonCell2()
{
    
    __weak IBOutlet UIImageView *_headerIcon;
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_descLab;
    __weak IBOutlet UILabel *_zhiwuLab;
    __weak IBOutlet UILabel *_iconLab;
    
//    __weak IBOutlet InsetsLabel *_statusLabel;
    
    __weak IBOutlet NSLayoutConstraint *_renzhengIconLeading;
}
@property (weak, nonatomic) IBOutlet UILabel *noRegisterLbl;

@end

@implementation MemberPersonCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _headerIcon.layer.masksToBounds = YES;
    _headerIcon.layer.cornerRadius = 22.5;
    _headerIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _headerIcon.layer.borderWidth = 0.5;
    
    _iconLab.layer.masksToBounds = YES;
    _iconLab.layer.cornerRadius = 22.5;
    _iconLab.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconLab.layer.borderWidth = 0.5;
    
    [_statusLabel labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2 borderWdith:0.5 borderColor:BLUE_TITLE_COLOR];
    _statusLabel.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    _statusLabel.text = @"FA";
    
    _contactButton.layer.cornerRadius = 15;
    _contactButton.clipsToBounds = YES;
    _contactButton.backgroundColor = [BLUE_BG_COLOR colorWithAlphaComponent:0.08];
    [_contactButton setTitleColor:HTColorFromRGB(0x006EDA) forState:UIControlStateNormal];
    
    _nameLab.textColor = H3COLOR;
    _zhiwuLab.textColor = H6COLOR;
    _descLab.textColor = COLOR737782;
}


- (void)setManager:(ManagerItem *)manager{
    
    _manager = manager;
    if (manager.is_adviser.integerValue == 1) {
        _statusLabel.hidden = NO;
        self.statusLabel.text = @"FA";
//        [_statusLabel labelWithFontSize:12 textColor:BLUE_TITLE_COLOR cornerRadius:4 borderWdith:0.5 borderColor:BLUE_BG_COLOR];
        [_statusLabel labelWithFontSize:10 textColor:HTColorFromRGB(0x006EDA) cornerRadius:2 borderWdith:0.5 borderColor:HTColorFromRGB(0x006EDA)];
        _statusLabel.backgroundColor = [UIColor whiteColor];
        
    }else  if (manager.is_dimission.intValue == 1) {
        
        _statusLabel.hidden = NO;
        [_statusLabel labelWithFontSize:10 textColor:H9COLOR cornerRadius:2 borderWdith:0 borderColor:nil];
        _statusLabel.backgroundColor = HTColorFromRGB(0xe3e3e3);
        self.statusLabel.text = @"已离职";

    }else{
        _statusLabel.hidden = YES;
        self.statusLabel.text = @"";
    }
    
    [_headerIcon sd_setImageWithURL:[NSURL URLWithString:manager.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    
    _nameLab.text = [PublicTool isNull:manager.name]?([PublicTool isNull:manager.ename]?@"-":manager.ename):manager.name;
    _zhiwuLab.text = manager.zhiwu;
    if (![PublicTool isNull:manager.jieshao]) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1.0;
        style.alignment = NSTextAlignmentJustified;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        NSAttributedString *desc = [[NSAttributedString alloc] initWithString:manager.jieshao
                                                                   attributes:@{
                                                                                NSFontAttributeName: _descLab.font,
                                                                                NSForegroundColorAttributeName: _descLab.textColor,
                                                                                NSParagraphStyleAttributeName: style,
                                                                                
                                                                                }];
        _descLab.attributedText = desc;
        
    } else {
        _descLab.attributedText = [[NSAttributedString alloc]initWithString:@" "];
    }
    if (![_manager.claim_type isEqualToString:@"2"]) {
        self.noRegisterLbl.hidden = NO;
    }else{
        self.noRegisterLbl.hidden = YES;
    }
    
    [_descLab sizeToFit];
    [self setNeedsUpdateConstraints];
}

- (void)setStatusTxt:(NSString *)statusTxt{
    _statusTxt = statusTxt;
    _statusLabel.text = _statusTxt;
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

@end
