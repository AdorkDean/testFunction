//
//  CustomAlertView.m
//  CustomAlertView
//


#import "CustomAlertView.h"
#import <objc/runtime.h>
#import "AllFeedbackViewController.h"
#import "TestNetWorkReached.h"
 

#import "InputTextview.h"

#define AlertViewJianGe (42*ratioWidth)
@interface CustomAlertView()<InputTextviewDelegate>
{
    NSInteger _moduleNum;//个数
    
    UIImageView *selfImage;
    float alertViewHeight;
    NSInteger _rowCount;
}

@property (strong, nonatomic) NSArray *companyKeyArr;
@property (strong, nonatomic) NSArray *organizeKeyArr;
@property (assign, nonatomic) BOOL isFeeds;//是否是信息流反馈

@end
@implementation CustomAlertView

- (instancetype)initWithAlertViewHeight:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height infoDic:(NSDictionary *)infoDic viewcontroller:(UIViewController *)vc moduleNum:(NSInteger)moduleNum isFeeds:(BOOL)isFeed
{
    self=[super init];
    if (self) {
        [self buidUIWithAlertViewHeight:mArr WithAlertViewHeight:height infoDic:infoDic viewcontroller:vc moduleNum:moduleNum isFeeds:isFeed];
    }
    return self;
}

- (void)buidUIWithAlertViewHeight:(NSMutableArray *)mArr WithAlertViewHeight:(CGFloat)height infoDic:(NSDictionary *)infoDic viewcontroller:(UIViewController *)vc moduleNum:(NSInteger)moduleNum isFeeds:(BOOL)isFeed{

    _feedbackAllModulesArr = mArr;
    //几行button
    _rowCount = mArr.count%2>0 ? (mArr.count/2+1):mArr.count/2;
    CGFloat AlertViewHeight = _rowCount*(30+15) + 65 + 84;
    if ([infoDic[@"type"] isEqualToString:@"成为官方人物"]) {
        AlertViewHeight = AlertViewHeight + 100 + (_rowCount == 3 ? 90:114);;
    }else{
        AlertViewHeight = AlertViewHeight + (_rowCount == 3 ? 90:114);
    }
    _VC = vc;
    _moduleNum = moduleNum;
    _infoDic = infoDic;
    _isFeeds = isFeed;
    
    self.center = CGPointMake(SCREENW/2, SCREENH/2);
    self.bounds = CGRectMake(0, 0, SCREENW, SCREENH);
    [KEYWindow addSubview:self];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.6;
    [self addSubview:view];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackgroudView:)];
    [view addGestureRecognizer:tap1];
    view.userInteractionEnabled = YES;
    
    selfImage = [[UIImageView alloc] initWithFrame:CGRectMake(AlertViewJianGe,118*ratioHeight, SCREENW - 2*AlertViewJianGe, AlertViewHeight)];
    selfImage.backgroundColor = [UIColor whiteColor];
    alertViewHeight = AlertViewHeight;
    selfImage.layer.cornerRadius = 4;
    selfImage.layer.masksToBounds = YES;
    selfImage.userInteractionEnabled = YES;
    [self addSubview:selfImage];
    
    //叉号
    UIButton *dispearBtn = [[UIButton alloc]initWithFrame:CGRectMake(selfImage.width - 14-50, 2, 45, 45)];
    [dispearBtn setImage:[UIImage imageNamed:@"feedback_del"] forState:UIControlStateNormal];
    [dispearBtn addTarget:self action:@selector(dispAppear:) forControlEvents:UIControlEventTouchUpInside];
    [dispearBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [selfImage addSubview:dispearBtn];
    
    [self addLbl];
    
    [self addAllSelectedBtn:mArr withImg:selfImage];
    [self addInputViewWithCount];
    
    [self addConfirmBtn];
    
    //监听键盘移动
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    

}
/**增加更多反馈的输入框*/
- (void)addInputViewWithCount{
    CGFloat margin = 23*ratioWidth;
    CGFloat h = (_rowCount == 3 ? 90:114);
    if (_rowCount == 0 && [self.infoDic[@"type"] isEqualToString:@"成为官方人物"]) {
        h = 100 + h;
    }
    InputTextview *inputView = [[InputTextview alloc] initWithFrame:CGRectMake(margin, selfImage.height - h - 84, selfImage.width - margin * 2, h)];
    if (_rowCount == 0 && [self.infoDic[@"type"] isEqualToString:@"成为官方人物"]) {
        inputView.module = @"成为官方人物";
        [inputView toSetPlaceholderlblText];
    }
    self.textview = inputView.textView;
    inputView.delegate = self;
    inputView.layer.masksToBounds = YES;
    inputView.layer.cornerRadius = 2;
    inputView.layer.borderColor = HTColorFromRGB(0x777777).CGColor;
    inputView.layer.borderWidth = 0.5;
    [selfImage addSubview:inputView];
}

