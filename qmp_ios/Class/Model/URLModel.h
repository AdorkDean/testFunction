//
//  URLModel.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/2.
//  Copyright © 2016年 qimingpian. All rights reserved.
//  网址

#import <Foundation/Foundation.h>

@interface URLModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *collect_time;//收藏时间 0809 molly

@property (copy,nonatomic) NSString *urlId;
@property (copy, nonatomic) NSString *isRead;
@property (copy, nonatomic) NSString *isCollect;
@property (copy, nonatomic) NSString *isRecommend;
@property (copy, nonatomic) NSString *type;


@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;

@property(strong, nonatomic) NSDictionary *data;
@property(strong, nonatomic) NSString *dataStr;
@property(strong, nonatomic) NSArray *retArr;

@end
