/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */
#import "ConversationListController.h"

#import "ChatViewController.h"
#import "RobotManager.h"
#import "RobotChatViewController.h"
#import "ChatHelper.h"
#import "PushHeaderView.h"
#import "PushListController.h"
#import "ManagerHud.h"
#import "ActivityNotifiListController.h"
#import "CardExchangeListController.h"

@implementation EMConversation (search)

@end

@interface ConversationListController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource>
{
    PushHeaderView *_headerView; //推送消息
    NSInteger _finishCount;
    ManagerHud *_hudTool;
}
@property (nonatomic, strong) UIView *networkStateView;

@end

@implementation ConversationListController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadDataNofi];
    [self setNavigationBar];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([ToLogin isLogin] && ![EMClient sharedClient].isLoggedIn) {
        [[ChatHelper shareHelper] loginUser];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tableViewDidTriggerHeaderRefresh];
        });
    }
    
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    self.title = @"通知";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNofi) name:NOTI_MESSAGE_RECEIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNofi) name:@"conversationListRefresh" object:nil];
    
    [self removeEmptyConversationsFromDB];
    
    [self networkStateView];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    
    //客服 首次对话的本地存储
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"FIRST_CHATSDK"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //tableheaderView 互动提醒
    PushHeaderView *headerView =  (PushHeaderView*)[nil loadNibNamed:@"PushHeaderView" owner:nil options:nil].lastObject;
    headerView.height = 78*2;
    self.tableView.tableHeaderView = headerView;
    
    _headerView = headerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userActivityViewClick)];
    [_headerView.userActivityView addGestureRecognizer:tap];
    

    [_headerView.systemMsgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(systemClickTarget)]];
    [PublicTool showHudWithView:KEYWindow];
    
    [self requestData];
    
    [self refreshFriendApplyCount];
    
}

