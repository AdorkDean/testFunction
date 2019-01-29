//
//  ActivityLayout.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityLayout.h"
#import <YYText.h>
#import "SLPhotosView.h"
#import "NSDate+HY.h"
#import "ActivityModel.h"
#import "ActivityHtmlMedia.h"

const CGFloat ActivityCellAvatarWH = 40.0;
const CGFloat ActivityCellPaddingLR = 17.0;
const CGFloat ActivityCellAvatarT = 15.0;
const CGFloat ActivityCellNameT = 17.0;
const CGFloat ActivityCellNameL = 8.0;

const CGFloat ActivityCellTextT = 10.0;
const CGFloat ActivityCellVerticalMargin = 8.0;
const CGFloat ActivityCellHeaderH = 64.0;
const CGFloat ActivityCellPhotosT = 10.0;
const CGFloat ActivityCellTextFontSize = 15;
const CGFloat ActivityCellLinkHeight = 70.0;
const CGFloat ActivityCellBarHeight = 35.0;
const CGFloat ActivityCellHorizontalMargin = 10.0;
const CGFloat ActivityCellCompanyHeight = 32.0;
const CGFloat ActivityCellLinkInfoT = 10;
@interface ActivityLayout ()
@property (nonatomic, assign) CGFloat centerTop;

@property (nonatomic, assign) CGFloat textHeightV2;
@property (nonatomic, assign) CGFloat imagesHeightV2;
@property (nonatomic, assign) CGFloat relateHeightV2;

@end
@implementation ActivityLayout
+ (ActivityLayout *)activityLayoutWithActivity:(NSDictionary *)dict {
    ActivityLayout *layout = [[ActivityLayout alloc] initActivityLayoutWithActivity:dict];
    return layout;
}
- (instancetype)initActivityLayoutWithActivity:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.activity = dict;
        [self layout];
    }
    return self;
}


+ (ActivityLayout *)layoutWithActivityModel:(ActivityModel *)model {
    ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model];
    return layout;
}
- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model {
    self = [super init];
    if (self) {
        self.activityModel = model;
        [self layout];
    }
    return self;
}
- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model forNote:(BOOL)isNote {
    self = [super init];
    if (self) {
        self.isNote = isNote;
        self.activityModel = model;
        [self layout];
    }
    return self;
}
- (ActivityLayout *)reLayoutForDetail {
    ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:self.activityModel forDetail:YES];
    return layout;
}

