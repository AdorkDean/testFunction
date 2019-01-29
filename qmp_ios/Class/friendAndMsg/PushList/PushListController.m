//
//  PushListController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PushListController.h"
#import "PushListCell.h"
#import "OneSquareListViewController.h"
#import "NewsWebViewController.h"
#import "WebViewController.h"
#import "OnlyContentController.h"
#import "BPMgrController.h"
#import "FriendApplyListController.h"
#import "EaseSDKHelper.h"
#import "ProductContactsController.h"


@interface PushListController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_listArr;
}
@property(nonatomic,strong)PushListCell *newsCell;
@end

@implementation PushListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.navTitleStr;
    
    _listArr = [NSMutableArray array];
    self.numPerPage = 20;
    self.currentPage = 1;

    [self addView];
    
    [self showHUD];
    [self requestData];
    
    [self refreshUnReadCount];

}

- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:@"PushListCell" bundle:nil] forCellReuseIdentifier:@"PushListCellID"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.view addSubview:self.tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }    
    NSDictionary *dic = @{@"page":@(self.currentPage),@"page_num":@(self.numPerPage)};
    [AppNetRequest getPushListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && resultData[@"list"]) {
            
            if (self.currentPage == 1) {
                [_listArr removeAllObjects];
            }
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:dic];
            }
            [_listArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
           
        }

    }];
    return YES;
}