- (void)addConfirmBtn{

    
    CGFloat btnHeight = 40;
    CGFloat margin = 36*ratioWidth;

        
    _qRButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _qRButton.frame = CGRectMake(margin, selfImage.height-62, selfImage.width - margin*2, btnHeight);
    [_qRButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_qRButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [_qRButton setBackgroundImage:[UIImage imageFromColor:HCCOLOR andSize:_qRButton.size] forState:UIControlStateDisabled];
    [_qRButton setBackgroundImage:[UIImage imageFromColor:BLUE_BRIGHT_COLOR andSize:_qRButton.size] forState:UIControlStateNormal];

    _qRButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_qRButton addTarget:self action:@selector(pressConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_qRButton setTitle:@"提交" forState:UIControlStateNormal];
    _qRButton.enabled = NO;
    _qRButton.layer.masksToBounds = YES;
    _qRButton.layer.cornerRadius = 20;
    [selfImage addSubview:_qRButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoveNoti) name:@"RemoveFeedbackView" object:nil];
}

- (void)receiveRemoveNoti{

    [self removeFromSuperview];
}

- (void)dispAppear:(UIButton*)btn{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}

- (void)addLbl{

    _lab = [[UILabel alloc] init];
    _lab.frame = CGRectMake(23*ratioWidth,25, 130, 15);
    NSString *module = [_infoDic objectForKey:@"module"];
    if (@available(iOS 8.2, *)) {
        _lab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        _lab.font = [UIFont systemFontOfSize:15];
    }
    _lab.adjustsFontSizeToFitWidth = YES;
    _lab.textColor = HTColorFromRGB(0x666666);
    
    if (module && [module isEqualToString:@"单轮融资历史"]) {
        //如果是融资历史单轮反馈, 则显示当前反馈的轮次是哪轮
        _lab.text = [NSString stringWithFormat:@"%@(%@):",_infoDic[@"lunci"],_infoDic[@"time"]];
    }else if(![PublicTool isNull:module]){
        _lab.text = [NSString stringWithFormat:@"%@反馈",_infoDic[@"title"]];
    }else{ //module是空，不是反馈
        _lab.text = _infoDic[@"title"];

    }

    [selfImage addSubview:_lab];
    self.titleLabel =_lab;
}
- (void)addAllSelectedBtn:(NSArray *)mArr withImg:(UIImageView *)image{

    for (int i=0; i<_rowCount; i++) {
        float btnW = (image.frame.size.width-60*ratioWidth)/2;
        float btnH = 30;
        float btnY =  60 + i*(15+btnH);
        for (int j=0; j<2; j++) {
            float btnX = j*(btnW+14*ratioWidth)+_lab.frame.origin.x;
            if (i>=mArr.count/2&&j>=mArr.count%2) {
                break;
            }
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:mArr[i*2+j] forState:UIControlStateNormal];
            btn.tag = 100+i*2+j;
            
            [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
            
            [btn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(changeButtonStatus:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.layer.cornerRadius = 2;
            btn.layer.masksToBounds = YES;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = H9COLOR.CGColor;
            [selfImage addSubview:btn];
        }
    }
}

- (void)enterAllFeedback:(UIButton *)sender{
    
    AllFeedbackViewController *feedbackVC = [[AllFeedbackViewController alloc]init];

    if (_VC) {
        feedbackVC.delegate = (id)_VC;
    }
    
    [_VC.navigationController pushViewController:feedbackVC animated:YES];

}

- (void)tapBackgroudView:(UITapGestureRecognizer *)tap{

    if (tap.view != selfImage) {
        [self removeFromSuperview];
    }
}


/**
 信息流 - 云收藏快速反馈
 @param sender
 */
- (void)pressConfirmBtn:(UIButton *)sender{
    if (self.submitBtnClick) {
        self.submitBtnClick();
        [self removeFromSuperview];
        return;
    }
    if (![self.textview.text isEqualToString:@""] || (self.selectedBtnMArr && self.selectedBtnMArr.count > 0) ) {
        
    }else{
        [PublicTool showMsg:@"请完善反馈数据"];
        return;
    }
    
    if (_isFeeds) {
        [self requestUploadFeeds];
    }
    else{
        [self immediateFeedbackUs];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    CGFloat duraion = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duraion animations:^{
        selfImage.bottom = keyBoardEndY - 10;
    }];
    
}

#pragma mark - InputTextviewDelegate

- (void)inputTextViewChange:(NSString *)text{
    
    if (![text isEqualToString:@""] || (self.selectedBtnMArr && self.selectedBtnMArr.count > 0) ) {
        _qRButton.enabled = YES;
    }
    else{
        if (self.selectedBtnMArr.count) {
            _qRButton.enabled = YES;
        }else{
            _qRButton.enabled = NO;
        }
    }
}
#pragma mark - 请求云收藏反馈

/**
 请求云收藏反馈
 */
- (void)requestUploadFeeds{

    if ([TestNetWorkReached networkIsReachedAlertOnView:self]) {
        
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [requestDict setValue:[_infoDic objectForKey:@"weburl"] forKey:@"c3"];
        [requestDict setValue:[self toGetSelectText] forKey:@"desc"];
        [requestDict setValue:@"云收藏" forKey:@"type"];

        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:requestDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
        
        [self removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(feedsUploadSuccess)]) {
            [self.delegate feedsUploadSuccess];
        }

    }
    else{
        [self removeFromSuperview];

    }
}

#pragma mark - 立即反馈
- (void)immediateFeedbackUs{
    /* 自定义字段
     type：模块的名字 or 反馈类型
     product：项目名字 or 品牌名字 or 产品名
     company：公司名字，全名
     jgname: 机构名字
     contact： 联系方式
     dec：用户描述，提交错误信息
     */
    if (![TestNetWorkReached networkIsReachedAlertOnView:self]) {
        return;
    }else{
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
     
        NSString *action = @"h/editcommonfeedback";
        
        NSString *module = [_infoDic[@"module"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([module isEqualToString:@"专辑"]) {
            [mDict setValue:_infoDic[@"userfolderid"] forKey:@"tag"];

            [mDict setValue:[self toGetSelectText] forKey:@"info"];
            action = @"d/editalbumfeedback";
        }
        else{
            action = @"h/editcommonfeedback";
            [mDict setValue:module forKey:@"type"];
        }
        //项目反馈集
        if ([self.companyKeyArr containsObject:module]) {
            if ([module isEqualToString:@"企业画像"]) {
                module = @"标签";
                [mDict setValue:module forKey:@"type"];
            }
            if ([module containsString:@"相关成员"]) {
                module = @"公司团队";
                [mDict setValue:module forKey:@"type"];
            }
            
            if (([module isEqualToString:@"融资历史"]||[module isEqualToString:@"单轮融资历史"])&&_infoDic[@"lunci"]&&![_infoDic[@"lunci"] isEqualToString:@""]) {
                [mDict setValue:(_infoDic[@"lunci"]&&![_infoDic[@"lunci"] isEqualToString:@""]?_infoDic[@"lunci"]:@"") forKey:@"c1"];
                if ([module isEqualToString:@"单轮融资历史"]) {
                    [mDict setValue:(_infoDic[@"c1"]&&![_infoDic[@"c1"] isEqualToString:@""]?_infoDic[@"c1"]:@"") forKey:@"c1"];
                    [mDict setValue:(_infoDic[@"c4"]&&![_infoDic[@"c4"] isEqualToString:@""]?_infoDic[@"c4"]:@"") forKey:@"c4"];

                }
            }

            if ([module isEqualToString:@"公司团队"]&& _infoDic[@"managerName"]) {  //人物反馈
                [mDict setValue:_infoDic[@"managerName"] forKey:@"c3"];

            }
            
            
            [mDict setValue:[NSString stringWithFormat:@"%ld",(long)_moduleNum] forKey:@"c2"];
            
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] :@"") forKey:@"company"];
            [mDict setValue:(_infoDic[@"product"] ? _infoDic[@"product"] :@"") forKey:@"product"];

            [mDict setValue:[self toGetSelectText] forKey:@"desc"];
            
        }
        
        // 人物
        if ([module isEqualToString:@"人物信息"]||[module isEqualToString:@"人物画像"]||[module isEqualToString:@"个人简介"]||[module isEqualToString:@"投资领域"]||[module isEqualToString:@"主投阶段"]||[module isEqualToString:@"人物投资案例"]||[module isEqualToString:@"人物FA案例"]||[module isEqualToString:@"工作经历"]||[module isEqualToString:@"教育经历"] ||[module isEqualToString:@"获奖经历"] || [module isEqualToString:@"人物新闻"]) {
    
            [mDict setValue:module forKey:@"type"];
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] : @"")forKey:@"company"];
            [mDict setValue:(_infoDic[@"product"] ? _infoDic[@"product"] :@"") forKey:@"product"];
            
            [mDict setValue:[self toGetSelectText] forKey:@"desc"];
            if ([_infoDic[@"title"] containsString:@"人物已认证"]) {
                NSString *desc = [self toGetSelectText];
                [mDict setValue:[NSString stringWithFormat:@"该人物已认证反馈|%@",desc] forKey:@"desc"];
            }
        }

        if ([_infoDic[@"module"] isEqualToString:@"搜索列表详情"]) { //
            [mDict setValue:@"搜索结果" forKey:@"type"];
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] : @"") forKey:@"c1"];
            [mDict setValue:(_infoDic[@"num"] ? _infoDic[@"num"] : @"") forKey:@"c2"];
            [mDict setValue:([_infoDic[@"c4"] isEqualToString:@"急"] ? @"急" : @"") forKey:@"c2"];
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] : @"")forKey:@"company"];
            [mDict setValue:(_infoDic[@"product"] ? _infoDic[@"product"] :@"") forKey:@"product"];
         
            [mDict setValue:[self toGetSelectText] forKey:@"desc"];
        }

        //机构详情
        if ([self.organizeKeyArr containsObject:module]) {
            
            [mDict setValue:module forKey:@"type"];
            [mDict setValue:@"" forKey:@"c1"];
            [mDict setValue:[NSString stringWithFormat:@"%ld",(long)_moduleNum] forKey:@"c2"];
            [mDict setValue:(_infoDic[@"product"] ? _infoDic[@"product"] :@"") forKey:@"product"];//产品/关键字
            [mDict setValue:(_infoDic[@"jgname"] ? _infoDic[@"jgname"] :@"") forKey:@"jgname"];
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] : @"")forKey:@"company"]; //项目/机构/姓名
            
            [mDict setValue:[self toGetSelectText] forKey:@"desc"];
        }
        
        //合投公司 参投公司
        if ([module isEqualToString:@"合投项目"]||[module isEqualToString:@"参投项目"]) {
            
            [mDict setValue:module forKey:@"type"];
            [mDict setValue:(_infoDic[@"company"] ? _infoDic[@"company"] : @"") forKey:@"company"];
            [mDict setValue:(_infoDic[@"product"] ? _infoDic[@"product"] :@"") forKey:@"product"];
            [mDict setValue:(_infoDic[@"c3"] ? _infoDic[@"c3"] :@"") forKey:@"c3"];
            [mDict setValue:(_infoDic[@"c5"] ? _infoDic[@"c5"] :@"") forKey:@"c5"];

            [mDict setValue:[self toGetSelectText] forKey:@"desc"];
        }
        
        if ([module isEqualToString:@"投资团队"] && _infoDic[@"managerName"]) {
            [mDict setValue:_infoDic[@"managerName"] forKey:@"c3"];

        }
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:action HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
           
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        }];
        
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"感谢您的反馈"];
        if ([_infoDic[@"module"] isEqualToString:@"搜索列表详情"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchDetailAll" object:nil];
        }
        
        [self removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(feedsUploadSuccess)]) {
            [self.delegate feedsUploadSuccess];
        }

    }
}

