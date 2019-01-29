//
//  CardLeadProgressView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardLeadProgressView : UIView
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UIView *whiteView;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;

@end
