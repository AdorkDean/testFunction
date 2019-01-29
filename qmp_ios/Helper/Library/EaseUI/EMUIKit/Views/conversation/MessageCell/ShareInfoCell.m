//
//  ShareInfoCell.m
//  qmp_ios
//
//  Created by QMP on 2017/12/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ShareInfoCell.h"
#import "EaseBubbleView+Share.h"
static const CGFloat kCellHeight = 180.0f;

@implementation ShareInfoCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<IMessageModel>)model{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    
    if (self) {
        self.hasRead.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}
- (void)setCustomModel:(id<IMessageModel>)model
{
    UIImage *image = model.image;
    if (!image) {
        [self.bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:[UIImage imageNamed:model.failImageName]];
    } else {
        _bubbleView.imageView.image = image;
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}
- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setUpShareBubbleView];
    
    _bubbleView.imageView.image = [UIImage imageNamed:@"EaseUIResource.bundle/imageDownloadFail"];
}
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    
    [_bubbleView updateShareMargin:bubbleMargin];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat bubbleViewHeight = 120;// 气泡背景图高度
    CGFloat nameLabelHeight = 15;// 昵称label的高度
    if (model.isSender) {
        _bubbleView.frame =
        CGRectMake([UIScreen mainScreen].bounds.size.width - 273.5, nameLabelHeight, 213, bubbleViewHeight);
    }else{
        _bubbleView.frame = CGRectMake(55, nameLabelHeight, 213, bubbleViewHeight);
        
    }
    // 这里强制调用内部私有方法
    [self.bubbleView  _setupShareBubbleConstraints];
    
}
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return kCellHeight;
}

- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    
    NSDictionary *ext = [[NSDictionary alloc]initWithDictionary:model.message.ext];
    //发送了商品信息的情况
    if ([ext[@"msg_type"] isEqualToString:@"msg_share"]) {
        NSDictionary *msgtypeDic = [[NSDictionary alloc]initWithDictionary:ext[@"msg_info"]];
        self.bubbleView.titleLabel.text = msgtypeDic[@"title"];
        self.bubbleView.content.text = msgtypeDic[@"content"];
        NSString *imageUrl = [NSString stringWithFormat:@"%@",msgtypeDic[@"url_image"]];
        if (imageUrl.length > 0) {
            [self.bubbleView.imageShareView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
        }else{
            self.bubbleView.imageShareView.image = [UIImage imageNamed:PROICON_DEFAULT];
        }
    }
    
    _hasRead.hidden = YES;//名片消息不显示已读
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//
//    NSString *imageName = self.model.isSender ? @"RedpacketCellResource.bundle/redpacket_sender_bg" : @"RedpacketCellResource.bundle/redpacket_receiver_bg";
//    UIImage *image = self.model.isSender ? [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:30 topCapHeight:35] :
//    [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:20 topCapHeight:35];
    // 等待接入名片的背景图片
    //    self.bubbleView.backgroundImageView.image = image;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
