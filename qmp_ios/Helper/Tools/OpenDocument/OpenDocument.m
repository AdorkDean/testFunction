//
//  OpenDocument.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "OpenDocument.h"

//pdf--
#import <mupdf/common.h>
#import <mupdf/MuDocumentController.h>
#import "AlertInfo.h"
#import "CommonDocumentController.h"

//--end

@interface OpenDocument(){

    MuDocRef *doc;
    NSString *_filename;
    NSString *_filePath;
    NSString *_pdfPath;
}
@property (nonatomic,strong) AlertInfo *alertInfoTool;

@end
@implementation OpenDocument
-(instancetype)init{
    if (self = [super init]) {
        self.alertInfoTool = [[AlertInfo alloc]init];
    }
    return self;
}
/**
 *  打开文件
 *
 *  @param nsfilename 要打开的文件的文件名
 */
- (void)openDocumentofReportModel:(ReportModel *)pdfModel{
    
    self.pdfModel = pdfModel;
    
//    self.pdfModel.name = [self moveOutOfInbox:self.pdfModel.name];
    
    NSString *nspath = [[NSArray arrayWithObjects:NSHomeDirectory(), @"Documents", [self.pdfModel.pdfUrl lastPathComponent], nil]
                        componentsJoinedByString:@"/"];
    NSLog(@"----%@-----",nspath);
    _filePath = nspath;
    if (_filePath == NULL) {
        [self.alertInfoTool alertWithMessage:@"内存不足" aTitle:@"提示" inController:_viewController];
        return;
    }

//    strcpy(_filePath, [nspath UTF8String]);
    
    dispatch_sync(queue, ^{});
        
    _filename = self.pdfModel.name;
    doc = [[MuDocRef alloc] initWithFilename:_filePath];
    if (!doc) {
        [self.alertInfoTool alertWithMessage:@"文件无法打开" aTitle:@"提示" inController:_viewController];
        return;
    }
    
    if (fz_needs_password(ctx, doc->doc))
        [self showTips: @"'%@'文件已加密,无法打开"];
    else
        [self openPDF];
    
}

- (void)openDocumentofFilePath:(NSString *)filePath reportModel:(ReportModel*)pdfModel{
    self.pdfModel = pdfModel;
    
    self.pdfModel.name = [self moveOutOfInbox:self.pdfModel.name];
    
    _filePath = filePath;
    if (_filePath == NULL) {
        [self.alertInfoTool alertWithMessage:@"内存不足" aTitle:@"提示" inController:_viewController];
        return;
    }

    dispatch_sync(queue, ^{});
    
    printf("open document '%s'\n", _filePath);
    
    _filename = self.pdfModel.name;
    doc = [[MuDocRef alloc]initWithFilename:_filePath];
    if (!doc) {
        [self.alertInfoTool alertWithMessage:@"文件无法打开" aTitle:@"提示" inController:_viewController];
        return;
    }
    
    if (fz_needs_password(ctx, doc->doc))
        [self showTips: @"'%@'文件已加密,无法打开"];
    else
        [self openPDF];
    
}


- (void) showTips: (NSString*)prompt
{
    //=======这个方法还需要封装出去
    
    UIAlertView *passwordAlertView = [[UIAlertView alloc]
                                      initWithTitle: @"Password Protected"
                                      message: [NSString stringWithFormat: prompt, [_filename lastPathComponent]]
                                      delegate: self
                                      cancelButtonTitle: @"取消"
                                      otherButtonTitles: @"好的", nil];
    [passwordAlertView setAlertViewStyle: UIAlertViewStyleSecureTextInput];
    [passwordAlertView show];
}

