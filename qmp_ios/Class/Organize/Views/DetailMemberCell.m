//
//  DetailMemberCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailMemberCell.h"
#import "ManagerItem.h"
#import "InsetsLabel.h"

@interface DetailMemberCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet InsetsLabel *dismissLab;

@end

@implementation DetailMemberCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarView.layer.cornerRadius = self.avatarView.width / 2;
    self.avatarView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.clipsToBounds = YES;
    
    _nameLabel.textColor = COLOR2D343A;
    _positionLabel.textColor = COLOR737782;
    _descLabel.textColor = COLOR737782;
    
    [_dismissLab labelWithFontSize:10 textColor:H9COLOR cornerRadius:2 borderWdith:0 borderColor:nil];
    _dismissLab.backgroundColor = HTColorFromRGB(0xe3e3e3);
}

- (void)setUser:(ManagerItem *)user {
    _user = user;
    
//    if (user.is_dimission.intValue == 1) {
//        _dismissLab.hidden = NO;
//        _dismissLab.text = @"已离职";
//    }else{
//    }
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    self.nameLabel.text = user.name;
    self.positionLabel.text = user.zhiwu;
    
    if (![PublicTool isNull:user.jieshao]) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1.0;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        NSAttributedString *desc = [[NSAttributedString alloc] initWithString:user.jieshao
                                                                   attributes:@{
                                                                                NSFontAttributeName: self.descLabel.font,
                                                                                NSForegroundColorAttributeName: self.descLabel.textColor,
                                                                                NSParagraphStyleAttributeName: style,
                                                                                
                                                                                                        }];
        self.descLabel.attributedText = desc;
    } else {
        self.descLabel.text = @"";
    }
    [_positionLabel sizeToFit];
}


@end
