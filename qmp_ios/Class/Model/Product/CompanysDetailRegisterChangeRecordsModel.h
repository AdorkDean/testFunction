//
//  CompanysDetailRegisterChangeRecordsModel.h
//  qmp_ios
//
//  Created by qimingpian10 on 2017/2/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanysDetailRegisterChangeRecordsModel : JSONModel

@property(nonatomic,copy)NSString <Optional>* change_name;
@property(nonatomic,copy)NSString <Optional>* change_before;
@property(nonatomic,copy)NSString <Optional>* change_after;
@property(nonatomic,copy)NSString <Optional>* change_time;
@property(nonatomic,copy)NSAttributedString <Optional>* beforeAtt;
@property(nonatomic,copy)NSAttributedString <Optional>* afterAtt;

@end
