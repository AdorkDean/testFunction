//
//  TagsItem.h
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsItem : JSONModel

@property (strong ,nonatomic) NSString <Optional>*tag_uuid;
@property (strong ,nonatomic) NSString <Optional>*tag_id;
@property (strong ,nonatomic) NSString <Optional>*tag;
@property (strong ,nonatomic) NSString <Optional>*product_num;

@property(nonatomic,strong) NSNumber <Optional>*choosed;
@end
