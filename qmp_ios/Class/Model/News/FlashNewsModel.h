//
//  FlashNewsModel.h
//  qmp_ios
//
//  Created by QMP on 2018/3/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FlashNewsModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *title;
@property (copy, nonatomic) NSString <Optional> *post_time;
@property (copy, nonatomic) NSString <Optional> *showAll;
@property (copy, nonatomic) NSMutableAttributedString <Optional> *attText;

@property (strong, nonatomic) NSNumber <Optional> *rowHeight;

@end
