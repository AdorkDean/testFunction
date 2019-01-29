//
//  NoInterestView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NoInterestView.h"
#import "TestNetWorkReached.h"
#import "HMTextView.h"
#import "AllFeedbackViewController.h"

#define AlertViewJianGe (42*ratioWidth)
@interface NoInterestView()<UITextViewDelegate>
{
    
    UIImageView *selfImage;
    float alertViewHeight;
    NSInteger _rowCount;
}

@property (strong, nonatomic) NSArray *companyKeyArr;
@property (strong, nonatomic) NSArray *organizeKeyArr;
@property (assign, nonatomic) BOOL isFeeds;//是否是信息流反馈

@end
@implementation NoInterestView


- (instancetype)initWithAlertViewTitles:(NSArray *)mArr  viewcontroller:(UIViewController *)vc{

    self=[super init];
    if (self) {
        [self buidUIWithAlertViewHeight:mArr viewcontroller:vc];
    }
    return self;
}

- (void)buidUIWithAlertViewHeight:(NSArray *)mArr viewcontroller:(UIViewController *)vc{
    
    //几行button
    _rowCount = mArr.count%2>0 ? (mArr.count/2+1):mArr.count/2;
    CGFloat AlertViewHeight = _rowCount*(30+15) + 65 + 84 + (_rowCount == 3 ? 90:114);
    _VC = vc;

    
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
    
    [self addLbl];
    
    //叉号
    UIButton *dispearBtn = [[UIButton alloc]initWithFrame:CGRectMake(selfImage.width - 14-50, 2, 45, 45)];
    [dispearBtn setImage:[BundleTool imageNamed:@"feedback_del"] forState:UIControlStateNormal];
    [dispearBtn addTarget:self action:@selector(dispAppear:) forControlEvents:UIControlEventTouchUpInside];
    [dispearBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [selfImage addSubview:dispearBtn];
    
    
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
    HMTextView *inputView = [[HMTextView alloc] initWithFrame:CGRectMake(margin, selfImage.height - h - 84, selfImage.width - margin * 2, h)];
    self.textview = inputView;
    inputView.placehoder = @"备注";
    inputView.delegate = self;
    inputView.layer.masksToBounds = YES;
    inputView.layer.cornerRadius = 2;
    inputView.layer.borderColor = HTColorFromRGB(0x777777).CGColor;
    inputView.layer.borderWidth = 0.5;
    [selfImage addSubview:inputView];
}

- (void)addLbl{
    
    _lab = [[UILabel alloc] init];
    _lab.frame = CGRectMake(23*ratioWidth,25, 130, 15);
    if (@available(iOS 8.2, *)) {
        _lab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        _lab.font = [UIFont systemFontOfSize:15];
    }
    _lab.adjustsFontSizeToFitWidth = YES;
    _lab.textColor = HTColorFromRGB(0x666666);
    
    _lab.text = @"反馈理由，精准屏蔽";

    [selfImage addSubview:_lab];
    self.titleLabel =_lab;
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
        self.submitBtnClick([self toGetSelectText], _textview.text);
        [self removeFromSuperview];
        return;
    }
//    if (![self.textview.text isEqualToString:@""] || (self.selectedBtnMArr && self.selectedBtnMArr.count > 0) ) {
//
//    }else{
//        [PublicTool showMsg:@"请完善反馈数据"];
//        return;
//    }
//
//    if (_isFeeds) {
//        [self requestUploadFeeds];
//    }
//    else{
//        [self immediateFeedbackUs];
//    }
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

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    if (![textView.text isEqualToString:@""] || (self.selectedBtnMArr && self.selectedBtnMArr.count > 0) ) {
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


- (NSMutableString *)toGetSelectText{
    
    NSMutableString *miaoshu = [NSMutableString stringWithCapacity:0];
    for (int i=0; i<self.selectedBtnMArr.count; i++) {
        if (i==self.selectedBtnMArr.count-1) {
            [miaoshu appendFormat:@"%@",self.selectedBtnMArr[i]];
        }else{
            [miaoshu appendFormat:@"%@|",self.selectedBtnMArr[i]];
        }
    }
    
//    [miaoshu appendString:[NSString stringWithFormat:@"|%@",_textview.text]];
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


@end
