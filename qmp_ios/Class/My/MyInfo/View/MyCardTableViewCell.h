//
//  MyCardTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/3/21.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *imgBtn;
@property (weak, nonatomic) IBOutlet UIButton *backImgBtn;

- (void)initData:(NSString *)imgName placeImg:(UIImage*)img  withBack:(NSString *)backImgName placeBackImg:(UIImage*)backimg;

- (void)initData:(NSString *)imgName withBack:(NSString *)backImgName;
@end
