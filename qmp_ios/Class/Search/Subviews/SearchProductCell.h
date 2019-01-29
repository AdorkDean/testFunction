//
//  SearchProductCell.h
//  qmp_ios
//
//  Created by QMP on 2018/8/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchProduct;
@interface SearchProductCell : UITableViewCell
+ (instancetype)searchProductCellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;

@property (weak, nonatomic) IBOutlet UIImageView *bottonLineView;



@property (nonatomic, strong) SearchProduct *product;
@end
