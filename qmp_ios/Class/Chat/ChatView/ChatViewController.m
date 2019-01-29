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

#import "ChatViewController.h"
#import "FriendModel.h"
#import "PersonDetailsController.h"
#import "UnauthPeresonPageController.h"
#import "QMPChatViewCell.h"
#import "AlertActionView.h"
#import "BPDeliverController.h"
#import "ReportModel.h"
#import "FileItem.h"
#import "FileWebViewController.h"
#import "OpenDocument.h"
#import "DownloadView.h"
#import "AlertActionView.h"
#import "EditBasicInfoController.h"
@interface ChatViewController ()<UIAlertViewDelegate, EMClientDelegate, DownloadViewDelegate>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    UIMenuItem *_recallItem;
    UIMenuItem *_saveCardIMenutem;
    
    UIButton *_rightBtn;
}

@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic) NSMutableDictionary *emotionDic;
@property (nonatomic, copy) EaseSelectAtTargetCallback selectedCallback;

@property (nonatomic, strong) NSString *phone;

@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;


@property (nonatomic, weak) UIButton *exPhoneButton;
@property (nonatomic, weak) UIButton *exWechatButton;
@end

@implementation ChatViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //消息列表刷新  空消息删除
    [[NSNotificationCenter defaultCenter] postNotificationName:@"conversationListRefresh" object:nil];
    [QMPEvent endEvent:@"chatpage_timer"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [QMPEvent event:@"chat_enter"];
    // Do any additional setup after loading the view.
    [[ChatHelper shareHelper]loginUser];
    
    [self createBackButton];
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    self.timeCellHeight =  50;
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitChat) name:@"ExitChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    
    
    NSArray *messages = self.messsagesSource;
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [self.dataSource messageViewController:self
                             shouldSendHasReadAckForMessage:message read:YES];
        }
        else{
            isSend = [self shouldSendHasReadAckForMessage:message
                                                     read:YES];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
    
    
    if (!self.title) {
        self.title = self.chatFriendM.nickname;
        
    }
    self.tableView.backgroundColor = HTColorFromRGB(0xF8F8F8);
    self.tableView.contentInset = UIEdgeInsetsMake(55, 0, 0, 0);
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 55);
    view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, SCREENW/4.0, 55);
    [button setTitle:@"换电话" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_phone_b"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_phone_g"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self fixButton:button];
    [view addSubview:button];
    self.exPhoneButton = button;
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(SCREENW/4.0, 0, SCREENW/4.0, 55);
    [button2 setTitle:@"换微信" forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_wechat_b"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_wechat_g"] forState:UIControlStateSelected];
    [button2 addTarget:self action:@selector(wechatClick) forControlEvents:UIControlEventTouchUpInside];
    [self fixButton:button2];
    [view addSubview:button2];
    self.exWechatButton = button2;
    
    UIButton *button3 = [[UIButton alloc] init];
    button3.frame = CGRectMake(SCREENW/4.0*2, 0, SCREENW/4.0, 55);
    [button3 setTitle:@"发BP" forState:UIControlStateNormal];
    [button3 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_bp_b"] forState:UIControlStateNormal];
    [button3 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_phone_g"] forState:UIControlStateSelected];
    [button3 addTarget:self action:@selector(sendBpClick) forControlEvents:UIControlEventTouchUpInside];
    [self fixButton:button3];
    [view addSubview:button3];
    
    UIButton *button4 = [[UIButton alloc] init];
    button4.frame = CGRectMake(SCREENW/4.0*3, 0, SCREENW/4.0, 55);
    [button4 setTitle:@"屏蔽ta" forState:UIControlStateNormal];
    [button4 setTitle:@"已屏蔽" forState:UIControlStateSelected];
    [button4 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_shield_b"] forState:UIControlStateNormal];
    [button4 setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chat_shield_g"] forState:UIControlStateSelected];
    [button4 addTarget:self action:@selector(blackClick:) forControlEvents:UIControlEventTouchUpInside];
    [self fixButton:button4];
    [view addSubview:button4];
    
    UIImageView *v = [[UIImageView alloc] init];
    v.frame = CGRectMake(SCREENW/4.0, 10, 1, 35);
    v.backgroundColor = HTColorFromRGB(0xF0F0F0);
    [view addSubview:v];
    
    UIImageView *v1 = [[UIImageView alloc] init];
    v1.frame = CGRectMake(SCREENW/4.0*2, 10, 1, 35);
    v1.backgroundColor = HTColorFromRGB(0xF0F0F0);
    [view addSubview:v1];
    
    UIImageView *v2 = [[UIImageView alloc] init];
    v2.frame = CGRectMake(SCREENW/4.0*3, 10, 1, 35);
    v2.backgroundColor = HTColorFromRGB(0xF0F0F0);
    [view addSubview:v2];
    
    if ([[[EMClient sharedClient].contactManager getBlackList] containsObject:self.conversation.conversationId]) {
        button4.selected = YES;
    } else {
        button4.selected = NO;
    }
    
    [self.view addSubview:view];
    
    [self getUnionId];
    
    
    if ([self.conversation.conversationId isEqualToString:QMPHelperUserCode]) {
        view.hidden = YES;
        self.tableView.contentInset = UIEdgeInsetsZero;
    }
}
- (void)blackClick:(UIButton *)button {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    if (button.selected) {
        [AlertActionView alertViewWithMessage:@"" tipInfo:@"解除屏蔽后将再次接收\n对方的私信消息" cancelTitle:@"取消" sureBtnTitle:@"确认" sureBtnEnabled:YES cancelBtnAction:^{
            
        } sureBtnAction:^{
            EMError *error = [[EMClient sharedClient].contactManager removeUserFromBlackList:weakSelf.conversation.conversationId];
            if (!error) {
                QMPLog(@"发送成功");
                button.selected = !button.selected;
            }
        }];
        
    } else {
        EMError *error = [[EMClient sharedClient].contactManager addUserToBlackList:self.conversation.conversationId relationshipBoth:YES];
        if (!error) {
            QMPLog(@"拉黑了");
            button.selected = !button.selected;
        }
    }
    [QMPEvent event:@"chat_action_click" label:@"屏蔽"];

    [QMPEvent event:@"chatpage_shield_click"];
}

- (void)fixButton:(UIButton *)button {
    
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    [button setTitleColor:HTColorFromRGB(0x006EDA) forState:UIControlStateNormal];
    [button setTitleColor:HTColorFromRGB(0xCCCCCC) forState:UIControlStateSelected];
    
    CGFloat imageW = button.imageView.frame.size.width;
    CGFloat imageH = button.imageView.frame.size.height;
    
    CGFloat titleW = button.titleLabel.frame.size.width;
    CGFloat titleH = button.titleLabel.frame.size.height;
    [button setImageEdgeInsets:UIEdgeInsetsMake(-titleH, 0.f, 0.f,-titleW)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageW, -imageH - 8, 0.f)];
}
- (void)verifyUserShieldMe:(void(^)(void))noShield {
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"qmp:verify"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:@{}];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
            if (noShield) {
                noShield();
            }
        } else {
            if (aError.code == EMErrorUserPermissionDenied) {
                [weakSelf appendMessage:MESSAGE_REJECTED];
            }else if(aError.code == EMErrorUserNotLogin){
                [[ChatHelper shareHelper] loginUser];
            }
        }
    }];
}
- (void)sendBpClick {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [self verifyUserShieldMe:^{
        [weakSelf sendBpClick2];
    }];
    [QMPEvent event:@"chat_action_click" label:@"BP"];
}
   
    
- (void)sendBpClick2 {
    [PublicTool showHudWithView:KEYWindow];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"f/getUserAuthCount" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData) {
            
            NSString *haveGetCount = resultData[@"deliverbp_count"]; //已经发的次数
            NSString *leftCount = resultData[@"left_deliverbp_count"];  //剩余次数
            NSString *message;
            
            if (!leftCount || leftCount.intValue == 0) {
                message = @"今日可投递BP次数已用完";
                NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:message];
                [attText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(message.length-3, 3)];
                NSMutableAttributedString *tipInfo = [[NSMutableAttributedString alloc]initWithString:@"请移步http://vip.qimingpian.com继续投递"];
                [tipInfo addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(3,tipInfo.length - 7)];
                [AlertActionView alertViewWithMessage:attText tipInfo:tipInfo sureBtnAction:^{
                    
                } sureBtnEnabled:NO];
                
                
            }else{
                message = [NSString stringWithFormat:@"每日可投递BP %ld次",haveGetCount.integerValue+leftCount.integerValue];
                NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:message];
                NSMutableAttributedString *tipInfo = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"剩余%@次",leftCount]];
                [tipInfo addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(2 ,tipInfo.length - 3)];
                [AlertActionView alertViewWithMessage:attText tipInfo:tipInfo cancelBtnAction:^{
                } sureBtnAction:^{
                    [self sureDeliverBtnClick];
                } sureBtnEnabled:YES];
                
            }
            
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    [QMPEvent event:@"chatpage_bp_click"];
}

