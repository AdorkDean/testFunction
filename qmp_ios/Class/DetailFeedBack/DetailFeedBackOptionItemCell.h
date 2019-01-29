//
//  DetailFeedBackOptionItemCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallTagTitleBlock)(BOOL isSelected,NSString * tagTitle, NSArray * selectedArr);

@interface DetailFeedBackOptionItemCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray * selectTagArr;//被选中的标签

@property (nonatomic, strong) NSArray * itemBtnTitleArr;
@property (nonatomic, assign) CGFloat cellHeight;

- (CGFloat)getCellHeight;

+ (instancetype)initCellWithTableView:(UITableView *)tableview didSelectItem:(CallTagTitleBlock)callBackBlock;
@end
