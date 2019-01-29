//
//  InvestorCommentModel.h
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface InvestorCommentModel : JSONModel
@property (nonatomic, copy) NSString <Optional>*content;
@property (nonatomic, copy) NSString <Optional>*update_time;
@property (nonatomic, copy) NSString <Optional>*invest_id;
@property (nonatomic, copy) NSString <Optional>*operate_name;
@property (nonatomic, copy) NSString <Optional>*commentId;
@property (nonatomic, copy) NSString <Optional>*img_url;
@property (nonatomic, copy) NSString <Optional>*invest_name;
@property (nonatomic, copy) NSString <Optional>*title;
@property (nonatomic, copy) NSString <Optional>*channel;
@property (nonatomic, copy) NSString <Optional>*open_flag;
@property (nonatomic, copy) NSString <Optional>*create_time;
@end
