//
//  UploadReportView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "UploadReportView.h"
#import "InfoWithoutConfirmAlertView.h"
#import "UploadView.h"
#import "GetNowTime.h"
#import "ShowInfo.h"

@interface UploadReportView()<InfoWithoutConfirmAlertViewDelegate,UploadViewDelegate>

@property(nonatomic,assign)BOOL isBP;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)InfoWithoutConfirmAlertView *fileAlertView;
@property(nonatomic,strong)UploadView *uploadView;
@property(nonatomic,strong)UIScrollView *scrollV;

@end


@implementation UploadReportView

- (UploadReportView *)initWithIsBP:(BOOL)isBP uploadSuccess:(void (^)(ReportModel *))uplaodSuccessBlock{
   
    if (self = [super initWithFrame:KEYWindow.bounds]) {
        
        self.isBP = isBP;
        self.uploadSuccess = uplaodSuccessBlock;
        [self initViews];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleUploadNoti:) name:NOTIFI_HANDLEUPLOAD object:nil];
        [KEYWindow addSubview:self];
    }
    return self;
}

- (void)initViews{
    
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(20*ratioWidth, 0,self.width-40*ratioWidth , 400)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bgView];
    bgView.centerY = self.height/2.0;
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    self.bgView = bgView;
    
   
    //标题
    UILabel *keyTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bgView.width, 50)];
    [keyTitleLab labelWithFontSize:16 textColor:NV_TITLE_COLOR];
    keyTitleLab.textAlignment = NSTextAlignmentCenter;
    keyTitleLab.text = self.isBP ? @"通过微信上传BP":@"通过微信上传文档";
    [bgView addSubview:keyTitleLab];
    //线
    UIView *line0 = [[UIView alloc]initWithFrame:CGRectMake(0, keyTitleLab.bottom, bgView.width, 1)];
    line0.backgroundColor = LIST_LINE_COLOR;
    [bgView addSubview:line0];
    
    
    self.scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, keyTitleLab.height, bgView.width, bgView.height - keyTitleLab.height - 45)];
    self.scrollV.showsHorizontalScrollIndicator = NO;
    self.scrollV.contentSize = CGSizeMake(bgView.width*3, self.scrollV.height);
    self.scrollV.pagingEnabled = YES;
    [bgView addSubview:self.scrollV];
    
    //三张图片
    for (int i = 0; i<3; i++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.scrollV.width, 1, self.scrollV.width, self.scrollV.height-1)];
        imgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"bp%d",i+1]];
        [self.scrollV addSubview:imgV];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    //线
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, self.scrollV.bottom, bgView.width, 1)];
    line1.backgroundColor = LIST_LINE_COLOR;
    [bgView addSubview:line1];
    
    
    //两个按钮
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, bgView.height - 45, bgView.width/2.0, 45)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:leftBtn];
    
    //线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(leftBtn.right, leftBtn.top, 1, leftBtn.height)];
    line2.backgroundColor = LIST_LINE_COLOR;
    [bgView addSubview:line2];
    
    //两个按钮
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(bgView.width/2.0, bgView.height - 45, bgView.width/2.0, 45)];
    [rightBtn setTitle:@"去微信上传" forState:UIControlStateNormal];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn addTarget:self action:@selector(uploadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:rightBtn];
    
}


#pragma mark --Event--
- (void)leftBtnClick{
    
    [self removeFromSuperview];
    
}

//跳转到微信
- (void)uploadBtnClick{
    NSURL * url = [NSURL URLWithString:@"weixin://"];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    //先判断是否能打开该url
    if (canOpen){   //打开微信
        [[UIApplication sharedApplication] openURL:url];
    }else {
        [PublicTool showMsg:@"打开微信失败"];
    }
}


- (void)handleUploadNoti:(NSNotification*)uploadTf{
    
    if (self.bgView.superview) {
        [self.bgView removeFromSuperview];
    }
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.0];
    
    NSString *filePath = uploadTf.object;
    NSArray *nameArr = [filePath componentsSeparatedByString:@"/"];
    NSString *filename = [nameArr lastObject];

    InfoWithoutConfirmAlertView *alertView = [InfoWithoutConfirmAlertView initFrame];
    [alertView initViewWithTitle:@"上传文件" withInfo:filename withLeftBtnTitle:@"确定上传"  onAction:@"uploadFile"];
    alertView.dataStr = filePath;
    alertView.delegate = self;
    self.fileAlertView = alertView;
    [KEYWindow addSubview:alertView];
    
}

