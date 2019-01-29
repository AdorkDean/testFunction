//
//  SetTableViewController.m
//  qmp_ios
//
//  Created by 李建 on 16/11/22.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "SetTableViewController.h"
#import "SettingTableViewCell.h"
#import "QuitTableViewCell.h"
#import "ManagerHud.h"
#import "ChangeFlowerNameController.h"

#import <sqlite3.h>

static NSString *const APPGroupId = @"group.mofang.Qimingpian";
@interface SetTableViewController (){

    BOOL _isLogin;//是否登录的标志位

}

@property (strong, nonatomic) NSArray *tableDataArr;
@property (strong, nonatomic) UIButton *loginButton;



@end

@implementation SetTableViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.title = @"设置";
    
    static NSString *reuseIdentifier = @"cell";
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //footerV
    UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenBottomHeight-kScreenTopHeight-6, SCREENW, 55)];
    UIButton *existBtn = [[UIButton alloc]initWithFrame:CGRectMake(29, 0, SCREENW-29-26, 35)];
    existBtn.layer.cornerRadius = 2;
    existBtn.layer.masksToBounds = YES;
    existBtn.backgroundColor = RED_BG_COLOR;
    [existBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    existBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [footV addSubview:existBtn];
    [existBtn addTarget:self action:@selector(pressQuitLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:footV];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingTableViewCell *cell = [SettingTableViewCell cellWithTableView:tableView];
    cell.titleLab.font = [UIFont systemFontOfSize:16];
    cell.leftImageV.contentMode = UIViewContentModeCenter;
    [cell.leftImageV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(16);
        make.width.equalTo(@(26));
        make.height.equalTo(@(26));
        make.centerY.equalTo(cell.contentView);
    }];
    
    [cell.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(50);
        make.top.equalTo(cell.contentView).offset(0);
        make.bottom.equalTo(cell.contentView).offset(0);
        make.width.greaterThanOrEqualTo(@(30));
    }];
    
    NSString *title = self.tableDataArr[indexPath.row][@"title"];
    cell.titleLab.text = title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.leftImageV setImage:[UIImage imageNamed:self.tableDataArr[indexPath.row][@"image"]]];
    cell.redPointView.hidden = YES;
    if ([title isEqualToString:@"清理缓存"]) {
        cell.rightImageV.hidden = YES;
    }else{
        cell.rightImageV.hidden = NO;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *rowDict = self.tableDataArr[indexPath.row];
    
    SEL selector = NSSelectorFromString(rowDict[@"action"]);
    ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
}


#pragma mark --Event--
- (void)clearCache{
    
    CGFloat folderSize = [self folderSizeWithPath:[self getPath]] + [self folderSizeWithPath:[self getDocumentsPath]];
    //弹窗 删除 0801 molly
    [self deleteFileWithFolderSize:folderSize];
}