- (ActivityLayout *)reLayoutForShare {
    ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:self.activityModel forShare:YES];
    return layout;
}
- (void)layout {
    self.centerTop = 0;
    self.cellHeight = 0;
    self.centerHeight = 0;
    [self layoutText];
    self.centerHeight += ActivityCellTextT + self.textLayout.textBoundingSize.height;
    
    if (!self.share) {
        [self layoutImages];
    }
    
    self.linkInfoTop = ActivityCellTextT + self.textLayout.textBoundingSize.height + ActivityCellLinkInfoT;
    
    
    
    self.centerHeight = 12 + self.textHeightV2;
    if (self.imagesHeightV2 > 10) {
        self.imageTop = 12 + self.textHeightV2 + 10;
        self.centerHeight += (10+self.imagesHeightV2);
        self.companyTop = self.imageTop + self.imagesHeightV2;
    }
    [self fixShowRelates];
    if (_showRelates.count > 0) {
        if (self.detail) {
            CGFloat h = [self heightOfDetailRelate];
            self.centerHeight += (14+h);
        } else {
            
            self.centerHeight += (12+20);
        }
        
    }
    self.centerHeight += 14;
    
    
    
    CGFloat cellH = ActivityCellAvatarT + ActivityCellAvatarWH +
    self.centerHeight + ActivityCellBarHeight;
    self.cellHeight = cellH + 10;
    
    if (self.detail) {
        self.cellHeight -= ActivityCellBarHeight;
    }
    
    if (self.isNote) {
        self.cellHeight -= ActivityCellBarHeight;
    }
}
- (void)layoutText {
    CGFloat maxW = SCREENW - ActivityCellPaddingLR * 2;
    
    NSString *orgText = self.activityModel.htmlMedia.displayText;
    
    NSString *tmp = self.activityModel.htmlMedia.displayText;
    
    
    if (![PublicTool isNull:self.activityModel.linkInfo.linkUrl]) {
        tmp = [NSString stringWithFormat:@"%@%@", tmp, self.activityModel.linkInfo.linkTitle];
    }
    
    NSMutableAttributedString *mText = [[NSMutableAttributedString alloc] initWithString:tmp?:@""
                                                                              attributes:@{
                                                                                           NSFontAttributeName: [UIFont systemFontOfSize:ActivityCellTextFontSize]
                                                                                           }];
    
    UIImage *image = [BundleTool imageNamed:@"activity_cell_textlink"];
    
    
    NSMutableAttributedString *atr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:[UIFont systemFontOfSize:ActivityCellTextFontSize] alignment:YYTextVerticalAlignmentCenter];
    
    if (![PublicTool isNull:self.activityModel.linkInfo.linkUrl]) {
        [mText insertAttributedString:atr atIndex:mText.length - self.activityModel.linkInfo.linkTitle.length];
        //        [mText insertAttributedString:atr atIndex:0];
    }
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    mText.yy_lineSpacing = 6.0 - (font.lineHeight- font.pointSize);
    mText.yy_alignment = NSTextAlignmentJustified;
    mText.yy_color = COLOR2D343A;
    NSInteger maxRow = 8;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxW, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:mText];
    if (!self.detail && textLayout.lines.count > maxRow ) {
        _needExplored = YES;
        if (self.explored) {
            NSString *s = @"收起";
            if (![PublicTool isNull:self.activityModel.linkInfo.linkUrl]) {
                s = @"\n收起";
            }
            NSAttributedString *x = [[NSAttributedString alloc] initWithString:s attributes:[self attributes]];
            [mText appendAttributedString:x];
            _textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:mText];
        } else {
            NSMutableString *mStr = [NSMutableString string];
            for (int i = 0; i < maxRow-1; i++) {
                YYTextLine *line = textLayout.lines[i];
                [mStr appendString:[mText.string substringWithRange:line.range]];
            }
            YYTextLine *lastLine = textLayout.lines[maxRow-1];
            NSString *lastStr = [mText.string substringWithRange:lastLine.range];
            
            NSString *expandText = @"...展开";
            NSAttributedString *aStr_m = [[NSAttributedString alloc] initWithString:lastStr attributes:[self attributes]];
            CGFloat expandTextWidth = [self calculateLabelWidthWithString:expandText height:ceil([UIFont systemFontOfSize:16].lineHeight)];
            YYTextContainer *con_m = [YYTextContainer containerWithSize:CGSizeMake(maxW-expandTextWidth, MAXFLOAT)];
            YYTextLayout *layout_m = [YYTextLayout layoutWithContainer:con_m text:aStr_m];
            YYTextLine *firstLine = [layout_m.lines firstObject];
            [mStr appendString:[lastStr substringWithRange:firstLine.range]];
            [mStr appendString:expandText];
            
            NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:mStr attributes:[self attributes]];
            _textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:finalStr];
            
        }
    } else {
        _textLayout = textLayout;
    }
    
    self.centerTop = ActivityCellTextT + self.textLayout.textBoundingSize.height;
    
    CGFloat fixheigth = textLayout.lines.count == 1 ? 6 : 4;
    self.textHeightV2 = self.textLayout.textBoundingSize.height - fixheigth;
}
- (void)layoutImages {
    self.imageSize = CGSizeZero;
    self.imageTop = ActivityCellTextT + self.textLayout.textBoundingSize.height + ActivityCellPhotosT;
    self.imagesHeightV2 = 0;
    
    if (![PublicTool isNull:self.activityModel.linkInfo.linkUrl] && NO) {
        return;
    }
    
    if (self.activityModel.images.count > 0) {
        self.imageSize = [SLPhotosView qmp_photosViewSizeWithPhotosCount:(int)self.activityModel.images.count];
        self.centerHeight += self.imageSize.height;
        self.centerHeight += ActivityCellVerticalMargin;
        
        self.imageTop = self.centerTop + ActivityCellPhotosT;
        
        self.centerTop = self.imageTop+self.imageSize.height;
        
        self.imagesHeightV2 = self.imageSize.height;
    }
}
- (NSDictionary *)attributes {
    
    UIFont *font = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 6 - (font.lineHeight - font.pointSize);
    style.alignment = NSTextAlignmentJustified;
    return @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:HTColorFromRGB(0x333333), NSParagraphStyleAttributeName: style};
}
- (NSDictionary *)attributes_highlight {
    
    UIFont *font = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 6 - (font.lineHeight - font.pointSize);
    style.alignment = NSTextAlignmentJustified;
    return @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:BLUE_TITLE_COLOR, NSParagraphStyleAttributeName: style};
}
- (CGFloat)calculateLabelWidthWithString:(NSString *)string height:(CGFloat)height {
    if (string.length == 0) {
        return 0.f;
    }
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    return ceil(size.width);
}

