//
//  EditBasicInfoController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "EditBasicInfoController.h"
#import "EditInfoViewController.h"

#import "MyImgViewController.h"
#import "ImgInfoTableViewCell.h"
#import "MyInfoTableViewCell.h"
#import "MyCardTableViewCell.h"
#import "DataHandle.h"
#import "ManagerHud.h"
#import "ShareTo.h"
#import "TakeImageTool.h"
#import "InfoWithoutConfirmAlertView.h"
#import "SearchComController.h"
#import "SearchJigouModel.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"

@interface EditBasicInfoController ()<UITableViewDelegate,UITableViewDataSource,MyImgViewControllerDelegate,UIScrollViewDelegate,InfoWithoutConfirmAlertViewDelegate,EditInfoViewControllerDelegate>{
    TakeImageTool *_userTool;
    BOOL isBack;
    UIButton *_finOSBtn;
    UIView *_footerView;
    UIButton *_shareBtn;
    
    UIView *_underView;
    UIImageView *_headIcon;
    InfoWithoutConfirmAlertView *_alertV;
    ShareTo *_shareTool;
    UIImage *_headImg;
    UIImage *_cardImg;
    UIImage *_cardBackImg;
    
}


@property (strong, nonatomic) NSArray *titleArr;
@property (strong, nonatomic) NSDictionary *keyDict;
@property (strong, nonatomic) NSDictionary *personDict;

@end

@implementation EditBasicInfoController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的资料";
    _shareTool = [[ShareTo alloc]init];
    _userTool = [[TakeImageTool alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addView];
}

