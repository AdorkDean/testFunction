//
//  WalletCoinListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "WalletCoinListCell.h"
#import "ActivityDetailViewController.h"
#import "PersonModel.h"

@interface WalletCoinListCell() <TTTAttributedLabelDelegate>
@end


@implementation WalletCoinListCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{

    WalletCoinListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletCoinListCellID"];
    if (!cell) {
        cell = [[BundleTool commonBundle]loadNibNamed:@"WalletCoinListCell" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.eventLab.delegate = self;
    self.eventLab.userInteractionEnabled = YES;
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];//网址没有下划线
    [linkAttributes setValue:BLUE_TITLE_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
    _eventLab.linkAttributes = linkAttributes;
}


- (void)setTradeModel:(CoinFlowModel *)tradeModel{
    _tradeModel = tradeModel;
    
    NSString *coinString = tradeModel.coin;
    if (![coinString containsString:@"-"]) {
        self.coinLab.textColor = BLUE_TITLE_COLOR;
        self.coinLab.text = [NSString stringWithFormat:@"+%@ 币",tradeModel.coin];
    }else{
        self.coinLab.textColor = COLOR737782;
        self.coinLab.text = [NSString stringWithFormat:@"%@ 币",tradeModel.coin];
    }
    self.timeLab.text = tradeModel.trade_time;
    if ([[tradeModel.trade_time componentsSeparatedByString:@" "] count] > 1) {
        self.timeLab.text = [[tradeModel.trade_time componentsSeparatedByString:@" "] firstObject];
    }
    
    //具体的显示文案
    NSString *event = tradeModel.event;
    BOOL negative = [coinString containsString:@"-"];
    NSString *eventDesc = @"";  //动态描述
    if ([event isEqualToString:@"online"]) {
        eventDesc = @"系统奖励：使用时长达到30分钟";
    }else if ([event isEqualToString:@"firstlogin"]) {
        eventDesc = @"系统奖励：每日登陆";
    }else if ([event isEqualToString:@"10TimesbyDay"]) {
        eventDesc = @"系统奖励：每日投币十次";
    }else if ([event isEqualToString:@"activity"]) {
        if (negative) { //负
            eventDesc = [NSString stringWithFormat:@"你投币了%@的动态",tradeModel.trade_nickname];
            if (tradeModel.anonymous.integerValue == 1) {
                eventDesc = @"你投币了一条动态";
            }
        }else{
            eventDesc = [NSString stringWithFormat:@"%@投币了你的动态",tradeModel.trade_nickname];
        }
    
    }else if([event isEqualToString:@"updateInfomation"]){
        eventDesc = @"系统奖励：完善个人资料";
    }
     
    [_eventLab setText:eventDesc afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        return mutableAttributedString;
    }];
    [_eventLab sizeToFit];
    
    if ([PublicTool isNull:eventDesc]) {
        return;
    }
    if (![PublicTool isNull:tradeModel.trade_nickname] && (![PublicTool isNull:tradeModel.person_ticket] || ![PublicTool isNull:tradeModel.unionid]) && (tradeModel.anonymous.integerValue != 1)) {
        NSArray *nickRanges = [PublicTool rangeOfSubString:tradeModel.trade_nickname inString:eventDesc];
        for (NSValue *rangeV in nickRanges) {
            NSRange nickRange = rangeV.rangeValue;
            [_eventLab addLinkToURL:[NSURL URLWithString:@"person"] withRange:nickRange];
        }
    }
   
    
    NSArray *activityRanges = [PublicTool rangeOfSubString:@"动态" inString:eventDesc];
    for (NSValue *rangeV in activityRanges) {
        NSRange activityRange = rangeV.rangeValue;
        [_eventLab addLinkToURL:[NSURL URLWithString:@"activity"] withRange:activityRange];
    }
    
}


#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
    if ([url.absoluteString containsString:@"person"]) {
        PersonModel *person = [[PersonModel alloc]init];
        person.unionid = self.tradeModel.unionid;
        person.personId = self.tradeModel.person_id;
        [PublicTool goPersonDetail:person];
    }else if ([url.absoluteString containsString:@"activity"]) {
        ActivityDetailViewController *activityVC = [[ActivityDetailViewController alloc]init];
        activityVC.activityID = self.tradeModel.event_ticket_id;
        activityVC.activityTicket = self.tradeModel.event_ticket;
        [[PublicTool topViewController].navigationController pushViewController:activityVC animated:YES];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
