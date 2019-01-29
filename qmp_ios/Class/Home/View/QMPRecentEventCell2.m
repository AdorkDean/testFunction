//
//  QMPRecentEventCell2.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/1.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "QMPRecentEventCell2.h"

@interface QMPRecentEventCell2 ()
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) UILabel *bpLabel;
@end

@implementation QMPRecentEventCell2

+ (QMPRecentEventCell2 *)cellWithTableView:(UITableView *)tableView {
    QMPRecentEventCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPRecentEventCell2"];
    if (!cell) {
        cell = [[QMPRecentEventCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPRecentEventCell2"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.metaLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.bpLabel];
}
- (void)setEvent:(QMPRecentEvent2 *)event {
    _event = event;
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:event.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
    
    self.nameLabel.text = event.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(67, 11.5, MIN(SCREENW-67-13-30, self.nameLabel.width), 18);
    
    
    self.descLabel.text = event.desc;
    
    self.bpLabel.hidden = !event.hasBP;
    self.bpLabel.frame = CGRectMake(self.nameLabel.right+6, 17+2.5, 22, 14);
    self.bpLabel.hidden = YES;
    
    self.metaLabel.attributedText = [QMPRecentEventCell2 fixMeta:event.meta];
    self.metaLabel.frame = CGRectMake(67, 54, SCREENW-67-13, 18);
    [self.metaLabel sizeToFit];
    self.metaLabel.frame = CGRectMake(67, 54, SCREENW-67-13, self.metaLabel.height);
    //
    
    self.descLabel.hidden = YES;
    if ([PublicTool isNull:event.desc]) {
        self.metaLabel.frame = CGRectMake(67, 54-24, SCREENW-67-13, self.metaLabel.height);
    } else {
        self.descLabel.hidden = NO;
        self.metaLabel.frame = CGRectMake(67, 54, SCREENW-67-13, self.metaLabel.height);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(17, self.height-1, SCREENW-34, 1);
}
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.frame = CGRectMake(13, 13, 44, 44);
        _avatarView.layer.cornerRadius = 4.0;
        _avatarView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        _avatarView.layer.borderWidth = 1.0;
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(67, 11.5, SCREENW-67-13, 18);
        if (@available(iOS 8.2, *)) {
            _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        } else {
            _nameLabel.font = [UIFont systemFontOfSize:16];
        }
        _nameLabel.textColor = H27COLOR;
    }
    return _nameLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(67, 35, SCREENW-67-13, 14);
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = HTColorFromRGB(0x838CA1);
    }
    return _descLabel;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, 0, 0);
        _lineView.backgroundColor = LIST_LINE_COLOR;
    }
    return _lineView;
}
- (UILabel *)metaLabel {
    if (!_metaLabel) {
        _metaLabel = [[UILabel alloc] init];
        _metaLabel.font = [UIFont systemFontOfSize:13];
        _metaLabel.textColor = H4COLOR;
        _metaLabel.numberOfLines = 0;
    }
    return _metaLabel;
}
- (UILabel *)bpLabel {
    if (!_bpLabel) {
        _bpLabel = [[UILabel alloc] init];
        _bpLabel.font = [UIFont systemFontOfSize:10];
        _bpLabel.textColor = BLUE_TITLE_COLOR;
        _bpLabel.textAlignment = NSTextAlignmentCenter;
        _bpLabel.layer.cornerRadius = 2;
        _bpLabel.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        _bpLabel.layer.borderWidth = 1;
        _bpLabel.text = @"BP";
    }
    return _bpLabel;
}

+ (NSAttributedString *)fixMeta:(NSString *)meta{
    UIFont *font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 9 - (font.lineHeight - font.pointSize);
    NSAttributedString *aMeta = [[NSAttributedString alloc] initWithString:meta
                                                                attributes:@{
                                                                             NSFontAttributeName: font,
                                                                             NSForegroundColorAttributeName:H4COLOR,
                                                                             NSParagraphStyleAttributeName: style
                                                                             }];
    return aMeta;
}
@end


@implementation QMPRecentEvent2
- (instancetype)initWithSmarketEventModel:(SmarketEventModel *)event {
    self = [super init];
    if (self) {
        _ticket = [PublicTool toGetDictFromStr:event.detail][@"ticket"];
        _ticket_id = [PublicTool toGetDictFromStr:event.detail][@"id"];
        _detail = event.detail;
        
        _icon = event.icon;
        _name = event.product;
        _desc = event.yewu;
        
        _subType = @"product";
        
        _hasBP = NO;
        
        NSMutableString *m = [NSMutableString string];
        NSString *time = event.date;
        if ([time hasPrefix:[PublicTool currentYear]]) {
            time = [time substringFromIndex:5];
        }
        time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        [m appendString:time];
        
        if (![PublicTool isNull:event.shangshididian]) {
            [m appendFormat:@"  %@",event.shangshididian];
        }
        
        if (![PublicTool isNull:event.money]) {
            [m appendFormat:@"  募资%@",event.money];
        }
        
        
        
        _meta = [m stringByReplacingOccurrencesOfString:@"，" withString:@"、"];
        
        
        UIFont *font = [UIFont systemFontOfSize:13];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 9 - (font.lineHeight - font.pointSize);
        
        NSAttributedString *aMeta = [[NSAttributedString alloc] initWithString:_meta
                                                                    attributes:@{
                                                                                 NSFontAttributeName: font,
                                                                                 NSForegroundColorAttributeName:H4COLOR,
                                                                                 NSParagraphStyleAttributeName: style
                                                                                 }];
        
        CGFloat h = [aMeta boundingRectWithSize:CGSizeMake(SCREENW-67-13, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        
        if (h < 30) {
            h -= 4;  // fix one line bug
        }
        _cellHeight = h+63;
        
        if ([PublicTool isNull:_desc]) {
            _cellHeight -= 20;
        }
    }
    return self;
}
- (instancetype)initWithBingGouProModel:(BingGouProModel *)event {
    self = [super init];
    if (self) {
        _ticket = [PublicTool toGetDictFromStr:event.yewu.detail][@"ticket"];
        _ticket_id = [PublicTool toGetDictFromStr:event.yewu.detail][@"id"];
        _detail = event.yewu.detail;
        
        _icon = event.yewu.icon;
        _name = event.yewu.product;
        _desc = event.yewu.yewu;
        
        _subType = @"product";
        
        _hasBP = NO;
        
        NSMutableString *m = [NSMutableString string];
        NSString *time = event.lunci.time;
        if ([time hasPrefix:[PublicTool currentYear]]) {
            time = [time substringFromIndex:5];
        }
        time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        [m appendString:time];
        [m appendFormat:@"  %@", event.lunci.money];
        [m appendFormat:@"  %@", event.lunci.tzr];
        
        _meta = [m stringByReplacingOccurrencesOfString:@"，" withString:@"、"];
        
        
        UIFont *font = [UIFont systemFontOfSize:13];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 9 - (font.lineHeight - font.pointSize);
        
        NSAttributedString *aMeta = [[NSAttributedString alloc] initWithString:_meta
                                                                    attributes:@{
                                                                                 NSFontAttributeName: font,
                                                                                 NSForegroundColorAttributeName:H4COLOR,
                                                                                 NSParagraphStyleAttributeName: style
                                                                                 }];
        
        CGFloat h = [aMeta boundingRectWithSize:CGSizeMake(SCREENW-67-13, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        
        if (h < 30) {
            h -= 4;  // fix one line bug
        }
        _cellHeight = h+63;
        
        if ([PublicTool isNull:_desc]) {
            _cellHeight -= 20;
        }
    }
    return self;
}

@end
