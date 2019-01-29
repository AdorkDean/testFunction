//
//  SearchPersonVC.h
//  qmp_ios
//
//  Created by QMP on 2018/2/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SearchfromType){
    SearchfromTypeInvestor = 1,
    SearchfromTypeMySelf
};

#import "CustomAlertView.h"

@interface SearchPersonVC : BaseViewController

//传入姓名
@property (copy, nonatomic)NSString *keyword;

@property (nonatomic, assign) SearchfromType type;

@end
