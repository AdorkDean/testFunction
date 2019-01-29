//
//  HomeNavigationBar.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HomeNavigationBar.h"
#import "MainSearchController.h"
#import "ConversationListController.h"

#import "PostActivityViewController.h"

@interface HomeNavigationBar()

@property(nonatomic,strong)UIButton *msgBtn;
@property(nonatomic,strong)UILabel *msgLab;
@property(nonatomic,strong)UIButton *addBtn;
@property(nonatomic,strong)NSDictionary *iconDict;
@property(nonatomic,strong)NSDictionary *blackIconDict;
@property(nonatomic,strong)NSDictionary *whiteIconDict;

@property(nonatomic,assign)BOOL showAdd;

@end


@implementation HomeNavigationBar

+ (HomeNavigationBar*)navigationBarWithBarStyle:(BarStyle)barStyle{
    CGFloat height = kScreenTopHeight;
    HomeNavigationBar *nabarView = [[HomeNavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    nabarView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    nabarView.barStyle = barStyle;
    return nabarView;
}

+ (HomeNavigationBar*)navigationBarWithBarStyle:(BarStyle)barStyle showAdd:(BOOL)showAdd{
    HomeNavigationBar *bar = [HomeNavigationBar navigationBarWithBarStyle:barStyle];
    bar.showAdd = showAdd;
    return bar;
    
}


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addView];
    }
    return self;
}



- (void)addView{
    
    //消息icon
    UIButton *msgBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW-42, 0, 42, 44)];
    [msgBtn setImage:[UIImage imageNamed:@"nabar_msgicon"] forState:UIControlStateNormal];
    msgBtn.centerY = self.searchBtn.centerY;
    [msgBtn addTarget:self action:@selector(msgBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.msgBtn = msgBtn;
    [self addSubview:msgBtn];
    
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, self.height-37, SCREENW-75, 30)];
    
    if (@available(iOS 8.2, *)) {
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    } else {
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    [searchBtn setTitle:@"项目、机构、人物、新闻、公司、报告" forState:UIControlStateNormal];
    
//    searchBtn.layer.masksToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    searchBtn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    searchBtn.layer.borderWidth = 1;
    [self addSubview:searchBtn];
    
    [searchBtn addTarget:self action:@selector(tapSearchBar:) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn = searchBtn;
    
    self.searchBtn.backgroundColor = [UIColor whiteColor];
    [self.searchBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.searchBtn.imageView.contentMode = UIViewContentModeCenter;
    [self.searchBtn setTitleColor:HTColorFromRGB(0x838CA1) forState:UIControlStateNormal];
    self.searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    self.searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, -16);
    self.searchBtn.layer.shadowColor = HTColorFromRGB(0xDDDDDD).CGColor;//shadowColor阴影颜色
    self.searchBtn.layer.shadowOpacity = 0.6;//阴影透明度，默认0
    self.searchBtn.layer.shadowRadius = 3;//阴影半径，默认3
    self.searchBtn.layer.shadowOffset = CGSizeMake(0,0);

    self.searchBtn.adjustsImageWhenHighlighted = NO;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:) name:NOTI_MESSAGE_RECEIVE object:nil];
    /// 监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroud:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(receiverLoginNotificationToRefresh:) name:NOTIFI_LOGIN object:nil];
    [center addObserver:self selector:@selector(receiverLoginNotificationToRefresh:) name:NOTIFI_QUITLOGIN object:nil];

}

- (void)setShowAdd:(BOOL)showAdd{
    _showAdd = showAdd;
    if (showAdd) {
        self.searchBtn.width = SCREENW - 13 - 82;
        //笔记icon
        self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW-34-6, 0, 34, 44)];
        [self.addBtn setImage:[UIImage imageNamed:@"nabar_add"] forState:UIControlStateNormal];
        [self.addBtn setImage:[UIImage imageNamed:@"nabar_add"] forState:UIControlStateHighlighted];
        [self addSubview:self.addBtn];
        self.addBtn.centerY = self.searchBtn.centerY;
        [self.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.msgBtn.frame = CGRectMake(SCREENW-73, 0, 34, 44);
        self.msgBtn.centerY = self.searchBtn.centerY;
    }
}
- (void)requestUnReadContData{
    
    if (![ToLogin isLogin]) {
        return;
    }
    if ([PublicTool isNull:[WechatUserInfo shared].vip]) {
//        return;
    }
    //请求好友申请 和  通知未读
    NSDictionary *dic = @{@"keyword":@""};
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"user/getBpCardCoutByUnionid" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
          
            [WechatUserInfo shared].apply_count = resultData[@"apply_count"];
            [WechatUserInfo shared].bp_count = resultData[@"bp_count"];
            [WechatUserInfo shared].exchange_card_count = resultData[@"exchange_card_count"];
            [WechatUserInfo shared].activity_notifi_count = resultData[@"activity_notifi_count"];
            [WechatUserInfo shared].system_notification_count = resultData[@"system_notification_count"];
            [[WechatUserInfo shared] save];

            //如果交换的名片 和收到的BP有未读
            if ([resultData[@"bp_count"] integerValue] || [resultData[@"exchange_card_count"] integerValue]) {
                [[PublicTool topViewController].tabBarController.tabBar showBadgeOnItemIndex:3];
            }else{
                [[PublicTool topViewController].tabBarController.tabBar hideBadgeOnItemIndex:3];
            }
            
            [self refreshNabarBtnIcon];
        }
    }];
}

