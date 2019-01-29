//
//  CenterButton.h
//  qmp_ios
//
//  Created by Molly on 2016/11/7.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterButton : UIView

@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLbl;


- (void)setToCenterWithImage:(NSString*)imgName withImgSize:(CGSize)imgSize withTitle:(NSString *)title withTitleSize:(CGSize)titleSize withFont:(CGFloat)font withTitleColor:(UIColor*)titleColor withBtnW:(CGFloat)btnW;

- (void)setToCenterWithRightImage:(NSString*)imgName withImgSize:(CGSize)imgSize withTitle:(NSString *)title withTitleSize:(CGSize)titleSize withFont:(CGFloat)font withTitleColor:(UIColor*)titleColor withBtnW:(CGFloat)btnW;

- (void)changeImageWithName:(NSString *)imgName;

@end
