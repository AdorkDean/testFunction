//
//  GetSizeWithText.m
//  QiMingPian
//
//  Created by Molly on 16/3/25.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "GetSizeWithText.h"

@implementation GetSizeWithText
- (CGSize)calculateSize:(NSString *)contentStr withFont:(UIFont *)font withWidth:(CGFloat)width{
    NSDictionary *atttibute = @{NSFontAttributeName:font};
    CGSize size = [contentStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:atttibute context:nil].size;
    return size;

}
+ (CGSize)calculateSize:(NSString *)contentStr withFont:(UIFont *)font withWidth:(CGFloat)width{

    NSDictionary *atttibute = @{NSFontAttributeName:font};
    CGSize size = [contentStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:atttibute context:nil].size;
    return size;
    
}
- (CGSize)calculateSize:(NSString *)contentStr withDict:(NSDictionary *)atttibute withWidth:(CGFloat)width{

    CGSize size = [contentStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:atttibute context:nil].size;
    return size;
    
}

+ (CGSize)calculateSize:(NSString *)contentStr withDict:(NSDictionary *)atttibute withWidth:(CGFloat)width{
    CGSize size = [contentStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:atttibute context:nil].size;
    return size;
}


@end
