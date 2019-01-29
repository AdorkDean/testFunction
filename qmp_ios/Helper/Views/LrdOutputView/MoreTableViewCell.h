//
//  MoreTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 16/10/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *txtLbl;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@end
