//
//  TagEditController.m
//  qmp_ios
//
//  Created by QMP on 2017/8/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "TagEditController.h"
#import "QMPTagView.h"

@interface TagEditController ()
{
    
    NSMutableArray *_groupArr;
}
@property(nonatomic,assign)dispatch_semaphore_t semaphore;
@property(nonatomic,strong)QMPTagView *qmpTagView;
@property(nonatomic,strong)NSMutableDictionary *requetDict;

@property(nonatomic,strong)NSMutableArray *myTagItems;

@property(nonatomic,strong)NSMutableArray *myTagArr;


@end

@implementation TagEditController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[UIButton class]]) {
            [subV removeFromSuperview];
        }
    }
    [[IQKeyboardManager sharedManager] setEnable:YES];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加到专辑";
    _groupArr = [NSMutableArray array];
    [self requestWorkTag];
}


#pragma mark ----Request Data--
- (void)requestWorkTag{
    
    [self showHUD];

    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [mDict setValue:(self.productId?self.productId:@"") forKey:@"product_id"];
    [mDict setValue:(self.tableView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];
    
    [AppNetRequest getWorkTagByProductWithParameter:mDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && resultData[@"list"]) {
            NSMutableArray *workTagStrs = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                TagsItem *tagItem = [[TagsItem alloc]initWithDictionary:dic error:nil];
                [workTagStrs addObject:tagItem.tag];
            }
            self.editTagArr = workTagStrs;
        }
        [self requestAllMyTag];
    }];
    
}

- (void)requestAllMyTag{
    
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/workTagSelect" HTTPBody:self.requetDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
      
        [self hideHUD];

        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
           
            self.myTagArr = [NSMutableArray array];
            
            for (NSDictionary *dic in resultData) {
                TagsItem *tag = [[TagsItem alloc]initWithDictionary:dic error:nil];
                [self.myTagItems addObject:tag];
                [self.myTagArr addObject:tag.tag];
            }
            
            [self setUI];
        }
    }];

}


#pragma mark ----UI --
- (void)setUI{
    
    _qmpTagView = [[QMPTagView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_qmpTagView setEditArr:[NSMutableArray arrayWithArray:self.editTagArr] myTagArr:self.myTagArr];
    
    [self.view addSubview:_qmpTagView];
    
    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 47, 44)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];

}

#pragma mark -------Event-----
- (void)finishBtnClick{
    
    //
    if (_qmpTagView.searchString && _qmpTagView.searchString.length && ![_qmpTagView.tagtitleArr containsObject:_qmpTagView.searchString]) {
        [_qmpTagView.tagtitleArr addObject:_qmpTagView.searchString];

    }
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *tagIdArr = [NSMutableArray array];
    NSMutableArray *addTagitems = [NSMutableArray array];

    for (NSString *editStr in _qmpTagView.tagtitleArr) {
        if (![self.myTagArr containsObject:editStr]) {
            [arr addObject:editStr]; //把新建的专辑挑出来
        }else{
            for (TagsItem *item in self.myTagItems) {
                if ([item.tag isEqualToString:editStr]) {
                    [tagIdArr addObject:item.tag_id];
                    [addTagitems addObject:item];
                }
            }
        }
    }
    
    [PublicTool showHudWithView:KEYWindow];
    
    if (arr.count > 0) { //请求新建专辑
        
        self.semaphore = dispatch_semaphore_create(0);
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        [_groupArr addObject:group]; //保证group不会释放，存在可能group释放了，请求还未结束
        for (NSString *tagStr in arr) {
            dispatch_group_async(group, queue, ^{
                NSDictionary *dic = @{@"tag":tagStr};
                [AppNetRequest tagAddNewWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                    
                    if (resultData && resultData[@"tag_id"]) {
                        [tagIdArr addObject:resultData[@"tag_id"]];
                        TagsItem *tagItem = [[TagsItem alloc]init];
                        tagItem.tag = resultData[@"tag"];
                        tagItem.tag_id = resultData[@"tag_id"];
                        [addTagitems addObject:tagItem];

                    }
                    dispatch_semaphore_signal(self.semaphore);
                }];
            });
        }
        
        dispatch_group_notify(group, queue, ^{
            for (NSString *str in arr) {
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            }
            NSDictionary *dic = @{@"tagid_str":[tagIdArr componentsJoinedByString:@"|"],@"product_id":self.productId,@"flag":@"all"};
            [AppNetRequest addProductToWorkTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData) {
                    [PublicTool showMsg:@"加入成功"];
                    self.finishEdit(addTagitems);
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    [PublicTool showMsg:REQUEST_ERROR_TITLE];
                }
                
                [PublicTool dismissHud:KEYWindow];
            }];
           
        });
    }else if(arr.count == 0){ //都是已有的专辑 没有新建专辑
        
        //判断是否做了编辑
        if (self.editTagArr.count == _qmpTagView.tagtitleArr.count) {
            BOOL haveEdit = NO;
            for (int i = 0; i<self.editTagArr.count; i++) {
                NSString *oldStr = self.editTagArr[i];
                NSString *newStr = _qmpTagView.tagtitleArr[i];
                if (![_qmpTagView.tagtitleArr containsObject:oldStr] || ![self.editTagArr containsObject: newStr]) {
                    haveEdit = YES;
                }
            }
            
            if (haveEdit == NO) {
                [PublicTool dismissHud:KEYWindow];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
       
        
        NSDictionary *dic = @{@"tagid_str":[tagIdArr componentsJoinedByString:@"|"],@"product_id":self.productId,@"flag":@"all"};
        [AppNetRequest addProductToWorkTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData) {
                
                if (tagIdArr.count == 0) {
                    [PublicTool showMsg:@"操作成功"];

                }else{
                    [PublicTool showMsg:@"操作成功"];

                }
                self.finishEdit(addTagitems);
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [PublicTool showMsg:REQUEST_ERROR_TITLE];
            }
            
            [PublicTool dismissHud:KEYWindow];

        }];
    }

}


- (NSMutableDictionary *)requetDict{
    
    if (!_requetDict) {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        [mDict setValue:@"qmp_ios" forKey:@"ptype"];
        [mDict setValue:[NSString stringWithFormat:@"%@",VERSION] forKey:@"version"];
        
        NSString *unionid = [[NSUserDefaults standardUserDefaults] objectForKey:@"unionid"];
        [mDict setValue:[NSString stringWithFormat:@"%@",unionid] forKey:@"unionid"];
        [mDict setValue:[NSString stringWithFormat:@"%@",self.productId] forKey:@"product_id"];
        _requetDict = mDict;
    }
    return _requetDict;
}



- (NSMutableArray *)myTagItems{
    if (!_myTagItems) {
        _myTagItems = [NSMutableArray array];
    }
    return _myTagItems;
}

-(NSMutableArray *)myTagArr{
    if (!_myTagArr) {
        _myTagArr = [NSMutableArray array];
    }
    return _myTagArr;
}
@end
