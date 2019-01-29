//
//  FeedbackModel.h
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *feedbackId;
@property (copy, nonatomic) NSString <Optional> *type;
@property (copy, nonatomic) NSString <Optional> *name;
@property (copy, nonatomic) NSString <Optional> *time;
@property (copy, nonatomic) NSString <Optional> *desc;
@property (copy, nonatomic) NSString <Optional> *folder;
@property (copy, nonatomic) NSString <Optional> *product;
@property (copy, nonatomic) NSString <Optional> *company;
@property (copy, nonatomic) NSString <Optional> *complete;
@property (copy, nonatomic) NSString <Optional> *rewardStatus;

@property (nonatomic, strong) NSArray <Optional> *images;
@property (nonatomic, strong) NSArray <Optional> *url;

@end