- (void)addView{
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


#pragma mark --Event--
- (void)cancelBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark --- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.titleArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray*)self.titleArr[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }else if(indexPath.section == 1 && indexPath.row == 3){
        return 127;
    }
    return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *imgCellIdentifier = @"ImgInfoTableViewCell";
        ImgInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:imgCellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ImgInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadICon)];
        [cell.iconImg addGestureRecognizer:tap];
        [cell initData:self.personInfo ? self.personInfo[@"headimgurl"]:self.userInfoDic[@"headimgurl"]];
        return cell;
        
    }else if(section == 1 && indexPath.row == 3){
        
        static NSString *imgCellIdentifier = @"MyCardTableViewCell";
        MyCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:imgCellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyCardTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.personInfo) {
            [cell initData:self.personInfo[@"card"] withBack:self.userInfoDic[@"cardback"]];
        }else{
            [cell initData:self.userInfoDic[@"card"] withBack:nil];
        }
        
        [cell.imgBtn addTarget:self action:@selector(pressMyCardImg) forControlEvents:UIControlEventTouchUpInside];
        if (self.personInfo) { //来自人物
            cell.backImgBtn.hidden = YES;
        }
        [cell.backImgBtn addTarget:self action:@selector(pressMyCardBackImg) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    }else{
        
        static NSString *infoCellIdentifier = @"MyInfoTableViewCell";
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *keyStr = [[self.titleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *key = self.keyDict[keyStr];
        NSString *value = self.personInfo ? self.personInfo[key]:self.userInfoDic[key];
        [cell initDataWithKey:keyStr withValue:value];
        
        //
        if ([keyStr isEqualToString:@"微信"] || [keyStr isEqualToString:@"邮箱"] || [keyStr isEqualToString:@"手机"]) {
            keyStr = [NSString stringWithFormat:@"%@(仅好友可见)",keyStr];
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:keyStr];
            [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:NV_TITLE_COLOR} range:NSMakeRange(0, 2)];
            [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:H9COLOR} range:NSMakeRange(2, keyStr.length - 2)];
            cell.keyLbl.attributedText = attText;
        }
        
        if(section == 0 && (indexPath.row == 1) && [WechatUserInfo shared].claim_type.integerValue == 2){
            
            cell.rightImgV.hidden = YES;

        }else{
            cell.rightImgV.hidden = NO;
        }
        if (section == 0 && indexPath.row == 3) {
            cell.lineV.hidden = YES;
        }
        else{
            cell.lineV.hidden = NO;
        }

        return cell;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [[self.titleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([key containsString:@"名片"]) {
        return;
    }
    if (indexPath.section == 1 && indexPath.row == 2) { //手机号
        [PublicTool alertActionWithTitle:@"提示" message:@"修改绑定手机需重新验证手机" leftTitle:@"取消" rightTitle:@"修改" leftAction:^{
            
        } rightAction:^{
            __weak typeof(self) weakSelf = self;
            [[AppPageSkipTool shared]appPageSkipToBindPhoneFinish:^(NSString * _Nonnull bindPhone) {
                [weakSelf.personInfo setValue:bindPhone forKey:@"phone"];
                [weakSelf.tableView reloadData];
            }];
        }];
        
    }else if (indexPath.section == 0 && indexPath.row == 0 ){
        
        [self tapHeadICon];
        
    }else{
        
        NSString *key = [[self.titleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *value = self.personInfo ? self.personInfo[self.keyDict[key]]:self.userInfoDic[self.keyDict[key]];
        
        if ([WechatUserInfo shared].claim_type.integerValue == 2  && [key isEqualToString:@"姓名"]){
            return;
        }
//            
//        if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3) && [WechatUserInfo shared].claim_type.integerValue == 2 && self.person.claim_flag.integerValue == 1) { //审核中 修改资料
//            return;
//        }

        if (self.personInfo) { //官方人物修改
            if ([key isEqualToString:@"所在公司/机构"]) {
                [self selectCompany];
                return;
            }
            //跳转
            EditInfoViewController *editVC = [[EditInfoViewController alloc] init];
            editVC.key = key;
            editVC.value = value;
            __weak typeof(self) weakSelf = self;
            editVC.sureBtnClick = ^(NSString *value) {
                [PublicTool showHudWithView:KEYWindow];
                QMPLog(@"修改了---%@=%@",key,value);
                //官方人物修改
                NSDictionary *param = @{@"person_id":weakSelf.personInfo[@"personId"],@"field":self.keyDict[key],@"value":value};
                [AppNetRequest submitPersonInfoOfDetailWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                   
                    [PublicTool dismissHud:KEYWindow];

                    //提交修改数据
                    QMPLog(@"修改基本信息页--修改基本数据----%@=%@---%@",key,value,resultData);
                    if ([resultData[@"msg"] isEqualToString:@"success"]) {
                        [PublicTool showMsg:@"保存成功"];
                        [weakSelf.personInfo setValue:value forKey:self.keyDict[key]];
                        [weakSelf.tableView reloadData];
                        [[WechatUserInfo shared] setValue:[NSString stringWithFormat:@"%@",value] forKey:self.keyDict[key]];
                    }else{
                        [PublicTool showMsg:@"保存失败"];
                    }
                }];
        
            };
            [self.navigationController pushViewController:editVC animated:YES];
        
        }else{ //非官方人物修改
            if ([key isEqualToString:@"所在公司/机构"]) {
                [self selectCompany];
            }else{
                //跳转
                EditInfoViewController *editVC = [[EditInfoViewController alloc] init];
                editVC.key = key;
                editVC.value = value;
                editVC.userid = self.userInfoDic[@"id"];
                editVC.delegate = self;
                [self.navigationController pushViewController:editVC animated:YES];
            }
        }
        
    }
}

- (void)selectCompany{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"所在公司" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        SearchComController *searchVC = [[SearchComController alloc]init];
        __weak typeof(self) weakSelf = self;
        searchVC.didSelected = ^(id selectedObject) {
           
            if ([selectedObject isKindOfClass:[SearchCompanyModel class]]) {
                [weakSelf saveCompanyOfUser:[selectedObject valueForKey:@"product"] type:@"company" company:[selectedObject valueForKey:@"company"]];
                
            }else if([selectedObject isKindOfClass:[SearchProRegisterModel class]]){
                [weakSelf saveCompanyOfUser:[selectedObject valueForKey:@"company"] type:@"common" company:[selectedObject valueForKey:@"company"]];
                
            }else{
                [weakSelf saveCompanyOfUser:selectedObject type:@"common" company:selectedObject];
            }
        };
        searchVC.isCompany = YES;
        [self.navigationController pushViewController:searchVC animated:YES];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"所在机构" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SearchComController *searchVC = [[SearchComController alloc]init];
        __weak typeof(self) weakSelf = self;
        searchVC.didSelected = ^(id selectedObject) {
            if ([selectedObject isKindOfClass:[SearchJigouModel class]]) {
                [weakSelf saveCompanyOfUser:[selectedObject valueForKey:@"jigou_name"] type:@"jigou" company:[selectedObject valueForKey:@"jigou_name"]];

            }else if ([selectedObject isKindOfClass:[NSString class]]){
                [weakSelf saveCompanyOfUser:selectedObject type:@"common" company:selectedObject];

            }
        };
        searchVC.isCompany = NO;
        [self.navigationController pushViewController:searchVC animated:YES];
        
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        
    }];
    [alertVC addAction:action0];
    [alertVC addAction:action1];
    [alertVC addAction:action3];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
        
    }else{
        
        [self.navigationController presentViewController:alertVC animated:YES
                                              completion:nil];
    }
    
}


