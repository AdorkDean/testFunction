//
//  MyCardTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/3/21.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "MyCardTableViewCell.h"

#import <UIButton+WebCache.h>
@implementation MyCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgBtn.layer.masksToBounds = YES;
    self.imgBtn.layer.cornerRadius = 6;
    
    self.backImgBtn.layer.masksToBounds = YES;
    self.backImgBtn.layer.cornerRadius = 6;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initData:(NSString *)imgName placeImg:(UIImage*)img  withBack:(NSString *)backImgName placeBackImg:(UIImage*)backimg{

    if (![PublicTool isNull:imgName]) {
        [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:imgName] forState:UIControlStateNormal placeholderImage:(img?img:[BundleTool imageNamed:@"card_zheng"])];
    }else{
        [self.imgBtn setImage:[BundleTool imageNamed:@"card_zheng"] forState:UIControlStateNormal];
    }
    
    if (![PublicTool isNull:backImgName]) {
        [self.backImgBtn sd_setImageWithURL:[NSURL URLWithString:backImgName] forState:UIControlStateNormal placeholderImage:backimg?backimg:[BundleTool imageNamed:@"card_back"]];
        
    }else{
        [self.backImgBtn setImage:[BundleTool imageNamed:@"card_back"] forState:UIControlStateNormal];
    }
}

- (void)initData:(NSString *)imgName withBack:(NSString *)backImgName{
    
    if (![PublicTool isNull:imgName]) {
        [self.imgBtn sd_setImageWithURL:[NSURL URLWithString:imgName] forState:UIControlStateNormal placeholderImage:[BundleTool imageNamed:@"card_zheng"]];
    }else{
        [self.imgBtn setImage:[BundleTool imageNamed:@"card_zheng"] forState:UIControlStateNormal];
    }
    
    if (![PublicTool isNull:backImgName]) {
        [self.backImgBtn sd_setImageWithURL:[NSURL URLWithString:backImgName] forState:UIControlStateNormal placeholderImage:[BundleTool imageNamed:@"card_back"]];
        
    }else{
        [self.backImgBtn setImage:[BundleTool imageNamed:@"card_back"] forState:UIControlStateNormal];
    }
}


@end