- (void)sureDeliverBtnClick{
    
    BPDeliverController *selectVC = [[BPDeliverController alloc]init];
    selectVC.personId = self.chatFriendM.personid;
    @weakify(self);
    selectVC.selectedBP = ^(ReportModel *report) {
        @strongify(self);
        [self deliverBPEvent:report];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:selectVC animated:YES];
}

- (void)deliverBPEvent:(ReportModel*)report{
    
    if ([PublicTool isNull:report.pdfUrl]) {
        [PublicTool showMsg:@"BP数据错误"];
        return;
    }
    NSString *fid = report.isMy?report.reportId:report.fileid;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:report.name forKey:@"bp_name"];
    [param setValue:report.pdfUrl forKey:@"bp_link"];
    [param setValue:[PublicTool isNull:report.size]?@"":report.size forKey:@"size"];
    
    if (report.isMy) {
        [param setValue:report.reportId forKey:@"fileid"];
    }else{
        [param setValue:report.fileid forKey:@"fileid"]; //收到的BP
    }
    
    [param setValue:self.chatFriendM.nickname forKey:@"huoyue_name"];
    [param setValue:self.chatFriendM.personid forKey:@"huoyue_id"];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param setValue:report.product?report.product:@"" forKey:@"product"];
    
    QMPLog(@"投递BP----------%@",report.name);
    [AppNetRequest deliverBPToInvestorWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"msg"] isKindOfClass:[NSString class]] && [resultData[@"msg"] isEqualToString:@""]) {
//            [PublicTool showMsg:@"投递成功"];
            [self sendBPMessage:report];
        }else{
            if ([PublicTool isNull:resultData[@"msg"]]) {
                [PublicTool showMsg:REQUEST_ERROR_TITLE];
            }else{
                [PublicTool showMsg:resultData[@"msg"]];
                
            }
        }
    }];
    
}
- (void)sendBPMessage:(ReportModel*)report {
    
    NSString *fid = report.isMy?report.reportId:report.fileid;
    
    EMMessage *message = [EaseSDKHelper getTextMessage:@"[BP]" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"sendbp",@"bpurl":report.pdfUrl, @"bpname":report.name, @"bpname":report.name, @"bpid":fid, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
            EMError *saveError = nil;
            [self.conversation appendMessage:aMessage error:&saveError];
            [weakSelf a_refreshAfterSentMessage:aMessage];
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
}
- (void)wechatClick {
    if (self.exWechatButton.selected) {
        NSInteger f = [self.chatFriendM.is_friend integerValue];
        if (f == 2 || f == 3) {
            [PublicTool showMsg:@"已经交换过微信号了"];
            return;
        }
        
        NSInteger s = [self.chatFriendM.exWechatStatus integerValue];
        if (s == 1) {
            [PublicTool showMsg:@"正在交换微信号"];
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    [self verifyUserShieldMe:^{
        [weakSelf wechatClick2];
    }];
    [QMPEvent event:@"chat_action_click" label:@"换微信"];
}
- (void)wechatClick2 {
    if (self.exWechatButton.selected) {
        if ([PublicTool isNull:[WechatUserInfo shared].wechat]) {
            //            [PublicTool showMsg:@"请您完善微信号"];
            [AlertActionView alertViewWithMessage:@"" tipInfo:@"您尚未填写本人微信号\n补充完整后方可进行交换" cancelTitle:@"取消" sureBtnTitle:@"去填写" sureBtnEnabled:YES cancelBtnAction:^{
                
            } sureBtnAction:^{
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:[WechatUserInfo shared].headimgurl?:@"" forKey:@"headimgurl"];
                [dict setValue:[WechatUserInfo shared].nickname?:@"" forKey:@"nickname"];
                [dict setValue:[WechatUserInfo shared].zhiwei?:@"" forKey:@"zhiwei"];
                [dict setValue:[WechatUserInfo shared].company?:@"" forKey:@"company"];
                [dict setValue:[WechatUserInfo shared].wechat?:@"" forKey:@"wechat"];
                [dict setValue:[WechatUserInfo shared].phone?:@"" forKey:@"phone"];
                [dict setValue:[WechatUserInfo shared].email?:@"" forKey:@"email"];
                [dict setValue:[WechatUserInfo shared].person_id?:@"" forKey:@"personId"];
                EditBasicInfoController *vc = [[EditBasicInfoController alloc] init];
                vc.personInfo = dict;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            
            return;
        }
        if ([PublicTool isNull:self.chatFriendM.wechat]) {
            [PublicTool showMsg:@"暂无对方微信号，无法进行交换"];
            return;
        }
        
    }
    
    [PublicTool showHudWithView:KEYWindow];
    [AppNetRequest getLeftCountOfExchangeCardWithParameter:@{} completionHandle:^(NSURLSessionDataTask *dataTask, BOOL resultTrue, NSError *error) {
        
        if (resultTrue) {
            [self requestExWechat];
        }
    }];
    [QMPEvent event:@"chatpage_wechat_click"];
}
- (void)requestExWechat {
    
    
    self.exWechatButton.selected = YES;
    NSDictionary *dict = @{@"type":@(2), @"receive_unionid":self.chatFriendM.unionid?:@"", @"person_id":self.chatFriendM.personid?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/sendContactRequest" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSString *aid = resultData[@"id"];
            self.chatFriendM.exWechatStatus = @"1";
            
            
            EMMessage *message = [EaseSDKHelper getTextMessage:@"申请交换微信" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"aid":aid,@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exwechat1", @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
            message.conversationId = self.conversation.conversationId;
            
            //Construct message model
            id<IMessageModel> model = nil;
            
            model = [self messageViewController:nil modelForMessage:message];
            
            [self addMessageToDataSource:message progress:nil];
            
            __weak typeof(self) weakSelf = self;
            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            } completion:^(EMMessage *aMessage, EMError *aError) {
                
                if (!aError) {
                    EMError *saveError = nil;
                    [self.conversation appendMessage:aMessage error:&saveError];
                    [weakSelf a_refreshAfterSentMessage:aMessage];
                }else {
                    [weakSelf.tableView reloadData];
                    if (aError.code == EMErrorUserPermissionDenied) {
                        //                [self appendMessage:MESSAGE_REJECTED];
                    }else{
                        [PublicTool showMsg:@"消息发送失败"];
                    }
                }
                [self sendGetContactMessage:aid];
            }];
           
        }
    }];
}

- (void)sendGetContactMessage:(NSString*)aid{
    return;
    EMMessage *message = [EaseSDKHelper getTextMessage:@"如长时间未收到回应，可以试试委托联系" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"aid":aid,@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname,SHOWINFO_MSG_KEY:@"1"}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    [[EMClient sharedClient].chatManager importMessages:@[message] completion:^(EMError *aError) {
        NSLog(@"---%@",aError.errorDescription);
    }];
//    __weak typeof(self) weakSelf = self;
//    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//    } completion:^(EMMessage *aMessage, EMError *aError) {
//
//        if (!aError) {
//            EMError *saveError = nil;
//        }else {
//            [weakSelf.tableView reloadData];
//            if (aError.code == EMErrorUserPermissionDenied) {
//                //                [self appendMessage:MESSAGE_REJECTED];
//            }else{
//                [PublicTool showMsg:@"消息发送失败"];
//            }
//        }
//    }];
}
- (void)phoneClick {
    if (self.exPhoneButton.selected) {
        NSInteger f = [self.chatFriendM.is_friend integerValue];
        if (f == 1 || f == 3) {
            [PublicTool showMsg:@"已经交换过电话了"];
            return;
        }
        
        NSInteger s = [self.chatFriendM.exPhoneStatus integerValue];
        if (s == 1) {
            [PublicTool showMsg:@"正在交换电话"];
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [self verifyUserShieldMe:^{
        [weakSelf phoneClick2];
    }];
    [QMPEvent event:@"chat_action_click" label:@"换电话"];
}
- (void)phoneClick2 {
    if (self.exPhoneButton.selected) {
        if ([PublicTool isNull:[WechatUserInfo shared].phone]) {
            [AlertActionView alertViewWithMessage:@"" tipInfo:@"您尚未填写本人手机号\n补充完整后方可进行交换" cancelTitle:@"取消" sureBtnTitle:@"去填写" sureBtnEnabled:YES cancelBtnAction:^{
                
            } sureBtnAction:^{
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:[WechatUserInfo shared].headimgurl?:@"" forKey:@"headimgurl"];
                [dict setValue:[WechatUserInfo shared].nickname?:@"" forKey:@"nickname"];
                [dict setValue:[WechatUserInfo shared].zhiwei?:@"" forKey:@"zhiwei"];
                [dict setValue:[WechatUserInfo shared].company?:@"" forKey:@"company"];
                [dict setValue:[WechatUserInfo shared].wechat?:@"" forKey:@"wechat"];
                [dict setValue:[WechatUserInfo shared].phone?:@"" forKey:@"phone"];
                [dict setValue:[WechatUserInfo shared].email?:@"" forKey:@"email"];
                [dict setValue:[WechatUserInfo shared].person_id?:@"" forKey:@"personId"];
                EditBasicInfoController *vc = [[EditBasicInfoController alloc] init];
                vc.personInfo = dict;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            return;
        }
        if ([PublicTool isNull:self.chatFriendM.phone]) {
            [PublicTool showMsg:@"暂无对方电话，无法进行交换"];
            return;
        }
    }
    
    
    [PublicTool showHudWithView:KEYWindow];
    [AppNetRequest getLeftCountOfExchangeCardWithParameter:@{} completionHandle:^(NSURLSessionDataTask *dataTask, BOOL resultTrue, NSError *error) {
        
        if (resultTrue) {
            [self requestAddFriend];
        }
    }];
    [QMPEvent event:@"chatpage_phone_click"];
}
- (void)requestAddFriend {
    
    self.exPhoneButton.selected = YES;
    NSDictionary *dict = @{@"type":@(1), @"receive_unionid":self.chatFriendM.unionid?:@"", @"person_id":self.chatFriendM.personid?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/sendContactRequest" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSString *aid = resultData[@"id"];
            self.chatFriendM.exPhoneStatus = @"1";
            
            EMMessage *message = [EaseSDKHelper getTextMessage:@"申请交换电话" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone1",@"aid":aid, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
            message.conversationId = self.conversation.conversationId;
            
            //Construct message model
            id<IMessageModel> model = nil;
            
            model = [self messageViewController:nil modelForMessage:message];
            
            [self addMessageToDataSource:message progress:nil];
            
            __weak typeof(self) weakSelf = self;
            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            } completion:^(EMMessage *aMessage, EMError *aError) {
                
                if (!aError) {
                    EMError *saveError = nil;
                    [self.conversation appendMessage:aMessage error:&saveError];
                    [weakSelf a_refreshAfterSentMessage:aMessage];
                }else {
                    [weakSelf.tableView reloadData];
                    if (aError.code == EMErrorUserPermissionDenied) {
                        //                [self appendMessage:MESSAGE_REJECTED];
                    }else{
                        [PublicTool showMsg:@"消息发送失败"];
                    }
                }
                [self sendGetContactMessage:aid];
            }];
        }
    }];
}

#pragma mark --委托联系
- (void)getContact{
    [PublicTool showMsg:@"委托联系"];
}


- (void)a_refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime) {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = self.messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]]) {
            
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound) {
                [self.messsagesSource removeObjectAtIndex:index];
                [self.messsagesSource addObject:aMessage];
                
                //格式化消息
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:formattedMessages];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                return;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        self.navigationItem.leftBarButtonItems = @[leftButtonItem] ;
    }
    self.navigationItem.leftBarButtonItems =  @[negativeSpacer,leftButtonItem];
}

