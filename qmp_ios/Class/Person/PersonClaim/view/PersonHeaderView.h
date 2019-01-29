//
//  PersonHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2018/3/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"

@interface PersonHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *companyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *renzhengIcon;
@property (weak, nonatomic) IBOutlet UIView *contactNoSeeView;
@property (weak, nonatomic) IBOutlet UIView *contactInfoView;
@property (weak, nonatomic) IBOutlet UIButton *noseeContactBtn;
@property (weak, nonatomic) IBOutlet UIButton *friendShipBtn;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property(nonatomic,assign) BOOL fromUnauthenEdit;

@property(nonatomic,strong) PersonModel *person;

@end
