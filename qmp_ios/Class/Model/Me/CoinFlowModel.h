//
//  CoinFlowModel.h
//  qmp_ios
//
//  Created by QMP on 2018/9/7.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JSONModel.h"

@interface CoinFlowModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *trade_nickname; //交易人昵称
@property (nonatomic, copy) NSString<Optional> *unionid; //用户unionid
@property (nonatomic, copy) NSString<Optional> *uuid; //用户uuid
@property (nonatomic, copy) NSString<Optional> *person_ticket; //人物ticket
@property (nonatomic, copy) NSString<Optional> *person_ticket_id; //人物ticket_id
@property (nonatomic, copy) NSString<Optional> *person_id; //人物id
@property (nonatomic, copy) NSString<Optional> *event; //交易事件
@property (nonatomic, copy) NSString<Optional> *event_ticket; //事件ticket
@property (nonatomic, copy) NSString<Optional> *event_ticket_id; //事件ticket_id
@property (nonatomic, copy) NSString<Optional> *trade_time; //交易时间
@property (nonatomic, copy) NSString<Optional> *coin; //
@property (nonatomic, copy) NSString<Optional> *anonymous; // 发布者是否匿名

@end