- (void)popSelf{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUnionId{
    
    // 曾辉号
    if ([self.chatFriendM.usercode isEqualToString:QMPHelperUserCode] || [PublicTool isNull:self.chatFriendM.usercode]) {
        return;
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/getUserInfoByUsercode" HTTPBody:@{@"usercode":self.chatFriendM.usercode} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        self.chatFriendM.unionids = resultData[@"unionid"];
        self.chatFriendM.unionid = resultData[@"unionid"];
        self.chatFriendM.person_id = resultData[@"person_id"];
        self.chatFriendM.personid = resultData[@"person_id"];
        self.chatFriendM.is_friend = resultData[@"is_friend"];
        self.chatFriendM.phone =  resultData[@"bind_phone"];
        self.chatFriendM.wechat = resultData[@"wechat"];
        self.chatFriendM.nickname = resultData[@"nickname"];
        self.chatFriendM.headimgurl = resultData[@"icon"];
        
        if (![PublicTool isNull:resultData[@"opp_apply"]]) {
            NSDictionary *dict = resultData[@"opp_apply"];
            self.chatFriendM.exPhoneStatus2 = dict[@"phone_status"];
            self.chatFriendM.exWechatStatus2 = dict[@"wechat_status"];
        }
        if (![PublicTool isNull:resultData[@"self_apply"]]) {
            NSDictionary *dict = resultData[@"self_apply"];
            self.chatFriendM.exPhoneStatus = dict[@"phone_status"];
            self.chatFriendM.exWechatStatus = dict[@"wechat_status"];
        }
        
        
        [self _setupBarButtonItem];
        
        
        
        NSInteger f = [self.chatFriendM.is_friend integerValue];
        NSInteger p = [PublicTool isNull:self.chatFriendM.exPhoneStatus]?0:[self.chatFriendM.exPhoneStatus integerValue];
        NSInteger w = [self.chatFriendM.exWechatStatus integerValue];
        self.exPhoneButton.selected = f == 1 || f == 3 || p == 1 || p == 3;
        self.exWechatButton.selected = f == 2 || f == 3 || w == 1|| w == 3;
        
        if (f == 1 || f == 3) {
            [self.exPhoneButton setTitle:@"已交换" forState:UIControlStateNormal];
        }
        if (f == 2 || f == 3) {
            [self.exWechatButton setTitle:@"已交换" forState:UIControlStateNormal];
        }
        
        if ([PublicTool isNull:self.chatFriendM.phone] || [PublicTool isNull:[WechatUserInfo shared].phone]) {
            self.exPhoneButton.selected = YES;
        }
        if ([PublicTool isNull:self.chatFriendM.wechat] || [PublicTool isNull:[WechatUserInfo shared].wechat]) {
            self.exWechatButton.selected = YES;
        }
        
        
        self.title = self.chatFriendM.nickname;
        
        if ([[[EMClient sharedClient].contactManager getBlackList] containsObject:self.conversation.conversationId]) {
             [self appendMessage:MESSAGE_REJECTRECEIVE];
        }
        
    }];
}




