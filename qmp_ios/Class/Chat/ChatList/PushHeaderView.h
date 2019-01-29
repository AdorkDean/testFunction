//
//  PushHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushHeaderView : UIView

//系统通知
@property (weak, nonatomic) IBOutlet UIView *systemMsgView;
@property (weak, nonatomic) IBOutlet UILabel *systemMsgContentLab;
@property (weak, nonatomic) IBOutlet UILabel *systemMsgRedV;


//互动提醒
@property (weak, nonatomic) IBOutlet UIView *userActivityView;
@property (weak, nonatomic) IBOutlet UILabel *userActivityViewContentLab;
@property (weak, nonatomic) IBOutlet UILabel *userActivityRedV;


// 交换联系方式
//@property (weak, nonatomic) IBOutlet UIView *applyView;
//@property (weak, nonatomic) IBOutlet UILabel *applyContentLab;
//@property (weak, nonatomic) IBOutlet UILabel *applyRedV;
@property (weak, nonatomic) IBOutlet UIView *line;



@end
