//
//  QMPActivityCellModel.m
//  qmp_ios
//
//  Created by QMP on 2018/8/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPActivityCellModel.h"
#import "ActivityModel.h"
#import "NSDate+HY.h"
#import <YYText.h>
#import "SLPhotosView.h"
@interface QMPActivityCellModel ()
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, strong) UIFont *textFont;
@end
@implementation QMPActivityCellModel
- (instancetype)initWithActivity:(ActivityModel *)activity forCommunity:(BOOL)community {
    self = [super init];
    if (self) {
        _isCommunity = community;
        _activity = activity;
        _contentWidth = SCREENW - 28;
        _textFont = [UIFont systemFontOfSize:16];
        [self handleData];
    }
    return self;
}

- (instancetype)initWithActivity:(ActivityModel *)activity forCommunity:(BOOL)community detail:(BOOL)detail {
    self = [super init];
    if (self) {
        _isCommunity = community;
        _activity = activity;
        
        _contentWidth = SCREENW - 28;
        _textFont = [UIFont systemFontOfSize:16];
        _detail = detail;
        
        [self handleData];
    }
    return self;
}

- (void)setNeedLayout {
    [self handleData];
}
- (void)handleData {
    CGFloat cellHeight = 0;
    
    CGFloat contentTop = 58;
    if (self.isCommunity) {
        if (self.detail) {
            contentTop = 61;
            if (_activity.anonymous && (_activity.anonymous_degree.integerValue == 1) && [PublicTool isNull:_activity.company.role]) {
                contentTop -= 17;
            }
        } else {
            contentTop = 40;
        }
    }
    
    cellHeight += contentTop;
    
    [self handleContent];
    
    cellHeight += _textHeight;
    
    [self handleImages];
    if (_imagesSize.height > 0) {
        cellHeight += 11;
        cellHeight += _imagesSize.height;
    }
    
    [self handleRelates];
    if (self.activity.isMine) { //我的动态
        CGFloat editW = 54;
        CGFloat maxW = SCREENW - 34;
        CGRect r = CGRectMake(0, 4, 0, 0);
        CGFloat right = 0;
        if (_relateItemFrames.count) {
            NSValue *v = [_relateItemFrames lastObject];
            r = [v CGRectValue];
            right = r.origin.x + r.size.width + 5;
        }
        
        CGFloat t = r.origin.y;
        CGFloat w = right + editW + 5;
        if (w > maxW) {
            t = t + 27;
            right = 0;
        }
        if (self.activity.showEdit) {
            _editRelateFrame = CGRectMake(right, t, editW, 23);
            if (self.activity.editing) {
                right = right + editW +5;
                w = right + editW + 5;
                if (w > maxW) {
                    t = t + 27;
                    right = 0;
                }
            }
            _editRelateFrame2 = CGRectMake(right, t, editW, 23);
        }
        _relatesSize = (_relateItemFrames.count || self.activity.showEdit) ? CGSizeMake(maxW, t+23+4):CGSizeMake(maxW, 0);
        self.needDelete = NO;
    }
    
    if (_relatesSize.height > 0) {
        cellHeight += 7;  // 关联上下多 4
        cellHeight += _relatesSize.height;
    }
    
    if (_relatesSize.height <= 0 && _imagesSize.height > 0 && self.activity.showEdit) {
        cellHeight += 4;
    }
    if (_relatesSize.height <= 0 && _imagesSize.height <= 0 && self.activity.showEdit) {
        cellHeight += 5;
    }
    
    cellHeight += 42;
    cellHeight -= _fixTextHeight;
    
    _cellHeight = cellHeight;
}