- (void)dealloc
{
    if (self.conversation.type == EMConversationTypeChatRoom) {
        //退出聊天室，删除会话
        if (self.isJoinedChatroom) {
            NSString *chatter = [self.conversation.conversationId copy];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EMError *error = nil;
                [[EMClient sharedClient].roomManager leaveChatroom:chatter error:&error];
                if (error !=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Leave chatroom '%@' failed [%@]", chatter, error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    });
                }
            });
        }
        else {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:YES completion:nil];
        }
    }
    
    [[EMClient sharedClient] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSDictionary *ext = self.conversation.ext;
        if ([[ext objectForKey:@"subject"] length])
        {
            self.title = [ext objectForKey:@"subject"];
        }
        
        if (ext && ext[kHaveUnreadAtMessage] != nil)
        {
            NSMutableDictionary *newExt = [ext mutableCopy];
            [newExt removeObjectForKey:kHaveUnreadAtMessage];
            self.conversation.ext = newExt;
        }
    }
    [QMPEvent beginEvent:@"chatpage_timer"];

}



#pragma mark - setup subviews

- (void)_setupBarButtonItem
{
    // 曾辉号
    if ([self.chatFriendM.usercode isEqualToString:QMPHelperUserCode]) {
        return;
    }
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"ta的主页" forState:UIControlStateNormal];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(rightbarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    _rightBtn = btn;
}

