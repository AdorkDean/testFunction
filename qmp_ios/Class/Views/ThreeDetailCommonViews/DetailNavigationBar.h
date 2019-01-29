//
//  DetailNavigationBar.h
//  qmp_ios
//
//  Created by QMP on 2018/7/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailNavigationBar : UIView

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor * titleColor;

/** menuArr:lrdoutput模型 */
+ (instancetype)detailTopBarWithRightMenuArr:(NSArray*)menuArr shareEvent:(void(^)(void))shareEvent moreClick:(void(^)(void))moreClickEvent;

// 没有分享
+ (instancetype)detailTopBarWithRightMenuArr:(NSArray*)menuArr  moreClick:(void(^)(void))moreClickEvent;

// 没有更多
+ (instancetype)detailTopBarWithShareClick:(void(^)(void))shareClickEvent;

// 没有分享 没有更多
+ (instancetype)detailTopBarNoBtn;

- (void)showAnimator;
- (void)hideAnimator;

- (void)changeColorToWhite:(BOOL)isWhite;
- (BOOL)isWhite;

@end