- (void)refreshUnReadCount{
    NSString *type = @"新系统通知";
    NSString *key = @"system_notification_count";
    [AppNetRequest updateUnreadCountWithKey:key type:type completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
    
}

#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;
    }
 
    NSDictionary *dic = _listArr[indexPath.row];
    NSAttributedString *attStr = [dic[@"content"] stringWithParagraphlineSpeace:6 wordSpace:0.2 textColor:H5COLOR textFont:[UIFont systemFontOfSize:13 weight:UIFontWeightLight]];
    
    CGFloat height = [attStr boundingRectWithSize:CGSizeMake(SCREENW-34, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    if (height < 25) { //一行
        return 90;
    }else{
        return 107;
    }
    
    
    return [tableView fd_heightForCellWithIdentifier:@"PushListCellID" configuration:^(PushListCell *cell) {
        cell.dic = _listArr[indexPath.row];
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count ? _listArr.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    
    PushListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushListCellID" forIndexPath:indexPath];
    cell.dic = _listArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArr == 0) {
        return;
    }
    NSDictionary *dic = _listArr[indexPath.row];
    NSString *type = dic[@"send_type"];
    QMPLog(@"%@", type);
    if (type.integerValue == 1 && ![PublicTool isNull:dic[@"detail"]]) {  //机构
        [self enterJigouDetail:dic];
        
    }else if (type.integerValue == 2 && ![PublicTool isNull:dic[@"detail"]]) {  //项目
        [self enterCompanyDetail:dic];
        
    }
//    else if (type.integerValue == 3 && ![PublicTool isNull:dic[@"activity_id"]]) {  //动态推送

//    }
    else if (type.integerValue == 3 && ![PublicTool isNull:dic[@"url"]]) {  //url
        [self enterWebDetail:dic];
        
    }else if (type.integerValue == 4 && ![PublicTool isNull:dic[@"userfolderid"]]) {  //专辑
        
        [self enterSquareList:dic];
        
    }else if(type.integerValue == 5 && ![PublicTool isNull:dic[@"content"]]){ //纯内容
        [self enterOnlyContentVC:dic];
    }else if(type.integerValue == 6 && ![PublicTool isNull:dic[@"day_url"]]) { //日报
        [self enterRibao];
    }else if(type.integerValue == 7 && ![PublicTool isNull:dic[@"week_url"]]) { //日报
        [self enterZhouBao];
    }
    
    
}


- (void)enterOnlyContentVC:(NSDictionary*)dic{
    NSInteger content_type = [dic[@"content_type"] integerValue];
    if(content_type == 2 && ![PublicTool isNull:dic[@"person_id"]]){
        PersonModel *person = [[PersonModel alloc]init];
        person.personId = dic[@"person_id"];
        [PublicTool goPersonDetail:person];
        return;
    }else if(content_type == 3 && ![PublicTool isNull:dic[@"usercode"]]&& ![PublicTool isNull:dic[@"apply_id"]]){ //收到交换通知
        [self enterChatView:dic];
        return;
    }else if(content_type == 4){ // 委托联系成功
        [self enterProductContact];
        return;
    }else if ([dic[@"content"] containsString:@"您收到了一份BP"]) {
        [self enterMyBp];
        return;
    }else{
        OnlyContentController *onlyVC = [[OnlyContentController alloc]init];
        onlyVC.dic = dic;
        if ([_pushType isEqualToString:@"2"]) {
            onlyVC.navTitle = @"通知详情";
        }
        [self.navigationController pushViewController:onlyVC animated:YES];
    }
   
}

- (void)enterProductContact{
    ProductContactsController *cardVC = [[ProductContactsController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:cardVC animated:YES];
}

- (void)enterChatView:(NSDictionary*)dic{
    
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    NSMutableArray *aaa = [NSMutableArray array];
    for (EMConversation *conversation in conversations) {
        QMPLog(@"%@", conversation.conversationId);
        [aaa addObject:conversation.conversationId];
    }
    
    if (![aaa containsObject:dic[@"usercode"]]) {
        // 生成回话
        NSInteger changeType = [dic[@"apply_type"] integerValue];
        NSString *msg = changeType == 1 ? @"[交换电话]" : @"[交换微信]";
        NSString *type = changeType == 1 ? @"exphone1" : @"exwechat1";
        NSString *headUrl = [PublicTool isNull:dic[@"icon"]]?@"":dic[@"icon"];
        NSString *nickname = [PublicTool isNull:dic[@"nickname"]]?@"":dic[@"nickname"];
        EMMessage *message = [EaseSDKHelper getTextMessage:msg to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":headUrl,@"userNick":nickname,@"type":type,@"forme":@"1",@"aid":dic[@"apply_id"]}];
        message.from = dic[@"usercode"];
        message.to = [WechatUserInfo shared].usercode;
        message.conversationId = dic[@"usercode"];
        message.direction = EMMessageDirectionReceive;
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            
        } completion:^(EMMessage *message, EMError *error) {
            
        }];
    }
    
    [[AppPageSkipTool shared] appPageSkipToChatView:dic[@"usercode"]];
    
}

- (void)enterMyBp {
    BPMgrController *mybpVC = [[BPMgrController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:mybpVC animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mybpVC selectedIndexPage:1];
    });
}

- (void)enterFriendApply{
    FriendApplyListController *applyVC = [[FriendApplyListController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:applyVC animated:YES];
    
}

- (void)enterRibao{
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIXINWEN_BASE;
    VC.titleLabStr = @"融资日报";
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)enterZhouBao{
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIZHOUBAO_NEWS;
    VC.titleLabStr = @"融资周报";
    VC.hidesBottomBarWhenPushed = YES;//
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)enterSquareList:(NSDictionary*)dic{
    
    GroupModel *groupM = [[GroupModel alloc]initWithDictionary:dic error:nil];
    OneSquareListViewController *listVC = [[OneSquareListViewController alloc] init];
    listVC.groupModel = groupM;
    listVC.action = @"ManagerSquare";
    
    [self.navigationController pushViewController:listVC animated:YES];
}

- (void)enterWebDetail:(NSDictionary*)dic{
    
    URLModel *urlM = [[URLModel alloc]init];
    urlM.url = dic[@"url"];
    
    NewsWebViewController *webVC = [[NewsWebViewController alloc]initWithUrlModel:urlM];
    
    if (![PublicTool isNull:dic[@"detail"]] && ![PublicTool isNull:dic[@"product"]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dict setValue:dic[@"product"] forKey:@"company"];
        webVC.companyDic = dict;
        
    }
    
    [self.navigationController pushViewController:webVC animated:YES];
    [QMPEvent event:@"news_webpage_enter" label:@"新闻_推送"];
}


- (void)enterJigouDetail:(NSDictionary*)dic{
    NSString *detail = dic[@"detail"];
    NSDictionary *paramDic = [PublicTool toGetDictFromStr:detail];
    [[AppPageSkipTool shared] appPageSkipToJigouDetail:paramDic];
    
}
- (void)enterCompanyDetail:(NSDictionary*)dic{
    
    NSString *detail = dic[@"detail"];
    NSDictionary *paramDic = [PublicTool toGetDictFromStr:detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:paramDic];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

