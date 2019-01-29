//
//  TextViewTableViewCell.h
//  qmp_ios
//
//  Created by QMP on 2018/5/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTextViewTableViewCellHeight 164.0
@class HMTextView;
@interface TextViewTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *keyLabel;
@property (nonatomic, strong) HMTextView *textView;
@property (nonatomic, strong) UIImageView *lineView;
@end
