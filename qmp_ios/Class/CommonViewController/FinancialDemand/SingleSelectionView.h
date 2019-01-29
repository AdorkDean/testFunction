//
//  SingleSelectionView.h
//  qmp_ios
//
//  Created by QMP on 2018/5/30.
//  Copyright © 2018年 Molly. All rights reserved.
//单选弹窗

#import <UIKit/UIKit.h>

@interface SingleSelectionView : UIView


//不用另写添加到父视图代码
-(instancetype)initWithTitle:(NSString*)keyTitle selectionTitles:(NSArray*)titlesArr selectedTitle:(NSString*)selectedTitle selectedEvent:(void (^)(NSString *selectedStr))selectedEvent;

@end
