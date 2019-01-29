//
//  AlbumCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/2.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsItem.h"

@interface AlbumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property(nonatomic,strong) TagsItem *item;

@end
