//
//  DownloadTool.h
//  ThreadTest
//
//  Created by anne on 2017/6/29.
//  Copyright © 2017年 anne. All rights reserved.
//reportPlist.plist文件存储pdfUrl的下载状态(0和1)，未下载完当做没下载，时刻更新

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"
#import "ReportModel.h"

@interface DownloadTool : NSObject

@property(nonatomic,assign)NSInteger maxConcurrentNum;

+ (instancetype)shared;

- (NSString*)filePathForUrl:(NSString*)url;

- (void)addDownloadUrl:(NSString*)url progress:(DownloadProgress)progress cancelDownload:(CancelOperation)cancelOperation downloadFinish:(DownloadFinish)downloadFinish;

- (void)pauseDownloadUrl:(NSString*)url;
- (void)cancelDownloadUrl:(NSString*)url;
- (void)continueDownloadUrl:(NSString*)url;
- (void)cancelAllDownload;


//缓存进度 没用着(行研报告)
- (void)cacheForUrl:(NSString*)url progress:(float)progress;
- (float)progressHaveDownloadForUrl:(NSString*)url;

//有用
- (void)deleteCacheUrl:(NSString*)url;
- (BOOL)isDownloadForUrl:(NSString*)url;
- (void)updateDownloadStatusUrl:(NSString*)url isDownload:(BOOL)isDownload;


@end
