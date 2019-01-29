//
//  SearchJgAndCNotFoundTableViewCell.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/4.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SearchJgAndCNotFoundTableViewCell.h"
#import "FactoryUI.h"
#import "BaseWebViewController.h"
#import "URLModel.h"

#import "UIViewAdditions.h"
#import "SMPagerTabView.h"
#import "FeedbackDetailViewControlerViewController.h"
@interface SearchJgAndCNotFoundTableViewCell()<SMPagerTabViewDelegate>
@property (nonatomic, strong) NSMutableArray *allVC;
@property (nonatomic, strong) SMPagerTabView *segmentView;
@end

@implementation SearchJgAndCNotFoundTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andVC:(UIViewController *)vc andSearchStr:(NSString *)searchStr
{
    _searchStr = searchStr;
    _vc = vc;
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];//cell背景

    _strLab1 = [FactoryUI createLabelWithFrame:CGRectMake(10, 5, SCREENW-20, 35) text:@"" font:[UIFont systemFontOfSize:12]];//SCREENW-20-96
    _strLab1.numberOfLines = 3;
    _strLab1.lineBreakMode = NSLineBreakByWordWrapping;
    _strLab1.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_strLab1];
    
    _feedbackBtn = [FactoryUI createButtonWithFrame:CGRectMake(10, 40, SCREENW-20, 30) title:@"请帮我人工完善信息" titleColor:nil imageName:nil backgroundImageName:@"" target:nil selector:nil];//170
    [_feedbackBtn setTitle:@"已收到您的反馈" forState:UIControlStateSelected];
    //设置标题颜色
    [_feedbackBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [_feedbackBtn setTitleColor:RGB(202, 68, 61, 1) forState:UIControlStateNormal];
    [_feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    _feedbackBtn.layer.cornerRadius = 5;
    _feedbackBtn.layer.masksToBounds = YES;
    
    _feedbackBtn.layer.borderWidth = 0.5;
    _feedbackBtn.userInteractionEnabled = YES;
//    [self.contentView addSubview:_feedbackBtn];
    _feedbackBtn.layer.borderColor = RGB(202, 68, 61, 1).CGColor;
    
    _webView = [[UIView alloc]initWithFrame:CGRectMake(0, _strLab1.frame.origin.y+_strLab1.frame.size.height, SCREENW, SCREENH-(_strLab1.frame.origin.y+_strLab1.frame.size.height+kScreenTopHeight))];
    [self.contentView addSubview:_webView];
    
    _allVC = [NSMutableArray array];
    URLModel *urlModel2 = [[URLModel alloc]init];
    urlModel2.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",[_searchStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    BaseWebViewController *webView1 = [[BaseWebViewController alloc] initWithUrlModel:urlModel2];
    webView1.title = @"百度一下";
    webView1.feedbackFlag = @"1";
    [webView1.view setFrame:CGRectMake(0, 0, SCREENW, SCREENH-(_strLab1.frame.origin.y+_strLab1.frame.size.height+5+kScreenTopHeight))];
    [_allVC addObject:webView1];
    
    URLModel *urlModel1 = [[URLModel alloc]init];
    urlModel1.url = [NSString stringWithFormat:@"http://m.tianyancha.com/search?key=%@",[_searchStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    BaseWebViewController *webView = [[BaseWebViewController alloc] initWithUrlModel:urlModel1];
    webView.title = @"天眼一下";
    webView.feedbackFlag = @"1";
    [webView.view setFrame:CGRectMake(0, 0, SCREENW, SCREENH-(_strLab1.frame.origin.y+_strLab1.frame.size.height+5+kScreenTopHeight))];
    [_allVC addObject:webView];

    
    FeedbackDetailViewControlerViewController *feedback = [[FeedbackDetailViewControlerViewController alloc]init];
    feedback.searchStr = _searchStr;
    feedback.title = @"反馈";
    feedback.from = @"搜索未命中";
    [_allVC addObject:feedback];
    
    self.segmentView.delegate = self;
    //可自定义背景色和tab button的文字颜色等
    
    //开始构建UI
    [_segmentView buildUI];
    //起始选择一个tab
    [_segmentView selectTabWithIndex:0 animate:NO];
    
    //显示红点，点击消失
//    [_segmentView showRedDotWithIndex:0];
}
#pragma mark - DBPagerTabView Delegate
- (NSUInteger)numberOfPagers:(SMPagerTabView *)view {
    return [_allVC count];
}
- (UIViewController *)pagerViewOfPagers:(SMPagerTabView *)view indexOfPagers:(NSUInteger)number {
    return _allVC[number];
}

- (void)whenSelectOnPager:(NSUInteger)number {
//    NSLog(@"页面 %lu",(unsigned long)number);
}

#pragma mark - setter/getter
- (SMPagerTabView *)segmentView {
    if (!_segmentView) {
        self.segmentView = [[SMPagerTabView alloc]initWithFrame:CGRectMake(0, 0, _webView.width, _webView.height)];
        [_webView addSubview:_segmentView];
    }
    return _segmentView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
