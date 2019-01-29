//
//  MyInfoTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/3/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *keyLbl;


@property (weak, nonatomic) IBOutlet UILabel *valueLbl;

@property (strong, nonatomic) UIView *lineV;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueTrail;

- (void)initDataWithKey:(NSString *)key withValue:(NSString *)value;

@end