#pragma mark ---保存用户公司
- (void)saveCompanyOfUser:(NSString*)companyName type:(NSString*)type company:(NSString*)company{
    
    if (self.personInfo) {  //官方人物修改
        
        [PublicTool showHudWithView:KEYWindow];
        //官方人物修改
        NSDictionary *param = @{@"person_id":self.personInfo[@"personId"],@"field":@"company",@"value":companyName,@"type":type,@"company":company};
        [AppNetRequest submitPersonInfoOfDetailWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            
            if ([resultData[@"msg"] isEqualToString:@"success"]) {
                [PublicTool showMsg:@"保存成功"];
                [self.personInfo setValue:companyName forKey:@"company"];
                [self.tableView reloadData];
            }else{
                [PublicTool showMsg:@"保存失败"];
            }
        }];
        
    }else{  //非官方人物 基本信息修改
        
        [PublicTool showHudWithView:KEYWindow];
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/addupduserinfo" HTTPBody:@{@"field":@"company",@"value":companyName,@"id":self.userInfoDic[@"id"]} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            [self.userInfoDic setValue:companyName forKey:@"company"];
            [self.tableView reloadData];
            
        }];
    
    }    
    
}

#pragma mark --EditInfoViewControllerDelegate--
-(void)updateInfoSuccess:(NSString *)value withKey:(NSString *)key{
    
    if (self.personInfo) { //人物 头像和名片正面
        if ([key containsString:@"card"]) {
            [self.personInfo setValue:value forKey:@"card"];
        }else{
            [self.personInfo setValue:value forKey:self.keyDict[@"头像"]];
            //官方人物修改
            NSDictionary *param = @{@"person_id":self.personInfo[@"personId"],@"field":@"icon",@"value":value};
            [AppNetRequest submitPersonInfoOfDetailWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                //提交修改数据
                QMPLog(@"修改基本信息页--修改基本数据----%@=%@---%@",key,value,resultData);
            }];
        }

    }else{
        [self.userInfoDic setValue:value forKey:key];
    }
    
    [[WechatUserInfo shared] setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
    [self.tableView reloadData];
    
    
    if ([key isEqualToString:@"headimgurl"] || [key isEqualToString:@"nickname"]) {
        
        [_headIcon sd_setImageWithURL:[NSURL URLWithString:value] placeholderImage:[UIImage imageNamed:@"heading"]];
        
    }
}

#pragma mark --头像 和 名片
- (void)tapHeadICon{
    
    MyImgViewController *imgVC = [[MyImgViewController alloc] init];
    
    imgVC.key = @"headimgurl";
    if (self.personInfo) {
        imgVC.value = self.personInfo[@"headimgurl"];
    }else{
        imgVC.value = self.userInfoDic[@"headimgurl"];
    }
    imgVC.delegate = self;
    [self.navigationController pushViewController:imgVC animated:YES];

}


- (void)pressMyCardImg{
    isBack = NO;
    if (self.personInfo) {
        [self openCard:self.personInfo[@"card"]];
    }else{
        [self openCard:self.userInfoDic[@"card"]];
    }
    
}

- (void)pressMyCardBackImg{
    isBack = YES;
    [self openCard:self.userInfoDic[@"cardback"]];
}

- (void)openCard:(NSString *)imgName {
    //名片
    MyImgViewController *imgVC = [[MyImgViewController alloc] init];
    imgVC.key = isBack ? @"cardback":@"card";
    imgVC.value = imgName;
    imgVC.delegate = self;
    [self.navigationController pushViewController:imgVC animated:YES];

}

#pragma mark -- InfoWithoutConfirmAlertView
- (void)confirmToChoose{
    
    [_alertV removeFromSuperview];
}


#pragma mark - public

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳入当前App设置界面
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
    }else{
        
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
    }
    
}

#pragma mark -懒加载
- (NSArray *)titleArr{
    
    if (!_titleArr) {
        _titleArr = @[@[@"头像",@"姓名",@"所在公司/机构",@"职位"],@[@"微信",@"邮箱",@"手机",@"个人名片"]];
    }
    return _titleArr;
}

- (NSDictionary *)keyDict{
    
    if (!_keyDict) {
        _keyDict = @{@"头像":@"headimgurl",@"姓名":@"nickname",@"职位":@"zhiwei",@"所在公司/机构":@"company",@"微信":@"wechat",@"手机":@"phone",@"邮箱":@"email"};
    }
    return _keyDict;
}


@end
