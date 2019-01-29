//
//  GroupModel.h
//  qmp_ios
//
//  Created by Molly on 16/8/18.
//  Copyright © 2016年 Molly. All rights reserved.
//专辑列表 model

#import <Foundation/Foundation.h>

@interface GroupModel : JSONModel

@property (copy, nonatomic) NSString<Optional> *groupId;
@property (copy, nonatomic) NSString<Optional> *name;
@property (copy, nonatomic) NSString <Optional>*name_display;
@property (copy, nonatomic) NSString <Optional>*open_flag;
@property (copy, nonatomic) NSString <Optional>*userfolderid;

@property (copy, nonatomic) NSString <Optional>*count;
//@property (copy, nonatomic) NSString <Optional>*defatlt;//0为默认选中
//@property (copy, nonatomic) NSString <Optional>*follow;
@property (copy, nonatomic) NSString <Optional>*share_id;
//@property (copy, nonatomic) NSString <Optional>*zhiding;//zhiding=2表示现在置顶；zhiding =1，表示以前置顶过，现在没有置顶了；zhiding=0表示从来没有置顶。
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*author;

//新专辑库字段
@property (copy, nonatomic) NSString <Optional>*album_name;
@property (copy, nonatomic) NSString <Optional>*hangye;
@property (copy, nonatomic) NSString <Optional>*open_time;
@property (copy, nonatomic) NSString <Optional>*img_url;
@property (copy, nonatomic) NSString <Optional>*album_id;
@property (copy, nonatomic) NSString <Optional>*pay_flag;
@property (copy, nonatomic) NSNumber <Optional>*hot_flag;


@property (nonatomic, strong) NSArray <Optional>*product;

@end
