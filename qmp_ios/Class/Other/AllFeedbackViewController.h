//
//  AllFeedbackViewController.h
//  qmp_ios
//
//  Created by molly on 2017/3/23.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AllFeedbackViewDelegate <NSObject>
@optional

- (void)feedbackSuccess;
@end

@interface AllFeedbackViewController : UIViewController
@property (weak, nonatomic) id<AllFeedbackViewDelegate> delegate;

@property (strong, nonatomic) NSString *flag;//如果不为nil, 说明为爆料; =1 公司爆料 , =2 机构爆料
@property (strong, nonatomic) NSString *module;//更多反馈的模块
@property (strong, nonatomic) NSString *from;//从哪个页面跳过来的, 电话下面显示的字段
@property (nonatomic,strong)NSArray *feedbackArr;//反馈模块的选项 ,  只有更多反馈需要传这个参数
@property (nonatomic,strong)NSArray *selectedFeedbackArr;//已选择模块

@property (nonatomic,copy)NSString *company;//givemore接口需要
@property (nonatomic,copy)NSString *product;//givemore接口需要
@property (nonatomic,copy)NSString *type;//givemore接口需要

@property (nonatomic,copy)NSString *oneid;//爆料

@end
