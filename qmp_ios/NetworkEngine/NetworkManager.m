//
//  NetworkManager.m
//  ObjectTool
//
//  Created by wss on 15/11/9.
//  Copyright © 2015年 WSS. All rights reserved.
//

#import "NetworkManager.h"
#import "JKEncrypt.h"
#import <AdSupport/AdSupport.h>

// 服务器
NSString *const TestBaseUrl = @"http://test.api.qimingpian.com/";
NSString *const TestPdfBaseUrl = @"http://test.news.api.qimingpian.com/";

NSString *const BaseUrl = @"http://ios1.api.qimingpian.com/";
NSString *const PdfBaseUrl = @"http://pdf.api.qimingpian.com/";
NSString *const NewsBaseUrl = @"http://news.api.qimingpian.com/";
NSString *const FileBaseUrl = @"http://file.api.qimingpian.com/";

#pragma mark -- 类 NetworkManager
@interface NetworkManager ()

@property(nonatomic,strong) JKEncrypt *encodeTool;
@property(nonatomic,strong) DataHandle *dataHandle;
@property(nonatomic,copy) NSString *app_uuid;
@property(nonatomic,copy) AFHTTPSessionManager *pdfSessionMgr;
@property(nonatomic,copy) AFHTTPSessionManager *newsSessionMgr;
@property(nonatomic,copy) AFHTTPSessionManager *fileSessionMgr;

@end

@implementation NetworkManager

- (instancetype)initWithBaseURL:(NSURL *)url{
    
    if (self = [super initWithBaseURL:url]) {
        NSString *baseUrlString = PdfBaseUrl;
#ifdef DEBUG
        baseUrlString = TestPdfBaseUrl;
#endif

#if ADHOC
        baseUrlString = TestPdfBaseUrl;
#endif
        
        _pdfSessionMgr = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseUrlString]];
        _pdfSessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _pdfSessionMgr.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html", @"text/plain",@"text/javascript",  @"image/png",@"mage/jpeg",@"audio/mpeg", @"application/octet-stream", @"audio/mp3"]];
        _pdfSessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _pdfSessionMgr.requestSerializer.timeoutInterval = 60;
        _pdfSessionMgr.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        _newsSessionMgr = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseUrlString]];
        _newsSessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _newsSessionMgr.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html", @"text/plain",@"text/javascript",  @"image/png",@"mage/jpeg",@"audio/mpeg", @"application/octet-stream", @"audio/mp3"]];
        _newsSessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _newsSessionMgr.requestSerializer.timeoutInterval = 60;
        _newsSessionMgr.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        
        _fileSessionMgr = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseUrlString]];
        _fileSessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _fileSessionMgr.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html", @"text/plain",@"text/javascript",  @"image/png",@"mage/jpeg",@"audio/mpeg", @"application/octet-stream", @"audio/mp3"]];
        _fileSessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _fileSessionMgr.requestSerializer.timeoutInterval = 60;
        _fileSessionMgr.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    
    return self;
}

+(NetworkManager*)sharedMgr{
    
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSString *baseUrlString = BaseUrl;
//
#ifdef DEBUG
        baseUrlString = TestBaseUrl;
#endif

#if ADHOC
        baseUrlString = TestBaseUrl;
#endif

        sharedInstance = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
        
        sharedInstance.responseSerializer = [AFHTTPResponseSerializer serializer];
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html", @"text/plain",@"text/javascript",  @"image/png",@"mage/jpeg",@"audio/mpeg", @"application/octet-stream", @"audio/mp3"]];
        sharedInstance.requestSerializer = [AFHTTPRequestSerializer serializer];
        sharedInstance.requestSerializer.timeoutInterval = 60;
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        sharedInstance.encodeTool = [[JKEncrypt alloc]init];
        sharedInstance.dataHandle = [[DataHandle alloc]init];
        sharedInstance.app_uuid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    });

    return sharedInstance;
}

