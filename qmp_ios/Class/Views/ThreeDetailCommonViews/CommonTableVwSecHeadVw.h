//
//  CommonTableVwSecHeadVw.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEADERHEIGHT  50
typedef void(^rightBtnClickBlock)(NSString* sectionTitle);
typedef void(^leftBtnClickBlock)(void);

/**
 完善中，详情页定制
 */
@interface CommonTableVwSecHeadVw : UIView


// 传 CGRectZero 隐藏  
- (instancetype)initWithFrame:(CGRect)frame lblFrame:(CGRect)LbliFrame lblLine:(CGRect)lblLineFrame rightBtn:(CGRect)rightBtnFrame;

- (void)lbltitle:(NSString *)title textColor:(UIColor *)txtColor fontSize:(CGFloat)fontSize;
- (void)rightBtnTarget:(id)target action:(SEL)action;

- (instancetype)initSectionHeadViewFrame:(CGRect)frame clickCallBack:(rightBtnClickBlock)callBlock;

//高度 60
- (instancetype)initlbltitle:(NSString *)title btnTitle:(NSString *)btnTitle callBack:(rightBtnClickBlock)callBlock;

- (instancetype)initlbltitle:(NSString *)title leftBtnTitle:(NSString *)leftBtnTitle  btnTitle:(NSString *)btnTitle callBack:(rightBtnClickBlock)callBlock leftBtnClick:(leftBtnClickBlock)leftBtnClickEvent;

- (instancetype)initlbltitle:(NSString *)title btnTitle:(NSString *)btnTitle height:(CGFloat)height callBack:(rightBtnClickBlock)callBlock;

- (instancetype)initlbltitle:(NSString *)title leftBtnTitle:(NSString *)leftBtnTitle btnTitle:(NSString *)btnTitle height:(CGFloat)height callBack:(rightBtnClickBlock)callBlock leftBtnClick:(leftBtnClickBlock)leftBtnClickEvent;

@end
