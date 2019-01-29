//
//  NoCommentCell.h
//  qmp_ios
//
//  Created by QMP on 2017/9/13.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *msgLbl;
+ (NoCommentCell *)cellWithTableView:(UITableView *)tableView;
@end
