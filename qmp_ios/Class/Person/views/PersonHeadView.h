//
//  PersonHeadView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"
#import "PersonDetailViewModel.h"

@interface PersonHeadView : UIView

@property(nonatomic,strong)UIImageView *iconImgV;
@property(nonatomic,strong)UIImageView *cardImgV;

//人物库
@property(nonatomic,assign) BOOL isMy;
@property(nonatomic,strong) PersonModel *person;
@property(nonatomic,strong) PersonDetailViewModel *viewModel; //监听更新
@property(nonatomic,strong)UIButton *tipInfoLab;

@property(nonatomic,strong)UIButton *editBtn;
@property(nonatomic,strong)UIColor *iconLabColor;


//非认证用户
@property(nonatomic,strong) NSDictionary *infoDic;

@end