- (void)refreshFriendApplyCount{
    if ([WechatUserInfo shared].apply_count.integerValue) {
        [AppNetRequest updateUnreadCountWithKey:@"apply_count" type:@"交换名片申请" completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
    }
}
- (void)setNavigationBar{
    UIButton *readBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [readBtn setTitle:@"已读" forState:UIControlStateNormal];
    [readBtn setTitle:@"已读" forState:UIControlStateDisabled];
    [readBtn setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateDisabled];
    [readBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    readBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [readBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    [readBtn addTarget:self action:@selector(readBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //通讯录
    UIButton *contactBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 44)];
    [contactBtn setImage:[UIImage imageNamed:@"contact_nabar"] forState:UIControlStateNormal];
    [contactBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [contactBtn addTarget:self action:@selector(gotoContact) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *readItem = [[UIBarButtonItem alloc]initWithCustomView:readBtn];
    UIBarButtonItem *contactItem = [[UIBarButtonItem alloc]initWithCustomView:contactBtn];

   
    
    self.navigationItem.rightBarButtonItems = @[contactItem,readItem];
    
    //如果都已读，则不可点
    BOOL unreadCount = NO;
    for (EaseConversationModel *conversationM in self.dataArray) {
        if (conversationM.conversation.unreadMessagesCount) {
            unreadCount = YES;
            break;
        }
    }
    if (unreadCount == NO) {
        if ([WechatUserInfo shared].system_notification_count.integerValue || [WechatUserInfo shared].activity_notifi_count.integerValue) {
            unreadCount = YES;
        }
    }
    readBtn.enabled = unreadCount;
}

//置为已读
- (void)readBtnClick:(UIButton*)readBtn{
    
    //user/updateAllUnreadCount 全部已读
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"user/updateAllUnreadCount" HTTPBody:@{@"alltype":@"新系统通知|动态互动通知|交换名片申请"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
    }];
    
    [WechatUserInfo shared].system_notification_count = @"";
    [WechatUserInfo shared].activity_notifi_count = @"";
    [[WechatUserInfo shared]save];
    
    _headerView.systemMsgRedV.hidden = YES;
    _headerView.userActivityRedV.hidden = YES;
    
    for (EaseConversationModel *conversationM in self.dataArray) {
        if (conversationM.conversation.unreadMessagesCount) {
            [conversationM.conversation markAllMessagesAsRead:nil];
        }
    }
    readBtn.enabled = NO;
    [self.tableView reloadData];
}

- (void)gotoContact{
    CardExchangeListController *contactVC = [[CardExchangeListController alloc]init];
    [self.navigationController pushViewController:contactVC animated:YES];
    [QMPEvent event:@"msg_contactalbum_click"];
}

- (void)setViews{
    
    
    _headerView.userActivityViewContentLab.text = self.userActivityMsgDic[@"content"];
    // 未读数
    _headerView.userActivityRedV.hidden = [WechatUserInfo shared].activity_notifi_count.integerValue == 0;
    
    
    //系统通知
    _headerView.systemMsgContentLab.text = self.systemMsgDic[@"title"];
    
    // 未读数
    _headerView.systemMsgRedV.hidden = [WechatUserInfo shared].system_notification_count.integerValue == 0;
    
}


#pragma mark --消息数据--
- (void)requestData{
    
    [self requestPushData];
    [self requestActivityData];
    [self requestFriend];
}

- (void)requestPushData{
    //keyword  会员类型  page、page_num
    NSDictionary *dict = @{@"page":@(1),@"page_num":@(2),@"keyword":[WechatUserInfo shared].vip?[WechatUserInfo shared].vip:@"", @"type_flag":@(2)};
    
    [AppNetRequest getPushListWithParameter:dict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        
        if (resultData && resultData[@"list"]) {
            NSArray *arr = resultData[@"list"];
            
            if (arr.count) {
                self.systemMsgDic = arr[0];
            }
        }
        _finishCount ++;
        if (_finishCount == 2) {
            [PublicTool dismissHud:KEYWindow];
            [self setViews];
            [self.tableView reloadData];
        }
    }];
    
}

//互动提醒数据
- (void)requestActivityData{
    // 11评论；12关注；13投币
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPActivityNotificationListURL HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && resultData[@"list"]) {
            if ([(NSArray*)resultData[@"list"] count]) {
                NSDictionary *activityDic = resultData[@"list"][0];
                NSString *name = [activityDic[@"anonymous"] integerValue] == 1 ? @"匿名用户": activityDic[@"user_info"][@"nickname"];
                if ([activityDic[@"send_type"] integerValue] == 12) { //关注
                    self.userActivityMsgDic = @{@"content":[NSString stringWithFormat:@"%@关注了你",name]};
                }else{
                    
                    if([activityDic[@"send_type"] integerValue] == 13){ //动态投币
                        self.userActivityMsgDic = @{@"content":[NSString stringWithFormat:@"%@对你的动态进行了投币",name]};
                        
                    }else if([activityDic[@"send_type"] integerValue] == 11){ //评论动态
                        self.userActivityMsgDic = @{@"content":[NSString stringWithFormat:@"%@评论了你的动态",name]};
                    }else if([activityDic[@"send_type"] integerValue] == 14){ //点赞动态
                        self.userActivityMsgDic = @{@"content":[NSString stringWithFormat:@"%@赞了你的动态",name]};
                    }else if([activityDic[@"send_type"] integerValue] == 15){ //点赞评论
                        self.userActivityMsgDic = @{@"content":[NSString stringWithFormat:@"%@赞了你的评论",name]};
                    }
                    
                }
            }
            
        }
        _finishCount ++;
        if (_finishCount == 2) {
            [PublicTool dismissHud:KEYWindow];
            [self setViews];
            [self.tableView reloadData];
        }
        
    }];
    
}

- (void)requestFriend {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSDictionary *dic = @{@"page":@(1),@"page_num":@(100)};
//        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/friendRequestList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
    
//            if (resultData) {
//
//
//                NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
//
//                NSMutableArray *aaa = [NSMutableArray array];
//                for (EMConversation *conversation in conversations) {
//                    QMPLog(@"%@", conversation.conversationId);
//                    [aaa addObject:conversation.conversationId];
//                }
//
//
//                for (NSDictionary *dic in resultData) {
//                    if (![aaa containsObject:dic[@"usercode"]]) {
//                        // 生成回话
//                        EMMessage *message = [EaseSDKHelper getTextMessage:@"[交换电话]" to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":dic[@"icon"],@"userNick":dic[@"nickname"],@"type":@"exphone1",@"forme":@"1",@"aid":dic[@"apply_id"]}];
//                        message.from = dic[@"usercode"];
//                        message.to = [WechatUserInfo shared].usercode;
//                        message.conversationId = dic[@"usercode"];
//                        message.direction = EMMessageDirectionReceive;
//
//                        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//
//                        } completion:^(EMMessage *message, EMError *error) {
//
//                        }];
//                    }
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            }
//        }];
//    });

}
#pragma mark ---消息列表
- (void)systemClickTarget{
    
    PushListController * pushListVC = [[PushListController alloc] init];
    pushListVC.navTitleStr = @"系统通知";
    pushListVC.pushType = @"2";
    [self.navigationController pushViewController:pushListVC animated:YES];
    [WechatUserInfo shared].system_notification_count = @"0";
    [[WechatUserInfo shared] save];
    _headerView.systemMsgRedV.hidden = YES;
}

