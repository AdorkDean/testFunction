//
//  SearchPersonCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"
#import "InsetsLabel.h"
#import "SearchPerson.h"


@interface MySearchPersonCellByXib : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *companyLab;
@property (weak, nonatomic) IBOutlet UILabel *zhiwuLab;
@property (weak, nonatomic) IBOutlet UIButton *claimBtn;
@property (weak, nonatomic) IBOutlet UILabel *firstNaLab;
@property (weak, nonatomic) IBOutlet InsetsLabel *renlingTagLbl;
@property (weak, nonatomic) IBOutlet UILabel *claimLab;

@property (strong, nonatomic) IBOutlet UIImageView *renzhengIcon;

@property(nonatomic,strong) PersonModel *person;
@property(nonatomic,strong) SearchPerson *searchPerson;

@property(nonatomic,strong) UIColor *nametitColor;
@end
