//
//  GetSizeWithText.h
//  QiMingPian
//
//  Created by Molly on 16/3/25.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GetSizeWithText : NSObject

- (CGSize)calculateSize:(NSString *)contentStr withFont:(UIFont *)font withWidth:(CGFloat)width;
+ (CGSize)calculateSize:(NSString *)contentStr withFont:(UIFont *)font withWidth:(CGFloat)width;
- (CGSize)calculateSize:(NSString *)contentStr withDict:(NSDictionary *)atttibute withWidth:(CGFloat)width;
+ (CGSize)calculateSize:(NSString *)contentStr withDict:(NSDictionary *)atttibute withWidth:(CGFloat)width;

@end