#pragma mark --Event--
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterForegroud:(NSNotification *)noit{
    [self refreshNabarBtnIcon];
}
- (void)receiveNewMessage:(NSNotification*)tf{ //收到新消息
    [self refreshNabarBtnIcon];
}

- (void)receiverLoginNotificationToRefresh:(NSNotification *)noti{
    [self refreshNabarBtnIcon];
}

- (void)refreshMsdCount{
    [self refreshNabarBtnIcon];
    [self requestUnReadContData];
}

- (void)setBarStyle:(BarStyle)barStyle{
    _barStyle = barStyle;
    [self refreshNabarBtnIcon];
}

- (void)refreshNabarBtnIcon{
    
    
    BOOL isWhite = (self.barStyle == BarStyle_White);
    [self.msgLab removeFromSuperview];

    self.addBtn.centerY = self.searchBtn.centerY;
    self.msgBtn.centerY = self.searchBtn.centerY;

    //背景色
    UIColor *bgColor = self.barStyle == BarStyle_Blue ? HTColorFromRGB(0x0F3068):(self.barStyle == BarStyle_Clear ? [[UIColor whiteColor] colorWithAlphaComponent:0.0] : [UIColor whiteColor]);
    self.backgroundColor = bgColor;

    [self.msgBtn setImage:[UIImage imageNamed:@"nabar_msgicon"] forState:UIControlStateNormal];
   
    if (![ToLogin isLogin]) { //登录状态才有消息
        return;
    }
    
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    int unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if (conversation.unreadMessagesCount) {
            unreadCount += conversation.unreadMessagesCount;
        }
    }
    if (unreadCount>0) {
        [self addSubview:self.msgLab];
        self.msgLab.frame = CGRectMake(self.msgBtn.right-self.msgBtn.width/2.0, self.msgBtn.top+2, 16, 16);
        if (unreadCount>=100) {
            self.msgLab.width = 22;
        }else if (unreadCount>=10) {
            self.msgLab.width = 18;
        }else{
            self.msgLab.width = 16;
        }
        self.msgLab.text = [NSString stringWithFormat:@"%@",unreadCount>=100 ? @"99+":@(unreadCount)];
        if (!self.showAdd) {
            self.msgLab.right = self.width-8;
        }
        return;
    }
    //红点
    if ([WechatUserInfo shared].apply_count.integerValue|| [WechatUserInfo shared].system_notification_count.integerValue|| [WechatUserInfo shared].activity_notifi_count.integerValue) {
        [self.msgBtn setImage:[UIImage imageNamed:@"nabar_msgicon_red"] forState:UIControlStateNormal];
        return;
    }
    
    //红点
    NSString *kefuWel = [[NSUserDefaults standardUserDefaults] valueForKey:@"FIRST_CHATSDK"];
    if (kefuWel == nil) {
        [self.msgBtn setImage:[UIImage imageNamed:@"nabar_msgicon_red"] forState:UIControlStateNormal];
        return;
    }
}


- (void)tapSearchBar:(UIButton *)sender{
    
    if (![ToLogin canEnterDeep]) {
        
        [ToLogin accessEnterDeep];
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveFilterView" object:nil];
    
    MainSearchController *searchVC = [[MainSearchController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:searchVC animated:YES];
    [QMPEvent event:@"tab_nabar_searchclick"];
    
    switch (self.tabbarIndex) {
        case 0:
            [QMPEvent event:@"home_search_click"];
            break;
        case 1:
            [QMPEvent event:@"tab_acvity_search_click"];
            break;
        case 2:
            [QMPEvent event:@"tab_discover_search_click"];
            break;
            
        default:
            break;
    }
    
}

- (void)msgBtnClick{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    ConversationListController *friendVC = [[ConversationListController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:friendVC animated:YES];
    [QMPEvent event:@"tab_nabar_msgclick"];
}

//导航笔记按钮点击
- (void)addBtnClick{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (self.addBtnClickEvent) {
        self.addBtnClickEvent();
    }
    [QMPEvent event:@"tab_nabar_publishclick"];
}

- (NSDictionary*)iconDict{
    
    if (!_iconDict) {
        _iconDict = [NSDictionary dictionaryWithContentsOfFile:[nilpathForResource:@"HomeMenuFile" ofType:@"plist"]];
    }
    return _iconDict;
}
- (NSDictionary*)blackIconDict{
    
    if (!_blackIconDict) {
        _blackIconDict = self.iconDict[@"black"];
    }
    return _blackIconDict;
}
- (NSDictionary*)whiteIconDict{
    
    if (!_whiteIconDict) {
        _whiteIconDict = self.iconDict[@"white"];
    }
    return _whiteIconDict;
}
-(UILabel *)msgLab{
    if (!_msgLab) {
        _msgLab = [[UILabel alloc]initWithFrame:CGRectMake(self.msgBtn.right-22, self.msgBtn.top+2, 16, 16)];
        [_msgLab labelWithFontSize:10 textColor:[UIColor whiteColor]];
        if (@available(iOS 8.2, *)) {
            _msgLab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        } else {
            _msgLab.font = [UIFont systemFontOfSize:10];
        }
        _msgLab.layer.cornerRadius = 8;
        _msgLab.layer.masksToBounds = YES;
        _msgLab.backgroundColor = RED_BG_COLOR;
        _msgLab.textAlignment = NSTextAlignmentCenter;
    }
    return _msgLab;
}
@end
