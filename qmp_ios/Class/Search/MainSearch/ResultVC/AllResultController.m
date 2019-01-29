//
//  AllResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AllResultController.h"
#import "RegisterInfoViewController.h"

#import "SearchJigouCell.h"
#import "IPOCompanyCell.h"
#import "SearchPersonCell.h"
#import "SearchRegistCell.h"

#import "SearchJigouModel.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"
#import "PersonModel.h"
#import "CompanyInvestorsController.h"

#import "GetMd5Str.h"
#import <objc/runtime.h>
#import "CreateProController.h"

#import "CustomAlertView.h"

#import "SearchProduct.h"
#import "SearchProductCell.h"
#import "SearchOrganize.h"
#import "SearchOrganizeCell.h"
#import "SearchPerson.h"
#import "SearchNewsCell.h"
#import "NewsModel.h"

@interface AllResultController () <CustomAlertViewDelegate>
{
    UIView *_headerView;//吐槽 headerview
    NSString *_resultCount;
    NSString * _registCount;
    NSString * _jigouCount;
    NSString * _productCount;
    NSString * _personCount;
    NSString * _newsCount;
    NSMutableArray *_sectionTitles;
}


@property (nonatomic, strong) NSMutableArray *companysModelMArr;  //存公司model
@property (nonatomic, strong) NSMutableArray *jigousModelMArr;  //存机构model
@property (nonatomic, strong) NSMutableArray *personModelMArr;   //人物model
@property (nonatomic, strong) NSMutableArray *registModelMArr;   //工商model
@property (nonatomic, strong) NSMutableArray *newsModelMArr;   //工商model

@property (strong, nonatomic) NSURLSessionDataTask *task;//当前页面只有一个搜索请求在进行
@property (strong, nonatomic) AlertInfo *alertTool;
@property (strong, nonatomic) AlertInfo *alertInfoTool;
@property (strong, nonatomic) UIView *tableHeaderView;

@end

@implementation AllResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _resultCount = @"";
    [self initTableView];
}