- (void)rightbarButtonClick:(UIButton*)btn{
    
    if (![PublicTool isNull:self.chatFriendM.person_id]) {
        PersonDetailsController *detailVC = [[PersonDetailsController alloc]init];
        detailVC.persionId = self.chatFriendM.person_id;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if (![PublicTool isNull:self.chatFriendM.unionids]) {
        UnauthPeresonPageController *detailVC = [[UnauthPeresonPageController alloc]init];
        detailVC.unionid = self.chatFriendM.unionids;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        self.messageTimeIntervalTag = -1;
        [self.conversation deleteAllMessages:nil];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}
- (void)tapHeaderImgView {
    if ([self.conversation.conversationId isEqualToString:QMPHelperUserCode]) {
        return;
    }
    
    if (![PublicTool isNull:self.chatFriendM.person_id]) {
        PersonDetailsController *pageVC = [[PersonDetailsController alloc]init];
        pageVC.persionId = self.chatFriendM.person_id;
        [self.navigationController pushViewController:pageVC animated:YES];
        return;
    }
    if (![PublicTool isNull:self.chatFriendM.unionids]) {
        UnauthPeresonPageController *pageVC = [[UnauthPeresonPageController alloc]init];
        pageVC.unionid = self.chatFriendM.unionids;
        [self.navigationController pushViewController:pageVC animated:YES];
        return;
    }
}
- (void)tapHeaderImgView2 {
    if ([self.conversation.conversationId isEqualToString:QMPHelperUserCode]) {
        return;
    }
    
    if (![PublicTool isNull:[WechatUserInfo shared].person_id]) {
        PersonDetailsController *pageVC = [[PersonDetailsController alloc]init];
        pageVC.persionId = [WechatUserInfo shared].person_id;
        [self.navigationController pushViewController:pageVC animated:YES];
        return;
    }
    if (![PublicTool isNull:[WechatUserInfo shared].unionid]) {
        UnauthPeresonPageController *pageVC = [[UnauthPeresonPageController alloc]init];
        pageVC.unionid = [WechatUserInfo shared].unionid;
        [self.navigationController pushViewController:pageVC animated:YES];
        return;
    }
}
#pragma mark - EaseMessageViewControllerDelegate

- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:SHOWINFO_MSG_KEY]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (recallCell == nil) {
            recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
        recallCell.title = body.text;
        recallCell.titleLabel.userInteractionEnabled = YES;
        [recallCell.titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getContact)]];
        return recallCell;
    }
    if ([ext objectForKey:@"em_recall"]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (recallCell == nil) {
            recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
        recallCell.title = body.text;
        return recallCell;
    }
    if ([ext[@"type"] isEqualToString:@"exwechat4"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nullcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nullcell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = HTColorFromRGB(0xF8F8F8);
            }
            return cell;
            
        } else {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
            if ([body.text containsString:@"拒绝"]) {
                recallCell.title = @"对方拒绝了与您交换微信";
            } else {
                recallCell.title = @"对方同意了与您交换微信";
            }
            
            return recallCell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exphone4"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nullcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nullcell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = HTColorFromRGB(0xF8F8F8);
            }
            return cell;
            
        } else {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
            if ([body.text containsString:@"拒绝"]) {
                recallCell.title = @"对方拒绝了与您交换电话";
            } else {
                recallCell.title = @"对方同意了与您交换电话";
            }
            return recallCell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exphone1"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
            recallCell.title = body.text;
            return recallCell;
        } else {
            
            NSString *TimeCellIdentifier = [QMPChatViewCell cellIdentifierWithModel:messageModel];
            QMPChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            __weak typeof(self) weakSelf = self;
            
            cell.okButtonClick = ^(NSString * _Nonnull aid) {
                weakSelf.exPhoneButton.selected = YES;
                weakSelf.chatFriendM.exPhoneStatus = @"3";
                [weakSelf sendPhone2:aid];
                [weakSelf sendPhone:aid];
                [weakSelf.exPhoneButton setTitle:@"已交换" forState:UIControlStateNormal];
            };
            cell.noOkButtonClick = ^(NSString * _Nonnull aid) {
                [weakSelf sendReject:aid];
                [weakSelf sendPhone3:aid];
                weakSelf.exPhoneButton.selected = NO;
                weakSelf.chatFriendM.exPhoneStatus = 0;
                weakSelf.chatFriendM.exPhoneStatus2 = @"2";
            };
            
            [cell setExStatus:self.chatFriendM.exPhoneStatus2];
            
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            
            return cell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exphone2"]) {
        
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) { // 发送者显示
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nullcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nullcell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = HTColorFromRGB(0xF8F8F8);
            }
            return cell;
        } else {
            NSString *TimeCellIdentifier = [QMPChatViewCell2 cellIdentifierWithModel:messageModel];
            QMPChatViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            return cell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exphone3"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nullcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nullcell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = HTColorFromRGB(0xF8F8F8);
            }
            return cell;
        } else {
            NSString *TimeCellIdentifier = [QMPChatViewCell2 cellIdentifierWithModel:messageModel];
            QMPChatViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            //            [cell.bubbleView.okButton addTarget:self action:@selector(obButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            return cell;
        }
    }
    
    if ([ext[@"type"] isEqualToString:@"sendbp"]) {
        
        NSString *TimeCellIdentifier = [QMPChatBPViewCell cellIdentifierWithModel:messageModel];
        QMPChatBPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        if (!cell) {
            cell = [[QMPChatBPViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.messageNameIsHidden = YES;
        cell.model = messageModel;
        __weak typeof(self) weakSelf = self;
        cell.okButtonClickBP = ^(NSString *url, NSString *name, NSString *fid) {
            [weakSelf lookBP:url name:name fid:fid];
        };
        
        cell.avatarView.userInteractionEnabled = YES;
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView2)];
            [cell.avatarView addGestureRecognizer:tap];
        } else {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
        }
        
        
        return cell;
    }
    
    if ([ext[@"type"] isEqualToString:@"exwechat1"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
            recallCell.title = body.text;
            return recallCell;
        } else {
            
            NSString *TimeCellIdentifier = [QMPChatViewCell cellIdentifierWithModel:messageModel];
            QMPChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            __weak typeof(self) weakSelf = self;
            
            cell.okButtonClick = ^(NSString * _Nonnull aid) {
                weakSelf.exWechatButton.selected = YES;
                weakSelf.chatFriendM.exWechatStatus = @"3";
                [weakSelf.exWechatButton setTitle:@"已交换" forState:UIControlStateNormal];
                [weakSelf sendWechat2:aid];
                [weakSelf sendWechat:aid];
            };
            cell.noOkButtonClick = ^(NSString * _Nonnull aid) {
                [weakSelf sendReject:aid];
                [weakSelf sendWechat3:aid];
                weakSelf.exWechatButton.selected = NO;
                weakSelf.chatFriendM.exWechatStatus = @"0";
                weakSelf.chatFriendM.exWechatStatus2 = @"2";
            };
            
            [cell setExStatus:self.chatFriendM.exWechatStatus2];
            
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            
            return cell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exwechat2"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            return recallCell;
        } else {
            NSString *TimeCellIdentifier = [QMPChatViewCell2 cellIdentifierWithModel:messageModel];
            QMPChatViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            //            [cell.bubbleView.okButton addTarget:self action:@selector(obButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            return cell;
        }
    }
    if ([ext[@"type"] isEqualToString:@"exwechat3"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
            EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            
            if (recallCell == nil) {
                recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            return recallCell;
        } else {
            NSString *TimeCellIdentifier = [QMPChatViewCell2 cellIdentifierWithModel:messageModel];
            QMPChatViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (!cell) {
                cell = [[QMPChatViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier model:messageModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageNameIsHidden = YES;
            cell.model = messageModel;
            //            [cell.bubbleView.okButton addTarget:self action:@selector(obButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.avatarView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImgView)];
            [cell.avatarView addGestureRecognizer:tap];
            return cell;
        }
    }
    
    
    return nil;
}
- (void)requestDownloadDocument:(ReportModel *)pdfModel{
    
    NSString *key = pdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    
    if (downloadAlertV){
        //隐藏过,没有下载完
        downloadAlertV.isShow = YES;
    }else{   //之前未下载
        downloadAlertV = [DownloadView initFrame];
        downloadAlertV.delegate = self;
        downloadAlertV.isShow = YES;
        [downloadAlertV initViewWithTitle:@"正在下载" withInfo:@"" withLeftBtnTitle:@"取消" withRightBtnTitle:@"隐藏" withCenter:CGPointMake(SCREENW/2, SCREENH/2) withInfoLblH:40.f ofDocument:pdfModel];
    }
    //    [self.downloadVMDict setValue:downloadAlertV forKey:key];
    [KEYWindow addSubview:downloadAlertV];
}

- (void)lookBP:(NSString *)url name:(NSString *)aName fid:(NSString *)fid {
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    
    //跳转,请求分组列表
    ReportModel *reportModel = [ReportModel new];
    reportModel.pdfUrl = url;
    reportModel.name = aName;
    reportModel.reportId = fid;
    
    if (reportModel.browse_status.integerValue == 2) { //未查看 - > 已查看
        NSDictionary *dic = @{@"id":reportModel.reportId,@"flag":@"1"};
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"bpDeliver/UpdateBpUnreadflag" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            QMPLog(@"BP已读---%@",resultData);
            reportModel.browse_status = @"0";
            [WechatUserInfo shared].bp_count =  [WechatUserInfo shared].bp_count.integerValue > 1 ? [NSString stringWithFormat:@"%ld",[WechatUserInfo shared].bp_count.integerValue-1]:@"";
            [[WechatUserInfo shared] save];
        }];
    }
    
    reportModel.collectFlag = @"禁止收藏";
    if (![reportModel.fileExt isEqualToString:@"pdf"]) {
        FileItem *file = [[FileItem alloc] init];
        file.fileName = reportModel.name;
        file.fileUrl = reportModel.pdfUrl;
        file.fileId = reportModel.reportId;
        
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;
        webVC.reportModel = reportModel;
        //            webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
        return;
    }
    
    if (reportModel.pdfUrl.length) {
        
        OpenDocument *openPDFTool = [[OpenDocument alloc] init];
        openPDFTool.viewController = self;
        //        openPDFTool.delegate = self;
        
        if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
            
            if ([reportModel.fileExt isEqualToString:@"pdf"]) {
                //本地下载了该文档
                [openPDFTool openDocumentofReportModel:reportModel];
                
            }else{
                FileItem *file = [[FileItem alloc] init];
                file.fileName = reportModel.name;
                file.fileUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:reportModel.name];
                file.fileId = reportModel.reportId;
                
                FileWebViewController *webVC = [[FileWebViewController alloc] init];
                webVC.fileItem = file;
                webVC.reportModel = reportModel;
                [self.navigationController pushViewController:webVC animated:YES];
            }
            
        }else{
            //需要下载
            if (![TestNetWorkReached networkIsReachedNoAlert]) {
                [ShowInfo showInfoOnView:self.view withInfo:@"网络不可用"];
                
                return;
            }
            Reachability *reach = [Reachability reachabilityForInternetConnection];
            NetworkStatus status = [reach currentReachabilityStatus];
            if (status == ReachableViaWWAN) {
                NSString *key = reportModel.reportId;
                DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
                
                if (downloadAlertV){
                    //隐藏过,没有下载完
                    downloadAlertV.isShow = YES;
                    [self.downloadVMDict setValue:downloadAlertV forKey:key];
                    [KEYWindow addSubview:downloadAlertV];
                }
                else{
                    //使用数据流量的时候弹窗提醒
                    [openPDFTool launchReachableViaWWANAlert:status ofCurrentVC:self withModel:reportModel];
                }
            }
            else{
                
                [self requestDownloadDocument:reportModel];
            }
        }
    }
    else{
        
        FileItem *file = [[FileItem alloc] init];
        file.fileName = reportModel.name;
        file.fileUrl = reportModel.pdfUrl;
        file.fileId = reportModel.reportId;
        
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;webVC.reportModel =reportModel;
        [self.navigationController pushViewController:webVC animated:YES];
        
    }
}
- (void)sendReject:(NSString *)aid {
    NSDictionary *dict = @{@"apply_id":aid, @"status":@(2), @"receive_unionid":self.chatFriendM.unionid?:@"", @"person_id":self.chatFriendM.personid?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/handleContactRequest" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}
- (void)sendPhone3:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"对方拒绝了与您交换电话" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone4",@"phone":[WechatUserInfo shared].bind_phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
            EMError *saveError = nil;
            [self.conversation appendMessage:aMessage error:&saveError];
            [weakSelf a_refreshAfterSentMessage:aMessage];
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
}
- (void)sendPhone2:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"对方同意了与您交换电话" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone4",@"phone":[WechatUserInfo shared].bind_phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
}
- (void)sendWechat3:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"对方拒绝了与您交换微信号" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone4",@"phone":[WechatUserInfo shared].bind_phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
}
- (void)sendWechat2:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"对方同意了与您交换微信号" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone4",@"phone":[WechatUserInfo shared].bind_phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
}
- (void)restrictionsDeal3:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"[微信号]" to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":self.chatFriendM.headimgurl,@"userNick":self.chatFriendM.nickname,@"type":@"exwechat3",@"forme":@"1",@"aid":aid, @"wechat":self.chatFriendM.wechat, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.from = self.chatFriendM.usercode;
    message.to = [WechatUserInfo shared].usercode;
    message.conversationId = self.chatFriendM.usercode;
    message.direction = EMMessageDirectionReceive;
    
    [self.conversation appendMessage:message error:nil];
    [self.messsagesSource addObject:message];
    // 格式化消息
    self.messageTimeIntervalTag = -1;
    NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:formattedMessages];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)restrictionsDeal2:(NSString *)aid {
    EMMessage *message = [EaseSDKHelper getTextMessage:@"[手机号]" to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":self.chatFriendM.headimgurl,@"userNick":self.chatFriendM.nickname,@"type":@"exphone3",@"forme":@"1",@"aid":aid, @"phone":self.chatFriendM.phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.from = self.chatFriendM.usercode;
    message.to = [WechatUserInfo shared].usercode;
    message.conversationId = self.chatFriendM.usercode;
    message.direction = EMMessageDirectionReceive;
    
    [self.conversation appendMessage:message error:nil];
    [self.messsagesSource addObject:message];
    // 格式化消息
    self.messageTimeIntervalTag = -1;
    NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:formattedMessages];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
- (void)sendPhone:(NSString *)aid {
    
    [self restrictionsDeal2:aid];

    EMMessage *message = [EaseSDKHelper getTextMessage:@"[手机号]" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone2",@"phone":[WechatUserInfo shared].bind_phone, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
            EMError *saveError = nil;
            [self.conversation appendMessage:aMessage error:&saveError];
            [weakSelf a_refreshAfterSentMessage:aMessage];
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
    
    NSDictionary *dict = @{@"apply_id":aid, @"status":@(3), @"receive_unionid":self.chatFriendM.unionid?:@"", @"person_id":self.chatFriendM.personid?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/handleContactRequest" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}
- (void)sendWechat:(NSString *)aid {
    
    [self restrictionsDeal3:aid];
    
    EMMessage *message = [EaseSDKHelper getTextMessage:@"[微信号]" to:self.conversation.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exwechat2",@"wechat":[WechatUserInfo shared].wechat, @"otherAvatar":self.chatFriendM.headimgurl, @"otherNick":self.chatFriendM.nickname}];
    message.conversationId = self.conversation.conversationId;
    
    //Construct message model
    id<IMessageModel> model = nil;
    
    model = [self messageViewController:nil modelForMessage:message];
    
    [self addMessageToDataSource:message progress:nil];
    
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        //        if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
        //            [weakself.dataSource messageViewController:weakself updateProgress:progress messageModel:nil messageBody:message.body];
        //        }
    } completion:^(EMMessage *aMessage, EMError *aError) {
        
        if (!aError) {
            EMError *saveError = nil;
            [self.conversation appendMessage:aMessage error:&saveError];
            [weakSelf a_refreshAfterSentMessage:aMessage];
        }else {
            [weakSelf.tableView reloadData];
            if (aError.code == EMErrorUserPermissionDenied) {
                //                [self appendMessage:MESSAGE_REJECTED];
            }else{
                [PublicTool showMsg:@"消息发送失败"];
            }
        }
    }];
    
    NSDictionary *dict = @{@"apply_id":aid, @"status":@(3), @"receive_unionid":self.chatFriendM.unionid?:@"", @"person_id":self.chatFriendM.personid?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"ContactExchage/handleContactRequest" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}
- (void)obButtonClick:(UIButton *)button {
    NSLog(@"dsadadsadas");
}
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:@"em_recall"]) {
        return self.timeCellHeight;
    }
    
    if ([ext[@"type"] isEqualToString:@"exphone1"]) {
        
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            
            return self.timeCellHeight;
        } else {
            return 78+15;
        }
    }
    
    if ([ext[@"type"] isEqualToString:@"exphone2"] || [ext[@"type"] isEqualToString:@"exphone3"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            return 0.1;
        } else {
            return 90+15;
        }
    }
    
    if ([ext[@"type"] isEqualToString:@"sendbp"]) {
        return 78+15;
    }
    
    
    if ([ext[@"type"] isEqualToString:@"exwechat1"]) {
        
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            
            return self.timeCellHeight;
        } else {
            return 78+15;
        }
    }
    
    if ([ext[@"type"] isEqualToString:@"exwechat2"] || [ext[@"type"] isEqualToString:@"exwechat3"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
            return 0.1;
        } else {
            return 90+15;
        }
    }
    
    if ([ext[@"type"] isEqualToString:@"exphone4"] || [ext[@"type"] isEqualToString:@"exwechat4"]) {
        // 发送者显示
        if ([messageModel.message.from isEqualToString:[WechatUserInfo shared].usercode]) {
             return 0.1;
        } else {
            return self.timeCellHeight;
        }
    }
    
    return 0;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[EaseMessageCell class]]) {
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
    return YES;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
}

