//
//  MEDocumentCollecttedListVC.h
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

/**
 文档管理 - 已收藏
 */
@interface DocumentCollecttedListVC : BaseViewController
@property (copy, nonatomic) NSString *searchWord;
@property (strong, nonatomic) UISearchBar *mySearchBar;
- (void)disAppear;  //左右切换

- (void)beginSearch:(NSString*)text;
@end
