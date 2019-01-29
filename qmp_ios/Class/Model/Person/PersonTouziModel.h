//
//  PersonTouziModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/*"icon": "http:\/\/img1.qimingpian.com\/product\/raw\/2c8e5a9d3c0a7b950b509deceee395b1.jpg",
 "product": "e\u7a0e\u5ba2",
 "company": "\u4f18\u8bc6\u4e91\u521b\uff08\u5317\u4eac\uff09\u79d1\u6280\u6709\u9650\u516c\u53f8",
 "detail": "http:\/\/dt.datadang.com\/#\/detailcom?src=magic&ticket=86fd3a837ea95897b166b1a3e930bd12&id=997f57b2ad4d445781319182bc3dd846"
 }, {*/
@interface PersonTouziModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*hangye;
@property (copy, nonatomic) NSString <Optional>*yewu;
@property (copy, nonatomic) NSString <Optional>*tzlunci;
@property (copy, nonatomic) NSString <Optional>*lunci;
@property (copy, nonatomic) NSString <Optional>*valuations_money;
@property (copy, nonatomic) NSString <Optional>*valuations_time;


@end
