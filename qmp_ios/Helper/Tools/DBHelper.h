//
//  DBHelper.h
//  qmp_ios
//
//  Created by Molly on 2016/11/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import <sqlite3.h>

@interface DBHelper : NSObject

+ (instancetype)shared;

- (BOOL) isTableOK:(NSString *)tableName ofDataBase:(FMDatabase *)db;
- (BOOL)oneTable:(NSString *)tableName hasOneInfo:(NSString *)info  ofDataBase:(FMDatabase *)db;
- (NSMutableArray *)toGetPdfFromLocal:(NSString *)tableName fDataBase:(FMDatabase *)db; //获取 pdf文件 name数组

- (NSMutableArray *)toGetPdfArrFromLocal:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr; //获取 pdf文件 模型数组

- (FMDatabase *)toGetDB;
- (NSString *)toGetTablename:(NSString *)name;

//删除内容
- (void)deleteLocal:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr; //删除 有条件
//带有状态
- (BOOL)deleteLocalTableName:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr;//删除 有条件
- (BOOL)deleteOneTableInfo:(NSString *)tableName fDataBase:(FMDatabase *)db;

- (BOOL)isUpdateLocalComeValue;
- (void)UpdateLocalDataDiffComeBPandBG;
@end
