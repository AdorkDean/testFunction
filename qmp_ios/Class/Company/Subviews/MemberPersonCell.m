//
//  MemberPersonCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MemberPersonCell.h"
#import "InsetsLabel.h"

@interface MemberPersonCell()
{
    
    __weak IBOutlet UIImageView *_headerIcon;
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_descLab;
    __weak IBOutlet UILabel *_zhiwuLab;
    __weak IBOutlet UILabel *_iconLab;
    
//    __weak IBOutlet InsetsLabel *_statusLabel;
    
    __weak IBOutlet NSLayoutConstraint *_renzhengIconLeading;
}
//@property (weak, nonatomic) IBOutlet UILabel *noRegisterLbl;

@property (nonatomic, strong) UIView *noRegisterLbl;
@end

@implementation MemberPersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _headerIcon.layer.masksToBounds = YES;
    _headerIcon.layer.cornerRadius = 24.0;
    _headerIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _headerIcon.layer.borderWidth = 0.5;
    
    _iconLab.layer.masksToBounds = YES;
    _iconLab.layer.cornerRadius = 24.0;
    _iconLab.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconLab.layer.borderWidth = 0.5;
    
    [_statusLabel labelWithFontSize:12 textColor:BLUE_TITLE_COLOR cornerRadius:4 borderWdith:0.5 borderColor:BLUE_BG_COLOR];
    _statusLabel.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    _statusLabel.text = @"FA 融资顾问";
    [self.clickCardBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.clickCardBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    self.clickCardBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.clickCardBtn.backgroundColor = [UIColor whiteColor];
    self.clickCardBtn.hidden = YES;
    
    _nameLab.textColor = HTColorFromRGB(0x333333);
    _zhiwuLab.textColor = HTColorFromRGB(0x333333);
    _descLab.textColor = HTColorFromRGB(0x666666);

    [_headerIcon addSubview:self.noRegisterLbl];
}


- (void)setManager:(ManagerItem *)manager{
    
    _manager = manager;
    if (manager.is_adviser.integerValue == 1) {
        _statusLabel.hidden = NO;
        self.statusLabel.text = @"FA 融资顾问";
        [_statusLabel labelWithFontSize:12 textColor:BLUE_TITLE_COLOR cornerRadius:4 borderWdith:0.5 borderColor:BLUE_BG_COLOR];
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
    
    self.noRegisterLbl.hidden = YES;
}

- (void)setHiddenStatusLab:(BOOL)hiddenStatusLab{
    if (hiddenStatusLab) {
        _statusLabel.text = @"";
        _statusLabel.hidden = YES;
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
- (UIView *)noRegisterLbl {
    if (!_noRegisterLbl) {
        _noRegisterLbl = [[UIView alloc] init];
        _noRegisterLbl.frame = CGRectMake(0, 26, 48, 22);
        _noRegisterLbl.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 4, 48, 9);
        label.font = [UIFont systemFontOfSize:9];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = @"暂未入驻";
        [_noRegisterLbl addSubview:label];
    }
    return _noRegisterLbl;
}
@end
