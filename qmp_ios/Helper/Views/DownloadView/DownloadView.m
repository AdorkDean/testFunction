//
//  DownloadView.m
//  qmp_ios
//
//  Created by Molly on 2016/11/15.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "DownloadView.h"
#import "Reachability.h"
#import "ManagerHud.h"
#import "GetNowTime.h"
#import "GetMd5Str.h"

#import "FMDatabase.h"
//#import "FMDatabaseQueue.h"
//#import <sqlite3.h>
#import "FMDatabaseAdditions.h"


@interface DownloadView()
{
    NSInteger downPrecent;
    NSString *_urlPdfTableName;
    NSString *_tableName;
    NSString *dbPath;
}

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLbl;
@property (strong, nonatomic) UIView *hudView;

@property (assign, nonatomic) BOOL isCancled;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;

@property (strong, nonatomic) FMDatabase *db;


@property (strong, nonatomic) ManagerHud *downHudTool;
@property (strong, nonatomic) ReportModel *pdfModel;
@property (strong, nonatomic) GetNowTime *timeTool;

@end

@implementation DownloadView

+ (instancetype)initFrame{
    
    DownloadView *alertView = [[DownloadView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [alertView toSetLocalData];
    return alertView;
}

- (void)toSetLocalData{

    _db = [[DBHelper shared] toGetDB];
    _tableName = PDFTABLENAME;
    _urlPdfTableName = @"urlpdflist";
}

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle withCenter:(CGPoint)centerPoint withInfoLblH:(CGFloat)infoLblH ofDocument:(ReportModel *)pdfModel{
    
    self.pdfModel = pdfModel;
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];

    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, 160)];
    alertView.center = centerPoint;
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 10.f;
    alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:alertView];
    
    CGFloat width = alertView.frame.size.width;
    CGFloat height = alertView.frame.size.height;
    CGFloat lblH = 20.f;
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width, lblH)];
    titleLbl.text = title;
    titleLbl.textColor = RGBa(50,49,55,1);
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLbl];
    
    CGFloat hudW = 200.f;
    _hudView = [[UIView alloc] initWithFrame:CGRectMake((width - hudW)/2, titleLbl.frame.origin.y + titleLbl.frame.size.height + 20, hudW, 53)];
    _hudView.backgroundColor  = [UIColor clearColor];
    [alertView addSubview:_hudView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.hudView.frame.size.width, 3)];
    self.progressView.layer.borderColor = RGBa(58, 153, 216, 1).CGColor;
    self.progressView.layer.borderWidth = 0.5f;
    self.progressView.tintColor = RGBa(58, 153, 216, 1);
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.hudView addSubview:self.progressView];
    
    self.progressLbl = [[UILabel alloc] initWithFrame: CGRectMake(0, 13, self.hudView.frame.size.width, 20.f)];
    self.progressLbl.textColor = [UIColor grayColor];
    self.progressLbl.textAlignment = NSTextAlignmentCenter;
    self.progressLbl.font = [UIFont systemFontOfSize:16.f];
    [self.hudView addSubview:self.progressLbl];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.hudView.frame.origin.y + self.hudView.frame.size.height, width, 1)];
    rowView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:rowView];
    
    CGFloat btnY = rowView.frame.origin.y + rowView.frame.size.height;
    CGFloat btnH = height - btnY;
    CGFloat btnW = width / 2;
    
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, btnY, btnW - 0.5, btnH)];
    [leftBtn addTarget:self action:@selector(pressleftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
    [leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [alertView addSubview:leftBtn];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW + 0.5, btnY, btnW - 1, btnH)];
    [rightBtn addTarget:self action:@selector(pressRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [alertView addSubview:rightBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btnW - 1, btnY, 1, btnH)];
    lineView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:lineView];
    
    [self requestDocument];

}

- (void)pressleftBtn:(UIButton *)sender{

    
    [self removeFromSuperview];
    self.isCancled = YES;
    [_task cancel];
    _task = nil;
    
    if ([self.delegate respondsToSelector:@selector(pressCancleDownLoad:)]) {
        [self.delegate pressCancleDownLoad:self.pdfModel];
    }
    [QMPEvent event:@"pdf_down_cancel"];
    
}

- (void)pressRightBtn:(UIButton *)sender{

    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(pressHiddenDownLoad:)]) {
        [self.delegate pressHiddenDownLoad:self.pdfModel];
    }
    [QMPEvent event:@"pdf_down_hidden"];

}