- (NSString *)desc {
    if (self.share) {
        return @"";
    }
    NSString *date = [self formatDate:self.activityModel.createTime];
    if (date.length == 0) {
        date = self.activityModel.createTime;
    }
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:date];
    
    if (self.activityModel.followRelates.count > 0 && !self.detail) {
        [desc appendFormat:@"@%@发布", self.activityModel.user.name];
        return desc;
    }
    
    if (self.activityModel.isAnonymous) {
        return desc;
    }
    
    if ([self.activityModel.user.type isEqualToString:@"2"]) {
        [desc appendFormat:@" %@", self.activityModel.user.desc];
        return desc;
    }
    
    if (![PublicTool isNull:self.activityModel.user.position]) {
        [desc appendFormat:@" %@", self.activityModel.user.position];
        if (![PublicTool isNull:self.activityModel.user.company]) {
            [desc appendFormat:@"@%@", self.activityModel.user.company];
        }
    }
    
    return desc;
}
- (NSString *)formatDate:(NSString *)dateStr {
    if (!dateStr || dateStr.length < 19) {
        return @"";
    }
    dateStr = [dateStr substringToIndex:18];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; //.S
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M月d日"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy年M月dd日"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (date.hy_isToday) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.hy_isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.hy_year == now.hy_year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}


- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model forDetail:(BOOL)detail {
    self = [super init];
    if (self) {
        self.activityModel = model;
        self.detail = detail;
        [self layout];
    }
    return self;
}
- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model forShare:(BOOL)share {
    self = [super init];
    if (self) {
        self.activityModel = model;
        self.detail = YES;
        self.share = share;
        [self layout];
    }
    return self;
}


- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model type:(ActivityLayoutType)theType {
    self = [super init];
    if (self) {
        self.activityModel = model;
        self.type = theType;
        // 460 200
        
        
        CGFloat maxW = (SCREENW-32-28);
        
        if (theType == ActivityLayoutTypeCompanyValue) {
            maxW = SCREENW-32;
        }
        
        NSString *tmp = self.activityModel.content;
        
        NSMutableAttributedString *mText = [[NSMutableAttributedString alloc] initWithString:tmp?:@""
                                                                                  attributes:@{
                                                                                               NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                                               NSForegroundColorAttributeName: H3COLOR,
                                                                                               }];
        NSMutableAttributedString *mLink;
        if (![PublicTool isNull:self.activityModel.linkInfo.linkUrl]) {
            
            mLink = [[NSMutableAttributedString alloc] initWithString:self.activityModel.linkInfo.linkTitle?:@""
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                                                   NSForegroundColorAttributeName: BLUE_TITLE_COLOR,}];
            [mLink insertAttributedString:[self linkAttrImage] atIndex:0];
            [mText appendAttributedString:mLink];
            _linkRange = NSMakeRange(mText.length-mLink.length, mLink.length);
        }
        
        
        mText.yy_lineSpacing = 6.0;
        mText.yy_alignment = NSTextAlignmentJustified;
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxW, MAXFLOAT)];
        container.maximumNumberOfRows = 3;
