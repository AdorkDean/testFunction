//
//  SearchJgAndCNotFoundTableViewCell.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/4.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchJgAndCNotFoundTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *strLab1;
@property (nonatomic,strong) UILabel *strLab2;
@property (nonatomic,strong) UILabel *strLab3;

@property (nonatomic,strong) UIButton *feedbackBtn;
@property (nonatomic,weak) UIViewController *vc;
@property (nonatomic,copy) NSString *searchStr;
@property (nonatomic,strong)UIView *webView;

//@property (nonatomic,strong) UIButton *searchBtn;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andVC:(UIViewController *)vc andSearchStr:(NSString *)searchStr;
@end
