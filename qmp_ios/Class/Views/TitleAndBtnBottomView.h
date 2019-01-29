//
//  TitleAndBtnBottomView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleAndBtnBottomView : UIView

+ (TitleAndBtnBottomView*)titleAndBtnViewWithFrame:(CGRect)frame  Title:(NSString*)leftTitle  buttonTitle:(NSString*)btnTitle btnClick:(void(^)(void))btnClickBlock;

@end