#pragma mark - 请求搜索
- (BOOL)requestData {
    if (![TestNetWorkReached networkIsReached:self]) {
        return NO;
    }
        
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [self showHUD];
    [dic setValue:@"" forKey:@"type"];

    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        _resultCount = @"";
        self.feedbackBtn.selected = NO;
        self.feedbackBtn.userInteractionEnabled = YES;
        
        [self.registModelMArr removeAllObjects];
        [self.personModelMArr removeAllObjects];
        [self.jigousModelMArr removeAllObjects];
        [self.companysModelMArr removeAllObjects];
        [self.newsModelMArr removeAllObjects];

        [_sectionTitles removeAllObjects];
        _resultCount = @"0";
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            self.tableView.backgroundColor = TABLEVIEW_COLOR;
            
            NSArray *order = resultData[@"order"];
            
            NSDictionary *dataMDict = resultData;
            
            // product
            NSString *count = dataMDict[@"product"][@"count"];
            _resultCount = [NSString stringWithFormat:@"%ld",_resultCount.integerValue + count.integerValue];

            _productCount = dataMDict[@"product"][@"count"];
            
            NSMutableArray *tmpProducts = [[NSMutableArray alloc] init];
            for (NSDictionary *resDict in dataMDict[@"product"][@"list"]) {
                SearchProduct *product = [[SearchProduct alloc] init];
                [product setValuesForKeysWithDictionary:resDict];
                [tmpProducts addObject:product];
            }
            self.companysModelMArr = tmpProducts;
                  
            //jigous            
            NSString *jigouCount = dataMDict[@"institution"][@"count"];
            _resultCount = [NSString stringWithFormat:@"%ld",_resultCount.integerValue + jigouCount.integerValue];

            _jigouCount = dataMDict[@"institution"][@"count"];
           
            NSMutableArray *tmpOrganizes = [NSMutableArray array];
            for (NSDictionary *resDict in dataMDict[@"institution"][@"list"]) {
                SearchOrganize *organize = [[SearchOrganize alloc] init];
                [organize setValuesForKeysWithDictionary:resDict];
                [tmpOrganizes addObject:organize];
            }
            self.jigousModelMArr = tmpOrganizes;
            
            
            //persons
            NSString *personCount = dataMDict[@"person"][@"count"];
            _resultCount = [NSString stringWithFormat:@"%ld",_resultCount.integerValue + personCount.integerValue];

            _personCount = dataMDict[@"person"][@"count"];
            NSMutableArray *tmpPersons = [[NSMutableArray alloc] init];
            for (NSDictionary *resDict in dataMDict[@"person"][@"list"]) {
                SearchPerson *person = [[SearchPerson alloc] initWithDictionary:resDict error:nil];
                [tmpPersons addObject:person];
            }
            self.personModelMArr = tmpPersons;
            
            //工商
            if (dataMDict[@"company"] && dataMDict[@"company"][@"list"]) {
                if (self.currentPage == 1) {
                    _registCount = dataMDict[@"company"][@"count"];
                }
                
                for (NSDictionary *dic in dataMDict[@"company"][@"list"]) {
                    SearchProRegisterModel *registM = [[SearchProRegisterModel alloc]initWithDictionary:dic error:nil];
                    [self.registModelMArr addObject:registM];
                }
            }
            //新闻
            if (dataMDict[@"news"] && dataMDict[@"news"][@"list"]) {
                if (self.currentPage == 1) {
                    _newsCount = dataMDict[@"news"][@"count"];
                }
                
                for (NSDictionary *dic in dataMDict[@"news"][@"list"]) {
                    NewsModel *registM = [[NewsModel alloc]initWithDictionary:dic error:nil];
                    if (registM.title.length > 60) {
                        registM.title = [registM.title substringToIndex:60];
                        registM.title = [registM.title stringByAppendingString:@"..."];
                    }
                    [self.newsModelMArr addObject:registM];
                }
            }
            _sectionTitles = [NSMutableArray array];
            if (!order) {
                order = @[@"product",@"person",@"institution"];
            }
            for (NSString *section in order) {
                if ([section isEqualToString:@"product"]) {
                    if (self.companysModelMArr.count) {
                        [_sectionTitles addObject:@"项目"];
                    }
                } else if ([section isEqualToString:@"person"]) {
                    if (self.personModelMArr.count) {
                        [_sectionTitles addObject:@"人物"];
                    }
                } else if ([section isEqualToString:@"institution"]) {
                    if (self.jigousModelMArr.count) {
                        [_sectionTitles addObject:@"机构"];
                    }
                }
            }
            if (self.newsModelMArr.count) {
                [_sectionTitles addObject:@"新闻"];
                _resultCount = [NSString stringWithFormat:@"%ld",_resultCount.integerValue + _newsCount.integerValue];
            }
            if (self.registModelMArr.count) {
                [_sectionTitles addObject:@"公司"];
                _resultCount = [NSString stringWithFormat:@"%ld",_resultCount.integerValue + _registCount.integerValue];
            }
            
        }
        
        [self initTableHeaderView];
        [self refreshFooter:@[]];
        [self.tableView reloadData];
        
    }];
    
    
    return YES;
}


