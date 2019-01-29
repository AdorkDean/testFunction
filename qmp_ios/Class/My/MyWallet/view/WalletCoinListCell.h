//
//  WalletCoinListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/8/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import "CoinFlowModel.h"

@interface WalletCoinListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *eventLab;

//@property (weak, nonatomic) IBOutlet UILabel *eventLab;
@property (weak, nonatomic) IBOutlet UILabel *coinLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@property(nonatomic,strong) CoinFlowModel *tradeModel;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