/** 新网络请求 接口  */
-(NSURLSessionDataTask*)requestNewWithMethod:(KHTTPMethod)HTTPMethod
                                   URLString:(NSString *)strURLString
                                    HTTPBody:(NSDictionary *)dicBody
                             completeHandler:(CompleteHandler)completeHandler{
   
    QMPLog(@"请求参数----%@",dicBody);
    
    NSString *baseUrl = @"https://iosapi.qimingpian.com/";
//    
#ifdef DEBUG
    baseUrl = @"https://testiosapi.qimingpian.com/";
#endif

#if ADHOC
    baseUrl = @"https://testiosapi.qimingpian.com/";
#endif
    strURLString = [NSString stringWithFormat:@"%@%@", baseUrl, strURLString];
    
    
    if(![TestNetWorkReached networkIsReachedNoAlert]){
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"网络连接不可用，请稍后再试"];//网络未连接
        [PublicTool dismissHud:KEYWindow];
        return nil;
    }
    
    switch (HTTPMethod) {
        case kHTTPGet:
            return [self GetWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPPost:
            return [self PostWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPPut:
            return [self PutWithURLString:strURLString HTTPBpdy:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPDelete:
            return [self DeleteWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        default:
            return nil;
            break;
    }
}



-(NSURLSessionDataTask*)RequestWithMethod:(KHTTPMethod)HTTPMethod
                                URLString:(NSString *)strURLString
                                 HTTPBody:(NSDictionary *)dicBody
                          completeHandler:(CompleteHandler)completeHandler
{
        QMPLog(@"请求参数----%@",dicBody);
    
        if(![TestNetWorkReached networkIsReachedNoAlert]){
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"网络连接不可用，请稍后再试"];//网络未连接
            [PublicTool dismissHud:KEYWindow];
            return nil;
        }
    
        switch (HTTPMethod) {
        case kHTTPGet:
            return [self GetWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPPost:
            return [self PostWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPPut:
            return [self PutWithURLString:strURLString HTTPBpdy:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        case kHTTPDelete:
            return [self DeleteWithURLString:strURLString HTTPBody:dicBody forModelClass:nil completeHandler:completeHandler];
            break;
        default:
            return nil;
            break;
    }
}
    
#pragma mark - HTTP Get, Post, Put, Delete
    
 - (NSURLSessionDataTask *)GetWithURLString:(NSString *)strURLString
                                    HTTPBody:(NSDictionary *)dicBody
                                    forModelClass:(id)modelClass
                                    completeHandler:(CompleteHandler)completeHandler {
    NSURLSessionDataTask *dataTask = [self GET:strURLString parameters:dicBody  progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
        [self successWithData:responseObject task:task handleBlock:completeHandler];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:nil error:error];
        [self failureWithError:error task:task handleBlock:completeHandler];
    }];
     return dataTask;
}
    
- (NSURLSessionDataTask *)PostWithURLString:(NSString *)strURLString
                                    HTTPBody:(NSDictionary *)dicBody
                                    forModelClass:(id)modelClass
                                    completeHandler:(CompleteHandler)completeHandler {
    
    dicBody = [self setHttpBody:dicBody];
    //图谱  上传pdf
    if ([strURLString containsString:@"t/webuploader1"]) {
        
        return [_pdfSessionMgr POST:strURLString parameters:dicBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
            [self successWithData:responseObject task:task handleBlock:completeHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
            
            [self failureWithError:error task:task handleBlock:completeHandler];
        }];
    }else if([strURLString containsString:QMPNewsFastListURL] || [strURLString containsString:QMPNewsBlockListURL]){
        // 快讯和区块链(虚拟币)
        return [_newsSessionMgr POST:strURLString parameters:dicBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
            [self successWithData:responseObject task:task handleBlock:completeHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
            
            [self failureWithError:error task:task handleBlock:completeHandler];
        }];
    }else if([strURLString containsString:@"t/uploadIosExceptionLog"]){ //上传崩溃日志
        
        return [_newsSessionMgr POST:strURLString parameters:dicBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
            [self successWithData:responseObject task:task handleBlock:completeHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
            
            [self failureWithError:error task:task handleBlock:completeHandler];
        }];
    }
        
   
    return [self POST:strURLString parameters:dicBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
        [self successWithData:responseObject task:task handleBlock:completeHandler];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
        [self failureWithError:error task:task handleBlock:completeHandler];
    }];
   
}
    
- (NSURLSessionDataTask *)PutWithURLString:(NSString *)strURLString
                                    HTTPBpdy:(NSDictionary *)dicBody
                                    forModelClass:(id)modelClass
                                    completeHandler:(CompleteHandler)completeHandler {
    return [self PUT:strURLString parameters:dicBody success:^(NSURLSessionDataTask *task, id responseObject) {
        [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
        [self successWithData:responseObject task:task handleBlock:completeHandler];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
        [self failureWithError:error task:task handleBlock:completeHandler];
    }];
    
    
    
}
    
- (NSURLSessionDataTask *)DeleteWithURLString:(NSString *)strURLString
                                    HTTPBody:(NSDictionary *)dicBody
                                    forModelClass:(id)modelClass
                                    completeHandler:(CompleteHandler)completeHandler {
    return [self DELETE:strURLString parameters:dicBody success:^(NSURLSessionDataTask *task, id responseObject) {
        [self printLogWithURLString:task.currentRequest.URL.absoluteString HTTPBody:dicBody responseObject:responseObject error:nil];
        [self successWithData:responseObject task:task handleBlock:completeHandler];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self printLogWithURLString:strURLString HTTPBody:dicBody responseObject:nil error:error];
        [self failureWithError:error task:task handleBlock:completeHandler];
    }];
}



#pragma mark - HTTP Handler
- (void)successWithData:(id)responseObject  task:(NSURLSessionDataTask*)task handleBlock:(CompleteHandler)handleBlock {
    
    if (responseObject == nil) {
        handleBlock(task,nil,nil);
        return;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
    NSString *str;
#ifdef DEBUG
    str = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
#endif
    
    NSInteger status = [dic[@"status"] integerValue];
    
    if (status == 0) {
          if ([dic.allKeys containsObject:@"count"] || [dic.allKeys containsObject:@"lunci"]) {
              QMPLog(@"网络请求返回----------------\n %@",dic);
              handleBlock(task,dic,nil);
              return;
          }
          NSString * data1Str;
//          NSDictionary *toDic = [self.encodeTool doDecEncryptAndConvertToDict:data1Str];
//
          if ([dic.allKeys containsObject:@"data1"]) {
              data1Str = dic[@"data1"];
          }else  if ([dic.allKeys containsObject:@"encrypt_data"]) {
              data1Str = dic[@"encrypt_data"];
          }

          NSDictionary *dataDic = dic[@"data"];
          if ([PublicTool isNull:data1Str] && !dataDic) {
              QMPLog(@"网络请求返回----------------\n %@",dic);
              handleBlock(task,dic,nil);
              return;
          }
          if (dataDic && [dataDic isKindOfClass:[NSDictionary class]] && dataDic.allKeys.count) { //数据在data中
              
              NSDictionary *responseDic = dic[@"data"];
              QMPLog(@"网络请求返回----------------\n %@",responseDic);
              handleBlock(task,responseDic,nil);
                  
          }else if(dataDic && [dataDic isKindOfClass:[NSArray class]]){
              QMPLog(@"网络请求返回----------------\n %@",dataDic);
              handleBlock(task,dataDic,nil);
          }else if(data1Str && [data1Str isKindOfClass:[NSString class]] && data1Str.length){
              //编码转换
              NSDictionary *toDic = [self.encodeTool doDecEncryptAndConvertToDict:data1Str];
              QMPLog(@"网络请求返回----------------\n %@",toDic);
              handleBlock(task,toDic,nil);
          }else if([dataDic isKindOfClass:[NSString class]]){
              handleBlock(task,dataDic,nil);
          }else{
              handleBlock(task,nil,nil);
          }
          
      }else{
          
          handleBlock(task,nil,nil);

          QMPLog(@"网络请求失败------%@", dic);
#ifdef DEBUG
          [PublicTool showMsg:dic[@"message"]];
#endif
          if ([dic[@"status"] integerValue] == 1 ) {
              if (![PublicTool isNull:dic[@"message"]]) {
                  [PublicTool showMsg:dic[@"message"]];
              }
          }else{
              if ([dic[@"status"] integerValue] == 10004) {
                  if (![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"LoginViewController")]&&
                      ![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"QMPLoginController")]&&
                      ![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"XZLoginController")]) {
                      [PublicTool alertActionWithTitle:@"提示" message:@"登录已过期，请重新登录" btnTitle:@"确定" action:^{
                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_QUITLOGIN object:@"0"];
                          [ToLogin enterLoginPage:[PublicTool topViewController]];
                      }];
                      
                  }
              }else{
                  
                  [PublicTool showMsg:dic[@"message"]];

                  NSString *urlStr = task.currentRequest.URL.absoluteString;
                  NSArray *arr = [urlStr componentsSeparatedByString:@"/"];
                  NSString *str = [NSString stringWithFormat:@"%@/%@",arr[arr.count-2],arr[arr.count-1]];
                  
                  [self.dataHandle handleOtherRetStatus:[NSString stringWithFormat:@"%@",dic[@"status"]] onCurrentVC:[PublicTool topViewController] withAction:[NSString stringWithFormat:@"%@:%@",[str stringByReplacingOccurrencesOfString:@"/" withString:@""],[self actionStrWithUrl:str]] withData:dic[@"data"]];
              }
              
          }
      }
}



