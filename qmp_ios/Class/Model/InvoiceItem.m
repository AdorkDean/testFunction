//
//  InvoiceItem.m
//  qmp_ios
//
//  Created by molly on 2017/6/6.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvoiceItem.h"

@implementation InvoiceItem

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

    if ([key isEqualToString:@"id"]) {
        self.invoice_id = value;
    }
}
@end
