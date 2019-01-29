//
//  OneInvoiceTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/6/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "OneInvoiceTableViewCell.h"
#import "GetSizeWithText.h"
#import <objc/runtime.h>
#import "FactoryUI.h"

@interface OneInvoiceTableViewCell()
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) UIButton *copysBtn;
@property (strong, nonatomic) GetSizeWithText *sizeTool;
@end
@implementation OneInvoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLbl = [FactoryUI createLabelWithFrame: CGRectMake(16.f, 15.f, 70.f,20.f) textColor:H999999 fontNum:15.f textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:titleLbl];
        self.titleLbl = titleLbl;
        
        UILabel *infoLbl = [FactoryUI createLabelWithFrame:CGRectZero textColor:[UIColor blackColor] fontNum:15.f textAlignment:NSTextAlignmentLeft];
        infoLbl.numberOfLines = 0;
        infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:infoLbl];
        self.infoLbl = infoLbl;
        
        UIButton *copyBtn = [FactoryUI createButtonWithFrame:CGRectZero title:@"复制" titleColor:[UIColor grayColor] fontNum:12.f textAlignment:UIControlContentHorizontalAlignmentCenter];
        copyBtn.layer.masksToBounds = YES;
        copyBtn.layer.borderColor = [UIColor grayColor].CGColor;
        copyBtn.layer.borderWidth = 0.5f;
        [self.contentView addSubview:copyBtn];
        self.copysBtn = copyBtn;
    }
    return self;
}

- (void)initKey:(NSString *)key withValue:(NSString*)value{
    
    CGFloat margin = 16.f;
    
    self.titleLbl.text = key;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    [style setLineSpacing:4.f];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:value];
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, value.length)];
    self.infoLbl.attributedText = attStr;

    NSDictionary *attribute = @{NSFontAttributeName: self.infoLbl.font,NSParagraphStyleAttributeName:style};
    CGFloat lblW = SCREENW - margin * 2 - self.titleLbl.width;
    CGFloat lblH = ceil([self.sizeTool calculateSize:value withDict:attribute withWidth:lblW].height);
    NSArray *keyArr = @[@"单位名称",@"单位地址",@"开户银行"];
    self.infoLbl.frame = CGRectMake(self.titleLbl.left + self.titleLbl.width, ([keyArr containsObject:key] && lblH < 22.f) ? 17.f : 15.f,lblW,lblH > 22.f ? lblH : 20.f);
    
    if (![key isEqualToString:@"税号"]&&![key isEqualToString:@"银行账号"] && ![key isEqualToString:@"单位名称"]) {
        self.copysBtn.hidden = YES;
        [self.copysBtn removeTarget:self action:@selector(pressCopyBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        CGFloat copyW = 30.f;
        self.copysBtn.frame = CGRectMake(SCREENW - copyW - margin, self.titleLbl.top, copyW, 20.f);
        self.copysBtn.hidden = NO;
        [self.copysBtn addTarget:self action:@selector(pressCopyBtn:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self.copysBtn, "copyStr", [NSString stringWithFormat:@"%@",value], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }
}

- (void)pressCopyBtn:(UIButton *)sender{
    NSString *copyStr = (NSString *)objc_getAssociatedObject(sender, "copyStr");
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = copyStr;
    
    [ShowInfo showInfoOnView:KEYWindow withInfo:@"复制成功"];
}

- (GetSizeWithText *)sizeTool{

    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}
@end
