//
//  EditExprienceController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "EditExprienceController.h"
#import "EditInfoViewController.h"
#import "MyInfoTableViewCell.h"
#import "TextViewCell.h"
#import "DatePickerView.h"
#import "OnePickerView.h"
#import "SearchComController.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"
#import "SearchJigouModel.h"

@interface EditExprienceController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    id _experience;
    BOOL _pressSave;
}
@property(nonatomic,strong)NSArray *section0Titles;
@property(nonatomic,strong) NSDictionary *keyDict;
@property(nonatomic,strong) NSDictionary *eduExperienceDict;
@property(nonatomic,strong) NSDictionary *workExperienceDict;

@end

@implementation EditExprienceController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self showNavigationBarLine];
    for (BaseViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"EditInfoViewController")]) {
            return;
        }
    }
    
    //最后返回 没保存则恢复数据
    if (!_pressSave) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([_experience class], &count);
        for (int i = 0; i < count; i++) {
            const char *name = property_getName(properties[i]);
            NSString *propertyName = [NSString stringWithUTF8String:name];
            id propertyValue = [_experience valueForKey:propertyName];
            if (propertyValue) {
                [self.experienceM setValue:propertyValue forKey:propertyName];
            }
        }
        free(properties);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.experienceM];
    _experience = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    if (self.isJob) {
        if (self.experienceM) {
            self.title = @"编辑工作经历";
        }else{
            self.title = @"添加工作经历";
        }
    }else{
        if (self.experienceM) {
            self.title = @"编辑教育经历";
        }else{
            self.title = @"添加教育经历";
        }
    }
    [self addView];
//    [self buildBarbutton];
    
    if (!self.experienceM) {
        if (self.fromView == FromView_CreatorPerson) {
            self.experienceM = [[ExperienceModel alloc]init];
        }else{
            if (self.isJob) {
                self.experienceM = [[ZhiWeiModel alloc]init];
            }else{
                self.experienceM = [[EducationExpModel alloc]init];
            }
        }
    }
    self.view.backgroundColor = TABLEVIEW_COLOR;

}

- (void)buildBarbutton{

    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 17 - 80, kScreenTopHeight - 33, 80.f, 20.f)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressSaveBarBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
}

- (void)addView{
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-kScreenBottomHeight-40) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[TextViewCell class] forCellReuseIdentifier:@"TextViewCellID"];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    CGFloat top =  SCREENH - kScreenTopHeight - 42 - 40 - 60;
    
    if (self.experienceM) {
        
        UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(19*ratioWidth, SCREENH - kScreenTopHeight - 42-40, SCREENW - 38*ratioWidth, 40)];
        delBtn.layer.cornerRadius = 20;
        delBtn.layer.masksToBounds = YES;
        delBtn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        delBtn.layer.borderWidth = 0.5;
        delBtn.backgroundColor = [UIColor whiteColor];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [delBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        [delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:delBtn];
        
        top = delBtn.top - 60;
        
    }
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(19*ratioWidth, top, SCREENW - 38*ratioWidth, 40)];
    saveBtn.layer.cornerRadius = 20;
    saveBtn.layer.masksToBounds = YES;
    saveBtn.backgroundColor = BLUE_BG_COLOR;
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(pressSaveBarBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveBtn];
}




#pragma mark --Event--

