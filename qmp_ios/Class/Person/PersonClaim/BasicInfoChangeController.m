//
//  BasicInfoChangeController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BasicInfoChangeController.h"
#import "EditInfoViewController.h"

#import "MyImgViewController.h"
#import "ImgInfoTableViewCell.h"
#import "MyInfoTableViewCell.h"
#import "DataHandle.h"
#import "ManagerHud.h"
#import "ShareTo.h"
#import "TakeImageTool.h"
#import "InfoWithoutConfirmAlertView.h"
#import "SearchComController.h"
#import "SearchJigouModel.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"

@interface BasicInfoChangeController ()<UITableViewDelegate,UITableViewDataSource,MyImgViewControllerDelegate,UIScrollViewDelegate,InfoWithoutConfirmAlertViewDelegate,EditInfoViewControllerDelegate>{
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

@implementation BasicInfoChangeController

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
            cell = [[nil loadNibNamed:@"ImgInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadICon)];
        [cell.iconImg addGestureRecognizer:tap];
        [cell initData:self.personInfo[@"headimgurl"]];
        return cell;
        
    }else{
        
        static NSString *infoCellIdentifier = @"MyInfoTableViewCell";
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        if (!cell) {
            cell = [[nil loadNibNamed:@"MyInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *keyStr = [[self.titleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *key = self.keyDict[keyStr];
        NSString *value = self.personInfo[key];
        [cell initDataWithKey:keyStr withValue:value];
        
        //
        if ([keyStr isEqualToString:@"微信"] || [keyStr isEqualToString:@"邮箱"] || [keyStr isEqualToString:@"手机"]) {
            keyStr = [NSString stringWithFormat:@"%@(仅好友可见)",keyStr];
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:keyStr];
            [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:NV_TITLE_COLOR} range:NSMakeRange(0, 2)];
            [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:H9COLOR} range:NSMakeRange(2, keyStr.length - 2)];
            cell.keyLbl.attributedText = attText;
        }
        
        if(section == 0 && (indexPath.row == 1)){
            
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
    
    if (indexPath.section == 0 && indexPath.row == 0){
        
        [self tapHeadICon];
        
    }else{
        
        NSString *key = [[self.titleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *value = self.personInfo[self.keyDict[key]];
        
        
        if (self.personInfo) { //官方人物修改
            //跳转
            EditInfoViewController *editVC = [[EditInfoViewController alloc] init];
            editVC.key = key;
            editVC.value = value;
            __weak typeof(self) weakSelf = self;
            editVC.sureBtnClick = ^(NSString *value) {
                QMPLog(@"修改了---%@=%@",key,value);
                //官方人物修改
                [weakSelf.personInfo setValue:value forKey:self.keyDict[key]];
                [weakSelf.tableView reloadData];

                
            };
            [self.navigationController pushViewController:editVC animated:YES];
            
        }else{
            if ([key isEqualToString:@"所在公司/机构"]) {
                [self selectCompany];
                
            }else{
                
                //跳转
                EditInfoViewController *editVC = [[EditInfoViewController alloc] init];
                editVC.key = key;
                editVC.value = value;
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
                [weakSelf.personInfo setValue:[selectedObject valueForKey:@"company"] forKey:@"company"];
                [weakSelf.tableView reloadData];
                
            }else if([selectedObject isKindOfClass:[SearchProRegisterModel class]]){
                [weakSelf.personInfo setValue:[selectedObject valueForKey:@"company"] forKey:@"company"];
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf.personInfo setValue:selectedObject  forKey:@"company"];
                [weakSelf.tableView reloadData];
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
                [weakSelf.personInfo setValue:[selectedObject valueForKey:@"jigou_name"] forKey:@"company"];
                [weakSelf.tableView reloadData];
                
            }else if ([selectedObject isKindOfClass:[NSString class]]){
                [weakSelf.personInfo setValue:selectedObject  forKey:@"company"];
                [weakSelf.tableView reloadData];
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
    
    [self.navigationController presentViewController:alertVC animated:YES
                                          completion:nil];
}


#pragma mark --EditInfoViewControllerDelegate--
-(void)updateInfoSuccess:(NSString *)value withKey:(NSString *)key{
    
    if (self.personInfo) { //只有头像是EditInfoViewControllerDelegate，剩余的都是sureBtnClick回调
        [self.personInfo setValue:value forKey:self.keyDict[@"头像"]];
    }
    
    [self.tableView reloadData];
    
    
    if ([key isEqualToString:@"headimgurl"] || [key isEqualToString:@"nickname"]) {
        
        [_headIcon sd_setImageWithURL:[NSURL URLWithString:value] placeholderImage:[UIImage imageNamed:@"heading"]];
    }
}

#pragma mark --头像 和 名片
- (void)tapHeadICon{
    
    MyImgViewController *imgVC = [[MyImgViewController alloc] init];
    
    imgVC.key = @"headimgurl";
    imgVC.value = self.personInfo[@"headimgurl"];
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
        if (self.personInfo) {
            _titleArr = @[@[@"头像",@"姓名",@"职位",@"所在公司/机构"]];
            
        }else{
            _titleArr = @[@[@"头像",@"姓名",@"职位",@"所在公司/机构"],@[@"微信",@"邮箱",@"手机",@"个人名片"]];
        }
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
