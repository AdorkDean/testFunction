//
//  StarProductsTableViewCell.h
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/17.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StarProductsModel;

@interface StarProductsTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *statusLbl;

@property (strong, nonatomic) UIButton *chooseBtn;
;@property (strong, nonatomic) UILabel *timeLabel; //专辑管理有
@property (strong, nonatomic) UIButton *contactBtn;  //投融资有


@property(nonatomic,strong) UIView *bottomLine;

@property (nonatomic,assign) BOOL isHomeRz;

@property(nonatomic,assign) BOOL isEditting;
@property(nonatomic,assign) BOOL isChoosed;


//刷新函数
@property(nonatomic,assign) BOOL hideStarImgV;

-(void)refreshUI:(StarProductsModel *)model;

@end
