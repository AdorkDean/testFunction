//
//  SearchProductViewController.m
//  qmp_ios
//
//  Created by Molly on 16/8/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "SearchProductViewController.h"
#import "ProductListTableViewCell.h"
#import "AddSearchJigouCell.h"
 
#import "GetMd5Str.h"
#import "GetNowTime.h"
#import <IQKeyboardManager.h>
 #import <objc/runtime.h>
#import "TestNetWorkReached.h"

@interface SearchProductViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITextField *_searchTf;
    BOOL _firstEnter;
}
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLab;

@property (strong, nonatomic) NSArray *productArr;
@property (copy, nonatomic) NSString *action;

@property (strong, nonatomic) GetNowTime *timeTool;

@property (copy, nonatomic) NSString *oldSearchStr;
@property (copy, nonatomic) NSString *firstSearchStr;


@end

@implementation SearchProductViewController

- (instancetype)initWithAction:(NSString *)action{
    
    self = [[SearchProductViewController alloc] init];
    if (self) {
        self.action = action;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _firstEnter = YES;
    _firstSearchStr = @"";
    _oldSearchStr  = @"";
    [self buildRightBarButtonItem];
    [self initHeaderView];
    [self initTableView];
    [self keyboardManager];

}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    
    if (([self.action isEqualToString:@"CollectCompanyListViewController"] || [self.action isEqualToString:@"OneWorkFlowViewController"]) && self.hasProductidMArr.count > 0) {
        [self changeTableviewFrame:self.productArr];
        [self.tableView reloadData];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_firstEnter) {
        [_searchTf becomeFirstResponder];
        _firstEnter = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [_searchTf resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([PublicTool isNull:_searchTf.text]) {
        return 0;
    }
    if([self.action isEqualToString:@"OneWorkFlowViewController"] || [self.action isEqualToString:@"CollectCompanyListViewController"]){
    
        if (self.productArr && self.productArr.count > 0) {
            return self.productArr.count;
        }
    }
   
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self.action isEqualToString:@"OneWorkFlowViewController"] || [self.action isEqualToString:@"CollectCompanyListViewController"]){
        
        if (self.productArr && self.productArr.count > 0) {
            return 65.f;
        }
    }

    return SCREENH - kScreenTopHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if([self.action isEqualToString:@"OneWorkFlowViewController"] || [self.action isEqualToString:@"CollectCompanyListViewController"]){
        
        if (self.productArr && self.productArr.count > 0) {
            NSString *cellIdentifier = @"ProductListTableViewCell";
            ProductListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell) {
                cell = [[ProductListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            SearchCompanyModel *productModel = self.productArr[indexPath.row];
            [cell refreshUI:productModel];
            
           
            if ([self.hasProductidMArr containsObject:productModel.productId]) {
                cell.addBtn.hidden = YES;
                cell.hasAddedBtn.hidden = NO;
            }
            else{
                cell.addBtn.hidden = NO;
                cell.hasAddedBtn.hidden = YES;
            }
            
            objc_setAssociatedObject(cell.addBtn, "addProduct", cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.addBtn addTarget:self action:@selector(pressAddProductBtn:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else{
            NSString *title = REQUEST_SEARCH_NULL;
            return [self nodataCellWithInfo:title tableView:tableView];
        }
    }
    
     return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}

    
    if (self.productArr && self.productArr.count > 0) {
        ProductListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
        if ([self.action isEqualToString:@"OneWorkFlowViewController"]) {
            //添加产品
            [self requestAddToWorkflow:cell];
            
        }else if([self.action isEqualToString:@"CollectCompanyListViewController"]){
            //添加产品
            [self requestAddToGroupOnCell:cell];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchTf resignFirstResponder];
    
}

- (void)textFieldDidChange:(UITextField*)tf{
    
    NSString *searchText = _searchTf.text;
    
    if ([PublicTool isNull:searchText]) {
        
        self.productArr = nil;
        [self changeTableviewFrame:self.productArr];
        [self.tableView reloadData];
    }else{
        _firstSearchStr = searchText;
        [self requestSearchProduct];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *searchText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (searchText.length == 0) {
        return NO; //搜索内容为空
    }
    [self requestSearchProduct];

    return YES;
    
}


#pragma mark - 请求添加到分组
- (void)requestAddToGroupOnCell:(ProductListTableViewCell *)cell{
    
    if (cell.hasAddedBtn.hidden) {
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagAddTagToProduct" HTTPBody:@{@"tagid_str":self.groupId,@"productId":cell.model.productId,@"flag":@"all"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData) {
                [self requestAddSuccess:cell.model.productId];
                
                cell.addBtn.hidden = YES;
                cell.hasAddedBtn.hidden = NO;
            }else{
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"添加失败"];
            }
        }];
    }
}

#pragma mark - 请求添加到某个工作流
- (void)requestAddToWorkflow:(ProductListTableViewCell *)cell{
    
    NSString *productid = cell.model.productId;
    if ([self.hasProductidMArr containsObject:productid]) {
        return;
    }else{
        [self.hasProductidMArr addObject:productid];
        cell.addBtn.hidden = YES;
        cell.hasAddedBtn.hidden = NO;

        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [mDict setValue:cell.model.productId forKey:@"productId"];
        [mDict setValue:self.groupId forKey:@"work_flow"];
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workflowAddProduct" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
          
            if (resultData && [resultData isKindOfClass:[NSString class]]) {
                NSString *data = resultData;
                if([data isEqualToString:@"already"] ||[data isEqualToString:@"success"]){
                    //添加成功
                    if ([self.delegate respondsToSelector:@selector(addProduct:)]) {
                        [self.delegate addProduct:cell.model];
                    }
                }else{
                    
                    //已经在其他工作流中, 进行提示
                    NSDictionary *workflowDict = @{@"1":@"感兴趣", @"2":@"跟进中", @"3":@"已投资", @"4":@"未投",@"5":@"回收站" , @"7":@"上会" , @"9":@"放弃"};
                    
                    NSDictionary *modelDict = @{@"company_id":cell.model.productId,@"status":workflowDict[data]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeOneProductWorkFlow" object:modelDict];
                    if ([self.delegate respondsToSelector:@selector(addProduct:)]) {
                        [self.delegate addProduct:cell.model];
                    }
                    [self.hasProductidMArr removeObject:productid];
                    
                }
                
            }else{
                [self.hasProductidMArr removeObject:productid];
                
            }
        }];
    }
    
}

#pragma mark - 请求搜索
// 
- (void)requestSearchProduct{
    
    NSString *searchStr = _searchTf.text;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        NSMutableArray *productMArr = [NSMutableArray array];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
           
            NSArray *companyArr = [resultData objectForKey:@"list"];
            
            for (NSDictionary *companyDict in companyArr) {
                SearchCompanyModel *companyModel = [[SearchCompanyModel alloc] init];
                
                [companyModel setValuesForKeysWithDictionary:companyDict];
                [productMArr addObject:companyModel];
            }
        }
        
        self.productArr = productMArr;
        [self changeTableviewFrame:productMArr];
        [self.tableView reloadData];
    }];
}