- (void)pressSaveBarBtn{
    //判空
    for (NSString *title in self.section0Titles) {
        
        NSString *key;
        if (self.fromView == FromView_CreatorPerson) {
            key = self.keyDict[title];
        }else{
            if (self.isJob) {
                key = self.workExperienceDict[title];
            }else{
                key = self.eduExperienceDict[title];
            }
        }
        NSString *value = [self.experienceM valueForKey:key];
        if ([PublicTool isNull: value]) {
            [PublicTool showMsg:@"请填写完整信息"];
            return;
        }
    }
    
    _pressSave = YES;
    
    if (self.fromView == FromView_CreatorPerson) {
        
        if ([PublicTool isNull:[self.experienceM valueForKey:@"experienceId"]]) { //上传
            [PublicTool showMsg:@"添加成功"];
            if (self.saveInfoSuccess) {
                self.saveInfoSuccess(self.experienceM);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{  //更新
            
            [PublicTool showMsg:@"修改成功"];
            if (self.saveInfoSuccess) {
                self.saveInfoSuccess(self.experienceM);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
        
    }else{  //来自人物详情页  
        if (self.isJob) {
            if ([PublicTool isNull:[self.experienceM valueForKey:@"zhiweiId"]]) { //添加
                if (self.saveInfoSuccess) {
                    self.saveInfoSuccess(self.experienceM);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{ //修改
                if (self.saveInfoSuccess) {
                    self.saveInfoSuccess(self.experienceM);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{
            if ([PublicTool isNull:[self.experienceM valueForKey:@"educationId"]]) { //添加
                if (self.saveInfoSuccess) {
                    self.saveInfoSuccess(self.experienceM);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if (self.saveInfoSuccess) {
                    self.saveInfoSuccess(self.experienceM);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }

        }
        return;
        
    }
    
//    [PublicTool showHudWithView:KEYWindow];

//    //添加或修改 后直接上传
//    if (self.isJob) {
//        [self uploadWorkExperience];
//    }else{
//        [self uploadSchoolExperience];
//    }
}

//上传工作经历
//- (void)uploadWorkExperience{
//
//
//    NSDictionary *dic = @{@"company":self.experienceM.company,@"zhiwei":self.experienceM.zhiwei,@"start_time":self.experienceM.start_time,@"end_time":self.experienceM.end_time,@"desc":self.experienceM.desc,@"id":[PublicTool isNull:self.experienceM.experienceId]?@"":self.experienceM.experienceId};
//
//    [AppNetRequest saveUserWorkExperienceWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
//        [PublicTool dismissHud:KEYWindow];
//        QMPLog(@"工作经历---%@",resultData);
//        if (resultData && [resultData[@"status"] integerValue] == 0) {
//            if ([PublicTool isNull:self.experienceM.experienceId]) { //上传
//                [PublicTool showMsg:@"添加成功"];
//                if (self.saveInfoSuccess) {
//                    self.saveInfoSuccess(self.experienceM);
//                }
//                [self.navigationController popViewControllerAnimated:YES];
//            }else{  //更新
//                [PublicTool showMsg:@"修改成功"];
//                if (self.saveInfoSuccess) {
//                    self.saveInfoSuccess(self.experienceM);
//                }
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }else{
//            [PublicTool showMsg:REQUEST_ERROR_TITLE];
//        }
//
//    }];
//
//}
//
//
////上传教育经历
//- (void)uploadSchoolExperience{
//
//    NSDictionary *dic = @{@"school":self.experienceM.school,@"zhuanye":self.experienceM.zhuanye,@"xueli":self.experienceM.xueli,@"start_time":self.experienceM.start_time,@"end_time":self.experienceM.end_time,@"desc":self.experienceM.desc,@"id":[PublicTool isNull:self.experienceM.experienceId]?@"":self.experienceM.experienceId};
//
//    [AppNetRequest saveUserEducationWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
//        [PublicTool dismissHud:KEYWindow];
//
//        QMPLog(@"教育经历---%@",resultData);
//        if (resultData && [resultData[@"status"] integerValue] == 0) {
//            if ([PublicTool isNull:self.experienceM.experienceId]) { //上传
//                [PublicTool showMsg:@"添加成功"];
//                if (self.saveInfoSuccess) {
//                    self.saveInfoSuccess(self.experienceM);
//                }
//                [self.navigationController popViewControllerAnimated:YES];
//            }else{  //更新
//                [PublicTool showMsg:@"修改成功"];
//                if (self.saveInfoSuccess) {
//                    self.saveInfoSuccess(self.experienceM);
//                }
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }else{
//            [PublicTool showMsg:REQUEST_ERROR_TITLE];
//        }
//    }];
//}


- (void)delBtnClick{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"确定要删除这段经历" leftTitle:@"取消"  rightTitle:@"删除" leftAction:^{
        
    } rightAction:^{
        _pressSave = YES;
        if (self.fromView == FromView_CreatorPerson) {
            
            [PublicTool showMsg:@"删除成功"];
            if (self.delInfoSuccess) {
                self.delInfoSuccess(self.experienceM);
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }else{ // 人物详情
            if (self.delInfoSuccess) {
                self.delInfoSuccess(self.experienceM);
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }];
    
}

#pragma mark --UITextViewDelegate--
- (void)textViewDidChange:(UITextView *)textView{
    
    [self.experienceM setValue:textView.text forKey:@"desc"];
}

#pragma mark --- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? self.section0Titles.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return indexPath.section == 0 ? 55:106;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString *infoCellIdentifier = @"MyInfoTableViewCell";
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *keyStr = self.section0Titles[indexPath.row];
        NSString *key;
        if (self.fromView == FromView_CreatorPerson) {
            key = self.keyDict[keyStr];
        }else{
            if (self.isJob) {
                key = self.workExperienceDict[keyStr];
            }else{
                key = self.eduExperienceDict[keyStr];
            }
        }
        NSString *value = [self.experienceM valueForKey:key];
        
        [cell initDataWithKey:keyStr withValue:value];

        if (self.isJob && [PublicTool isNull:value]) {
            if (indexPath.row == 2 || indexPath.row == 3) {
                cell.valueLbl.text = @"请选择";
//                cell.valueLbl.textColor = H9COLOR;
            }else{
                cell.valueLbl.text = @"必填";
            }
        }else  if (!self.isJob && [PublicTool isNull:value]) {
            if (indexPath.row == 3 || indexPath.row == 4) {
                cell.valueLbl.text = @"请选择";
                //                cell.valueLbl.textColor = H9COLOR;
            }else{
                cell.valueLbl.text = @"必填";
            }
        }
       
        return cell;
        
    }else{
        
        TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCellID" forIndexPath:indexPath];
        cell.textView.delegate = self;
        cell.textView.text = [self.experienceM valueForKey:@"desc"];
        cell.textView.placehoder = self.isJob ? @"描述你的工作职责或工作业绩（选填）":@"描述您的教育经历和成绩（选填）";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 50)];
    [lab labelWithFontSize:14 textColor:H9COLOR];
    lab.text = section == 0 ? (self.isJob?@"我的工作经历":@"我的教育经历"):@"经历描述";
    [headerView addSubview:lab];
    return headerView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    return;
    
    NSString *title = self.section0Titles[indexPath.row];
    if (indexPath.section == 1) {
        return;
    }
    __weak typeof(self) weakSelf = self;

    if ([title isEqualToString:@"开始时间"]) {
         DatePickerView *datePick = [[DatePickerView alloc]initDatePackerWithResponse:^(NSString *selectedDate) {
             if ([weakSelf compareTimeWithStartTime:selectedDate endTime:[self.experienceM valueForKey:@"end_time"]]) {
                 [weakSelf.experienceM setValue:selectedDate forKey:@"start_time"];
                 [weakSelf.tableView reloadData];
             }
            
        }];
        [datePick show];

    }else if([title isEqualToString:@"结束时间"]){
        DatePickerView *datePick = [[DatePickerView alloc]initDatePackerWithResponse:^(NSString *selectedDate) {
            if ([weakSelf compareTimeWithStartTime:[self.experienceM valueForKey:@"start_time"] endTime:selectedDate]) {
                [weakSelf.experienceM setValue:selectedDate forKey:@"end_time"];

                [weakSelf.tableView reloadData];
            }
        }];
        [datePick showSoFar];
    }else if([title isEqualToString:@"学历"]){
        OnePickerView *picker = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.experienceM setValue:selectedStr forKey:@"xueli"];
            [weakSelf.tableView reloadData];

        } dataSource:@[@"专科",@"本科",@"硕士",@"博士",@"博士后",@"其他"]];
        [picker show];
        
    }else if([title isEqualToString:@"所在公司/机构"]){
        [self selectCompany];
    }else{
        //跳转
        EditInfoViewController *editVC = [[EditInfoViewController alloc] init];
        editVC.key = title;
        NSString *keyStr;
        if (self.fromView == FromView_CreatorPerson) {
            keyStr = self.keyDict[title];
        }else{
            if (self.isJob) {
                keyStr = self.workExperienceDict[title];
            }else{
                keyStr = self.eduExperienceDict[title];
            }
        }
        editVC.value = [self.experienceM valueForKey:keyStr];
        
        editVC.sureBtnClick = ^(NSString *value) {
            QMPLog(@"填写的信息--------%@",value);
            NSString *key;
            if (self.fromView == FromView_CreatorPerson) {
                key = self.keyDict[title];
            }else{
                if (self.isJob) {
                    key = self.workExperienceDict[title];
                }else{
                    key = self.eduExperienceDict[title];
                }
            }
            [weakSelf.experienceM setValue:value forKey:key];
            [weakSelf.tableView reloadData];
        };
        
        [self.navigationController pushViewController:editVC animated:YES];
    }
   
}

- (void)selectCompany{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"所在公司" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        SearchComController *searchVC = [[SearchComController alloc]init];
        __weak typeof(self) weakSelf = self;
        searchVC.didSelected = ^(id selectedObject) {
            NSString *key = self.fromView == FromView_PersonDetail ? self.workExperienceDict[@"所在公司/机构"] : self.keyDict[@"所在公司/机构"];
            if ([selectedObject isKindOfClass:[SearchCompanyModel class]]) {
                SearchCompanyModel *companyM = selectedObject;
                [self.experienceM setValue:companyM.company forKey:key];
                [self.experienceM setValue:companyM.product forKey:@"product"];

                if (companyM.icon) {
                    [self.experienceM setValue:companyM.icon forKey:@"icon"];
                }
                [weakSelf.experienceM setValue:@"company" forKey:@"type"]; //工作经历是 公司
                
            }else if([selectedObject isKindOfClass:[SearchProRegisterModel class]]){
                SearchProRegisterModel *companyM = selectedObject;
                [self.experienceM setValue:companyM.company forKey:key];
                [weakSelf.experienceM setValue:@"other" forKey:@"type"]; //工作经历是 搜不到
                
            }else{
                [self.experienceM setValue:selectedObject forKey:key];
                [weakSelf.experienceM setValue:@"other" forKey:@"type"]; //工作经历是  搜不到
                
            }
            [weakSelf.tableView reloadData];
        };
        searchVC.isCompany = YES;
        [self.navigationController pushViewController:searchVC animated:YES];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"所在机构" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SearchComController *searchVC = [[SearchComController alloc]init];
        __weak typeof(self) weakSelf = self;
        searchVC.didSelected = ^(id selectedObject) {
            NSString *key = self.fromView == FromView_PersonDetail ? self.workExperienceDict[@"所在公司/机构"] : self.keyDict[@"所在公司/机构"];
            if ([selectedObject isKindOfClass:[SearchJigouModel class]]) {
                SearchJigouModel *jigouM = selectedObject;
                [self.experienceM setValue:jigouM.jigou_name forKey:key];
                if (jigouM.icon) {
                    [self.experienceM setValue:jigouM.icon forKey:@"icon"];
                }
                [weakSelf.experienceM setValue:@"jigou" forKey:@"type"]; //工作经历是  搜不到
                
            }else if ([selectedObject isKindOfClass:[NSString class]]){
                [self.experienceM setValue:selectedObject forKey:key];
                [weakSelf.experienceM setValue:@"other" forKey:@"type"]; //工作经历是  搜不到
            }
            [weakSelf.tableView reloadData];
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
        
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];        
    }
    
}
- (BOOL)compareTimeWithStartTime:(NSString*)startTime endTime:(NSString*)endTime{
    if ([PublicTool isNull:startTime] || [PublicTool isNull:endTime]) {
        return YES;
    }
    if ([startTime isEqualToString:@"至今"]) {
        [PublicTool showMsg:@"请选择正确时间"];
        return NO;
    }else if([endTime isEqualToString:@"至今"]){
        return YES;
    }else{
        NSArray *startArr = [startTime componentsSeparatedByString:@"."];
        NSString *startYear = startArr[0];
        NSString *startMonth = startArr.count > 1 ? startArr[1]:@"1";
        NSArray *endArr = [endTime componentsSeparatedByString:@"."];
        NSString *endYear = endArr[0];
        NSString *endMonth = endArr.count > 1 ? endArr[1]:@"1";
        if (startYear.integerValue > endYear.integerValue) {
            [PublicTool showMsg:@"请选择正确时间"];
            return NO;
        }else if(startYear.intValue == endYear.intValue  && startMonth.intValue > endMonth.integerValue){
            [PublicTool showMsg:@"请选择正确时间"];
            return NO;
        }else{
            return YES;
            
        }

    }
    return YES;
}
#pragma mark --懒加载--
-(NSArray *)section0Titles{
    if (!_section0Titles) {
        _section0Titles = self.isJob ? @[@"所在公司/机构",@"职位",@"开始时间",@"结束时间"] : @[@"学校",@"专业",@"学历",@"开始时间",@"结束时间"];
    }
    return _section0Titles;
}

//人物详情页编辑
- (NSDictionary*)workExperienceDict{
    if (!_keyDict) {
        _keyDict = @{@"所在公司/机构":@"name",@"职位":@"zhiwu",@"开始时间":@"start_time",@"结束时间":@"end_time"};
    }
    return _keyDict;
}

- (NSDictionary*)eduExperienceDict{
    if (!_keyDict) {
        _keyDict = @{@"学校":@"school",@"专业":@"major",@"学历":@"xueli",@"开始时间":@"start_time",@"结束时间":@"end_time"};
    }
    return _keyDict;
}



//创建人物时候
- (NSDictionary*)keyDict{
    if (!_keyDict) {
        _keyDict = @{@"所在公司/机构":@"company",@"职位":@"zhiwei",@"开始时间":@"start_time",@"结束时间":@"end_time",@"学校":@"school",@"专业":@"zhuanye",@"学历":@"xueli"};
    }
    return _keyDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
