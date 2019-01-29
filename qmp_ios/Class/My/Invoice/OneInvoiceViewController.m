//
//  OneInvoiceViewController.m
//  qmp_ios
//
//  Created by molly on 2017/6/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "OneInvoiceViewController.h"
#import "OneInvoiceTableViewCell.h"
#import "InvoiceListViewController.h"
#import "EditReceiptController.h"
#import "FactoryUI.h"

@interface OneInvoiceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableDictionary *tableData;
@property (strong, nonatomic) NSMutableArray *keyMArr;
@property (strong, nonatomic) NSMutableArray *cellHMArr;

@property (strong, nonatomic) InvoiceItem *item;

@property (strong, nonatomic) GetSizeWithText *sizeTool;
@end

@implementation OneInvoiceViewController

- (instancetype)initWithItem:(InvoiceItem *)item{

    if (self = [super init]) {
        _item = item;
        [self handleItemToDict:item];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票抬头";

    [self buildLeftBarBtnItem];
    [self buildRightBarBtnItem];
    [self initTableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 16.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cellHMArr[indexPath.row] floatValue];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"OneInvoiceTableViewCell";
    OneInvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OneInvoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *key = self.keyMArr[indexPath.row];
    [cell initKey:key withValue:self.tableData[key]];
    return cell;
}
#pragma mark - public
- (void)handleItemToDict:(InvoiceItem *)item{

    NSMutableDictionary *retMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray *keyMArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *cellHMArr = [[NSMutableArray alloc] initWithCapacity:0];

    if (![self empty:item.company]) {
        [retMDict setValue:item.company forKey:@"单位名称"];
        [keyMArr addObject:@"单位名称"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.company]]];
    }
    if (![self empty:item.code]) {
        [retMDict setValue:item.code forKey:@"税号"];
        [keyMArr addObject:@"税号"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.code]]];
    }
    if (![self empty:item.address]) {
        [retMDict setValue:item.address forKey:@"单位地址"];
        [keyMArr addObject:@"单位地址"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.address]]];
    }
    if (![self empty:item.tel]) {
        [retMDict setValue:item.tel forKey:@"公司电话"];
        [keyMArr addObject:@"公司电话"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.tel]]];
    }
    if (![self empty:item.bank]) {
        [retMDict setValue:item.bank forKey:@"开户银行"];
        [keyMArr addObject:@"开户银行"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.bank]]];
    }
    if (![self empty:item.account]) {
        [retMDict setValue:item.account forKey:@"银行账号"];
        [keyMArr addObject:@"银行账号"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.account]]];
    }
    if (![self empty:item.receiver]) {
        [retMDict setValue:item.receiver forKey:@"收件人"];
        [keyMArr addObject:@"收件人"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.account]]];
    }
    if (![self empty:item.receiver_tel]) {
        [retMDict setValue:item.receiver_tel forKey:@"手机号码"];
        [keyMArr addObject:@"手机号码"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.account]]];
    }
    if (![self empty:item.receiver_ads]) {
        [retMDict setValue:item.receiver_ads forKey:@"收件地址"];
        [keyMArr addObject:@"收件地址"];
        [cellHMArr addObject:[NSString stringWithFormat:@"%f",[self calculateHWithValue:item.account]]];
    }
    
    self.tableData = retMDict;
    self.keyMArr = keyMArr;
    self.cellHMArr = cellHMArr;
}

- (CGFloat )calculateHWithValue:(NSString *)value{

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    [style setLineSpacing:4.f];

    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15.f],NSParagraphStyleAttributeName:style};
    CGFloat lblH = ceil([self.sizeTool calculateSize:value withDict:attribute withWidth:(SCREENW - 77.f - 16 * 3)].height);
    return (lblH > 20.f ? lblH : 20.f) + 30;
}

- (BOOL)empty:(NSString *)value{

    return ([PublicTool isNull:value]);
}

- (void)buildLeftBarBtnItem{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(pressLeftBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    
    if (iOS11_OR_HIGHER) {
        
        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        self.navigationItem.leftBarButtonItems = @[buttonItem];

    }else{
        self.navigationItem.leftBarButtonItems = @[ negativeSpacer,leftButtonItem];
    }
    
}

- (void)pressLeftBarButtonItem:(UIBarButtonItem *)sender{

    NSArray *vcs = self.navigationController.viewControllers;
    for (NSInteger j = vcs.count - 1; j>=0;j-- ) {
        UIViewController *v = vcs[j];
        if ([v isKindOfClass:[InvoiceListViewController class]]) {
            [self.navigationController popToViewController:v animated:YES];
            break;
        }
    }
}

- (void)buildRightBarBtnItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)pressRightBarButtonItem:(UIBarButtonItem *)sender{

    EditReceiptController *editVC = [[EditReceiptController alloc]init];
    editVC.item = _item;
    __weak typeof(self) weakSelf = self;
    editVC.refreshReceipt = ^(InvoiceItem *item) {
        _item = item;
        [weakSelf handleItemToDict:item];
        [weakSelf.tableView reloadData];

        weakSelf.updateInvoiceSuccess(item);
    };
    [self.navigationController pushViewController:editVC animated:YES];

    
}

- (void)initTableView{
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    tableview.separatorInset = UIEdgeInsetsZero;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
    self.tableView = tableview;
    
    [self handleTableFooterView];
}

- (void)handleTableFooterView{
    if (self.tableData.count > 0) {
        UIButton *copyAllBtn = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, SCREENW , 44.f) title:@"复制全部" titleColor:[UIColor blackColor] fontNum:15.f textAlignment:UIControlContentHorizontalAlignmentCenter];
        copyAllBtn.backgroundColor = [UIColor whiteColor];
        [copyAllBtn addTarget:self action:@selector(pressCopyAllBtn) forControlEvents:UIControlEventTouchUpInside];
        self.tableView.tableFooterView = copyAllBtn;
    }
    else{
        self.tableView.tableFooterView = nil;
    }
}

- (void)pressCopyAllBtn{
    NSString *copyStr = @"";
    copyStr = [self handleCopyStr:copyStr withKey:@"单位名称"];
    copyStr = [self handleCopyStr:copyStr withKey:@"税号"];
    copyStr = [self handleCopyStr:copyStr withKey:@"单位地址"];
    copyStr = [self handleCopyStr:copyStr withKey:@"公司电话"];
    copyStr = [self handleCopyStr:copyStr withKey:@"开户银行"];
    copyStr = [self handleCopyStr:copyStr withKey:@"银行账号"];
    copyStr = [self handleCopyStr:copyStr withKey:@"收件人"];
    copyStr = [self handleCopyStr:copyStr withKey:@"手机号码"];
    copyStr = [self handleCopyStr:copyStr withKey:@"收件地址"];

    copyStr = [copyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = copyStr;
    [ShowInfo showInfoOnView:KEYWindow withInfo:@"复制成功"];

}

- (NSString *)handleCopyStr:(NSString *)copyStr withKey:(NSString *)key{
    if ([_keyMArr containsObject:key]) {
        NSString *value = [_tableData objectForKey:key];
        copyStr = [NSString stringWithFormat:@"%@\n%@:%@",copyStr,key,value];
    }
    return copyStr;
}
#pragma mark - 懒加载
- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

@end
