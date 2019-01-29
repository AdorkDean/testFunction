//
//  DBHelper.m
//  qmp_ios
//
//  Created by Molly on 2016/11/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "DBHelper.h"
#import "GetMd5Str.h"

@implementation DBHelper

static DBHelper *db = nil;

+ (instancetype)shared{
    dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        db = [[DBHelper alloc]init];
    });
    return db;
}


- (BOOL) isTableOK:(NSString *)tableName ofDataBase:(FMDatabase *)db{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = %@",tableName];
    QMPLog(@" ===tableExist=====%@",sql);
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        QMPLog(@"isTableOK %ld", (long)count);
        
        if (count == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)oneTable:(NSString *)tableName hasOneInfo:(NSString *)info  ofDataBase:(FMDatabase *)db{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from '%@' where name ='%@'",tableName,info];

    FMResultSet *rs = [db executeQuery:sql];
    QMPLog(@" ===tableExist=====%@",sql);
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        QMPLog(@"isTableOK %ld", (long)count);
        
        if (count == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSMutableArray *)toGetPdfFromLocal:(NSString *)tableName fDataBase:(FMDatabase *)db {
    NSMutableArray *localMArr = [[NSMutableArray alloc] initWithCapacity:0];

    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@'",tableName];
        
        FMResultSet *rs = [db executeQuery:sql];
        QMPLog(@" ===tableExist=====%@",sql);
        while ([rs next]) //create table '%@' ('name' text, 'url' text, 'id' text, 'type' text, 'time' text, 'size' text , 'come' text, 'collect' text,'report_date' text,'report_source' text)",_tableName];
        {
            NSString *name = [rs stringForColumn:@"name"];
            
            if (name) {
                [localMArr addObject:name];
            }
        }
        [db close];
    }
    return localMArr;
}

- (NSMutableArray *)toGetPdfArrFromLocal:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr{
    NSMutableArray *localMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from '%@' where %@",tableName,conditionStr];

        FMResultSet *rs = [db executeQuery:sql];
        QMPLog(@" ===tableExist=====%@",sql);
        
        while ([rs next]){
             NSString *name = [rs stringForColumn:@"name"];
             NSString *url = [rs stringForColumn:@"url"];
             NSString *idStr = [rs stringForColumn:@"id"];
             NSString *time = [rs stringForColumn:@"time"];
             NSString *size = [rs stringForColumn:@"size"];
             NSString *come = [rs stringForColumn:@"come"];
             NSString *collect = [rs stringForColumn:@"collect"];
             NSString *report_date = [rs stringForColumn:@"report_date"];
             NSString *report_source = [rs stringForColumn:@"report_source"];
            NSString *hangye1 = [rs stringForColumn:@"hangye1"];
            NSString *shangshididian = [rs stringForColumn:@"shangshididian"];
            
            ReportModel *report = [[ReportModel alloc]init];
            report.name = name;
            report.pdfUrl = url;
            report.reportId = idStr;
            report.downtime = time;
            report.size = size;
            report.from = come;
            report.collectFlag = collect;
            report.report_date = report_date;
            report.report_source = report_source;
            report.hangye1 = hangye1;
            report.shangshididian = shangshididian;

            if (name) {
                [localMArr addObject:report];
            }
        }
        [db close];
    }
    return localMArr;
}


- (FMDatabase *)toGetDB{

    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    return db;
}

- (NSString *)toGetTablename:(NSString *)name{

    NSString *unionidHandelStr = [[WechatUserInfo shared].unionid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (![PublicTool isNull:unionidHandelStr]) {
        return [NSString stringWithFormat:@"%@%@",[GetMd5Str md5:unionidHandelStr],name];

    }else{
        return name;
    }
}

- (BOOL)deleteOneTableInfo:(NSString *)tableName fDataBase:(FMDatabase *)db{

    BOOL res = NO;
    if ([db open]) {
        //这个函数其实应该用事物进行处理
        if ([self isTableOK:tableName ofDataBase:db]) {
        
            NSString *delSql = [NSString stringWithFormat:@"delete from '%@' where 1=1",tableName];
            QMPLog(@"%@", delSql);
            res = [db executeUpdate:delSql];
            
            [db close];
        }
    }

    return res;
}

//删除内容
- (void)deleteLocal:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr{ //删除 有条件
    
    if ([db open]) {
        
        NSString *delSql = [NSString stringWithFormat:@"delete from '%@' where %@",tableName,conditionStr];
        
        QMPLog(@"%@", delSql);
        BOOL isSuccess = [db executeUpdate:delSql];
        QMPLog(@"删除成功是否  %d", isSuccess);
        
        [db close];
    }
}

- (BOOL)deleteLocalTableName:(NSString *)tableName fDataBase:(FMDatabase *)db conditionStr:(NSString*)conditionStr{ //删除 有条件
    BOOL isSuccess = NO;
    if ([db open]) {
        NSString *delSql = [NSString stringWithFormat:@"delete from '%@' where %@",tableName,conditionStr];
        
        QMPLog(@"%@", delSql);
        isSuccess = [db executeUpdate:delSql];
        QMPLog(@"删除成功是否  %d", isSuccess);
        [db close];
    }
    return isSuccess;
}

#pragma mark 通过之前的 come 字段进行判断是否存在旧值
- (BOOL)isUpdateLocalComeValue{
    NSString * tblName = PDFTABLENAME;
    NSString * selectSql = [NSString stringWithFormat:@"select name from '%@' where come = 'pdfFromCollectList'", tblName];
    DBHelper *dbHelper = [DBHelper shared];
    FMDatabase *db = [dbHelper toGetDB];
    BOOL isContain = NO;
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSql];
        while ([rs next]) {
            isContain = YES;
        }
        [db close];
    }else{
    }
    return isContain;
}
/**
 更新之前本地表中的字段
 */
- (void)UpdateLocalDataDiffComeBPandBG{
    NSString * tblName = PDFTABLENAME;
    NSString * selectSql = [NSString stringWithFormat:@"select name,url,id from '%@' where come = 'pdfFromCollectList' AND type = 'cloud'", tblName];
    DBHelper *dbHelper = [DBHelper shared];
    FMDatabase *db = [dbHelper toGetDB];
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSql];
        while ([rs next]) {
            NSString * nameStr = [rs stringForColumn:@"name"];
            NSString * urlStr = [rs stringForColumn:@"url"];
            NSString * idStr = [rs stringForColumn:@"id"];
            
            NSString * comeRpStr;
            if ([idStr isEqualToString:@"(null)"]) {
                comeRpStr = BP;
            }else{
                comeRpStr = HYBG;
            }
            NSString * updateSql = [NSString stringWithFormat:@"update '%@' set come = '%@' where name = '%@' and url = '%@'", tblName,comeRpStr, nameStr, urlStr];
            if ([db executeUpdate:updateSql]) {
                QMPLog(@"update %@ success", nameStr);
            }else{
                QMPLog(@"update %@ fail", nameStr);
            }
        }
        [db close];
    }else{
    }
}
@end
