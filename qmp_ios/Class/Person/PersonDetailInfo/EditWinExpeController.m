//
//  EditWinExpeController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "EditWinExpeController.h"
#import "EditCell.h"
#import "TextViewCell.h"
#import "MyInfoTableViewCell.h"
#import "DatePickerView.h"

@interface EditWinExpeController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)NSDictionary *basicInfoKeyValueDic;
@property(nonatomic,strong)NSArray *sectionRowArr;



@end

@implementation EditWinExpeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"获奖经历";
    if (!self.experienceM) {
        self.experienceM = [[WinExperienceModel alloc]init];
    }
    [self showHUD];
    
    [self addView];
//    [self buildBarbutton];
}

- (void)buildBarbutton{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 17 - 80, kScreenTopHeight - 33, 80.f, 20.f)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressSaveBarBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
}

- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    self.tableView.tableFooterView = footerView;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    
    [self.tableView registerClass:[TextViewCell class] forCellReuseIdentifier:@"TextViewCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    CGFloat top =  SCREENH - kScreenTopHeight - 42 - 40 - 60;
    if (![PublicTool isNull:self.experienceM.winExId]) {
        
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
- (void)delBtnClick{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"确定要删除这段经历" leftTitle:@"取消"  rightTitle:@"删除" leftAction:^{
        
    } rightAction:^{
        
        if (self.delInfoSuccess) {
            self.delInfoSuccess(self.experienceM);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)pressSaveBarBtn{
    //判空
    if ([PublicTool isNull:self.experienceM.awards] || [PublicTool isNull:self.experienceM.time] || [PublicTool isNull:self.experienceM.winning] ) {
        [PublicTool showMsg:@"信息不能为空"];
        return;
    }
    
    if ([PublicTool isNull:self.experienceM.winExId]) { //上传
        
        if (self.saveInfoSuccess) {
            self.saveInfoSuccess(self.experienceM);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{  //更新
        
        if (self.saveInfoSuccess) {
            self.saveInfoSuccess(self.experienceM);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)editCellTextChange:(UITextField*)tf{
    
    EditCell *cell = (EditCell*)tf.superview.superview;
    [self.experienceM setValue:tf.text forKey:self.basicInfoKeyValueDic[cell.keyLabel.text]];
    
    
}

#pragma mark --UITextFieldDelegate--
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    if (row < 3) {
        row ++;
        EditCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
        [cell.valueTf becomeFirstResponder];
    }
    
    return YES;
}


#pragma mark --UITableViewDelegate--
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 50)];
    [lab labelWithFontSize:14 textColor:H9COLOR];
    lab.text = @"获奖经历";
    [headerView addSubview:lab];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionRowArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = self.sectionRowArr[section];
    return rows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *title  = self.sectionRowArr[indexPath.section][indexPath.row];
    if ([title isEqualToString:@"获奖时间"]) {
        static NSString *infoCellIdentifier = @"MyInfoTableViewCell";
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        if (!cell) {
            cell = [[[BundleTool commonBundle] loadNibNamed:@"MyInfoTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.rightImgV.hidden = NO;
        
        [cell initDataWithKey:@"获奖时间" withValue:self.experienceM.time];

        if ([PublicTool isNull:self.experienceM.time]) {
            cell.valueLbl.text = @"请选择";
        }
        return cell;
        
    }
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID" forIndexPath:indexPath];
    cell.keyLabel.text = title;
    cell.valueTf.placeholder = [NSString stringWithFormat:@"请输入%@",title];
    NSString *value = [self.experienceM valueForKey:self.basicInfoKeyValueDic[title]];
    cell.valueTf.text = [PublicTool isNull: value] ? @"":value;
    [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
    cell.valueTf.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([title isEqualToString:@"颁奖单位"]) {
        cell.line.hidden = YES;
    }else{
        cell.line.hidden = NO;
    }
    return cell;
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [self.view endEditing:YES];
        __weak typeof(self) weakSelf = self;

        DatePickerView *datePicker = [[DatePickerView alloc]initDatePackerWithNumColoum:@"3" response:^(NSString *selectedDate) {
            weakSelf.experienceM.time = selectedDate;
            [weakSelf.tableView reloadData];
        }];
        [datePicker show];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --懒加载--
- (NSArray *)sectionRowArr{
    
    if (!_sectionRowArr) {
        
        _sectionRowArr = @[@[@"获奖名称",@"获奖时间",@"颁奖单位"]];
        
    }
    return _sectionRowArr;
}


- (NSDictionary *)basicInfoKeyValueDic{
    if (!_basicInfoKeyValueDic) {
        _basicInfoKeyValueDic = @{@"获奖名称":@"winning",@"获奖时间":@"time",@"颁奖单位":@"awards"};
    }
    return _basicInfoKeyValueDic;
}
@end
