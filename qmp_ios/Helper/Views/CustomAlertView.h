//
//  CustomAlertView.h
//  CustomAlertView
//
//  Created by 丁宗凯 on 16/6/22.
//  Copyright © 2016年 dzk. All rights reserved.

// 反馈弹窗view

#import <UIKit/UIKit.h>

@protocol CustomAlertViewDelegate <NSObject>

@optional
- (void)feedsUploadSuccess;
@end
@interface CustomAlertView : UIView

@property(nonatomic,strong) UITextView *textview;

@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)NSArray *feedbackAllModulesArr;//反馈的所有模块选项
@property (nonatomic,strong)UILabel *lab;//提示
@property (nonatomic,strong)UIButton *feedbackAllBtn;
@property (nonatomic,weak)UIViewController *VC;
@property (nonatomic,strong)NSMutableArray *selectedBtnMArr;
@property (nonatomic,strong)UIButton *qRButton;
@property (nonatomic,strong)NSDictionary * infoDic;//反馈的模块
@property (nonatomic,copy)void(^submitBtnClick)(void);

@property (nonatomic, weak) id<CustomAlertViewDelegate> delegate;

- (NSMutableString *)toGetSelectText;
- (instancetype)initWithAlertViewHeight:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height infoDic:(NSDictionary *)infoDic viewcontroller:(UIViewController *)vc moduleNum:(NSInteger)moduleNum isFeeds:(BOOL)isFeed;

@end
