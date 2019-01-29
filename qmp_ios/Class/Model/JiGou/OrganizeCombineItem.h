//
//  OrganizeCombineItem.h
//  qmp_ios
//
//  Created by Molly on 2016/11/29.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrganizeCombineItem : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *count;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *agency_uuid;
@property (copy, nonatomic) NSString *detail;

@property (strong, nonatomic) NSString *type;

@end
