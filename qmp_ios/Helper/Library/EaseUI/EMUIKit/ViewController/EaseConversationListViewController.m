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

#import "EaseConversationListViewController.h"

#import "EaseEmotionEscape.h"
#import "EaseConversationCell.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseMessageViewController.h"
#import "NSDate+Category.h"
#import "EaseLocalDefine.h"

@interface EaseConversationListViewController ()
{
    NSMutableArray *_selectedIndex;
}
@end

@implementation EaseConversationListViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedIndex = [NSMutableArray array];
    [self tableViewDidTriggerHeaderRefresh];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if ([[WechatUserInfo shared].usercode isEqualToString:QMPHelperUserCode]) {
        //添加一键删除
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        [btn setTitle:@"一键删除" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)deleteMessages{
    if (_selectedIndex.count == 0) {
        return ;
    }
    [PublicTool alertActionWithTitle:@"一键删除" message:nil cancleAction:^{
        
    } sureAction:^{
        
        for (NSNumber *row in _selectedIndex) {
            id<IConversationModel> model = [self.dataArray objectAtIndex:row.integerValue];
            [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                
            }];
        }
        [_selectedIndex removeAllObjects];
        [self tableViewDidTriggerHeaderRefresh];
        
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataArray.count ? [self.dataArray count]:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count == 0) {
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
    EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.detailLabelFont = [UIFont systemFontOfSize:14];
        cell.detailLabelColor = COLOR737782;
        if (@available(iOS 8.2, *)) {
            cell.titleLabelFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        }else{
            cell.titleLabelFont = [UIFont systemFontOfSize:16];
        }
        cell.titleLabelColor = COLOR2D343A;
        cell.timeLabelFont = [UIFont systemFontOfSize:12];
        cell.timeLabelColor = H9COLOR;
    }
    
    if ([self.dataArray count] <= indexPath.row) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];

    cell.model = model;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(conversationListViewController:latestMessageTitleForConversationModel:)]) {
        NSMutableAttributedString *attributedText = [[_dataSource conversationListViewController:self latestMessageTitleForConversationModel:model] mutableCopy];
        [attributedText addAttributes:@{NSFontAttributeName : cell.detailLabel.font} range:NSMakeRange(0, attributedText.length)];
        if ( [attributedText.string containsString:@"我通过了你的好友验证请求"]) {
            
            NSString *str = @"你们已经成为好友，快来聊天吧";
            attributedText = [[NSMutableAttributedString alloc] initWithString:str];

        }
        cell.detailLabel.attributedText =  attributedText;
    } else {
        cell.detailLabel.attributedText =  [[EaseEmotionEscape sharedInstance] attStringFromTextForChatting:[self _latestMessageTitleForConversationModel:model]textFont:cell.detailLabel.font];
    }
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(conversationListViewController:latestMessageTimeForConversationModel:)]) {
        cell.timeLabel.text = [_dataSource conversationListViewController:self latestMessageTimeForConversationModel:model];
    } else {
        cell.timeLabel.text = [self _latestMessageTimeForConversationModel:model];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    //客服机 提供删除
    if ([[WechatUserInfo shared].usercode isEqualToString:QMPHelperUserCode]) {
        [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDelete:)]];
        UIButton *selectedBtn = [cell viewWithTag:1000];
        if (!selectedBtn) {
           selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 50, 0, 50, cell.height)];
            [selectedBtn setImage:[UIImage imageNamed:@"bp_unSelected"] forState:UIControlStateNormal];
            [selectedBtn setImage:[UIImage imageNamed:@"bp_selected"] forState:UIControlStateSelected];
            [cell addSubview:selectedBtn];
            [selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            selectedBtn.tag = 1000;
        }
        [selectedBtn setTitle:[NSString stringWithFormat:@"%ld",indexPath.row] forState:UIControlStateNormal];
        [selectedBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        selectedBtn.selected = [_selectedIndex containsObject:@(indexPath.row)]?YES:NO;
    }
    
    return cell;
}
- (void)selectedBtnClick:(UIButton*)btn{
    
    NSInteger row = btn.titleLabel.text.integerValue;
    btn.selected = !btn.selected;
    if (btn.selected && ![_selectedIndex containsObject:@(row)]) {
        [_selectedIndex addObject:@(row)];
    }else if(!btn.selected && [_selectedIndex containsObject:@(row)]){
        [_selectedIndex removeObject:@(row)];
    }
    [self.tableView reloadData];
}