- (void)initTableHeaderView {
    
    self.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];//表头
    self.tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    //    [self.tableHeaderView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"共%@条结果",_resultCount.integerValue>200?@"200+":_resultCount];
    headerLab.text = headerStr;
    [self.tableHeaderView addSubview:headerLab];
    
    UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
    baiduBtn.tag = 100;
    [baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [baiduBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [baiduBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
    [baiduBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [baiduBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeaderView addSubview:baiduBtn];
    baiduBtn.tag = 1999;
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.feedbackBtn.frame = CGRectMake(SCREENW-50-17,0, 50, 45);
    self.feedbackBtn.tag = 100;
    [self.feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeaderView addSubview:self.feedbackBtn];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}
#pragma mark - EVENT

- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有项目",@"有人物",@"有机构", nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}



#pragma mark - UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 && self.personModelMArr.count == 0&& self.registModelMArr.count == 0&& self.newsModelMArr.count == 0) { //没有数据(用户没输入或输入了但没有找到相应数据)
        return [[UIView alloc]init];
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    
    //添加表头 提示文字
    if (self.companysModelMArr.count>0||self.jigousModelMArr.count>0 || self.personModelMArr.count>0 || self.registModelMArr.count>0 || self.newsModelMArr.count>0) {
        
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];//表头
        _headerView.backgroundColor = [UIColor whiteColor];
        [_headerView addSubview:line];
        
        UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
        headerLab.backgroundColor = [UIColor clearColor];
        [_headerView addSubview:headerLab];
        headerLab.font = [UIFont systemFontOfSize:14];
        headerLab.textColor = H9COLOR;
        
        NSString *headerStr = nil;
        
        
        NSString *sectionTitle = _sectionTitles[section];
        if ([sectionTitle isEqualToString:@"机构"]) {
            headerStr = [NSString stringWithFormat:@"机构(%@)",_jigouCount.integerValue > 200 ? @"200+":_jigouCount];
        }else if ([sectionTitle isEqualToString:@"项目"]) {
            headerStr = [NSString stringWithFormat:@"项目(%@)",_productCount.integerValue > 200 ? @"200+":_productCount];
        }else if ([sectionTitle isEqualToString:@"人物"]) {
            headerStr = [NSString stringWithFormat:@"人物(%@)",_personCount.integerValue > 200 ? @"200+":_personCount];
        }else if ([sectionTitle isEqualToString:@"公司"]) {
            headerStr = [NSString stringWithFormat:@"公司(%@)",_registCount.integerValue > 20 ? @"20":_registCount];
        }else if ([sectionTitle isEqualToString:@"新闻"]) {
            headerStr = [NSString stringWithFormat:@"新闻(%@)",_newsCount];
        }
        
        headerLab.text = headerStr;
        headerLab.font = [UIFont systemFontOfSize:14];
        
        headerLab.text = headerStr;
        
        return _headerView;
    }
    return nil;
        
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (_sectionTitles.count > 0) {
        NSString *sectionTitle = _sectionTitles[section];
        if ([sectionTitle isEqualToString:@"机构"]) {
            return ( _jigouCount.integerValue > 3) ? 55:10.0;
        }else if ([sectionTitle isEqualToString:@"项目"]) {
            return (_productCount.integerValue > 3) ? 55:10.0;
        }else if ([sectionTitle isEqualToString:@"人物"]) {
            return (_personCount.integerValue > 3) ? 55:10.0;
        }else if ([sectionTitle isEqualToString:@"公司"]) {
            return (_registCount.integerValue > 3) ? 55:10.0;
        }else if ([sectionTitle isEqualToString:@"新闻"]) {
            return (_newsCount.integerValue > 3) ? 55:10.0;
        }
        return 10.0;
    }else{
        return 0.1;
    }
   
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_sectionTitles.count == 0) {
        return [[UIView alloc]init];
    }
    
    NSString *sectionTitle = _sectionTitles[section];
    if ([sectionTitle isEqualToString:@"机构"]) {
        if (_jigouCount.integerValue > 3) {
            UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
            footV.backgroundColor = TABLEVIEW_COLOR;
            UIButton *allBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
            allBtn.backgroundColor = [UIColor whiteColor];
            [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
            [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            allBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [footV addSubview:allBtn];
            [allBtn addTarget:self action:@selector(enterAllJigou) forControlEvents:UIControlEventTouchUpInside];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footV addSubview:line];
            return footV;
        }else{
            return [[UIView alloc]init];
            
        }
        
    }else if ([sectionTitle isEqualToString:@"项目"]) {
        if (_productCount.integerValue > 3) {
            UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
            footV.backgroundColor = TABLEVIEW_COLOR;
            UIButton *allBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
            allBtn.backgroundColor = [UIColor whiteColor];
            [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
            [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            allBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [footV addSubview:allBtn];
            
            [allBtn addTarget:self action:@selector(enterAllCompany) forControlEvents:UIControlEventTouchUpInside];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footV addSubview:line];
            return footV;
            
        }else{
            return [[UIView alloc]init];

        }
    }else if ([sectionTitle isEqualToString:@"人物"]) {
        if (_personCount.integerValue > 3) {
            UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
            footV.backgroundColor = TABLEVIEW_COLOR;
            UIButton *allBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
            allBtn.backgroundColor = [UIColor whiteColor];
            [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
            [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            allBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [footV addSubview:allBtn];
            [allBtn addTarget:self action:@selector(enterAllPerson) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footV addSubview:line];
            return footV;
        }else{
            return [[UIView alloc]init];
            
        }
    }else if ([sectionTitle isEqualToString:@"公司"]) {
        if (_registCount.integerValue > 3) {
            UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
            footV.backgroundColor = TABLEVIEW_COLOR;
            UIButton *allBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
            allBtn.backgroundColor = [UIColor whiteColor];
            [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
            [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            allBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [footV addSubview:allBtn];
            [allBtn addTarget:self action:@selector(enterAllRegister) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footV addSubview:line];
            return footV;
        }else{
            return [[UIView alloc]init];
            
        }
    }else if ([sectionTitle isEqualToString:@"新闻"]) {
        if (_newsCount.integerValue > 3) {
            UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
            footV.backgroundColor = TABLEVIEW_COLOR;
            UIButton *allBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
            allBtn.backgroundColor = [UIColor whiteColor];
            [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
            [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            allBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [footV addSubview:allBtn];
            [allBtn addTarget:self action:@selector(enterAllNews) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [footV addSubview:line];
            return footV;
        }else{
            return [[UIView alloc]init];
            
        }
    }
    return [[UIView alloc]init];
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
   if(self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 && self.personModelMArr.count == 0 && self.registModelMArr.count==0&& self.newsModelMArr.count == 0) { //没有数据(用户没输入或输入了但没有找到相应数据)
        return 0.1f;
    }else{
        return 45;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 && self.personModelMArr.count == 0 && self.registModelMArr.count == 0&& self.newsModelMArr.count == 0) { //没有数据(用户没输入或输入了但没有找到相应数据)
        return 1;
    }else{
        return _sectionTitles.count;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 && self.personModelMArr.count == 0&& self.registModelMArr.count == 0&& self.newsModelMArr.count == 0) {
        //没有数据(用户没输入或输入了但没有找到相应数据) notfoundcell
        [[self.tableHeaderView viewWithTag:1999] setHidden:YES];
        return 1;
        
    }else{
        [[self.tableHeaderView viewWithTag:1999] setHidden:NO];

        NSString *sectionTitle = _sectionTitles[section];
        if ([sectionTitle isEqualToString:@"机构"]) {
            return (_jigouCount.integerValue > 3) ? 3:self.jigousModelMArr.count;
        }else if ([sectionTitle isEqualToString:@"项目"]) {
            return ( _productCount.integerValue > 3) ? 3:self.companysModelMArr.count;
        }else if ([sectionTitle isEqualToString:@"人物"]) {
            return self.personModelMArr.count > 3 ? 3 : self.personModelMArr.count;
        }else if ([sectionTitle isEqualToString:@"公司"]) {
            return self.registModelMArr.count > 3 ? 3 : self.registModelMArr.count;
        }else if ([sectionTitle isEqualToString:@"新闻"]) {
            return self.newsModelMArr.count > 3 ? 3 : self.newsModelMArr.count;
        }
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 &&self.personModelMArr.count == 0 && self.registModelMArr.count == 0 && self.newsModelMArr.count == 0 &&  indexPath.section == 0) {
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }else{
        NSString *sectionTitle = _sectionTitles[indexPath.section];
        if ([sectionTitle isEqualToString:@"项目"]) {
            SearchProduct *product = self.companysModelMArr[indexPath.row];
            if ([product needShowReason]) {
                return 93;
            }
            return 76;
            
        } else if ([sectionTitle containsString:@"人物"]) {
            SearchPerson *person = self.personModelMArr[indexPath.row];
            if ([person needShowReason]) {
                return 96;
            }
            return 81;
        } else if ([sectionTitle containsString:@"机构"]) {
            SearchOrganize *organize = self.jigousModelMArr[indexPath.row];
            if ([organize needShowReason]) {
                return 93;
            }
            return 76;
        }else if ([sectionTitle containsString:@"公司"]) {
//            SearchProRegisterModel *regist = self.registModelMArr[indexPath.row];
            return 99;
        }else if ([sectionTitle containsString:@"新闻"]) {
            NewsModel *news = self.newsModelMArr[indexPath.row];
            return [tableView fd_heightForCellWithIdentifier:@"SearchNewsCellID" configuration:^(SearchNewsCell *cell) {
                cell.newsModel = news;
            }];
        }
        return 77;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     if(_sectionTitles.count){
        NSString *sectionTitle = _sectionTitles[indexPath.section];
        if ([sectionTitle isEqualToString:@"机构"]) {

            SearchOrganizeCell *cell = [SearchOrganizeCell searchOrganizeCellWithTableView:tableView];
            cell.organize = self.jigousModelMArr[indexPath.row];
            cell.bottomLineView.hidden = indexPath.row + 1 == self.jigousModelMArr.count;
            cell.iconLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if ([sectionTitle isEqualToString:@"项目"]) {

            SearchProductCell *cell = [SearchProductCell searchProductCellWithTableView:tableView];
            SearchProduct *model = self.companysModelMArr[indexPath.row];
            cell.product = model;
            cell.bottonLineView.hidden = indexPath.row+1 == self.companysModelMArr.count;
            cell.iconLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if ([sectionTitle isEqualToString:@"人物"]) {
            static NSString *ID2 = @"SearchPersonCellID";

            SearchPersonCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID2];
            if (!cell) {
                cell = (SearchPersonCell*)[nilloadNibNamed:@"SearchPersonCell" owner:nil options:nil].lastObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
//            PersonModel * model = self.personModelMArr[indexPath.row];
            SearchPerson *person = self.personModelMArr[indexPath.row];
            cell.person2 = person;
            cell.nametitColor = RANDOM_COLORARR[indexPath.row%6];
            cell.bottomLine.hidden = indexPath.row+1 == self.personModelMArr.count;
            cell.claimBtn.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if ([sectionTitle isEqualToString:@"公司"]) {
            NSArray *color = @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)];
            SearchRegistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRegistCellID" forIndexPath:indexPath];
            cell.keyWord = self.keyword;
            cell.registModel = self.registModelMArr[indexPath.row];
            
            cell.nameIconColor = color[indexPath.row % 6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if ([sectionTitle isEqualToString:@"新闻"]) {
            SearchNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchNewsCellID" forIndexPath:indexPath];
            NewsModel *newsModel = self.newsModelMArr[indexPath.row];
            cell.keyword = self.keyword;
            cell.newsModel = newsModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSInteger lastCell = self.dataArr.count-1;
            if (indexPath.row == lastCell) {
                cell.bottomLine.hidden = YES;
            }else{
                cell.bottomLine.hidden = NO;
            }
            //长按复制
            UILongPressGestureRecognizer *longNews = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressJianjieLbl:)];
            [cell.titleLbl addGestureRecognizer:longNews];
            return cell;
        }
    }
    

    NSString *title = REQUEST_DATA_NULL;
    HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
    [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
    cell.createBtn.hidden = NO;
    [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
    return cell;

}

/**
 长按新闻复制
 
 @param longPress
 */
- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片",lbl.text];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    if ([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]) {return;}
    

    //判断indexPath得cell是不是SearchJigouCell
    if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchOrganizeCell class]) {
        if (indexPath.row >= self.jigousModelMArr.count) {
            return;
        }
        SearchJigouModel * model = self.jigousModelMArr[indexPath.row];
        NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
        [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDict];
        [QMPEvent event:@"mainsearch_resultcell_click" label:@"机构点击详情"];
        
    }else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchProductCell class]){
        if (indexPath.row >= self.companysModelMArr.count) {
            return;
        }
        SearchCompanyModel * model = self.companysModelMArr[indexPath.row];
        
        NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
        [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
        [QMPEvent event:@"mainsearch_resultcell_click" label:@"项目点击详情"];

    }else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchPersonCell class]){
        if (indexPath.row >= self.personModelMArr.count) {
            return;
        }
        PersonModel* person = self.personModelMArr[indexPath.row];
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:person.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row % 6]];
        [QMPEvent event:@"mainsearch_resultcell_click" label:@"人物点击详情"];

    }else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchRegistCell class]){
        if (indexPath.row >= self.registModelMArr.count) {
            return;
        }
        SearchProRegisterModel * model = self.registModelMArr[indexPath.row];
        
        NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
        RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:urlDict];
        [mdic removeObjectForKey:@"id"];
        [mdic removeObjectForKey:@"p"];
        registerDetailVC.urlDict = mdic;
        registerDetailVC.companyName = model.company;
        [self.navigationController pushViewController:registerDetailVC animated:YES];
        [QMPEvent event:@"mainsearch_resultcell_click" label:@"公司点击详情"];
        return;
    }else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchNewsCell class]){
        if (indexPath.row >= self.newsModelMArr.count) {
            return;
        }
        NewsModel *urlItem = self.newsModelMArr[indexPath.row];
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.urlId = urlItem.news_id;
        urlModel.url = urlItem.news_detail?urlItem.news_detail:urlItem.link;
        
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"recommand"];
        webView.cellId = indexPath.row;
        [self.navigationController pushViewController:webView animated:YES];
        [QMPEvent event:@"mainsearch_resultcell_click" label:@"新闻点击详情"];
        [QMPEvent event:@"news_webpage_enter" label:@"新闻_搜索"];

    }
    [QMPEvent event:@"search_allResult_tabClick"];
    
}