#pragma mark - public
- (void)initHeaderView{
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];//表头
    _headerLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 150, 30)];
    _headerLab.backgroundColor = [UIColor clearColor];
//    _feedBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 100 - 8, 15, 100, 30)];
//    
//    [_feedBackBtn setTitle:@"没有我想要的" forState:UIControlStateNormal];
//    [_feedBackBtn setTitle:@"已收到您的反馈" forState:UIControlStateSelected];
//    
//    [_feedBackBtn addTarget:self action:@selector(immediateFeedbackUs:) forControlEvents:UIControlEventTouchUpInside];
//    [_feedBackBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];//RGBa(218, 10, 22, 1)
//    [_feedBackBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
//    _feedBackBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
//    [_headerView addSubview:_feedBackBtn];
    [_headerView addSubview:_headerLab];
}

- (void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 50.f) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)buildRightBarButtonItem{
    
    self.navigationItem.leftBarButtonItems = nil;
    UIButton *cancelbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    cancelbtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelbtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelbtn];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW - 78, 44)];
    
    _searchTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, view.width, 29)];
    _searchTf.backgroundColor = HTColorFromRGB(0xf1f1f1);
    UIImageView *leftImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, _searchTf.frame.size.height)];
    leftImg.image = [BundleTool imageNamed:@"search"];
    leftImg.contentMode = UIViewContentModeCenter;
    _searchTf.returnKeyType = UIReturnKeySearch;
    _searchTf.leftView = leftImg;
    _searchTf.leftViewMode = UITextFieldViewModeAlways;
    _searchTf.placeholder = [self.action isEqualToString:@"OrganizeWorkFlow"]?@"搜索机构":@"搜索项目";
    _searchTf.layer.masksToBounds = YES;
    _searchTf.layer.cornerRadius = 4;
    _searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:_searchTf];
    _searchTf.delegate = self;
    _searchTf.font = [UIFont systemFontOfSize:14];
    _searchTf.centerY = view.centerY;
    [_searchTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    _searchTf.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
//    [_searchTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
}
- (void)popViewController{
    [_searchTf resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)keyboardManager{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap{
    
    if (tap.view != _searchTf) {
        [_searchTf resignFirstResponder];
    }
}

- (void)changeTableviewFrame:(NSArray *)mArr{
    
    CGRect frame = self.tableView.frame;
    CGFloat y = 0.f;
    
    if (mArr.count > 0) {
        
        _headerLab.textColor = [UIColor grayColor];
        NSString *numStr = [NSString stringWithFormat:@"%lu",(unsigned long)mArr.count];
        NSString *headerStr = [NSString stringWithFormat:@"共 %@ 个结果",numStr];
        NSRange range = {2,numStr.length};
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:headerStr];
        [str addAttribute:NSForegroundColorAttributeName value:RED_TEXTCOLOR range:range];
        _headerLab.attributedText = str;
        _headerLab.font = [UIFont systemFontOfSize:14];
        _headerView.layer.borderWidth = 0.5;
        _headerView.layer.borderColor = RGBLineGray.CGColor;
        [self.view addSubview:_headerView];
        
        y = _headerView.frame.size.height;
    }
    else{
        
        if ([_headerView isDescendantOfView:self.view]) {
            [_headerView removeFromSuperview];
        }
    }
    
    frame.origin.y = y;
    self.tableView.frame = frame;
}

- (void)requestAddSuccess:(NSString *)productId{
    
    [ShowInfo showInfoOnView:self.view withInfo:@"添加成功"];
    [self addProductSuccessAndHandelDelegate:productId];
}

- (void)pressAddProductBtn:(UIButton *)sender{
    
    UITableViewCell * cell = (UITableViewCell *)objc_getAssociatedObject(sender, "addProduct");

    
    if([self.action isEqualToString:@"CollectCompanyListViewController"]){
        //某个标签里添加产品
        [self requestAddToGroupOnCell:(ProductListTableViewCell*)cell];
    }
    
    if ([self.action isEqualToString:@"OneWorkFlowViewController"]) {
        //添加产品
        [self requestAddToWorkflow:(ProductListTableViewCell*)cell];
        
    }
   
}



#pragma mark - Delegete
-(void)addProductSuccessAndHandelDelegate:(NSString *)productId{

    [self.hasProductidMArr addObject:productId];
    [self.tableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(addSuccess)]) {
        
        [self.delegate addSuccess];
    }

}

#pragma mark - 懒加载
- (GetNowTime *)timeTool{

    if (!_timeTool) {
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}

@end