- (void)cancelUpload{
    
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
}

#pragma mark --Delegate

- (void)confirmToChooseWithData:(NSString *)dataStr{
   
    BOOL isBP = self.isBP;
    NSArray *nameArr = [dataStr componentsSeparatedByString:@"/"];
    NSString *filename = [nameArr lastObject];
    
    UploadView *uploadView = [UploadView initFrameWithInfo:filename];
    uploadView.delegate = self;
    [uploadView initData];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:uploadView];

    //报告：cloud     BP：work_bp
    NSString *uploadType = isBP ? @"work_bp":@"cloud";
    
    NSDictionary *param = @{@"upload_type": uploadType};
    
    [AppNetRequest uploadPDFWithFilePath:dataStr fileName:filename params:param progress:^(CGFloat progress) {
        [uploadView changeProgressWithProgress:progress];
    } completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            NSString *info = @"上传成功";
            //将本地文件重命名 dataStr -> resultDic[@"data"][@"name"]
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //库里的文件名
            NSString *newfileName = isBP ? resultData[@"bp_name"] : resultData[@"name"];
            NSString *newNamePath = [[dataStr stringByDeletingLastPathComponent] stringByAppendingPathComponent:newfileName];
            [fileManager moveItemAtPath:dataStr toPath:newNamePath error:nil];
            //InfoWithoutConfirmAlertView移除
            for (UIView *subv in keyWindow.subviews) {
                if ([subv isKindOfClass:[InfoWithoutConfirmAlertView class]]) {
                    [subv removeFromSuperview];
                    break;
                }
            }
            [uploadView removeFromSuperview];
            
            [ShowInfo showInfoOnView:KEYWindow withInfo:info];
            //----------根据name和from更改本地数据库中的pdf的收藏状态
            DBHelper *dbHelper = [DBHelper shared];
            FMDatabase *db = [dbHelper toGetDB];
            NSString *tableName = PDFTABLENAME;
            
            if ([db open]) {
                BOOL hasTable = [[DBHelper shared] isTableOK:tableName ofDataBase:db];
                if (!hasTable) {
                    //如果不存在,先创建表
                    NSString *countrySql = [NSString stringWithFormat:@"create table '%@' ('name' text, 'url' text, 'id' text, 'type' text, 'time' text, 'size' text , 'come' text, 'collect' text)",tableName];
                    [db executeUpdate:countrySql];
                }
                NSString *pdfUrl = isBP ? resultData[@"bp_link"]:resultData[@"url"];
                NSString *pdfId = isBP ? resultData[@"id"]:resultData[@"id"];
                NSString *pdfSize = isBP ? resultData[@"bp_size"]:resultData[@"size"];
                NSString *type = @"cloud";
                NSString * comeStr = isBP ? BP : HYBG;
                if (![[DBHelper shared] oneTable:tableName hasOneInfo:newfileName ofDataBase:db]) {
                    //不存在当前文件的名字
                    NSString *time = [[[GetNowTime alloc]init] getCompleteYearDayWithHour];
                    
                    NSString *insertSql = [NSString stringWithFormat:@"insert into '%@' (name,url,id,type,time,size,come,collect) values('%@','%@','%@','%@','%@','%@','%@','%@')",tableName,newfileName,pdfUrl,pdfId,type,time,pdfSize,comeStr,@"1"];
                    [db executeUpdate:insertSql];
                }else{
                    NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and id='%@'", tableName,@"1",newfileName, pdfId];
                    [db executeUpdate:updateSql];
                }
                
                [db close];
            }
            self.uploadSuccess(nil);
            [self removeFromSuperview];
            
        } else {
            NSString *info = @"上传失败，请重新操作";
            [ShowInfo showInfoOnView:KEYWindow withInfo:info];
            [uploadView removeFromSuperview];
            [self removeFromSuperview];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
}

-(void)pressCancleDownLoad{
    [self removeFromSuperview];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UIView *touchV = touches.anyObject.view;
    if (touchV == self.bgView) {
        
    }else{
        
        [self removeFromSuperview];
    }
}
@end