- (void)failureWithError:(NSError *)error task:(NSURLSessionDataTask *)task handleBlock:(CompleteHandler)handleBlock {
    
        [PublicTool dismissHud:KEYWindow];
        if (handleBlock) {
            handleBlock(task, nil,error);
        }

        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            if (error.code == -1001 || error.code == -1004 ) {
//                [ShowInfo showInfoOnView:KEYWindow withInfo:@"请求超时"];
            }
//            else{
//                [ShowInfo showInfoOnView:KEYWindow withInfo:@"攻城狮们正在抢修!"];
//            }
        }
    
    
}

#pragma mark - Helper
    
- (void)printLogWithURLString:(NSString *)strURLString HTTPBody:(NSDictionary *)dicBody responseObject:(id)responseObject error:(NSError *)error {
    QMPLog(@"=====  HTTP START =====");
    QMPLog(@"Request URL: %@", strURLString);
    QMPLog(@"Parameter: %@", dicBody);
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

//    QMPLog(@"Response: %@ msg: ", dic);
    QMPLog(@"Error: %@", error);
    QMPLog(@"=====  HTTP END =====");
}


#pragma mark --图片和文件上传
-(void)uploadUrl:(NSString*)urlString fileDataArr:(NSArray*)fileDataArr  parameters:(NSDictionary*)parameters completeHandler:(CompleteHandler)completeHandler{
    
    parameters = [self setHttpBody:parameters];

    [self POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       
        for (int i=0; i<fileDataArr.count;i++) {
            NSData *data = fileDataArr[i];
            [formData appendPartWithFileData:data name:@"pic" fileName:[NSString stringWithFormat:@"card%d.jpg",i] mimeType:@"image/jpeg"];

        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self successWithData:responseObject task:task handleBlock:completeHandler];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failureWithError:error task:task handleBlock:completeHandler];
        
    }];

}

