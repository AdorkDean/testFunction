//
//  EditReceiptController.h
//  qmp_ios
//
//  Created by QMP on 2017/9/1.
//  Copyright © 2017年 Molly. All rights reserved.
//添加  编辑发票

#import <UIKit/UIKit.h>
#import "InvoiceItem.h"

@interface EditReceiptController : BaseViewController

@property(nonatomic,strong)InvoiceItem *item;

@property (copy, nonatomic) void(^refreshReceipt)(InvoiceItem *item);
@property (copy, nonatomic) void(^addReceipt)(InvoiceItem *item);


@end
