//
//  WorkFlowToAlbumController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/2.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "WorkFlowToAlbumController.h"
#import "AlbumCell.h"
#import "ManagerAlertView.h"
#import "TagsItem.h"

@interface WorkFlowToAlbumController ()<UITableViewDelegate,UITableViewDataSource,ManagerAlertDelegate>

@property (strong, nonatomic) NSMutableArray *tagsMArr;
@property (strong, nonatomic) NSMutableArray *nameArr;

@property (strong, nonatomic) NSIndexPath *changeNameIndexPath;

@property (strong, nonatomic) ManagerHud *hudTool;

@end

@implementation WorkFlowToAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = [NSString stringWithFormat:@"已选%ld个项目导入至",self.companyIdArr.count];
    [self buildRightBarButtonItem];
    
    [self initTableView];
    
    [self showHUD];
    [self requsetGetTagList];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
   
    count = self.tagsMArr.count > 0 ? self.tagsMArr.count : 1;
    
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = self.tagsMArr.count > 0 ? 60.f : SCREENH - 113.f;
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tagsMArr.count == 0 ) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }else{
        
        NSString *groupCellIdentifier = @"AlbumsTableViewCell";
        AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
        if (!cell) {
            cell = [[nil loadNibNamed:@"AlbumCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        TagsItem *item  =  self.tagsMArr[indexPath.row];
        cell.item = item;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TagsItem *tag = self.tagsMArr[indexPath.row];
    tag.choosed = @(1-tag.choosed.integerValue);
    for (TagsItem *item in self.tagsMArr) {
        if (![item.tag_id isEqualToString:tag.tag_id]) {
            item.choosed = @(0);
        }
    }
    [tableView reloadData];
   
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10.f)];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


#pragma mark - ManagerAlertDelegate
//新建专辑 处于选中状态
- (void)createFolder:(TagsItem *)tag inId:(NSString *)userfolderid{
    [self.tagsMArr enumerateObjectsUsingBlock:^(TagsItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.choosed = @(0);
    }];
   
    tag.choosed = @(1);
    [self.tagsMArr insertObject:tag atIndex:0];
    [self.nameArr insertObject:tag.tag atIndex:0];
    [self.tableView reloadData];
}

- (void)changeName:(TagsItem *)tag{
    
    [self.tagsMArr replaceObjectAtIndex:self.changeNameIndexPath.row withObject:tag];
    [self.nameArr replaceObjectAtIndex:self.changeNameIndexPath.row withObject:tag.tag];
    
    [self.tableView reloadData];
    
}

- (void)pressCancleChangeName{
    
    self.tableView.editing = NO;
}


#pragma mark - 请求标签列表
- (void)requsetGetTagList{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagList" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *nameMArr = [[NSMutableArray alloc] initWithCapacity:0];

            if (resultData && [resultData isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *dataDict in resultData) {
                    TagsItem *items = [[TagsItem alloc] init];
                    [items setValuesForKeysWithDictionary:dataDict];
                    
                    if (![self.tag.tag_id isEqualToString:items.tag_id]) {
                        
                        [retMArr addObject:items];
                        [nameMArr addObject:items.tag];
                    }
                    
                }
                
                //不是搜索状态
                self.tagsMArr = retMArr;
                self.nameArr = nameMArr;
                
            }
            [self.tableView reloadData];

        }];

    }else{
        
        self.tagsMArr = nil;
        self.nameArr = nil;
        [self.tableView reloadData];
        [self hideHUD];
    }
}

#pragma mark - public
- (void)buildRightBarButtonItem{
    
    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBtn addTarget:self action:@selector(pressRightButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
   
}

//完成导入
- (void)pressRightButtonItem:(id)sender{
    NSString *tagid;
    for (TagsItem *item in self.tagsMArr) {
        if (item.choosed.integerValue == 1) {
            tagid = item.tag_id;
            break;
        }
    }
    if (!tagid || tagid.length == 0) {
        [PublicTool showMsg:@"请选择要导入的专辑"];
        return ;
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:[self.companyIdArr componentsJoinedByString:@"|"] forKey:@"product_id"];
    [dic setValue:tagid forKey:@"tag_id"];
    [PublicTool showHudWithView:KEYWindow];
    [AppNetRequest workflowToAlbumWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if ([resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:@"导入成功"];

            if (self.introductSuccess) {
                self.introductSuccess();
            }
            [self.navigationController popViewControllerAnimated:YES];

        }else{
            [PublicTool showMsg:@"导入失败,请稍后重试"];

        }

    }];
    
    
}

//新建专辑
- (void)addAlbumClick{
    if ( [TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        
        ManagerAlertView *alertView = [ManagerAlertView initFrame];
        alertView.nameArr = [NSMutableArray arrayWithArray:self.nameArr];
        [alertView initViewWithTitle:@"新建专辑"];
        alertView.delegata = self;
        alertView.currentVC = self;
        
        [KEYWindow addSubview:alertView];
    }
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *tableHeaderV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 68)];
    tableHeaderV.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *whiteV = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 48)];
    whiteV.backgroundColor = [UIColor whiteColor];
    [tableHeaderV addSubview:whiteV];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(17, 0, 96, whiteV.height)];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [addBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    [addBtn setTitle:@"新建专辑" forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"onework_add"] forState:UIControlStateNormal];
    [addBtn setTitleColor:HTColorFromRGB(0x1d1d1d) forState:UIControlStateNormal];
    [addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:10];
    [addBtn addTarget:self action:@selector(addAlbumClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteV addSubview:addBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addAlbumClick)];
    [tableHeaderV addGestureRecognizer:tap];
    self.tableView.tableHeaderView = tableHeaderV;
}


#pragma mark - 懒加载
- (NSMutableArray *)tagsMArr{
    
    if (!_tagsMArr) {
        _tagsMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tagsMArr;
}
- (NSMutableArray *)nameArr{
    
    if (!_nameArr) {
        _nameArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _nameArr;
}




@end
