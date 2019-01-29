//
//  ContactInfoCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ContactInfoCell.h"
#import "GetSizeWithText.h"
#import "CopyLabel.h"//带有 长按复制 等功能菜单 的label
#import <MessageUI/MessageUI.h>//发邮件

#import "AlertInfo.h"//弹出框工具栏


@interface ContactInfoCell ()<MFMailComposeViewControllerDelegate>{
    GetSizeWithText *_getSizeWithText;
    AlertInfo *_alertInfoTool;
}
@property (strong, nonatomic) UIImageView *leftIconImgV;//左侧内容
@property (strong, nonatomic) UILabel *titleLabel;//左侧内容
@property (weak, nonatomic) UIViewController *currentVC;//当前控制器

@end

@implementation ContactInfoCell
+ (ContactInfoCell *)cellWithTableView:(UITableView *)tableView {
    ContactInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactInfoCellID"];
    if (cell == nil) {
        cell = [[ContactInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactInfoCellID"];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat top = 0;
        CGFloat height = 20;
        //初始左侧的文本都是两个字,所以width可以确定
        _leftIconImgV = [[UIImageView alloc]initWithFrame:CGRectMake(17, top, 20, height)];
        _leftIconImgV.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_leftIconImgV];
        
        //内容的width根据长短变化,初始化时不指定 frame
        _contentLabel = [[CopyLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:15.f];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLabel.textColor = H9COLOR;
        [self.contentView addSubview:_contentLabel];
        
        
        //给电话号/邮箱 等添加手势,点击时打电话或者发邮件,或者什么也不干
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressLabel)];
        [_contentLabel addGestureRecognizer:tap];
        _contentLabel.userInteractionEnabled = YES;
        
        if (!_getSizeWithText) {
            _getSizeWithText = [[GetSizeWithText alloc] init];
        }
        if (!_alertInfoTool) {
            _alertInfoTool = [[AlertInfo alloc] init];
        }
        
        _showAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 61, 0, 44, 40)];
        [_showAllBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        _showAllBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_showAllBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.contentView addSubview:_showAllBtn];
        
        _showAllBtn2 = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 61-44, 0, 44, 40)];
        [_showAllBtn2 setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        _showAllBtn2.titleLabel.font = [UIFont systemFontOfSize:13];
        [_showAllBtn2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.contentView addSubview:_showAllBtn2];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _showAllBtn.centerY = self.leftIconImgV.centerY;
    _showAllBtn2.centerY = self.leftIconImgV.centerY;
}