- (void)requestDocument{
    
    
    [self.progressView setProgress:0 animated:NO];
    self.progressLbl.text = @"正在加载...";
    downPrecent = 0;
    NSString *pdfUrl = self.pdfModel.pdfUrl;
   
    self.isCancled = NO;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:pdfUrl]];
    _task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        CGFloat progressNum = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        //打印下下载进度
//        QMPLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
        NSInteger num =[[NSString stringWithFormat:@"%.0f",progressNum*100] integerValue];
        if (num >= downPrecent + 1 ) {
            downPrecent ++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:progressNum animated:YES];
                self.progressLbl.text = [NSString stringWithFormat:@"%ld %%",(long)num];

            });
        }
        
    }  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *fileName = @"";
        
        NSString *ppth = @"";
        if (![PublicTool isNull:self.pdfModel.name]) {
            fileName = self.pdfModel.name;
        }else{
            
            NSString *key = [GetMd5Str md5:self.pdfModel.pdfUrl];
            
            fileName = response.suggestedFilename ? response.suggestedFilename : [NSString stringWithFormat:@"%@%@",[key substringFromIndex:key.length - 20],[self.pdfModel.pdfUrl lastPathComponent]];
            
            if ([self.pdfModel.pdfUrl hasPrefix:@"http://note.youdao.com"]) {
                
                
                NSData * fileNameStringData = [fileName dataUsingEncoding:NSISOLatin1StringEncoding];
                fileName = [[NSString alloc]initWithData:fileNameStringData encoding:NSUTF8StringEncoding];
                
            }else{
                fileName = [fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            self.pdfModel.name = fileName;

        }
        
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        ppth = [docPath stringByAppendingPathComponent:response.suggestedFilename];
        
        //fileURLWithPath 拿到的是本地url路径
        return [NSURL fileURLWithPath:ppth];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (error.code == -1005) { //此种失败和NSURLSession内部有关系
            [self requestDocument];
            return;
        }
        
        //自动取消的下载 原因不明
        if (error.code == -999 && (self.isCancled == NO)) {
            [self requestDocument];
            return;
        }
        if (error.code == -1001) {  //请求超时
            [self requestDocument];
            return;
        }
        
        [self.downHudTool removeHud];
        
        NSString *name = (self.pdfModel.name?self.pdfModel.name : @"");
        
        NSFileManager *fileM = [NSFileManager defaultManager];
        NSString *cacPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cacPath stringByAppendingPathComponent:[self.pdfModel.pdfUrl lastPathComponent]];
        
        if ([fileM fileExistsAtPath:path]) {
            
            NSString *url = self.pdfModel.pdfUrl;
            NSString *pdfId = (self.pdfModel.reportId? self.pdfModel.reportId : @"");
            NSString *pdfType = (self.pdfModel.pdfType ? self.pdfModel.pdfType :@"");
            NSString *time = [self.timeTool getCompleteYearDayWithHour];
            NSString *size = self.pdfModel.size ;
            NSString *from = (self.pdfModel.from ? self.pdfModel.from : PDFFURL);
            NSString *collect = (self.pdfModel.collectFlag ? self.pdfModel.collectFlag : @"0");
           
            //新增报告日期  和 报告来源
            NSString *report_date = (self.pdfModel.report_date? self.pdfModel.report_date : @"");
            NSString *report_source = self.pdfModel.report_source?self.pdfModel.report_source:@"";
            
            //新增招股书 行业 和  板块
            NSString *report_hangye = [NSString stringWithFormat:@"%@",self.pdfModel.hangye1];
            NSString *report_bankuai = [NSString stringWithFormat:@"%@",self.pdfModel.shangshididian];
           
            if (!size) {
                
                NSFileManager *filem = [NSFileManager defaultManager];
                NSString *cacPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *path = [cacPath stringByAppendingPathComponent:self.pdfModel.name];
                if ([filem fileExistsAtPath:path]){
                    CGFloat fileSize = [filem attributesOfItemAtPath:path error:nil].fileSize;//字节
                    size = [NSString stringWithFormat:@"%.2fMB",fileSize/1024/1024];
                }
            }
            if(self.fromUrl){
                
                if ([_db open]) {
                    BOOL hasTable = [[DBHelper shared] isTableOK:_urlPdfTableName ofDataBase:_db];
                    if (!hasTable) {
                        //如果不存在,先创建表
                        NSString *countrySql = [NSString stringWithFormat:@"create table '%@' ('name' text, 'url' text)",_urlPdfTableName];
                        [_db executeUpdate:countrySql];
                    }
                    
                    if (![[DBHelper shared] oneTable:_urlPdfTableName hasOneInfo:name ofDataBase:_db]) {
                        NSString *insertSql = [NSString stringWithFormat:@"insert into '%@' (name,url) values('%@','%@')",_urlPdfTableName,name,url];
                        [_db executeUpdate:insertSql];
                        
                    }
                }
            }
            
            if (!_isCancled) {
                if ([_db open]) {
                    BOOL hasTable = [[DBHelper shared] isTableOK:_tableName ofDataBase:_db];
                    if (!hasTable) {
                        //如果不存在,先创建表
                        NSString *countrySql = [NSString stringWithFormat:@"create table '%@' ('name' text, 'url' text, 'id' text, 'type' text, 'time' text, 'size' text , 'come' text, 'collect' text,'report_date' text,'report_source' text, 'hangye1' text, 'shangshididian' text)",_tableName];
                        [_db executeUpdate:countrySql];
                        
                    }else{ //表是否存在此字段 报告日期和来源   3.4.4
                        
                        if (![_db columnExists:@"report_date" inTableWithName:_tableName]){
                            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",_tableName,@"report_date"];
                            BOOL worked = [_db executeUpdate:alertStr];
                            if(worked){
                                QMPLog(@"插入成功============================");
                            }else{
                                QMPLog(@"插入失败============================");
                            }
                        }
                        if (![_db columnExists:@"report_source" inTableWithName:_tableName]){
                            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",_tableName,@"report_source"];
                            BOOL worked = [_db executeUpdate:alertStr];
                            if(worked){
                                QMPLog(@"插入成功============================");
                            }else{
                                QMPLog(@"插入失败============================");
                            }
                        }
                        if (![_db columnExists:@"hangye1" inTableWithName:_tableName]){
                            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",_tableName,@"hangye1"];
                            BOOL worked = [_db executeUpdate:alertStr];
                            if(worked){
                                QMPLog(@"插入成功============================");
                            }else{
                                QMPLog(@"插入失败============================");
                            }
                        }
                        if (![_db columnExists:@"shangshididian" inTableWithName:_tableName]){
                            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",_tableName,@"shangshididian"];
                            BOOL worked = [_db executeUpdate:alertStr];
                            if(worked){
                                QMPLog(@"插入成功============================");
                            }else{
                                QMPLog(@"插入失败============================");
                            }
                        }
                        
                    }
                    
                    if (![[DBHelper shared] oneTable:_tableName hasOneInfo:name ofDataBase:_db]) {
                        NSString *insertSql = [NSString stringWithFormat:@"insert into '%@' (name,url,id,type,time,size,come,collect,report_date,report_source,hangye1,shangshididian) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",_tableName,name,url,pdfId,pdfType,time,size,from,collect,report_date,report_source,report_hangye,report_bankuai];
                        [_db executeUpdate:insertSql];
                        
                    }
                }
                
                NSMutableDictionary *pdfDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [pdfDict setValue:name forKey:@"title"];
                [pdfDict setValue:url forKey:@"url"];
                [pdfDict setValue:pdfId forKey:@"id"];
                [pdfDict setValue:pdfType forKey:@"type"];
                [pdfDict setValue:collect forKey:@"collect"];
                [pdfDict setValue:from forKey:@"from"];
                //还要存储report_time  3.4.4
                [pdfDict setValue:report_date forKey:@"report_date"];
                [pdfDict setValue:report_source forKey:@"report_source"];
                //存储招股书行业 和 板块
                [pdfDict setValue:report_hangye forKey:@"hangye1"];
                [pdfDict setValue:report_bankuai forKey:@"shangshididian"];


                //文件下载成功后应该用通知,否则会有bug
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_PDFDOWNSUCCESS object:pdfDict];
            }
            
            if ([_db open]) {
                [_db close];
            }

            
            if (_fromUrl) {
                if ([self.delegate respondsToSelector:@selector(downloadPdfFromUrlSuccess:)]) {
                    [self.delegate downloadPdfFromUrlSuccess:self.pdfModel];
                }
            }
        }else{  //下载失败
            if (_isCancled) {
                
            }else{
                QMPLog(@"下载失败--------");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_PDFDOWNFAIL object:self.pdfModel];
            }
            
        }
        
    }];
    [_task resume];
    
}


- (ManagerHud *)downHudTool{
    
    if (!_downHudTool) {
        _downHudTool = [[ManagerHud alloc] init];
    }
    return _downHudTool;
}
- (GetNowTime *)timeTool{
    
    if(!_timeTool){
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}

@end
