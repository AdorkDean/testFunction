//
//  NoCommentCell.m
//  qmp_ios
//
//  Created by QMP on 2017/9/13.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "NoCommentCell.h"

@implementation NoCommentCell

+ (NoCommentCell *)cellWithTableView:(UITableView *)tableView {
    NoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCommentCellID"];
    if (cell == nil) {
        cell = (NoCommentCell *)[[[NSBundle mainBundle] loadNibNamed:@"NoCommentCell" owner:self options:nil] lastObject];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
