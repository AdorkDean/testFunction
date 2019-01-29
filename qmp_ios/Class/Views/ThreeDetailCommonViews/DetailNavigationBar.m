//
//  DetailNavigationBar.m
//  qmp_ios
//
//  Created by QMP on 2018/7/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailNavigationBar.h"
#import "LrdOutputView.h"

@interface DetailNavigationBar()<LrdOutputViewDelegate>

@property(nonatomic,strong)UIActivityIndicatorView *animatorView;

@property(nonatomic,strong)UIButton *backBtn;
@property(nonatomic,strong)UIButton *shareBtn;
@property(nonatomic,strong)UIButton *moreBtn;
@property(nonatomic,strong)NSArray *rightMenuArr;
@property(nonatomic,strong)UILabel *titleLabel;

@property(nonatomic,copy)void(^shareBtnEvent)(void);
@property(nonatomic,strong)void(^moreBtnEvent)(void);
@property(nonatomic,strong)LrdOutputView *outputView;

@property(nonatomic,assign)BOOL isWhite;

@end


@implementation DetailNavigationBar

// 没有分享 没有更多
+ (instancetype)detailTopBarNoBtn{
    DetailNavigationBar *topBar = [[DetailNavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenTopHeight)];
    topBar.backgroundColor = [UIColor redColor];
    [topBar addViews];
    return topBar;
}


//没有分享
+ (instancetype)detailTopBarWithRightMenuArr:(NSArray*)menuArr  moreClick:(void(^)(void))moreClickEvent{
    DetailNavigationBar *topBar = [[DetailNavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenTopHeight)];
    topBar.backgroundColor = [UIColor redColor];
    topBar.rightMenuArr = menuArr;
    topBar.moreBtnEvent = moreClickEvent;
    [topBar addViews];
    return topBar;
}

+ (instancetype)detailTopBarWithRightMenuArr:(NSArray*)menuArr shareEvent:(void(^)(void))shareEvent moreClick:(void(^)(void))moreClickEvent;{
    DetailNavigationBar *topBar = [[DetailNavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenTopHeight)];
    topBar.backgroundColor = [UIColor redColor];
    topBar.rightMenuArr = menuArr;
    topBar.shareBtnEvent = shareEvent;
    topBar.moreBtnEvent = moreClickEvent;
    [topBar addViews];
    return topBar;
}

+ (instancetype)detailTopBarWithShareClick:(void(^)(void))shareClickEvent{
    DetailNavigationBar *topBar = [[DetailNavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenTopHeight)];
    topBar.backgroundColor = [UIColor redColor];
    topBar.shareBtnEvent = shareClickEvent;
    [topBar addViews];
    return topBar;
}

- (void)addViews{
    [self addSubview:self.backBtn];
    if (self.shareBtnEvent) {
        [self addSubview:self.shareBtn];
    }
    if (self.moreBtnEvent) {
        [self addSubview:self.moreBtn];
    }
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.animatorView];
    self.animatorView.centerX = self.width/2.0;
    self.animatorView.hidden = YES;
    [self changeColorToWhite:YES];
    if (!self.rightMenuArr || self.rightMenuArr.count == 0) {
        self.shareBtn.left = SCREENW - 51;
        [self.shareBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    }
    //底部line
//    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenTopHeight-0.5, SCREENW, 0.5)];
//    [self addSubview:bottomLine];
}



- (UIButton *)backBtn{
    if (!_backBtn) {
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(15, kStatusBarHeight, 50, kNavigationBarHeight)];
        [leftButton setImage:[BundleTool imageNamed:@"detail_leftArrow"] forState:UIControlStateNormal];
        [leftButton setImage:[BundleTool imageNamed:@"detail_leftArrow"] forState:UIControlStateHighlighted];
        [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];

        _backBtn = leftButton;
    }
    return _backBtn;
}