- (NSMutableString *)toGetSelectText{

    NSMutableString *miaoshu = [NSMutableString stringWithCapacity:0];
    for (int i=0; i<self.selectedBtnMArr.count; i++) {
        if (i==self.selectedBtnMArr.count-1) {
            [miaoshu appendFormat:@"%@",self.selectedBtnMArr[i]];
        }else{
            [miaoshu appendFormat:@"%@|",self.selectedBtnMArr[i]];
        }
    }
    
    [miaoshu appendString:[NSString stringWithFormat:@"|%@",_textview.text]];
    return miaoshu;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 更改Button状态
- (void)changeButtonStatus:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        button.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    }else{
        button.layer.borderColor = H9COLOR.CGColor;
    }
    
    NSMutableArray *selectedMArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *viewsArray = [selfImage subviews];
    for (int i=0; i<viewsArray.count; i++) {
        
        if ([viewsArray[i] isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)viewsArray[i];
            if (btn.tag>=100&&btn.selected == YES) {
                [selectedMArr addObject:btn.titleLabel.text];
            }
        }
    }
    self.selectedBtnMArr = selectedMArr;

    if (self.selectedBtnMArr.count > 0) {
        _qRButton.enabled = YES;

    }
    else{
        _qRButton.enabled = NO;
    }
}

