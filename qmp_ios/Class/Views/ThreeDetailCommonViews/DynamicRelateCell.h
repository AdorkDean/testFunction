//
//  DynimacRelateCell.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//  项目、机构、人的用户分享

#import <UIKit/UIKit.h>
#import "PersonModel.h"

typedef NS_ENUM(NSInteger, DynamicRelateCellType) {
    DynamicRelateCellTypePerson = 0,    ///< 人物
    DynamicRelateCellTypeUser,          ///< 用户(unionid)
    DynamicRelateCellTypeProduct,       ///< 项目
    DynamicRelateCellTypeOrganize       ///< 机构
};

@interface DynamicRelateCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;


@property (nonatomic, strong) NSArray *dataArr;   ///< 数组数据
@property (nonatomic, copy) NSString *totalCount; ///< 动态总数


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier didSelectedItem:(void(^)(NSInteger index))didSelectedItem;

/**
 初始化需要注册一下UICollectionViewCell
 */
+ (instancetype)cellWithTableView:(UITableView*)tableView clickSeeMore:(void(^)(void))clickSeeMore;

@property (nonatomic, copy) NSString *ID;
//@property (nonatomic, assign) NSInteger type; ///< 0: product  1: organize
@property (nonatomic, assign) DynamicRelateCellType type;
@end

@interface MyCollectionViewFlowLayout : UICollectionViewFlowLayout

@end
