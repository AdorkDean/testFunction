//
//  HotMgrListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HotMgrListCell.h"

@interface HotMgrListCell()
{
    __weak IBOutlet UILabel *_titleLab;
    __weak IBOutlet UIImageView *_imgView;
    
    __weak IBOutlet UILabel *_timeLab;
    __weak IBOutlet UILabel *_countLab;
}
@end

@implementation HotMgrListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgView.layer.masksToBounds = YES;
    _imgView.layer.cornerRadius = 6;
    
}


- (void)setGroupModel:(GroupModel *)groupModel{
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:groupModel.img_url] placeholderImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_imgView.size]];
    
//    [_imgView sd_setImageWithURL:[NSURL URLWithString:groupModel.img_url] placeholderImage:[BundleTool imageNamed:@"product_default"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _imgView.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(105, 75)];
//    }];
    
    UIFont *jianjieFont = [UIFont systemFontOfSize:14.f];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineSpacing:4.f];
    NSDictionary *attribute = @{NSFontAttributeName:jianjieFont,NSParagraphStyleAttributeName:style};
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:groupModel.album_name attributes:attribute];
    _titleLab.attributedText = attText;
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if ([PublicTool isNull:groupModel.open_time]) {
        _timeLab.text = @"";
    }else{
        NSString *time = [[groupModel.open_time componentsSeparatedByString:@" "] firstObject];
        _timeLab.text = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    }
    _countLab.text = [NSString stringWithFormat:@"%@个项目",groupModel.count];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
