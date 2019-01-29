
//  DocuMgrMyUploadListVC.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/16.
//  Copyright © 2016年 qimingpian. All rights reserved.

#import <UIKit/UIKit.h>

/**
 文档管理 - 我上传的
 */
@interface DocuMgrMyUploadListVC : BaseViewController

@property (copy, nonatomic) NSString *searchWord;
@property (strong, nonatomic) UISearchBar *mySearchBar;
- (void)disAppear;  //左右切换

- (void)beginSearch:(NSString*)text;

@end