- (void)messageViewController:(EaseMessageViewController *)viewController
               selectAtTarget:(EaseSelectAtTargetCallback)selectedCallback
{
    _selectedCallback = selectedCallback;
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:self.conversation.conversationId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:self.conversation.conversationId];
    }
    
    if (chatGroup) {
        if (!chatGroup.occupants) {
            __weak ChatViewController* weakSelf = self;
            [self showHudInView:self.view hint:@"Fetching group members..."];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EMError *error = nil;
                EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:chatGroup.groupId error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong ChatViewController *strongSelf = weakSelf;
                    if (strongSelf) {
                        [strongSelf hideHud];
                        if (error) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Fetching group members failed [%@]", error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alertView show];
                        }
                        else {
                            NSMutableArray *members = [group.occupants mutableCopy];
                            NSString *loginUser = [EMClient sharedClient].currentUsername;
                            if (loginUser) {
                                [members removeObject:loginUser];
                            }
                            if (![members count]) {
                                if (strongSelf.selectedCallback) {
                                    strongSelf.selectedCallback(nil);
                                }
                                return;
                            }
                        }
                    }
                });
            });
        }
        else {
            NSMutableArray *members = [chatGroup.occupants mutableCopy];
            NSString *loginUser = [EMClient sharedClient].currentUsername;
            if (loginUser) {
                [members removeObject:loginUser];
            }
            if (![members count]) {
                if (_selectedCallback) {
                    _selectedCallback(nil);
                }
                return;
            }
        }
    }
}