//  颜色转换为背景图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)show:(BOOL)animated
{
    /*
    if (animated)
    {
        self.transform = CGAffineTransformScale(self.transform,0,0);
        __weak CustomAlertView *weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.transform = CGAffineTransformScale(weakSelf.transform,1.2,1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.transform = CGAffineTransformIdentity;
            }];
        }];
    }
     */
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat liuHeight = SCREENW-(self.frame.origin.y+self.frame.size.height);
    if (liuHeight<216) {
        CGRect rect = self.frame;
        rect.origin.y = rect.origin.y-(216-liuHeight);
        self.frame =rect;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.center = self.superview.center;
    [self endEditing:YES];
    
    return YES;
}

- (NSMutableArray *)selectedBtnMArr{

    if (!_selectedBtnMArr) {
        _selectedBtnMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedBtnMArr;
}

- (NSArray *)companyKeyArr{

    if (!_companyKeyArr) {
        _companyKeyArr = @[@"头部反馈",@"企业画像",@"基本信息",@"融资历史",@"公司团队",@"公司公告",@"新闻列表",@"竞品",@"联系方式",@"单轮融资历史",@"工商信息",@"云收藏",@"项目投资人",@"融资需求",@"相关成员",@"项目获奖经历"];
    }
    return _companyKeyArr;
}

- (NSArray *)organizeKeyArr{

    if (!_organizeKeyArr) {
        _organizeKeyArr = @[@"机构头部反馈",@"机构画像",@"投资案例",@"投资团队",@"机构联系方式",@"机构新闻",@"机构获奖经历",@"FA服务案例",@"热门机构"];
    }
    return _organizeKeyArr;
}
@end
