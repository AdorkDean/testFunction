//
//  NetworkManager.h
//  ObjectTool
//
//  Created by wss on 15/11/9.
//  Copyright © 2015年 WSS. All rights reserved.

// 用JSONModel 实现网络数据(json,dic)转换为model
//NetworkManager 继承自AFN类 AFHTTPSessionManager，实现下载


#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#pragma mark --类 NetworkManager

typedef NS_ENUM(NSInteger, KHTTPMethod) {
    kHTTPGet = 0,
    kHTTPPost,
    kHTTPPut,
    kHTTPDelete,
};

//共用 block块，传出的是model，所以定义的model，可以是数组(例如：OrderListModel)，解析数据的时候要考虑服务器的真实返回数据，做一定更改
typedef void(^CompleteHandler)(NSURLSessionDataTask *dataTask,id resultData,NSError *error);
typedef void(^ScanCardResult)(NSDictionary *resultDic);
//进度
typedef void(^Progress)(CGFloat progress);
//上传图片 返回的文件url
typedef void(^UploadFinished)(NSURLSessionDataTask *dataTask,NSString *fileUrl);
typedef void(^UploadFinishedWithStatus)(NSURLSessionDataTask *dataTask, NSDictionary * resultDic);


@interface NetworkManager : AFHTTPSessionManager

//单例
+(NetworkManager*)sharedMgr;
//统一的网络请求接口
-(NSURLSessionDataTask*)RequestWithMethod:(KHTTPMethod)HTTPMethod
                      URLString:(NSString *)strURLString
                       HTTPBody:(NSDictionary *)dicBody
                completeHandler:(CompleteHandler)completeHandler;

/** 新网络请求 接口  */
-(NSURLSessionDataTask*)requestNewWithMethod:(KHTTPMethod)HTTPMethod
                                URLString:(NSString *)strURLString
                                 HTTPBody:(NSDictionary *)dicBody
                          completeHandler:(CompleteHandler)completeHandler;




/**上传图片接口
 */
-(void)uploadUrl:(NSString*)urlString image:(UIImage*)image progress:(Progress)progress uploadFinished:(UploadFinished)finished;


/**
 上传图片数组，二进制数组
 */
-(void)uploadUrl:(NSString*)urlString fileDataArr:(NSArray*)fileDataArr  parameters:(NSDictionary*)parameters completeHandler:(CompleteHandler)completeHandler;


/**
 上传多个文件，图片文件都可以
 */
-(void)uploadUrl:(NSString*)urlString file:(NSArray*)fileDataArr fileName:(NSArray*)fileName fileType:(NSString*)fileType progressBlock:(Progress)progressblock  parameters:(NSDictionary*)parameters completeHandler:(CompleteHandler)completeHandler;


- (void)uploadFileWithUrl:(NSString *)urlString filePath:(NSString *)ptah fileName:(NSString *)name fileKey:(NSString *)key params:(NSDictionary *)params progress:(Progress)progress completeHandler:(CompleteHandler)completeHandler;


//名片识别
- (void)scanCardApiWithImage:(UIImage*)image resultDic:(ScanCardResult) result;

-(void)cancleRequest;

@end



