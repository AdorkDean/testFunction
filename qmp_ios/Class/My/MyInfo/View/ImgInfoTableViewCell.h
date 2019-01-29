//
//  ImgInfoTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2017/3/11.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

- (void)initData:(NSString *)imgName;
@end
