//
//  JigouInvestmentsCaseModel.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/26.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "JigouInvestmentsCaseModel.h"

@implementation JigouInvestmentsCaseModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (NSString *)nowLunci{
    if (!_nowLunci || _nowLunci.length == 0) {
        
        _nowLunci = [NSString stringWithFormat:@"%@  %@  %@",self.time,self.jieduan,self.money];
        
    }
    return _nowLunci;
}

- (NSString *)pastLunci{
    if (!_pastLunci || _pastLunci.length == 0) {
        _pastLunci = [NSString string];
        
        for (NSDictionary *dic  in self.luncis) {
            _pastLunci = [_pastLunci stringByAppendingString:[NSString stringWithFormat:@"%@  %@  %@\n",dic[@"time"],dic[@"lunci"],dic[@"money"]]];
        }
        
        if (_pastLunci.length > 0) {
            _pastLunci = [_pastLunci stringByReplacingCharactersInRange:NSMakeRange(_pastLunci.length-1, 1) withString:@""];

        }
    }
    return _pastLunci;
}

//机构详情 投资案例cell
-(NSArray *)lunciStringArr{

    NSArray *arr = self.luncis.count ? self.luncis : (self.invest_turns ? : self.finance_history);
    if (!arr || ![arr isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    if (arr.count == 0) {
        return @[];
    }
    NSMutableArray *array = [NSMutableArray array];

    for (NSDictionary *dic  in arr) {
        //时间处理
        NSMutableArray *arr;
        if ([dic[@"time"] containsString:@"."]) {
            arr = [NSMutableArray arrayWithArray:[dic[@"time"] componentsSeparatedByString:@"."]];
            [arr removeLastObject]; //删除日期中的日

        }else if([dic[@"time"] length] > 0){
            arr = [NSMutableArray arrayWithObjects:dic[@"time"], nil];
        }else{
            arr = [NSMutableArray array];
        }
        NSMutableString *timeStr = [NSMutableString string];
        for (NSString *str in arr) {
            if (str.length == 1) {
                [timeStr appendString:[NSString stringWithFormat:@".%@%@",@"0",str]];
            }else{
                [timeStr appendString:[NSString stringWithFormat:@".%@",str]];
            }
        }
        if (timeStr.length) {
            [timeStr deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        NSString *rowStr = [NSString stringWithFormat:@"%@  %@  %@",timeStr,dic[@"lunci"]?:dic[@"jieduan"],dic[@"money"]];
        [array addObject:rowStr];
    }
    
    return array;
}

- (NSString*)lunciName:(NSString*)lunci{ //占位过滤
    NSInteger length = lunci.length;
    if (length == 4) {
        return lunci;
    }else if(length == 3){
        return [NSString stringWithFormat:@"%@ ",lunci];
    }else if(length == 2){
        return [NSString stringWithFormat:@"%@  ",lunci];
    }else if(length == 1){
        return [NSString stringWithFormat:@"%@   ",lunci];
    }
    
    return lunci;
}

-(NSString<Optional> *)time{
    if (![PublicTool isNull:_time]) {
        return _time;
    }else if(![PublicTool isNull:_lunci_time]){
        return _lunci_time;
    }else{
        return @"";
    }
}

-(NSString<Optional> *)jieduan{
    if (![PublicTool isNull:_jieduan]) {
        return _jieduan;
    }else if(![PublicTool isNull:_lunci]){
        return _lunci;
    }else{
        return @"";
    }
}

@end
