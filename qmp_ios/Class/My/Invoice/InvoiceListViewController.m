//
//  InvoiceListViewController.m
//  qmp_ios
//
//  Created by molly on 2017/6/6.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvoiceListViewController.h"
#import "OneInvoiceViewController.h"
#import "InvoiceListAddTableViewCell.h"

 
#import "InvoiceItem.h"

#import "EditReceiptController.h"

@interface InvoiceListViewController ()<UITableViewDelegate,UITableViewDataSource>

//@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *firstView;

@property (strong, nonatomic) NSMutableArray *tableData;


@end

@implementation InvoiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票抬头";
    [self initTableView];
    
    [self initNetUnavaliableView];
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        [self showHUD];
        [self requestInvoiceList];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return (self.tableData.count + 1);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.tableData.count) {
        static NSString *cellIdentifier = @"InvoiceListAddTableViewCell";
        InvoiceListAddTableViewCell *addCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!addCell) {
            addCell = [[InvoiceListAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            addCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return addCell;
    }
    else{
        static NSString *cellIdentifier = @"InvoiceTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        }
        
        InvoiceItem *item = self.tableData[indexPath.row];
        cell.textLabel.text = item.company;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        if (indexPath.row == self.tableData.count) {
            [self addInvoice];
        }
        else{
            InvoiceItem *item = self.tableData[indexPath.row];
            
            OneInvoiceViewController *oneVC = [[OneInvoiceViewController alloc] initWithItem:item];
            __weak typeof(self) weakSelf = self;
            oneVC.updateInvoiceSuccess = ^(InvoiceItem *item) {
                for (int i = 0; i < weakSelf.tableData.count ; i++) {
                    InvoiceItem *oldInvoice = self.tableData[i];
                    if ([oldInvoice.invoice_id isEqualToString:item.invoice_id]) {
                        [weakSelf.tableData replaceObjectAtIndex:i withObject:item];
                        [weakSelf.tableView reloadData];
                        break;
                    }
                }
            };
            [self.navigationController pushViewController:oneVC animated:YES];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.tableData.count) {
        return NO;
    }
    else{
        return YES;
    }
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.tableData.count) {
        return nil;
    }
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        InvoiceItem *delItem = self.tableData[indexPath.row];
        [self requestDelOne:delItem];

    }];
    deleteAction.backgroundColor = RED_TEXTCOLOR;
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    if (indexPath.row == self.tableData.count) {
        return @[];
    }
    else{
        UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            InvoiceItem *delItem = self.tableData[indexPath.row];
            [self requestDelOne:delItem];
        }];
        return @[delAction];
    }
}
#pragma mark - 请求删除某个发票抬头
- (void)requestDelOne:(InvoiceItem *)delItem{

    if ([TestNetWorkReached networkIsReached:self]) {
        
        [PublicTool showHudWithView:self.view];
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/delOneInvoice" HTTPBody:@{@"id":delItem.invoice_id} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [PublicTool dismissHud:self.view];
            if (resultData) {
                NSArray *tmpArr = [NSArray arrayWithArray:self.tableData];
                for (InvoiceItem *item in tmpArr) {
                    if ([item.invoice_id isEqualToString:delItem.invoice_id]) {
                        [self.tableData removeObject:delItem];
                        [self.tableView reloadData];
                    }
                }
            }
            else{
                
                [ShowInfo showInfoOnView:self.view withInfo:@"删除失败"];
            }
        }];
    }
}
#pragma mark - 请求发票列表
- (void)requestInvoiceList{

    if ([TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/invoiceList" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (_firstView) {
                _firstView.hidden = YES;
                [_firstView removeFromSuperview];
            }
            if (resultData) {
                NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
                if ([resultData isKindOfClass:[NSArray class]]) {
                    NSArray *data = resultData;
                    for (NSDictionary *dict in data) {
                        InvoiceItem *item = [[InvoiceItem alloc] init];
                        [item setValuesForKeysWithDictionary:dict];
                        [retMArr addObject:item];
                    }
                    self.tableData = retMArr;
                    [self.tableView reloadData];
                }
            }
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
        }];
       
    }
    else{
        [self hideHUD];

    }
    
}
#pragma mark - public
- (void)initTableView{

    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    tableview.separatorInset = UIEdgeInsetsZero;
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
    self.tableView = tableview;
    
    tableview.mj_header = self.mjHeader;
}

- (void)pullDown{
    [self requestInvoiceList];
}

- (void)addInvoice{

    EditReceiptController *editReceiptVC = [[EditReceiptController alloc]init];
    editReceiptVC.refreshReceipt = ^(InvoiceItem *item) {
        for (int i = 0; i < self.tableData.count ; i++) {
            InvoiceItem *oldInvoice = self.tableData[i];
            if ([oldInvoice.invoice_id isEqualToString:item.invoice_id]) {
                [self.tableData replaceObjectAtIndex:i withObject:item];
                [self.tableView reloadData];
                break;
            }
        }
    };
    
    editReceiptVC.addReceipt = ^(InvoiceItem *item) {
        
        [self.tableData insertObject:item atIndex:0];
        [self.tableView reloadData];
    };
    
    [self.navigationController pushViewController:editReceiptVC animated:YES];
    
    [QMPEvent event:@"me_receipt_addClick"];

}

- (void)initNetUnavaliableView{
    
    UIView *fristView = [[UIView alloc]init];
    fristView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    fristView.backgroundColor = RGBTableViewBackgroud;
    self.firstView = fristView;
    [self.view addSubview:self.firstView];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake((SCREENW-150)/2, 100, 150, 150);
    imageView.image = [UIImage imageNamed:@"logol"];
    [self.firstView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake((SCREENW-250)/2, 260, 250, 100);
    label.text = @"网络加载失败,请点击屏幕重试";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = RGB(120, 119, 115, 1);
    label.font = [UIFont systemFontOfSize:16.f];
    label.userInteractionEnabled = YES;
    [self.firstView addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstRefresh)];
    [self.firstView addGestureRecognizer:tap];
}

- (void)firstRefresh{
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        [self requestInvoiceList];
    }
}
#pragma mark - 懒加载


- (NSMutableArray *)tableData{

    if (!_tableData) {
        _tableData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tableData;
}

@end