- (void)changeFlowerName{
    if (![ToLogin isLogin]) {
        [ToLogin enterLoginPage:self];
        return;
    }
    ChangeFlowerNameController *vc = [[ChangeFlowerNameController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - public

//退出登录的提示框

- (void)pressQuitLoginBtn{

    [PublicTool alertActionWithTitle:@"退出确认" message:@"你确认要退出当前企名片的账号吗?" cancleAction:^{
        
    } sureAction:^{
        [[ChatHelper shareHelper]loginOutUser];
        
        if([self.delegate respondsToSelector:@selector(pressQuitLoginBtn)]){
            
            [self.delegate pressQuitLoginBtn];
            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}



/**
 *  弹出对话框 提示用户有多少缓存 询问用户是否删除缓存
 *
 *  @param folderSize
 */
-(void)deleteFileWithFolderSize:(CGFloat)folderSize{
    
    if (folderSize > 0.02) {
        [PublicTool alertActionWithTitle:@"提示" message:[NSString stringWithFormat:@"当前缓存大小为:%.2fM",folderSize] leftTitle:@"取消" rightTitle:@"清除" leftAction:^{
            
        } rightAction:^{
            
            ManagerHud *delHud = [[ManagerHud alloc] init];
            //删除Caches文件
            [self clearCachePath:[self getPath]];
            //删除Documents文件 0801 molly
            [self clearCachePath:[self getDocumentsPath]];
            //删除本地收藏的url 0808 molly
            [self clearLocalCollectUrl];
            [self clearLocalHistory];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [delHud addHud:self.view];
                
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [delHud removeHud];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removePdfFileSuccess" object:nil];
                
                [ShowInfo showInfoOnView:self.view withInfo:@"清理成功"];
                
            });
            //更新行研报告
        }];
        
    }else{
        
        [PublicTool alertActionWithTitle:@"提示" message:@"当前没有缓存" btnTitle:@"确定" action:^{
            
        }];
    }
}

/**
 *  找到缓存文件路径
 *
 *  @return
 */
-(NSString *)getPath{
    //缓存文件实际存在于沙盒目录下 library文件夹下cache文件夹
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    return path;
}

/**
 *  获取Document的路径
 *
 *  @return
 */
- (NSString *)getDocumentsPath{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return path;
}

/**
 *  计算文件大小
 *
 *  @param path 要计算的路径
 *
 *  @return
 */
-(CGFloat)folderSizeWithPath:(NSString *)path{
    //初始化文件管理器
    NSFileManager *filem = [NSFileManager defaultManager];
    
    CGFloat folderSize = 0.0;
    if ([filem fileExistsAtPath:path]) {
        //当前目录下文件存在
        //获取文件夹下所有文件
        NSArray *fileArr = [filem subpathsAtPath:path];
        for (NSString *fileName in fileArr) {
            //每个文件大小
            //获取每个文件的路径
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            //计算每个文件大小
            CGFloat fileSize = [filem attributesOfItemAtPath:filePath error:nil].fileSize;//字节
            //换算单位 并且计算所有文件大小总和
            folderSize += fileSize / 1024.0 /1024.0;
        }
        //删除缓存文件
        return folderSize;
    }
    return 0;
}


- (void)clearCachePath:(NSString *)path{
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    if ([fileM fileExistsAtPath:path]) {
        //文件存在 删除
        //获取所有文件
        NSArray *fileArray = [fileM subpathsAtPath:path];
        for (NSString *fileName in fileArray) {
            //可以过滤掉不想删除的文件格式
            if ([fileName hasSuffix:@".mp3"] || [fileName hasSuffix:@".sqlite"]) {
#if (DEBUG_LOG == TRUE)
                NSLog(@"不删除mp3格式文件");
#endif
            }else{
                //清理
                //获取每个文件的路径
                
                NSString *filePath = [path stringByAppendingPathComponent:fileName];
                
                //删除
                [fileM removeItemAtPath:filePath error:nil];
            }
        }
    }
}

/**
 *  清除本地收藏的url
 */
- (void)clearLocalCollectUrl{
    
    NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:APPGroupId];
    if ([sharedUserDefaults objectForKey:@"SharedExtension"]) {
        [sharedUserDefaults setValue:nil forKey:@"SharedExtension"];
        [sharedUserDefaults synchronize];
    }
    
}

/**
 *清除本地搜索历史
 */
- (void)clearLocalHistory{
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults] ;
    [userDefaults setValue:nil forKey:@"localHistory"];
    [userDefaults setValue:nil forKey:@"keywordsHistory"];
    [userDefaults setValue:nil forKey:@"pasteUrlMArr"];
    [userDefaults setValue:nil forKey:@"openPdfMArr"];
    [userDefaults setValue:nil forKey:@"pdfFromUrl"];
    [userDefaults setValue:nil forKey:@"openReportMArr"];
    [userDefaults synchronize];
    
    [self cleanLocalPdfTable]; //不清 我的下载 pdf文件
}

/**
    清除本地存储的pdf的数据表中的内容
 */
- (void)cleanLocalPdfTable{

    FMDatabase *db = [[DBHelper shared] toGetDB];
    NSString *tableName = PDFTABLENAME;
    NSString *urlPdfTableName = @"urlpdflist";
    NSString *gsggStr = [NSString stringWithFormat:@"come='%@'",GSGG];
    [[DBHelper shared] deleteLocal:tableName fDataBase:db conditionStr:gsggStr];
    BOOL delUrlPdf = [[DBHelper shared] deleteOneTableInfo:urlPdfTableName fDataBase:db];
}

- (NSArray *)tableDataArr{
    
    if (!_tableDataArr) {
        _tableDataArr = [[NSArray alloc] init];
        
        _tableDataArr = @[@{@"title":@"我的花名",@"image":@"set_flowname",@"action":@"changeFlowerName"},@{@"title":@"清理缓存",@"image":@"set_clear",@"action":@"clearCache"}];
    }
    return _tableDataArr;
}


@end
