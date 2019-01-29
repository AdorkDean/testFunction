//
//  FeedbackListCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FeedbackListCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "TTTAttributedLabel.h"
@interface FeedbackListCell() <TTTAttributedLabelDelegate>{
    
    __weak IBOutlet UILabel *typeLab;
    
    __weak IBOutlet UILabel *objectLab;
    
    __weak IBOutlet TTTAttributedLabel *contentLab;
    __weak IBOutlet UILabel *resultLab;
    
    __weak IBOutlet UILabel *resultTitleLab;
    
    __weak IBOutlet NSLayoutConstraint *resultTopHeight;
    __weak IBOutlet UILabel *_timeLab;
    __weak IBOutlet UIImageView *resultIcon;
}

@end
@implementation FeedbackListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    contentLab.delegate = self;
    self.contentView.backgroundColor = TABLEVIEW_COLOR;
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSString *im in self.feedbackM.url) {
        MJPhoto *p = [[MJPhoto alloc] init];
        p.url = [NSURL URLWithString:im];
        p.srcView = label;
//        p.firstShow = YES;
        [mArr addObject:p];
    }
    
    MJPhotoBrowser *b = [[MJPhotoBrowser alloc] init];
    b.currentPhotoIndex = 0;
    b.photos = mArr;
    [b show];
}
- (void)imageShow:(UITapGestureRecognizer *)tapGest {
    
    
    
}
-(void)setFeedbackM:(FeedbackModel *)feedbackM{

    _feedbackM = feedbackM;
    
    typeLab.text = feedbackM.type;
    objectLab.text = [PublicTool isNull:feedbackM.company] ? ([PublicTool isNull:feedbackM.product] ? @"-":feedbackM.product) : feedbackM.company;
    
    NSString *title = [[feedbackM.time componentsSeparatedByString:@" "] firstObject];
    
    _timeLab.text = [title stringByReplacingOccurrencesOfString:@"-" withString:@"."];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    contentLab.userInteractionEnabled = NO;
    NSString *desc = feedbackM.desc.length > 0 ? feedbackM.desc:@"";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:desc attributes:@{NSFontAttributeName:contentLab.font, NSForegroundColorAttributeName: contentLab.textColor, NSParagraphStyleAttributeName:style}];
    if (feedbackM.url.count > 0) {
        NSAttributedString *imStr = [[NSAttributedString alloc] initWithString:@"查看图片" attributes:@{NSFontAttributeName:contentLab.font, NSForegroundColorAttributeName: BLUE_TITLE_COLOR,NSParagraphStyleAttributeName:style}];
        [str appendAttributedString:imStr];
        contentLab.linkAttributes = @{NSFontAttributeName:contentLab.font, NSForegroundColorAttributeName: BLUE_TITLE_COLOR,NSParagraphStyleAttributeName:style};
        contentLab.activeLinkAttributes = @{NSFontAttributeName:contentLab.font, NSForegroundColorAttributeName: BLUE_TITLE_COLOR,NSParagraphStyleAttributeName:style};
        contentLab.attributedText = str;
        [contentLab addLinkToTransitInformation:@{} withRange:NSMakeRange(desc.length, 4)];
        contentLab.userInteractionEnabled = YES;
    } else {
        contentLab.attributedText = str;
        [contentLab addLinkToTransitInformation:@{} withRange:NSMakeRange(0, 0)];
    }
    
    if ([feedbackM.complete isEqualToString:@"处理中"]) {
        resultLab.text = @"正在处理";
        resultLab.textColor = HTColorFromRGB(0xFFB154);
        resultIcon.image = [BundleTool imageNamed:@"feedback_ing"];
    } else if ([feedbackM.complete isEqualToString:@"处理成功"]) {
        resultLab.text = @"处理成功";
        resultLab.textColor = HTColorFromRGB(0x197CD8);
        resultIcon.image = [BundleTool imageNamed:@"feedback_success"];
    } else {
        resultLab.text = @"处理失败";
        resultLab.textColor = HTColorFromRGB(0x197CD8);
        resultIcon.image = [BundleTool imageNamed:@"feedback_fail"];
    }
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