- (void)initTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchRegistCell" bundle:nil] forCellReuseIdentifier:@"SearchRegistCellID"];
    [self.tableView registerClass:[SearchNewsCell class] forCellReuseIdentifier:@"SearchNewsCellID"];

}

#pragma mark - Event
- (void)enterAllJigou {
    if (self.clickAllJigou) {
        self.clickAllJigou();
    }
}
- (void)enterAllCompany {
    if (self.clickAllProduct) {
        self.clickAllProduct();
    }
}
- (void)enterAllPerson {
    if (self.clickAllPerson) {
        self.clickAllPerson();
    }
}
- (void)enterAllRegister {
    if (self.clickAllRegist) {
        self.clickAllRegist();
    }
}
- (void)enterAllNews{
    if (self.clickAllNews) {
        self.clickAllNews();
    }
}


#pragma mark - Getter
- (NSMutableArray *)companysModelMArr {
    if (!_companysModelMArr) {
        _companysModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _companysModelMArr;
}
- (NSMutableArray *)jigousModelMArr {
    if (!_jigousModelMArr) {
        _jigousModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _jigousModelMArr;
}
- (NSMutableArray *)personModelMArr {
    if (!_personModelMArr) {
        _personModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _personModelMArr;
}
- (NSMutableArray *)registModelMArr {
    if (!_registModelMArr) {
        _registModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _registModelMArr;
}
- (NSMutableArray *)newsModelMArr {
    if (!_newsModelMArr) {
        _newsModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _newsModelMArr;
}

@end
