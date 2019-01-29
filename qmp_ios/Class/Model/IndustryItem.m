//
//  IndustryItem.m
//  qmp_ios
//
//  Created by Molly on 2016/10/26.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "IndustryItem.h"

@implementation IndustryItem
- (void)setValue:(id)value forKey:(NSString *)key{

    if ([key isEqualToString:@"name"]) {
        self.name = [NSString stringWithFormat:@"%@",value];
        
    }

    if ([key isEqualToString:@"selected"]) {
        self.selected = [NSString stringWithFormat:@"%@",value];
        return;
    }
    
}
@end
