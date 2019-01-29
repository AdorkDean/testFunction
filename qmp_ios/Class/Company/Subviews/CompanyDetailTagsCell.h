//
//  CompanyDetailTagsCell.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/11.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsFrame.h"
@class CompanyDetailTagsModel;

@interface CompanyDetailTagsCell : UITableViewCell

+ (id)cellWithTableView:(UITableView *)tableView;
+ (id)cellWithTableView:(UITableView *)tableView clickTag:(void(^)(NSString *tag))clickTagEvent;

//刷新函数
-(void)refreshUI:(NSArray *)tagArr andTagsFrame:(TagsFrame *)tagsFrame;

-(void)refreshPersonUI:(NSArray *)tagArr andTagsFrame:(TagsFrame *)tagsFrame;


@end
