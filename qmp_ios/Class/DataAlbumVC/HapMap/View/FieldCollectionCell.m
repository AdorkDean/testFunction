//
//  FieldCollectionCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "FieldCollectionCell.h"

@implementation FieldCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;
   
    self.contentView.backgroundColor = HTColorFromRGB(0xfafbfd);
    
    _nameLab.textColor = H5COLOR;
    _countLab.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    _countLab.textColor = H9COLOR;
}


- (void)setFiledModel:(HapMapAreaModel *)filedModel{
    _filedModel = filedModel;
    
    _nameLab.text = _filedModel.name;
    _countLab.text = [NSString stringWithFormat:@"共%@个项目",_filedModel.count];
}

@end