- (void)userActivityViewClick{
    [QMPEvent event:@"msg_interactionAlert_click"];
    ActivityNotifiListController *listVC = [[ActivityNotifiListController alloc]init];
    [self.navigationController pushViewController:listVC animated:YES];
    [WechatUserInfo shared].activity_notifi_count = @"0";
    [[WechatUserInfo shared] save];
    _headerView.userActivityRedV.hidden = YES;
}


- (void)reloadDataNofi{
    
    [self tableViewDidTriggerHeaderRefresh];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        for (EMConversation *conversation in needRemoveConversations) {
            [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                QMPLog(@"删除成功是否---%@",aError);
            }];
            
        }
        //
        //        [[EMClient sharedClient].chatManager deleteConversations:needRemoveConversations isDeleteMessages:YES completion:^(EMError *aError) {
        //            [self tableViewDidTriggerHeaderRefresh];
        //
        //        }];
    }
}

#pragma mark - getter

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"EaseUIResource.bundle/messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}


#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel
{
    if (conversationModel) {
        EMConversation *conversation = conversationModel.conversation;
        if (conversation) {
            if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
                RobotChatViewController *chatController = [[RobotChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
                chatController.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
                [self.navigationController pushViewController:chatController animated:YES];
            } else {
                UIViewController *chatController = nil;
#ifdef REDPACKET_AVALABLE
                chatController = [[RedPacketChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
#else
                chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
#endif
                //真实昵称头像
                NSString *header =  conversationModel.conversation.lastReceivedMessage.ext[@"userAvatar"];
                NSString *nickName = conversationModel.conversation.lastReceivedMessage.ext[@"userNick"];
                FriendModel *friend1 = [[FriendModel alloc]init];
                friend1.headimgurl = header;
                friend1.nickname = nickName;
                friend1.usercode = conversationModel.conversation.conversationId;
                
                [(ChatViewController*)chatController setChatFriendM:friend1];
                chatController.title = conversationModel.title;
                
                [self.navigationController pushViewController:chatController animated:YES];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
        [self.tableView reloadData];
    }
}

#pragma mark - EaseConversationListViewControllerDataSource
//返回聊天列表 cell的model，应该是从  接受到的最后一条消息（lastReceiveMessage）获取联系人信息，如果为空，就从本地unionid查好友信息
- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                                    modelForConversation:(EMConversation *)conversation
{
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
    if (model.conversation.type == EMConversationTypeChat) {
        if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
            model.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
        } else {
            
        }
    } else if (model.conversation.type == EMConversationTypeGroupChat) {
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"subject"])
        {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.conversationId]) {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setValue:group.subject forKey:@"subject"];
                    [ext setValue:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        NSDictionary *ext = conversation.ext;
        model.title = [ext objectForKey:@"subject"];
        imageName = [[ext objectForKey:@"isPublic"] boolValue] ? @"EaseUIResource.bundle/groupPublicHeader" : @"EaseUIResource.bundle/groupPrivateHeader";
        model.avatarImage = [UIImage imageNamed:imageName];
    }
    
    //接收者 真实昵称头像
    NSString *header =  model.conversation.lastReceivedMessage.ext[@"userAvatar"];
    NSString *nickName = model.conversation.lastReceivedMessage.ext[@"userNick"];
    
    if (!header) {
        header = model.conversation.latestMessage.ext[@"otherAvatar"];
    }
    if (!nickName) {
        nickName = model.conversation.latestMessage.ext[@"otherNick"];
    }
    
    model.avatarURLPath = header;
    model.title = nickName;
    
    return model;
}

- (NSAttributedString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];
    if (lastMessage) {
        NSString *latestMessageTitle = @"";
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
                if ([lastMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    latestMessageTitle = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[语音]";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
        
        NSDictionary *messageExt = lastMessage.ext;
        if (![PublicTool isNull:messageExt[@"type"]]) {
            NSString *text = ((EMTextMessageBody *)messageBody).text;
            if ([messageExt[@"type"] isEqualToString:@"exwechat4"]) {
                if ([text containsString:@"拒绝"]) {
                    latestMessageTitle = @"对方拒绝了与您交换微信";
                } else {
                    latestMessageTitle = @"对方同意了与您交换微信";
                }
                
            } else if ([messageExt[@"type"] isEqualToString:@"exphone4"]) {
                if ([text containsString:@"拒绝"]) {
                    latestMessageTitle = @"对方拒绝了与您交换电话";
                } else {
                    latestMessageTitle = @"对方同意了与您交换电话";
                }
                
            }
        }
        
        if (lastMessage.direction == EMMessageDirectionReceive) {
            latestMessageTitle = [NSString stringWithFormat:@"%@", latestMessageTitle];
            
        }
        
        NSDictionary *ext = conversationModel.conversation.ext;
        if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtAllMessage) {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"group.atAll", nil), latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, NSLocalizedString(@"group.atAll", nil).length)];
            
        }
        else if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtYouMessage) {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"group.atMe", @"[Somebody @ me]"), latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, NSLocalizedString(@"group.atMe", @"[Somebody @ me]").length)];
        }
        else {
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        }
    }
    
    return attributedStr;
}

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    //改下格式
    if (latestMessageTime.length == 19) {
        NSString *time = [PublicTool dateString:latestMessageTime];
        if ([time isEqualToString:@"今日"]) {
            NSArray *arr = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PUSHTIME"] componentsSeparatedByString:@" "];
            time = [[arr lastObject] substringToIndex:5];
        }
        return time;
    }
    
    
    return latestMessageTime;
}

