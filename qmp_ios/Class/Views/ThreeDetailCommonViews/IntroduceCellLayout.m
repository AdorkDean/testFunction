//
//  IntroduceCellLayout.m
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "IntroduceCellLayout.h"
#import <YYText.h>

@implementation IntroduceCellLayout
-(instancetype)initWithIntroduce:(NSMutableDictionary *)introduceInfoDic{
    self = [self init];
    if (self) {
        self.introduceInfoDic = introduceInfoDic;
        [self layout];
    }
    return self;
}

- (void)layout {
    
    NSInteger maxRow = 6;
    CGFloat textW = SCREENW-30;
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:self.introduceInfoDic[@"content"] attributes:[self attributes]];
    atr.yy_alignment = NSTextAlignmentJustified;
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(textW, MAXFLOAT) text:atr];
    if (textLayout.lines.count > maxRow) {
        _isNeedExplored = YES;
        if ([self.introduceInfoDic[@"spread"] boolValue]) {
            NSString *content = [self.introduceInfoDic[@"content"] stringByAppendingString:@"收起"];
            NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:content attributes:[self attributes]];
            [finalStr setAttributes:[self attributes_highlight] range:NSMakeRange(finalStr.length-2, 2)];
            _textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(textW, MAXFLOAT) text:finalStr];
        } else {
            NSMutableString *mStr = [NSMutableString string];
            for (int i = 0; i < maxRow-1; i++) {
                YYTextLine *line = textLayout.lines[i];
                [mStr appendString:[atr.string substringWithRange:line.range]];
            }
            YYTextLine *lastLine = textLayout.lines[maxRow-1];
            NSString *lastStr = [atr.string substringWithRange:lastLine.range];
            NSString *expandText = @"...展开详情";
            NSAttributedString *aStr_m = [[NSAttributedString alloc] initWithString:lastStr attributes:[self attributes]];
            CGFloat expandTextWidth = [self calculateLabelWidthWithString:expandText height:ceil([UIFont systemFontOfSize:14].lineHeight)];
            YYTextContainer *con_m = [YYTextContainer containerWithSize:CGSizeMake(textW-expandTextWidth, MAXFLOAT)];
            YYTextLayout *layout_m = [YYTextLayout layoutWithContainer:con_m text:aStr_m];
            YYTextLine *firstLine = [layout_m.lines firstObject];
            [mStr appendString:[lastStr substringWithRange:firstLine.range]];
            [mStr appendString:expandText];
            
            NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:mStr attributes:[self attributes]];
            [finalStr setAttributes:[self attributes_highlight] range:NSMakeRange(finalStr.length-4, 4)];
            _textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(textW, MAXFLOAT) text:finalStr];
            
        }
    } else {
        _textLayout = textLayout;
    }
    _cellHeight = _textLayout.textBoundingSize.height+18;

}

- (NSDictionary *)attributes {
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    style.alignment = NSTextAlignmentJustified;//文本对齐方式 左右对齐（两边对齐）    
    return @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:COLOR2D343A, NSParagraphStyleAttributeName: style,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]};
}
- (NSDictionary *)attributes_highlight {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    return @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:BLUE_TITLE_COLOR, NSParagraphStyleAttributeName: style};
}
- (CGFloat)calculateLabelWidthWithString:(NSString *)string height:(CGFloat)height {
    if (string.length == 0) {
        return 0.f;
    }
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    
    return ceil(size.width);
}

@end
