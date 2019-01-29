//
//  NSString+AttributedString.h
//  yingshibao
//
//  Created by anne on 2017/4/8.
//  Copyright © 2017年 北京掌控优教科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AttributedString)

/**
 *  设置段落样式
 *
 *  @param lineSpacing 行高
 *  @param textcolor   字体颜色
 *  @param font        字体
 *
 *  @return 富文本
 */
-(NSAttributedString *)stringWithParagraphlineSpeace:(CGFloat)lineSpacing
                                           textColor:(UIColor *)textcolor
                                            textFont:(UIFont *)font;


-(NSAttributedString *)stringWithParagraphlineSpeace:(CGFloat)lineSpacing
                                           wordSpace:(CGFloat)wordSpace
                                           textColor:(UIColor *)textcolor
                                            textFont:(UIFont *)font;

/**
 *  计算富文本字体高度
 *
 *  @param lineSpeace 行高
 *  @param font       字体
 *  @param width      字体所占宽度
 *
 *  @return 富文本高度
 */
-(CGFloat)getSpaceLabelHeightwithSpeace:(CGFloat)lineSpeace withFont:(UIFont*)font withWidth:(CGFloat)width;

/********************************************************************
 *  返回包含关键字的富文本编辑
 *
 *  @param lineSpacing 行高
 *  @param textcolor   字体颜色
 *  @param font        字体
 *  @param KeyColor    关键字字体颜色
 *  @param KeyFont     关键字字体
 *  @param KeyWords    关键字数组
 *
 *  @return
 ********************************************************************/
-(NSAttributedString *)stringWithParagraphlineSpeace:(CGFloat)lineSpacing
                                           textColor:(UIColor *)textcolor
                                            textFont:(UIFont *)font
                                    withKeyTextColor:(UIColor *)KeyColor
                                             keyFont:(UIFont *)KeyFont
                                            keyWords:(NSArray *)KeyWords;


/**
 htmlString的富文本

 *  @param lineSpacing 行高
 *  @param textcolor   字体颜色
 *  @param font        字体
 *
 *  @return 富文本
 */

-(NSAttributedString*)htmlStringWithParagraphlineSpeace:(CGFloat)lineSpacing
                                              textColor:(UIColor *)textcolor
                                               textFont:(UIFont *)font;
/**
 *  计算htmlString富文本字体高度
 *
 *  @param lineSpeace 行高
 *  @param font       字体
 *  @param width      字体所占宽度
 *
 *  @return 富文本高度
 */

-(CGFloat)htmlStringGetSpaceLabelHeightwithSpeace:(CGFloat)lineSpeace withFont:(UIFont*)font withWidth:(CGFloat)width;

@end