//机构
- (void)dataWithKey:(NSString*)key lianxiInfo:(NSDictionary*)lianxiinfo{
   
    NSString * value = lianxiinfo[key];


    if ([key isEqualToString:@"电话"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_phone"];
        _leftIconImgV.tag = 10001;
    }else if ([key isEqualToString:@"邮箱"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_email"];
        _leftIconImgV.tag = 10002;
    }else if ([key isEqualToString:@"地址"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_address"];
        _leftIconImgV.tag = 10003;
        
    }else if ([key isEqualToString:@"其他"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_address"];
        _leftIconImgV.tag = 10004;
        
    }
    _currentVC = [PublicTool topViewController];
    
    UIColor *color = H9COLOR;
    if ([key isEqualToString:@"邮箱"] || [key isEqualToString:@"电话"]) {
        color = BLUE_TITLE_COLOR;
    }
    
    _contentLabel.textColor = color;
    
    [self initKey:key aValue:value];
}

//项目
- (void)dataWithKey:(NSString*)key lianxiModel:(CompanyDetailLianxiModel*)lianxiModel{
    NSString *value;
    if ([key isEqualToString:@"电话"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_phone"];
        _leftIconImgV.tag = 10001;
        value = lianxiModel.phone;
    }else if ([key isEqualToString:@"邮箱"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_email"];
        _leftIconImgV.tag = 10002;
        value = lianxiModel.email;
    }else if ([key isEqualToString:@"地址"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_address"];
        value = lianxiModel.address;
        _leftIconImgV.tag = 10003;

    }else if ([key isEqualToString:@"其他"]) {
        _leftIconImgV.image = [BundleTool imageNamed:@"contactInfo_address"];
        value = lianxiModel.other;
        _leftIconImgV.tag = 10004;

    }
    _currentVC = [PublicTool topViewController];
    
    UIColor *color = H9COLOR;
    if ([key isEqualToString:@"邮箱"] || [key isEqualToString:@"电话"]) {
        color = BLUE_TITLE_COLOR;
    }
    
    _contentLabel.textColor = color;
    
    [self initKey:key aValue:value];
}

/**
 *  给相应控件赋值
 *
 *  @param key
 *  @param value
 */
- (void)initKey:(NSString *)key aValue:(NSString *)value{
    
    _titleLabel.text = [NSString stringWithFormat:@"%@：",key];
    CGFloat width = SCREENW - 69;
    if (self.onlyOneRow) {
        width = SCREENW - 110;
    }
    CGFloat height = [_getSizeWithText calculateSize:value withFont:[UIFont systemFontOfSize:15.f] withWidth:width].height;
    CGFloat x =  52;
    if (height < 25) { //一行
        _contentLabel.frame = CGRectMake( x , 0, width,  20);
        
    }else{
        _contentLabel.frame = CGRectMake( x , 0, width,  height);
    }
    
    _contentLabel.text = value;
    
}

/**
 *  点击右侧按钮  打电话或者发邮件或什么也不干
 */
- (void)pressLabel{
    
    if (_leftIconImgV.tag == 10002) {
        
        if (![MFMailComposeViewController canSendMail]) {
            [PublicTool alertActionWithTitle:@"提示" message:@"不能发送邮件,请检查邮箱设置" btnTitle:@"确定" action:^{
                
            }];
        }
        else{
            [self sendEmail];
        }
        
    }else if (_leftIconImgV.tag == 10001) {
        
        [self makeACall];
    }else if (_leftIconImgV.tag == 10003) { //地址
        
        [PublicTool alertActionWithTitle:nil message:@"复制" leftTitle:@"取消" rightTitle:@"复制" leftAction:^{
            
        } rightAction:^{
            [UIPasteboard generalPasteboard].string = _contentLabel.text;
            [PublicTool showMsg:@"复制成功"];
        }];
    }
    
    
    
}



#pragma mark - 发邮件
/**
 *  发邮件
 */
- (void)sendEmail{
    
    NSString *emailNum = _contentLabel.text;
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertWithMessage:@"用户没有设置邮件账户"];
        return;
    }
    [self displayMailPicker:emailNum];
    
}

/**
 *  调出邮件发送窗口
 *
 *  @param reciver 邮件接收者
 */
- (void)displayMailPicker:(NSString *)reciver
{
    NSMutableString *mailUrl = [[NSMutableString alloc] initWithCapacity:0];
    //添加收件人
    [mailUrl appendFormat:@"mailto:%@", reciver];
    //添加抄送
    [mailUrl appendFormat:@"?cc=%@", @""];
    //添加密送
    [mailUrl appendFormat:@"&bcc=%@",@""];
    //添加主题
    [mailUrl appendString:@"&subject=my email"];
    //添加邮件内容
    [mailUrl appendString:@"&body= body!"];
    NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
    
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [_currentVC dismissViewControllerAnimated:YES completion:nil];
    //[_currentVC dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    
    [self alertWithMessage:msg];
}

/**
 *  使用工具类在当前页面弹窗
 *
 *  @param msg
 */
- (void)alertWithMessage:(NSString *)msg{
    
    [_alertInfoTool alertWithMessage:msg aTitle:@"提示" inController:_currentVC];
}

#pragma mark - 打电话
/**
 *  打电话
 */
- (void)makeACall{
    NSString *phoneNum = _contentLabel.text;
    NSString *tmpPhoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉空格
    NSString *newPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];//例如010-12345678 去掉-变成01012345678
    
    UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [_currentVC.view addSubview:phoneCallWebView];
    
    if([PublicTool isMobileNumber:newPhoneNum]){ //未做检测
//    if([PublicTool checkIsTel:newPhoneNum]){ //检测校验
        NSURL* dialUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", newPhoneNum]];
        if ([[UIApplication sharedApplication] canOpenURL:dialUrl])
        {
            if (phoneCallWebView) {
                [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:dialUrl]];
            }
            else{
                [[UIApplication sharedApplication] openURL:dialUrl];
            }
        }
        else
        {
            [self alertWithMessage:@"设备不支持"];
        }
    } else {
        [self alertWithMessage:@"您选择的号码不合法"];
    }
}
@end

