//
//  InvoiceListAddTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/6/6.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvoiceListAddTableViewCell.h"
#import "FactoryUI.h"

@implementation InvoiceListAddTableViewCell

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
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(16, 15, 20, 20)];
        [imgV setImage:[UIImage imageNamed:@"company_addToTag"]];
        [self.contentView addSubview:imgV];
        
        UILabel *lbl = [FactoryUI createLabelWithFrame:CGRectMake(imgV.left + imgV.width , 15, 100, 20) text:@"添加发票抬头" textColor:[UIColor blackColor] fontNum:15.f textAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:lbl];
    }
    return self;
}

@end
