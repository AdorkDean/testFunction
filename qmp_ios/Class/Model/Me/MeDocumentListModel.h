//
//  MeDocumentListModel.h
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JSONModel.h"

@interface MeDocumentListModel : JSONModel

@property (nonatomic) NSString <Optional> *buy_source;
@property (nonatomic) NSString <Optional> *coin;
@property (nonatomic) NSString <Optional> *collect_flag;
@property (nonatomic) NSString <Optional> *datetime;
@property (nonatomic) NSString <Optional> *file_id;
@property (nonatomic) NSString <Optional> *fileext;
@property (nonatomic) NSString <Optional> *filetype;
@property (nonatomic) NSString <Optional> *ID;
@property (nonatomic) NSString <Optional> *is_public;
@property (nonatomic) NSString <Optional> *name;
@property (nonatomic) NSString <Optional> *open_flag;
@property (nonatomic) NSString <Optional> *pass_flag;
@property (nonatomic) NSString <Optional> *size;
@property (nonatomic) NSString <Optional> *source;
@property (nonatomic) NSString <Optional> *src;
@property (nonatomic) NSString <Optional> *url;

@end
