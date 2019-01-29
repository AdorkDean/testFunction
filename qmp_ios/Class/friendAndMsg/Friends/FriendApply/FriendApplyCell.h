//
//  FriendApplyCell.h
//  qmp_ios
//
//  Created by QMP on 2018/2/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendModel.h"

@interface FriendApplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *comZhiLab;
@property (weak, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *passBtn;
@property (weak, nonatomic) IBOutlet UILabel *zhiweiLab;

@property (weak, nonatomic) IBOutlet UIButton *rightButton; //操作可能认识的人

@property(nonatomic,strong) NSDictionary *dic;
@property(nonatomic,strong) FriendModel *friendM;

@end
