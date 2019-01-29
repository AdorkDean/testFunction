//
//  MyActivityListViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/7/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, MyActivityListViewControllerType){
    MyActivityListViewControllerTypeAnonymous = 1, //匿名
    MyActivityListViewControllerTypePublic,
    MyActivityListViewControllerTypeNote,
    MyActivityListViewControllerTypeFavor, // 收藏
    MyActivityListViewControllerTypeLike  // 点赞
};

@interface MyActivityListViewController : BaseViewController
@property (nonatomic, assign) MyActivityListViewControllerType type;
- (void)refreshData;

@end
