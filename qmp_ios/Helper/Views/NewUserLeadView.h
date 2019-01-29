//
//  NewUserLeadView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/19.
//  Copyright © 2018年 Molly. All rights reserved.
//新功能引导

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ShadeStyle){
    ShadeStyle_roundRect = 1,
    ShadeStyle_circle,
    ShadeStyle_rect
};

@interface NewUserLeadView : UIView

- (instancetype)initWithshadeFrame:(CGRect)shadeFrame shadeStyle:(ShadeStyle)shadeStyle imageFrame:(CGRect)imageFrame  image:(UIImage*)image leaderKey:(NSString*)leaderKey;

/**
 shadeFrame: 按钮frame
 shadeImage:按钮图片
 arrowImageFrame: 箭头的frame
 arrowImage： 箭头图片
 titleArr: 说明文案数组
 titleFrameArr： 说明文案frame数组
 clickBtnFrame： 我知道了 的位置frame
 leaderKey： 记录的key
 */
- (instancetype)initWithshadeFrame:(CGRect)shadeFrame shadeImage:(UIImage*)shadeImage arrowImageFrame:(CGRect)arrowImageFrame  arrowImage:(UIImage*)arrowImage titleArr:(NSArray*)titleArr titleFrameArr:(NSArray*)titleFrameArr clickBtnFrame:(CGRect)clickBtnFrame leaderKey:(NSString*)leaderKey;

/**
 imgFrame  图片位置
 leadImage 图片
 titleArr: 说明文案数组
 titleFrameArr： 说明文案frame数组
 clickBtnFrame： 我知道了 的位置frame
 leaderKey： 记录的key
 */
- (instancetype)initWithimageFrame:(CGRect)imgFrame leadImage:(UIImage*)leadImage titleArr:(NSArray*)titleArr titleFrameArr:(NSArray*)titleFrameArr clickBtnFrame:(CGRect)clickBtnFrame leaderKey:(NSString*)leaderKey;

@end