#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
    //如果是 客服 本地发送消息
    if ([PublicTool haveProperty:@"text" class:message.body]) {
        
        if([message.from isEqualToString:QMPHelperUserCode] && ![[WechatUserInfo shared].usercode isEqualToString:QMPHelperUserCode]){
            model.isSender = NO; //NO:左边，接受消息者-客服其他人  YES:右边 发送消息者
        }
        if ([[message.body valueForKey:@"text"] isEqualToString:kDefaultWel] || [[message.body valueForKey:@"text"] isEqualToString:kGetContactText] ) {
            model.isSender = NO;
        }
        if ([message.ext.allKeys containsObject:@"forme"]) {
            model.isSender = NO;
        }
    }
    
    if (model.isSender == YES) {
        model.avatarURLPath = [WechatUserInfo shared].headimgurl;
        model.nickname = [WechatUserInfo shared].nickname;
    }else{
        model.avatarURLPath = self.chatFriendM.headimgurl;
        model.nickname = self.chatFriendM.nickname;
        NSDictionary *dict = message.ext;
        if (!model.avatarURLPath) {
            model.avatarURLPath = dict[@"userAvatar"];
        }
        if (!model.nickname) {
            model.nickname = dict[@"userNick"];
        }
        
    }
    
    model.failImageName = @"imageDownloadFail";
    return model;
}

- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];
    
    NSMutableArray *emotionGifs = [NSMutableArray array];
    _emotionDic = [NSMutableDictionary dictionary];
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",@"icon_013",@"icon_018",@"icon_019",@"icon_020",@"icon_021",@"icon_022",@"icon_024",@"icon_027",@"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    int index = 0;
    for (NSString *name in names) {
        index++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:[NSString stringWithFormat:@"[示例%d]",index] emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [_emotionDic setValue:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    return @[managerDefault];
    
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

- (void)messageViewControllerMarkAllMessagesAsRead:(EaseMessageViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
}

#pragma mark - EaseMob

#pragma mark - EMClientDelegate

- (void)userAccountDidLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userAccountDidRemoveFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userDidForbidByServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidRecall:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        if (![self.conversation.conversationId isEqualToString:msg.conversationId]){
            continue;
        }
        
        NSString *text;
        if ([msg.from isEqualToString:[EMClient sharedClient].currentUsername]) {
            text = [NSString stringWithFormat:NSLocalizedString(@"message.recall", @"You recall a message")];
        } else {
            text = [NSString stringWithFormat:NSLocalizedString(@"message.recallByOthers", @"%@ recall a message"),msg.from];
        }
        
        [self _recallWithMessage:msg text:text isSave:NO];
    }
}