-(void)uploadUrl:(NSString*)urlString file:(NSArray*)fileDataArr fileName:(NSArray*)fileName fileType:(NSString*)fileType progressBlock:(Progress)progressblock  parameters:(NSDictionary*)parameters completeHandler:(CompleteHandler)completeHandler{
   
    parameters = [self setHttpBody:parameters];
    [self POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i=0; i<fileDataArr.count;i++) {
            NSData *data = fileDataArr[i];
            [formData appendPartWithFileData:data name:@"file" fileName:fileName[i] mimeType:fileType];
            
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if(progressblock){
            progressblock(uploadProgress.completedUnitCount*0.1/uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self successWithData:responseObject task:task handleBlock:completeHandler];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failureWithError:error task:task handleBlock:completeHandler];
        
    }];
}

//上传图片 encrypt_data 格式
-(void)uploadUrl:(NSString*)urlString image:(UIImage*)image progress:(Progress)progress uploadFinished:(UploadFinished)finished
{
    [self POST:urlString parameters:@{@"type":@"default",@"pic":@"file",@"uuid":[WechatUserInfo shared].uuid} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"pic" fileName:@"usrHead.jpg" mimeType:@"image/jpeg"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            CGFloat totalCount = uploadProgress.totalUnitCount/1.0;
            CGFloat completeCount = uploadProgress.completedUnitCount/1.0;
            progress(completeCount/totalCount);
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([dic[@"status"] integerValue] != 0) {
            finished(task,nil);
        }else{
            NSString *data = dic[@"encrypt_data"];
            NSDictionary *dic = [self.encodeTool doDecEncryptAndConvertToDict:data];
            finished(task,dic[@"img_url"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finished(task,nil);
    }];
}


- (void)uploadFileWithUrl:(NSString *)urlString filePath:(NSString *)path fileName:(NSString *)name fileKey:(NSString *)key params:(NSDictionary *)params progress:(Progress)progress completeHandler:(CompleteHandler)completeHandler {
    params = [self setHttpBody:params];
    key = key ? : @"file";
    [self.pdfSessionMgr POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSURL *fileUrl = [NSURL fileURLWithPath:path];
        [formData appendPartWithFileURL:fileUrl name:key fileName:name mimeType:@"application/octet-stream" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            CGFloat totalCount = uploadProgress.totalUnitCount/1.0;
            CGFloat completeCount = uploadProgress.completedUnitCount/1.0;
            progress(completeCount/totalCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self successWithData:responseObject task:task handleBlock:completeHandler];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failureWithError:error task:task handleBlock:completeHandler];
    }];
}

#pragma mark --名片识别
//名片识别
- (void)scanCardApiWithImage:(UIImage*)image resultDic:(ScanCardResult) result{
    
    if (!image) {
        result(nil);
        return;
    }
    
    //图像尺寸在960*640和2048*1024之间; 图像大小:200K左右（50k-1536k）JPEG压缩比65%-85%
//    CGFloat width = image.size.width > image.size.height ? image.size.height : image.size.width;
//    CGFloat height = image.size.width + image.size.height - width;
//    if (width < 640) {
//        image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(640, 640*height/width)];
//
//    }else if (width > 1024) {
//        image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(1024, 1024*height/width)];
//    }
//
//    CGFloat newWidth = image.size.width > image.size.height ? image.size.height : image.size.width;
//    CGFloat newHeight = image.size.width + image.size.height - newWidth;
//
//    if (newHeight > 2048) {
//        image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(2048*newWidth/newHeight, 2048)];
//    }else if(newHeight < 960){
//        image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(960*newWidth/newHeight, 960)];
//
//    }
    
    UIImage *pressImg = [PublicTool compressImage:image toByte:1530*1024];
    
    NSString *appcode = @"2c3d8b4576554253a7d675639fa6354d";
    NSString *host = @"http://businesscard.aliapi.hanvon.com";
    NSString *path = @"/rt/ws/v1/ocr/bcard/recg";
    NSString *method = @"POST";
    NSString *querys = @"?code=cf22e3bb-d41c-47e0-aa44-a92984f5829d";
    NSString *url = [NSString stringWithFormat:@"%@%@%@",  host,  path , querys];
    NSString *base64String = [UIImageJPEGRepresentation(pressImg, 1.0) base64EncodedStringWithOptions:0];
    NSDictionary *dic = @{@"uid":@"123.57.71.26",@"lang":@"auto",@"color":@"color",@"image":base64String ? base64String:@""};

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:  30];
    request.HTTPMethod  =  method;
    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    [request addValue: @"application/octet-stream" forHTTPHeaderField: @"Content-Type"];
    //根据API的要求，定义相对应的Content-Type
    [request addValue: @"application/json; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    NSData *data =    [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    NSData *data = [bodys dataUsingEncoding: NSUTF8StringEncoding];
    if (data) {
        [request setHTTPBody: data];
    }else{
        result(@{});
        return;
    }
    
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       
                                                       NSLog(@"Response object: %@" , response);
                                                       NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                                                       
                                                       //打印应答中的body
                                                       NSLog(@"Response body: %@" , bodyString);
                                                       if (!body) { //body是空
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               result(@{});
                                                           });
                                                       }else{
                                                           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingAllowFragments error:nil];
                                                           NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
                                                           
                                                           NSLog(@"Response body: %@" , dic);
                                                           
                                                           for (NSString *key in dic.allKeys) {
                                                               NSArray *value = dic[key];
                                                               if (value && [value isKindOfClass:[NSArray class]] && value.count) {
                                                                   if ([key isEqualToString:@"name"] && value.count > 1) { //中英文名字
                                                                       if ([value[1] isKindOfClass:[NSString class]] && [PublicTool isPureLetters:value[1]]) {
                                                                           [newDic setValue:[NSString stringWithFormat:@"%@(%@)",value[0],value[1]] forKey:key];
                                                                           continue;
                                                                       }
                                                                   }
                                                                   
                                                                   [newDic setValue:value[0] forKey:key];
                                                                   continue;
                                                               }
                                                               
                                                           }
                                                           if (![newDic.allKeys containsObject:@"name"] && [dic.allKeys containsObject:@"title"]) { //没姓名，title就是姓名
                                                               [newDic setValue:newDic[@"title"] forKey:@"name"];
                                                               
                                                           }
                                                           if (![newDic.allKeys containsObject:@"mobile"] && [PublicTool isNull:newDic[@"mobile"]] && [dic.allKeys containsObject:@"tel"]) {
                                                               NSArray *telArr = dic[@"tel"];
                                                               if (telArr.count) {
                                                                   [newDic setValue:telArr[0] forKey:@"mobile"];
                                                               }
                                                           }
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               result(newDic);
                                                               
                                                           });
                                                       }
                                                       
                                                   }];
    
    [task resume];
    
}