- (void)longPressDelete:(UILongPressGestureRecognizer*)gesture{
    
    EaseConversationCell *cell = (EaseConversationCell*)gesture.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [PublicTool alertActionWithTitle:@"删除" message:nil cancleAction:^{
        
    } sureAction:^{
        [self deleteCellAction:indexPath];
    }];
}
#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81;
    return [EaseConversationCell cellHeightWithModel:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dataArray.count) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(conversationListViewController:didSelectConversationModel:)]) {
       
        EaseConversationModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [_delegate conversationListViewController:self didSelectConversationModel:model];
    } else {
        EaseConversationModel *model = [self.dataArray objectAtIndex:indexPath.row];
        EaseMessageViewController *viewController = [[EaseMessageViewController alloc] initWithConversationChatter:model.conversation.conversationId conversationType:model.conversation.type];
        viewController.title = model.title;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self setupCellEditActions:indexPath];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self setupCellEditActions:indexPath];
}

#pragma mark - Action

- (void)deleteCellAction:(NSIndexPath *)aIndexPath
{
    EaseConversationModel *model = [self.dataArray objectAtIndex:aIndexPath.row];
    [self.dataArray removeObjectAtIndex:aIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:aIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:nil];

}

- (id)setupCellEditActions:(NSIndexPath *)aIndexPath
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self deleteCellAction:indexPath];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        return @[deleteAction];
    } else {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self deleteCellAction:aIndexPath];
        }];
        deleteAction.backgroundColor = RED_BG_COLOR;
        
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        config.performsFirstActionWithFullSwipe = NO;
        return config;
    }
}


#pragma mark - data

-(void)refreshAndSortView
{
    if ([self.dataArray count] > 1) {
        if ([[self.dataArray objectAtIndex:0] isKindOfClass:[EaseConversationModel class]]) {
            NSArray* sorted = [self.dataArray sortedArrayUsingComparator:
                               ^(EaseConversationModel *obj1, EaseConversationModel* obj2){
                                   EMMessage *message1 = [obj1.conversation latestMessage];
                                   EMMessage *message2 = [obj2.conversation latestMessage];
                                   if(message1.timestamp > message2.timestamp) {
                                       return(NSComparisonResult)NSOrderedAscending;
                                   }else {
                                       return(NSComparisonResult)NSOrderedDescending;
                                   }
                               }];
            [self.dataArray removeAllObjects];
            
            for (EaseConversationModel *model in sorted) {
                if ([model.conversation.conversationId isEqualToString:QMPHelperUserCode]) { //客服 置顶
                    [self.dataArray insertObject:model atIndex:0];
                }else{
                    [self.dataArray addObject:model];
                }
            }
        }
    }
    [self.tableView reloadData];
}

/*!
 @method
 @brief 加载会话列表
 @discussion
 @result
 */
- (void)tableViewDidTriggerHeaderRefresh
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSArray* sorted = [conversations sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    
    
    
    [self.dataArray removeAllObjects];
    for (EMConversation *converstion in sorted) {
        
        EaseConversationModel *model = nil;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(conversationListViewController:modelForConversation:)]) {
            model = [self.dataSource conversationListViewController:self
                                                   modelForConversation:converstion];
        }
        else{
            model = [[EaseConversationModel alloc] initWithConversation:converstion];
        }
        
        if (model) {
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
        
            
            if (!header || !nickName) {
                FriendModel *friend1 = [PublicTool friendForUsercode:converstion.conversationId];
                model.avatarURLPath = friend1.headimgurl;
                model.title = friend1.nickname;
            }
            if ([converstion.conversationId isEqualToString:QMPHelperUserCode]) {
                [self.dataArray insertObject:model atIndex:0];
            } else {
                [self.dataArray addObject:model];
            }
        }
    }
    
    [self.tableView reloadData];
    [self tableViewDidFinishTriggerHeader:YES reload:NO];
}

#pragma mark - EMGroupManagerDelegate

- (void)didUpdateGroupList:(NSArray *)groupList
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - private

/*!
 @method
 @brief 获取会话最近一条消息内容提示
 @discussion
 @param conversationModel  会话model
 @result 返回传入会话model最近一条消息提示
 */
- (NSString *)_latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"图片消息";
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"您收到一条语音消息";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"您收到一个位置消息";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSEaseLocalizedString(@"message.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSEaseLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

/*!
 @method
 @brief 获取会话最近一条消息时间
 @discussion
 @param conversationModel  会话model
 @result 返回传入会话model最近一条消息时间
 */
- (NSString *)_latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

@end
