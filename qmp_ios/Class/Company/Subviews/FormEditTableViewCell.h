//
//  FormEditTableViewCell.h
//  qmp_ios
//
//  Created by QMP on 2018/5/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMTextView.h"
@protocol FormEditTableViewCellDelegate;
@interface FormEditTableViewCell : UITableViewCell
@property(nonatomic,strong) UILabel *keyLabel;
@property(nonatomic,strong) UITextField *valueTf;
@property(nonatomic,strong) UIView *line;
@property(nonatomic,strong) UIView *selectsView;

@property (nonatomic, assign) BOOL isMultiSelection;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) NSMutableArray *selectedTitles;
@property (nonatomic, strong) HMTextView *textView;

@property (nonatomic, weak) id<FormEditTableViewCellDelegate> delegate;
@end

@protocol FormEditTableViewCellDelegate <NSObject>
@optional
- (void)formEditTableViewCell:(FormEditTableViewCell *)cell buttonClick:(UIButton *)button;
@end
