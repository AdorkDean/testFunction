/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "NSString+Valid.h"

@implementation NSString (Valid)

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

@end




@implementation NSString(NumK)

- (NSString *)fixCountShow{
    NSInteger count = [self integerValue];
    if (count <= 0) {
        return @"0";
    } else if (count < 1000) {
        return [NSString stringWithFormat:@"%zd", count];
    } else if (count < 10000) {
        return [NSString stringWithFormat:@"%.1fk", count / 1000.0];
    } else if (count < 100000) {
        return [NSString stringWithFormat:@"%zdk", count / 1000];
    } else {
        return @"99k+";
    }
}

@end
