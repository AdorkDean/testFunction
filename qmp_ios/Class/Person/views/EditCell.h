//
//  EditCell.h
//  qmp_ios
//
//  Created by QMP on 2018/3/1.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCell : UITableViewCell

@property(nonatomic,strong) UILabel *keyLabel;
@property(nonatomic,strong) UITextField *valueTf;
@property(nonatomic,strong) UIView *line;

@end