- (UIButton *)shareBtn{
    if (!_shareBtn) {
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 100, kStatusBarHeight, 50, kNavigationBarHeight)];
        [leftButton setImage:[BundleTool imageNamed:@"detail_shareIcon"] forState:UIControlStateNormal];
        [leftButton setImage:[BundleTool imageNamed:@"detail_shareIcon"] forState:UIControlStateHighlighted];
        [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [leftButton addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        _shareBtn = leftButton;
    }
    return _shareBtn;
}


- (UIButton *)moreBtn{
    if (!_moreBtn) {
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 51, kStatusBarHeight, 50, kNavigationBarHeight)];
        [leftButton setImage:[BundleTool imageNamed:@"detail_moreIcon_white"] forState:UIControlStateNormal];
        [leftButton setImage:[BundleTool imageNamed:@"detail_moreIcon_white"] forState:UIControlStateHighlighted];
        [leftButton addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        _moreBtn = leftButton;
    }
    return _moreBtn;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, kStatusBarHeight, SCREENW - 200, kNavigationBarHeight)];
        [label labelWithFontSize:18 textColor:NV_TITLE_COLOR];
        label.textAlignment = NSTextAlignmentCenter;
        
        _titleLabel = label;
    }
    return _titleLabel;
}

-(UIActivityIndicatorView *)animatorView{
    if (!_animatorView) {
        _animatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _animatorView.hidesWhenStopped = YES;
        _animatorView.frame = CGRectMake(45, kStatusBarHeight, 40, kNavigationBarHeight);
    }
    return _animatorView;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    self.titleLabel.textColor = _titleColor;
}

#pragma mark --EVent
- (void)changeColorToWhite:(BOOL)isWhite{
    if (isWhite) {
        _isWhite = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self.backBtn setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
        [self.backBtn setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateHighlighted];
        if (self.moreBtn) {
            [self.moreBtn setImage:[BundleTool imageNamed:@"detail_moreIcon"] forState:UIControlStateNormal];
            [self.moreBtn setImage:[BundleTool imageNamed:@"detail_moreIcon"] forState:UIControlStateHighlighted];
        }
        if (self.shareBtn) {
            [self.shareBtn setImage:[BundleTool imageNamed:@"detail_share"] forState:UIControlStateNormal];
            [self.shareBtn setImage:[BundleTool imageNamed:@"detail_share"] forState:UIControlStateHighlighted];
        }
        self.titleLabel.textColor = NV_TITLE_COLOR;


    }else{
        
        _isWhite = NO;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        [self.backBtn setImage:[BundleTool imageNamed:@"detail_leftArrow"] forState:UIControlStateNormal];
        [self.backBtn setImage:[BundleTool imageNamed:@"detail_leftArrow"] forState:UIControlStateHighlighted];
        if (self.moreBtn) {
            [self.moreBtn setImage:[BundleTool imageNamed:@"detail_moreIcon_white"] forState:UIControlStateNormal];
            [self.moreBtn setImage:[BundleTool imageNamed:@"detail_moreIcon_white"] forState:UIControlStateHighlighted];
        }
        if (self.shareBtn) {
            [self.shareBtn setImage:[BundleTool imageNamed:@"detail_shareIcon"] forState:UIControlStateNormal];
            [self.shareBtn setImage:[BundleTool imageNamed:@"detail_shareIcon"] forState:UIControlStateHighlighted];

        }
        self.titleLabel.textColor = [UIColor clearColor];

    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}
- (BOOL)isWhite{
    return _isWhite;
}

- (void)popSelf{
    
    [[PublicTool topViewController].navigationController popViewControllerAnimated:YES];
}

- (void)showAnimator{
    [self.animatorView startAnimating];
    self.animatorView.hidden = NO;
}

- (void)hideAnimator{
    if (self.animatorView.isAnimating) {
        [self.animatorView stopAnimating];
    }
}
- (void)shareBtnClick{
    if (self.shareBtnEvent) {
        self.shareBtnEvent();
    }
}

- (void)moreBtnClick{
    if (self.moreBtnEvent) {
        self.moreBtnEvent();
    }
}

@end
