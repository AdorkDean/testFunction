//
//  CardEditingTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 16/9/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardEditingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *infoLbl;
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;


@end
