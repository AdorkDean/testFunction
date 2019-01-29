//
//  InvoiceItem.h
//  qmp_ios
//
//  Created by molly on 2017/6/6.
//  Copyright © 2017年 Molly. All rights reserved.
//  发票

#import <Foundation/Foundation.h>

@interface InvoiceItem : NSObject

@property (strong, nonatomic) NSString *invoice_id;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *tel;
@property (strong, nonatomic) NSString *bank;
@property (strong, nonatomic) NSString *account;

//新增收货人信息
@property (strong, nonatomic) NSString *receiver;
@property (strong, nonatomic) NSString *receiver_tel;
@property (strong, nonatomic) NSString *receiver_ads;


@end
