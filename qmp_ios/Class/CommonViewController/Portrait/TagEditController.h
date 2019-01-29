//
//  TagEditController.h
//  qmp_ios
//
//  Created by QMP on 2017/8/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsItem.h"

@interface TagEditController : BaseViewController

@property (copy, nonatomic) NSString *productId;

@property(nonatomic,strong) NSArray *editTagArr;

@property (copy, nonatomic) void(^finishEdit)(NSArray *addTagArr); //添加到专辑数组TagsItem


@end
