//
//  OneInvoiceViewController.h
//  qmp_ios
//
//  Created by molly on 2017/6/7.
//  Copyright © 2017年 Molly. All rights reserved.

//发票详情

#import <UIKit/UIKit.h>
#import "InvoiceItem.h"


@interface OneInvoiceViewController : BaseViewController

- (instancetype)initWithItem:(InvoiceItem *)item;

@property (copy, nonatomic) void (^updateInvoiceSuccess)(InvoiceItem *invoiceItem);

@end
