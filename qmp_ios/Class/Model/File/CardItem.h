//
//  CardItem.h
//  qmp_ios
//
//  Created by Molly on 16/9/22.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardItem : NSObject

@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *imgUrl;
@property (strong, nonatomic) NSString *cardName;
@property (strong, nonatomic) NSString *remark;
@property (strong, nonatomic) NSString *uploadTime;
@property (copy, nonatomic) NSString *jigou;
@property (copy, nonatomic) NSString *product;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *zhiwu;

@property (strong,  nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *offaddress;

@property (strong, nonatomic) NSString *folder;
@property (assign, nonatomic) int back_flag;
@property (strong, nonatomic) NSString *backImgUrl;

//汉王云
@property (copy, nonatomic)NSString <Optional> *name;
@property (copy, nonatomic)NSString <Optional> *title;
@property (copy, nonatomic)NSString <Optional> *tel; //座机
@property (copy, nonatomic)NSString <Optional> *mobile;  //手机
@property (copy, nonatomic)NSString <Optional> *fax; //传真
@property (copy, nonatomic)NSString <Optional> *comp;
@property (copy, nonatomic)NSString <Optional> *degree;
@property (copy, nonatomic)NSString <Optional> *dept;
@property (copy, nonatomic)NSString <Optional> *post;
@property (copy, nonatomic)NSString <Optional> *web;
@property (copy, nonatomic)NSString <Optional> *addr;
@property (copy, nonatomic)NSString <Optional> *other;
@property (copy, nonatomic)NSString <Optional> *numOther;
@property (copy, nonatomic)NSString <Optional> *extTel;
@property (copy, nonatomic)NSString <Optional> *mbox;
@property (copy, nonatomic)NSString <Optional> *htel;
@property (copy, nonatomic)NSString <Optional> *im;

//委托联系
@property (strong, nonatomic) NSString *zhiwei;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *product_id;
@property (strong, nonatomic) NSString *person_id;
@property (strong, nonatomic) NSString *entrust_project; //项目机构
@property (strong, nonatomic) NSString *contacts;
@property (strong, nonatomic) NSString *telephone;
@property (strong, nonatomic) NSString *wechat;
@property (strong, nonatomic) NSString *type; //项目机构区分

@property (assign, nonatomic)BOOL selected;

@end
