//
//  RegisterInfoViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/10.
//  Copyright © 2016年 Molly. All rights reserved.
//  项目工商信息 天眼查

#import <UIKit/UIKit.h>

@interface RegisterInfoViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *urlDict;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *product;
@property (nonatomic, strong) NSString *gotoSection;

@end