- (void) openPDF
{
//    LCDocumentViewController *document = [[LCDocumentViewController alloc] initWithFilename: _filename path:_filePath document:doc];
    CommonDocumentController *document = [[CommonDocumentController alloc] initWithFilename:_filename path:_filePath document:doc];
    
    document.pdfModel = self.pdfModel;
    
    UINavigationController *documentNav = [[UINavigationController alloc] initWithRootViewController:document];

//    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@ "nav"]];
//    imgView.frame = CGRectMake(0, -20, SCREENW, 20.f);
//    [documentNav.navigationBar addSubview:imgView];
    
    [documentNav.navigationBar setTintColor:[UIColor whiteColor]];
    [documentNav.navigationBar setTranslucent:NO];
//    [documentNav.navigationBar setBackgroundImage:[UIImage imageNamed:@ "nav"] forBarMetrics:UIBarMetricsDefault];
    [documentNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:HTColorFromRGB(0x1d1d1d),NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0]}];

    if (document) {
        [_viewController presentViewController:documentNav animated:YES completion:^{
            
        }];
    }
//    free(_filePath);
}


- (NSString *)moveOutOfInbox:(NSString *)docpath{
    
    if ([docpath hasPrefix:@"Inbox/"])
    {
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSString *base = [docpath stringByReplacingOccurrencesOfString:@"Inbox/" withString:@""];
        
        for (int i = 0; YES; i++)
        {
            NSString *newname = [self alertedFilename:base atIndex:i];
            NSString *newfullpath = [NSString pathWithComponents:[NSArray arrayWithObjects:NSHomeDirectory(), @"Library",@"Caches", newname, nil]];
            
            if (![fileMan fileExistsAtPath:newfullpath])
            {
                NSString *fullpath = [NSString pathWithComponents:[NSArray arrayWithObjects:NSHomeDirectory(), @"Library",@"Caches", docpath, nil]];
                [fileMan copyItemAtPath:fullpath toPath:newfullpath error:nil];
                [fileMan removeItemAtPath:fullpath error:nil];
                return newname;
            }
        }
    }
    
    return docpath;
}
- (NSString *)alertedFilename:(NSString *)name atIndex:(int)i{
    
    if (i == 0)
        return name;
    
    NSString *nam = [name stringByDeletingPathExtension];
    NSString *e = [name pathExtension];
    return [[NSString alloc] initWithFormat:@"%@(%d).%@", nam, i, e];
    
}
- (void)launchReachableViaWWANAlert:(NetworkStatus)status ofCurrentVC:(UIViewController *)currentVC withModel:(ReportModel *)reportModel{
    [PublicTool alertActionWithTitle:@"温馨提示" message:@"您当前处于移动网络,下载会耗费流量,是否下载" leftTitle:@"取消" rightTitle:@"下载" leftAction:^{
        
    } rightAction:^{
        
        if ([self.delegate respondsToSelector:@selector(downloadPdfUseWWAN:)]) {
            [self.delegate downloadPdfUseWWAN:reportModel];
        }
    }];
    
}

- (BOOL)downDocumentToBox:(ReportModel *)pdfModel{
    
    //判断本地是否存在该文档
    NSString *tmp = [self findFileWithPath:[self getPath] fileName:[pdfModel.pdfUrl lastPathComponent]];
    
    if (!tmp) {
        
        return NO;
    }else{
        
        return YES;
    }
}
- (NSString *)getPath{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    return path;
}
- (NSString *)findFileWithPath:(NSString *)path fileName:(NSString *)name{
    
    NSFileManager *filem = [NSFileManager defaultManager];
    if ([filem fileExistsAtPath:path]) {
        
        //获取文件夹下所有文件
        NSArray *fileArr = [filem subpathsAtPath:path];
        for (NSString *fileName in fileArr) {
            if ([fileName isEqualToString:[name lastPathComponent]]) {
                NSString *cacPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *ppth = [cacPath stringByAppendingPathComponent:fileName];
                _pdfPath = [NSString stringWithString:ppth];//pdf文件本地路径
                return fileName;
            }
        }
        return nil;
    }
    return nil;
}

@end