#pragma mark --取消所有请求
-(void)cancleRequest{
    
    [self.operationQueue cancelAllOperations];
}


//添加公共参数 ptype  VERSION  unionid(可能为空)
- (NSDictionary*)setHttpBody:(NSDictionary*)bodyDic{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:bodyDic];
    [param setValue:@"qmp_ios" forKey:@"ptype"];
    [param setValue:VERSION forKey:@"version"];
    [param setValue:self.app_uuid forKey:@"app_uuid"];

    if ([PublicTool isNull:[bodyDic valueForKey:@"unionid"]]) {
        NSString *unionid = [WechatUserInfo shared].unionid;
        [param setValue:unionid ? unionid :@"" forKey:@"unionid"];
    }
    if ([PublicTool isNull:[bodyDic valueForKey:@"uuid"]]) {
        NSString *uuid = [WechatUserInfo shared].uuid;
        [param setValue:uuid ? uuid :@"" forKey:@"uuid"];
    }
    
//    NSString *unionid = @"oP3fkwE8nPSdOfaor6lRlIWZlROY"; //朱剑昭
//    NSString *unionid = @"oP3fkwNZWbmDiC92rMLpwH7qxkVY"; // 程红烯
//    NSString *unionid = @"oP3fkwLtT7LdgoOHh_EZ8WUW12cg"; // 叶慧芳
//    NSString *unionid = @"oP3fkwGXCd-meMJxgGznwYUgahQA"; // 党壮
//    NSString *unionid = @"oP3fkwPfMp9crKWXzdnwkaLLXh3Y";
//        NSString *unionid = @"oP3fkwG2IIMpRFaW9BRtHK6LC9Sw";
//
//    [param setObject:@"ade63f641ade546aa0cc423cc7077a51" forKey:@"uuid"];
//    [param setObject:@"oP3fkwD0bUymaaEsOD3nkeXLfNqI" forKey:@"unionid"];

    return param;
}


- (NSString*)actionStrWithUrl:(NSString*)str {
    NSDictionary *dict = [NetConst urlDescDict];
    if ([dict.allKeys containsObject:str]) {
        return dict[@"str"];
    }
    return @"";
}

@end
