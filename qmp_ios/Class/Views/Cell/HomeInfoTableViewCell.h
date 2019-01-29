//
//  HomeInfoTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 16/8/18.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *subInfoLab;

@property (weak, nonatomic) IBOutlet UILabel *infoLbl;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

@end