#pragma mark - action
- (void)messageCellSelected:(id<IMessageModel>)model {
    [super messageCellSelected:model];
    if (model.bodyType == EMMessageBodyTypeText) {
        
        NSString *phoneRe = @"\\+?(86)?1\\d{10}";
        NSError *error;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:phoneRe options:NSRegularExpressionCaseInsensitive error:&error];
        [regex enumerateMatchesInString:model.text options:NSMatchingReportProgress range:NSMakeRange(0, model.text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (NSMatchingReportProgress==flags) {
                
            }else{
                if (result.range.length==11) {
                    
                    NSString *phoneStr = [model.text substringWithRange:result.range];
                    self.phone = phoneStr;
                    [PublicTool dealPhone:phoneStr];
                }
            }
        }];
    }
}

- (void)backAction
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    //    [[ChatDemoHelper shareHelper] setChatVC:nil];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:NO completion:nil];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.type == EMConversationTypeGroupChat) {
    }
    else if (self.conversation.type == EMConversationTypeChatRoom)
    {
    }
}

- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.conversation.conversationId];
        if (self.conversation.type != EMConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation deleteAllMessages:nil];
            [self.messsagesSource removeAllObjects];
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else if ([sender isKindOfClass:[UIButton class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alertView show];
    }
}

- (void)revokeMessageWithMessageId:(NSString *)aMessageId   conversationId:(NSString *)conversationId {
    
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"REVOKE_FLAG"];
    NSDictionary *ext = @{@"msgId":aMessageId};
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:conversationId from:currentUsername  to:conversationId body:body ext:ext];
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    } else {
        message.chatType = EMChatTypeChat;
    }
    
    //发送cmd消息
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"发送成功");
            // 需要自己从dataArray里将聊天消息删掉， 还有self.conversation里，最后刷新
            NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
            [self.conversation deleteMessageWithId:aMessageId error:nil];
            [self.messsagesSource removeObject:message];
            if (self.menuIndexPath.row - 1 >= 0) {
                id nextMessage = nil;
                id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
                if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                    nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
                }
                if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                    [indexs addIndex:self.menuIndexPath.row - 1];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
                }
            }
            [self.dataArray removeObjectAtIndex:self.menuIndexPath.row];
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:aMessageId]) {
                    [self.messsagesSource removeObject:obj];
                }
            }];
            
            
            //            [self.tableView beginUpdates];
            [self.tableView reloadData];
            //            [self.tableView endUpdates];
            
            if ([self.dataArray count] == 0) {
                self.messageTimeIntervalTag = -1;
            }
            
        }else {
            NSLog(@"发送失败");
        }
    }];
    
}

- (void)recallMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSString *messageId  = model.message.messageId;
        // 发送这条消息在服务器的时间戳
        NSTimeInterval time1 = (model.message.timestamp) / 1000.0;
        // 当前的时间戳
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval cha = nowTime - time1;
        NSInteger timecha = cha;
        if (timecha <= 120) {
            // 开始调用发送消息回撤的方法
            [self revokeMessageWithMessageId:messageId conversationId:self.conversation.conversationId];
        } else {
            [self showHint:@"消息已经超过两分钟 无法撤回"];
        }
    }
    
    
}

- (void)transpondMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
    }
    self.menuIndexPath = nil;
}

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        if ([self.dataArray count] == 0) {
            self.messageTimeIntervalTag = -1;
        }
    }
    
    self.menuIndexPath = nil;
}

- (void)saveCardMenuAction:(id)sender{
    
    
}


#pragma mark - notification
- (void)exitChat
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EMClient sharedClient].chatManager importMessages:@[message] completion:nil];
    }
}

- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isViewDidAppear = NO;
    } else {
        //结束call
        self.isViewDidAppear = YES;
    }
}

#pragma mark - private

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (self.menuController == nil) {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (_transpondMenuItem == nil) {
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"transpond", @"Transpond") action:@selector(transpondMenuAction:)];
    }
    
    if (_recallItem == nil) {
        _recallItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMenuAction:)];
    }
    
    if (_saveCardIMenutem == nil) {
        _saveCardIMenutem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"transpond", @"Transpond") action:@selector(saveCardMenuAction:)];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    
    
    if (messageType == EMMessageBodyTypeText) {
        [items addObject:_copyMenuItem];
        //        [items addObject:_transpondMenuItem];
        [items addObject:_deleteMenuItem];
#pragma mark ---如果有联系人、手机 、微信
        NSString *text = model.text;
        
        if ([text containsString:@"姓名"] && [text containsString:@"电话"] && [text containsString:@"微信"]) {
            QMPLog(@"收到委托联系方式------%@",text);
        }
        
    } else if (messageType == EMMessageBodyTypeImage || messageType == EMMessageBodyTypeVideo) {
        [items addObject:_transpondMenuItem];
        [items addObject:_deleteMenuItem];
    } else {
        [items addObject:_deleteMenuItem];
    }
    
    if (model.isSender) {   //不做撤回
        [items addObject:_recallItem];
    }
    
    [self.menuController setMenuItems:items];
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}

- (void)_recallWithMessage:(EMMessage *)msg text:(NSString *)text isSave:(BOOL)isSave
{
    EMMessage *message = [EaseSDKHelper getTextMessage:text to:msg.conversationId messageType:msg.chatType messageExt:@{@"em_recall":@(YES)}];
    message.isRead = YES;
    [message setTimestamp:msg.timestamp];
    [message setLocalTime:msg.localTime];
    id<IMessageModel> newModel = [[EaseMessageModel alloc] initWithMessage:message];
    __block NSUInteger index = NSNotFound;
    [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
        if ([model conformsToProtocol:@protocol(IMessageModel)]) {
            if ([msg.messageId isEqualToString:model.message.messageId])
            {
                index = idx;
                *stop = YES;
            }
        }
    }];
    if (index != NSNotFound)
    {
        __block NSUInteger sourceIndex = NSNotFound;
        [self.messsagesSource enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL *stop){
            if ([message isKindOfClass:[EMMessage class]]) {
                if ([msg.messageId isEqualToString:message.messageId])
                {
                    sourceIndex = idx;
                    *stop = YES;
                }
            }
        }];
        if (sourceIndex != NSNotFound) {
            [self.messsagesSource replaceObjectAtIndex:sourceIndex withObject:newModel.message];
        }
        [self.dataArray replaceObjectAtIndex:index withObject:newModel];
        [self.tableView reloadData];
    }
    
    if (isSave) {
        [self.conversation insertMessage:message error:nil];
    }
}


#pragma mark - EMChooseViewDelegate
-(BOOL)prefersStatusBarHidden{
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
@end