- (void)handleContent {
    
    UIFont *font = [UIFont systemFontOfSize:16];
    
    NSString *text = self.activity.content;
    NSMutableAttributedString *attrText = [self fixContentAttributed:text];
    
    if (![PublicTool isNull:self.activity.linkInfo.linkUrl]) {
        NSString *linkTitle = self.activity.linkInfo.linkTitle;
        NSMutableAttributedString *linkAttrTitle = [self fixContentAttributed:linkTitle];
        [linkAttrTitle insertAttributedString:[self linkAttrImage] atIndex:0];
        
        [attrText appendAttributedString:linkAttrTitle];
        
        _linkHighlightRange = NSMakeRange(text.length, linkAttrTitle.length);
    }
    
    NSInteger maxRow = 8;
    CGFloat maxW = self.contentWidth;
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxW, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attrText];
    if (textLayout.lines.count > maxRow && !self.detail) {
        _needExpand = YES;
        if (self.expanding) {
            [attrText appendAttributedString:[self fixContentAttributed:@"  收起"]];
            textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:attrText];
            
        } else {
            NSMutableString *mStr = [NSMutableString string];
            for (int i = 0; i < maxRow-1; i++) {
                YYTextLine *line = textLayout.lines[i];
                [mStr appendString:[attrText.string substringWithRange:line.range]];
            }
            YYTextLine *lastLine = textLayout.lines[maxRow-1];
            NSString *lastText = [attrText.string substringWithRange:lastLine.range];
            
            NSString *expandText = @"...展开";
            NSAttributedString *tmpAttrText = [self fixContentAttributed:lastText];
            CGFloat expandTextWidth = [self calculateLabelWidthWithString:expandText height:ceil(font.lineHeight) font:font];
            YYTextContainer *tmpContainer = [YYTextContainer containerWithSize:CGSizeMake(maxW-expandTextWidth, MAXFLOAT)];
            YYTextLayout *tmpLayout = [YYTextLayout layoutWithContainer:tmpContainer text:tmpAttrText];
            YYTextLine *firstLine = [tmpLayout.lines firstObject];
            
            [mStr appendString:[lastText substringWithRange:firstLine.range]];
            [mStr appendString:expandText];
            
            NSMutableAttributedString *finalStr = [self fixContentAttributed:mStr];
            textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:finalStr];
        }
    }
    
    
    _textLayout = textLayout;
    _textHeight = textLayout.textBoundingSize.height;// - (font.lineHeight - font.pointSize);
    _fixTextHeight = 3;
}
- (void)handleImages {
    _imagesSize = CGSizeZero;
    if (self.activity.images.count == 1) {
        ActivityImageModel *image = [self.activity.images firstObject];
        _imagesSize = [SLPhotosView qmp_onePhotoViewSizeWithImageModel:image];
    } else {
        _imagesSize = [SLPhotosView qmp_photosViewSizeWithPhotosCount:(int)self.activity.images.count maxWidth:self.contentWidth];
    }
}
- (void)handleRelates {
    _relatesSize = CGSizeZero;
    NSMutableArray *relates = [NSMutableArray arrayWithArray:self.activity.relates];
    
    if (self.activity.headerRelate) {
        if ([relates containsObject:self.activity.headerRelate]) {
            [relates removeObject:self.activity.headerRelate];
        }
    }
    
    _displayRelates = relates;
    
    if (relates.count == 0) {
        _relatesSize = CGSizeZero;
        _relateItemFrames = [NSMutableArray array];
        return;
    }
    NSMutableArray *arr = [NSMutableArray array];
    UIFont *font = [UIFont systemFontOfSize:12];
    
    CGFloat iconW = 12;
    CGFloat margin = 6;
    CGFloat maxW = self.contentWidth;
    CGFloat lastRight = 0;
    CGFloat height = 23;
    CGFloat top = 4;
    NSInteger index = 0;
    for (ActivityRelateModel *relate in relates) {
        if (index >= 10) {
            break;
        }
        CGFloat w = [self calculateLabelWidthWithString:relate.name height:ceil(font.lineHeight) font:font];
        w = w + iconW + margin * 3;
        if (relate.isFollowed) {
            w = w + iconW + margin;
        }
        
        CGRect r = CGRectMake(lastRight, top, w, height);
        
        lastRight = lastRight + w + margin;
        if (lastRight > maxW) {
            top += (height + margin);
            lastRight = 0;
            r = CGRectMake(lastRight, top, w, height);
            lastRight = (w+margin);
        }
        
        [arr addObject:[NSValue valueWithCGRect:r]];
        index++;
    }
    height += top;
    
    _relatesSize = CGSizeMake(maxW, height+4);
    _relateItemFrames = arr;
}
#pragma mark - Utils
- (NSMutableAttributedString *)linkAttrImage {
    UIImage *image = [UIImage imageNamed:@"activity_cell_textlink"];
    NSMutableAttributedString *attr = [NSMutableAttributedString yy_attachmentStringWithContent:image
                                                                                    contentMode:UIViewContentModeCenter
                                                                                 attachmentSize:image.size
                                                                                    alignToFont:self.textFont
                                                                                      alignment:YYTextVerticalAlignmentCenter];
    attr.yy_alignment = NSTextAlignmentJustified;
    attr.yy_lineSpacing = 7;
    return attr;
}
- (NSMutableAttributedString *)fixContentAttributed:(NSString *)text {
    UIFont *font = self.textFont;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    attrText.yy_font = font;
    attrText.yy_alignment = NSTextAlignmentJustified;
    attrText.yy_color = H2COLOR;
    attrText.yy_lineSpacing = 7;
    return attrText;
}
- (CGFloat)calculateLabelWidthWithString:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    if (string.length == 0) {
        return 0.f;
    }
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    
    return ceil(size.width);
}

@end
