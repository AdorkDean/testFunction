//
//  ReportModel.h
//  qmp_ios
//
//  Created by Molly on 16/9/2.
//  Copyright © 2016年 Molly. All rights reserved.
//报告  和  招股书都用此model

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SearchCompanyModel.h"

typedef NS_ENUM(NSInteger,DownloadStatus) {
    DownloadStatusNone = 1,
    DownloadStatusDowning,
    DownloadStatusFinish
};
@interface ReportModel : NSObject
@property (copy, nonatomic) NSString *isBP;
@property (copy, nonatomic) NSString *datetime;
@property (copy, nonatomic) NSString *reportId;
@property (copy, nonatomic) NSString *fileid; //收到的BP

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *remark;
@property (copy, nonatomic) NSString *pdfUrl;
@property (copy, nonatomic) NSString *collectFlag;
@property (copy, nonatomic) NSString *openFlag;
@property (copy, nonatomic) NSString *pdfType;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *recommandFlag;
@property (copy, nonatomic) NSString *fileExt;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *downtime;
@property (copy, nonatomic) NSString *downLocaltime; //下载存储时间2017-9-30 14:23:47
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;

@property(strong, nonatomic) NSDictionary *data;
@property(strong, nonatomic) NSString *dataStr;
@property(strong, nonatomic) NSArray *retArr;

@property (copy, nonatomic) NSString *report_date; //报告时间
@property (copy, nonatomic) NSString *report_source;
@property (copy, nonatomic) NSString *update_time; //更新时间
@property (copy, nonatomic) NSString *read_count; //阅读数

//关于下载
@property(nonatomic,assign) CGFloat progress;
@property(nonatomic,assign) DownloadStatus downloadStatus; //下载状态

@property(nonatomic,assign) BOOL  selected; //选择BP

//招股书
@property (copy, nonatomic) NSString *hangye1;
@property (copy, nonatomic) NSString *company;
@property (copy, nonatomic) NSString *shangshididian;

//投递人
@property (copy, nonatomic) NSString *send_nickname;
@property (copy, nonatomic) NSString *send_unionids;
@property (copy, nonatomic) NSString *send_user_company;
@property (copy, nonatomic) NSString *send_user_job;
@property (copy, nonatomic) NSString *send_person_id;
@property (copy, nonatomic) NSString *send_user_phone;
@property (copy, nonatomic) NSString *send_status;

@property (assign, nonatomic) BOOL isNewThird;
@property (assign, nonatomic) BOOL isDownload;
@property (assign, nonatomic) BOOL fromUrl;
@property (copy, nonatomic) NSString *browse_status; //2 未查看
//我的BP
@property(nonatomic,assign)NSInteger showOptionView; //0 不显示 1 显示
@property(nonatomic,assign)NSInteger interest_flag; //1 未标记   0 不感兴趣  2 感兴趣
@property(nonatomic,strong)SearchCompanyModel *product_info;

@property(nonatomic,copy) NSString * product; //项目名字
@property(nonatomic,copy) NSString * icon; //项目图片
@property (assign, nonatomic) BOOL isMy; //我的BP  非收到的BP
@property (copy, nonatomic) NSString *detail; //相关项目链接

@end
