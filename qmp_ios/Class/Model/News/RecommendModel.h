//
//  RecommendModel.h
//  qmp_ios
//
//  Created by Molly on 2017/3/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSString <Optional>*detail;
@property (strong, nonatomic) NSString <Optional>*icon;
@property (strong, nonatomic) NSString <Optional>*img_url;
@property (strong, nonatomic) NSString <Optional>*qmp_url;

@property (strong, nonatomic) NSString <Optional>*time;
@property (strong, nonatomic) NSString <Optional>*post_time;
@property (strong, nonatomic) NSString <Optional>*post_time2;

@property (strong, nonatomic) NSString <Optional>*opentime;
@property (strong, nonatomic) NSString <Optional>*yewu;
@property (strong, nonatomic) NSString <Optional>*province;
@property (strong, nonatomic) NSString <Optional> *jieduan;
@property (strong, nonatomic) NSString <Optional>*hy1;
@property (strong, nonatomic) NSString <Optional>*hangye1;

@property (strong, nonatomic) NSString <Optional>*need_flag;
@property (strong, nonatomic) NSString <Optional>*tuijian;
@property (strong, nonatomic) NSString <Optional>*title;
@property (strong, nonatomic) NSString <Optional> *renzheng;
@property (strong, nonatomic) NSString <Optional>*product;
@property (strong, nonatomic) NSString <Optional>*lunci;
@property (strong, nonatomic) NSString <Optional>*news_link;
@property (strong, nonatomic) NSString <Optional>*link;

@end
