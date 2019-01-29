//
//  DetailFeedBackHeadVw.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailFeedBackHeadVw.h"
@interface DetailFeedBackHeadVw()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgVw;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLbl;
@end
@implementation DetailFeedBackHeadVw

+ (instancetype)initLoadViewNibFrame:(CGRect)frame{
    DetailFeedBackHeadVw * headVw = [[BundleTool commonBundle] loadNibNamed:@"DetailFeedBackHeadVw" owner:self options:nil].lastObject;
    headVw.frame = frame;
    headVw.iconImgVw.layer.cornerRadius = 4;
    headVw.iconImgVw.clipsToBounds = YES;
    return headVw;
}
+ (instancetype)initLoadViewNibFrame:(CGRect)frame type:(NSInteger)type{
    DetailFeedBackHeadVw * headVw = [[BundleTool commonBundle] loadNibNamed:@"DetailFeedBackHeadVw" owner:self options:nil].lastObject;
    headVw.frame = frame;
    if (type == 0) {
        headVw.iconImgVw.layer.cornerRadius = (frame.size.height - 18 * 2) / 2;
    }else{
        headVw.iconImgVw.layer.cornerRadius = 4;
    }
    headVw.iconImgVw.clipsToBounds = YES;
    return headVw;
}
- (void)setImgUrlStr:(NSString *)imgUrlStr{
    _imgUrlStr = imgUrlStr;
    [self.iconImgVw sd_setImageWithURL:[NSURL URLWithString:_imgUrlStr] placeholderImage:[BundleTool imageNamed:@""]];
}
- (void)setDetailNameStr:(NSString *)detailNameStr{
    _detailNameStr = detailNameStr;
    self.tagNameLbl.text = _detailNameStr;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
