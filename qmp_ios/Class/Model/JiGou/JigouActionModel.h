//
//  JigouActionModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface JigouActionModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*source;
@property (copy, nonatomic) NSString <Optional>*tzr_all;
@property (copy, nonatomic) NSString <Optional>*date;
@property (copy, nonatomic) NSString <Optional>*money;
@property (copy, nonatomic) NSString <Optional>*lunci;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*product_url;
@property (copy, nonatomic) NSString <Optional>*jigou;
@property (copy, nonatomic) NSString <Optional>*jigou_url;
@property (copy, nonatomic) NSString <Optional>*title;
@property (copy, nonatomic) NSString <Optional>*img_url;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*news_id;



@end
