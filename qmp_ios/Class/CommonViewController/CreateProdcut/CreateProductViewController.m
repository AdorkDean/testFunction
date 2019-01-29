//
//  CreateProductViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CreateProductViewController.h"
#import "GetMd5Str.h"
#import "IPOCompanyCell.h"
#import "CreateProController.h"
@interface CreateProductViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIButton *confirmButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation CreateProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"填写项目信息";
    
    [self initTableView];
}
- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 130) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.footerView];
    self.footerView.frame = CGRectMake(0, SCREENH - kScreenTopHeight - 130, SCREENW, 120);
    
    self.tableView.tableHeaderView = self.headerView;
    
    [self.tableView registerClass:[IPOCompanyCell class] forCellReuseIdentifier:@"IPOCompanyCellID"];

}
- (void)textFieldTextChange:(UITextField *)textField {
    self.confirmButton.userInteractionEnabled = textField.text.length > 0;
    self.confirmButton.backgroundColor = textField.text.length > 0 ? BLUE_TITLE_COLOR:HTColorFromRGB(0xB1B5BD);
}
- (void)confirmButtonClick:(UIButton *)button {
    self.textField.userInteractionEnabled = NO;
    self.keyword = self.textField.text;
    [self requestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)continueButtonClick {
    CreateProController *vc = [[CreateProController alloc] init];
    vc.productName = self.keyword?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)cancelButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.productData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    IPOCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPOCompanyCellID" forIndexPath:indexPath];
    [cell refreshUI:self.productData[indexPath.row]];
    cell.iconBgColor = RANDOM_COLORARR[indexPath.row % 6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.bottomLine.hidden = (self.productData.count == indexPath.row+1);
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchCompanyModel *product = self.productData[indexPath.row];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:product.detail]];
}
- (NSMutableArray *)productData {
    if (!_productData) {
        _productData = [NSMutableArray array];
    }
    return _productData;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 120)];
        footerView.backgroundColor = TABLEVIEW_COLOR;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 20, SCREENW, 20);
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = NV_TITLE_COLOR;
        label.text = @"已存在以上项目，是否继续创建？";
        label.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:label];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.frame = CGRectMake((SCREENW-240)/3.0, 60, 120, 40);
        cancelButton.backgroundColor = HTColorFromRGB(0xB1B5BD);
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        cancelButton.layer.masksToBounds = YES;
        cancelButton.layer.cornerRadius = 20;
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:cancelButton];
        
        UIButton *continueButton = [[UIButton alloc] init];
        continueButton.frame = CGRectMake(cancelButton.right+(SCREENW-240)/3.0, 60, 120, 40);
        continueButton.backgroundColor = BLUE_BG_COLOR;
        [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        continueButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        continueButton.layer.masksToBounds = YES;
        continueButton.layer.cornerRadius = 20;
        [continueButton setTitle:@"继续创建" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:continueButton];
        
        _footerView = footerView;
    }
    return _footerView;
}
- (UIView *)headerView {
    if (!_headerView) {
        CGFloat height = 44 + 12;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
        headerView.backgroundColor = TABLEVIEW_COLOR;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(17, 12, SCREENW-34, 32)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 4;
        view.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        view.layer.borderWidth = 1.0;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, SCREENW-34-20, 32)];
        textField.font = [UIFont systemFontOfSize:14];
        textField.placeholder = @"输入项目名称";
        [textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:textField];
        [headerView addSubview:view];
        textField.text = self.keyword;
        textField.userInteractionEnabled = NO;
        self.textField = textField;

        _headerView = headerView;
    }
    return _headerView;
}
@end
