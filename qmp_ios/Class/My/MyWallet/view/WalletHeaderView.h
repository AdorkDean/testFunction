//
//  WalletHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2018/8/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *coinNumLab;
@property (weak, nonatomic) IBOutlet UIView *usrHeadV;
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImgV;

@end
