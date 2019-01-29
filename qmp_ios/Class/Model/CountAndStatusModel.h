//
//  CountAndStatusModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JSONModel.h"

@interface CountAndStatusModel : NSObject

//初始值-1
@property(nonatomic,assign)NSInteger like_status;
@property(nonatomic,assign)NSInteger focus_status;

@property(nonatomic,assign)NSInteger comment_count;
@property(nonatomic,assign)NSInteger focus_count;
@property(nonatomic,assign)NSInteger like_count;


@end
