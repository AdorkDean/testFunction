//
//  SetTableViewController.h
//  qmp_ios
//
//  Created by 李建 on 16/11/22.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetTableViewControllerDelegate <NSObject>

- (void)pressQuitLoginBtn;

@end
@interface SetTableViewController : UITableViewController

@property(nonatomic,weak) id<SetTableViewControllerDelegate>delegate;

@end