//        container.truncationType = YYTextTruncationTypeEnd;

        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:mText];
        
        NSMutableString *mutableText = [NSMutableString string];
        //第三行字符串
        for (int i=0; i<layout.rowCount; i++) {
           YYTextLine *line = layout.lines[i];
           [mutableText appendString:[mText.string substringWithRange:line.range]];
        }
        //链接在省略里,且第三行不能有换行
        if ((mutableText.length < tmp.length) && ![PublicTool isNull:self.activityModel.linkInfo.linkUrl]) {
            NSRange lastLineRange = [layout.lines[layout.rowCount-1] range];
            if ([[mutableText substringFromIndex:mutableText.length-1] isEqualToString:@"\n"]) {
                [mutableText deleteCharactersInRange:NSMakeRange(mutableText.length-1, 1)];
                if (mutableText.length > mLink.length+3) {
                    [mutableText deleteCharactersInRange:NSMakeRange(mutableText.length-mLink.length-3, mLink.length+3)];
                }
            }else{
                [mutableText deleteCharactersInRange:NSMakeRange(lastLineRange.location+lastLineRange.length-mLink.length-3, mLink.length+3)];
            }

            [mutableText appendString:@"..."];
            mText = [[NSMutableAttributedString alloc] initWithString:mutableText?:@""
                                                           attributes:@{
                                                                        NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                        NSForegroundColorAttributeName: H3COLOR,
                                                                        }];
            mText.yy_lineSpacing = 6.0;
            mText.yy_alignment = NSTextAlignmentJustified;
            [mText appendAttributedString:mLink];
            
            _linkRange = NSMakeRange(mText.length-mLink.length, mLink.length);
            layout = [YYTextLayout layoutWithContainer:container text:mText];
        }
        
        self.collectionCellSize = CGSizeMake(SCREENW-32, layout.textBoundingSize.height+28);
        self.textLayout = layout;
        
    }
    return self;
}

- (NSMutableAttributedString *)linkAttrImage {
    UIImage *image = [BundleTool imageNamed:@"activity_cell_textlink"];
    NSMutableAttributedString *attr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:[UIFont systemFontOfSize:14] alignment:YYTextVerticalAlignmentCenter];
    return attr;
}
- (void)fixShowRelates {
    if (self.detail) {
        _showRelates = [NSMutableArray arrayWithArray:self.activityModel.relates];
    } else {
        
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:self.activityModel.relates];
        if (self.activityModel.followRelates.count > 0) {
            if ([arr1 containsObject:[self.activityModel.followRelates firstObject]]) {
                [arr1 removeObject:[self.activityModel.followRelates firstObject]];
            }
            _showRelates = [NSArray array];
        } else {
            _showRelates = arr1;
        }
        //        if (!self.activityModel.anonymous) {
        //            ActivityRelateModel *relate = [[ActivityRelateModel alloc] init];
        //            relate.name = self.activityModel.user.name;
        //            relate.image = self.activityModel.user.avatar;
        //            if ([PublicTool isNull:self.activityModel.user.ID]) {
        //                relate.type = @"user";
        //                relate.ID = self.activityModel.user.uID;
        //            } else {
        //                relate.type = @"person";
        //                relate.ID = self.activityModel.user.ID;
        //            }
        //            [arr1 addObject:relate];
        //        }
        
        
        
    }
}
- (CGFloat)heightOfDetailRelate {
    
    
    
    NSMutableArray *arr = [NSMutableArray array];
    UIFont *font = [UIFont systemFontOfSize:13];
    CGFloat extral = 28;
    CGFloat margin = 10;
    CGFloat padding = 34;
    CGFloat maxW = SCREENW - padding;
    CGFloat lastRight = 0;
    CGFloat height = 24;
    CGFloat marginH = 8;
    CGFloat top = 0;
    for (ActivityRelateModel *relate in _showRelates) {
        CGFloat w = [relate.name boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                              options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:font} context:nil].size.width;
        w = w + extral;
        CGRect r = CGRectMake(lastRight, top, w, height);
        
        lastRight = lastRight + w + margin;
        if (lastRight > maxW) {
            top += (height + marginH);
            lastRight = 0;
            r = CGRectMake(lastRight, top, w, height);
            lastRight = (w+margin);
        }
        
        [arr addObject:[NSValue valueWithCGRect:r]];
    }
    height += top;
    self.detailRelateFrames = arr;
    self.detailRelateHeight = height;
    self.relateHeightV2 = height;
    return height;
}
@end
