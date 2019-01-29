//
//  BingGouProModel.h
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//并购库model

#import <JSONModel/JSONModel.h>
#import "BingGouYewuModel.h"


@interface BingGouLunci:JSONModel

@property (nonatomic, copy) NSString <Optional>*tzr;
@property (nonatomic, copy) NSString <Optional>*bili;
@property (nonatomic, copy) NSString <Optional>*lunciId;
@property (nonatomic, copy) NSString <Optional>*guzhi;
@property (nonatomic, copy) NSString <Optional>*money;
@property (nonatomic, copy) NSString <Optional>*orderbyrztime;
@property (nonatomic, copy) NSString <Optional>*jieduan;
@property (nonatomic, copy) NSString <Optional>*time;

@end




@interface BingGouProModel : JSONModel

@property (nonatomic, strong) NSArray <Optional> *bingous;
@property (nonatomic, strong) BingGouYewuModel <Optional>*yewu;
@property (nonatomic, strong) BingGouLunci <Optional>*lunci;

@end