//#pragma mark - EMSearchControllerDelegate
//
//- (void)cancelButtonClicked
//{
//    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
//}
//
//- (void)searchTextChangeWithString:(NSString *)aString
//{
//    __weak typeof(self) weakSelf = self;
//    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
//        if (results) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.resultController.displaySource removeAllObjects];
//                [weakSelf.resultController.displaySource addObjectsFromArray:results];
//                [weakSelf.resultController.tableView reloadData];
//            });
//        }
//    }];
//}

#pragma mark - private

//- (void)setupSearchController
//{
//    [self enableSearchController];
//
//    __weak ConversationListController *weakSelf = self;
//    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
//        NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
//        EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//        // Configure the cell...
//        if (cell == nil) {
//            cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//
//        id<IConversationModel> model = [weakSelf.resultController.displaySource objectAtIndex:indexPath.row];
//        cell.model = model;
//
//        cell.detailLabel.attributedText = [weakSelf conversationListViewController:weakSelf latestMessageTitleForConversationModel:model];
//        cell.timeLabel.text = [weakSelf conversationListViewController:weakSelf latestMessageTimeForConversationModel:model];
//        return cell;
//    }];
//
//    [self.resultController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
//        return [EaseConversationCell cellHeightWithModel:nil];
//    }];
//
//    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [weakSelf.searchController.searchBar endEditing:YES];
//        id<IConversationModel> model = [weakSelf.resultController.displaySource objectAtIndex:indexPath.row];
//        EMConversation *conversation = model.conversation;
//        ChatViewController *chatController;
//        if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
//            chatController = [[RobotChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
//            chatController.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
//        }else {
//#ifdef REDPACKET_AVALABLE
//            chatController = [[RedPacketChatViewController alloc]  initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
//#else
//            chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
//#endif
//            chatController.title = [conversation showName];
//        }
//        [weakSelf.navigationController pushViewController:chatController animated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
//        [weakSelf.tableView reloadData];
//
//        [weakSelf cancelSearch];
//    }];
//
//    UISearchBar *searchBar = self.searchController.searchBar;
//    [self.view addSubview:searchBar];
//    self.tableView.frame = CGRectMake(0, searchBar.frame.size.height, self.view.frame.size.width,self.view.frame.size.height - searchBar.frame.size.height);
////    self.tableView.tableHeaderView = searchBar;
////    [searchBar sizeToFit];
//}

#pragma mark - public

-(void)refresh
{
    [self refreshAndSortView];
}

-(void)refreshDataSource
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        self.tableView.tableHeaderView = _networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
    
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == EMConnectionDisconnected) {
        self.tableView.tableHeaderView = _networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}
@end
