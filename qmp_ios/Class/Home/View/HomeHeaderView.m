//
//  HomeHeaderView.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HomeHeaderView.h"
//const CGFloat HomeHeaderViewBgHeight = (kStatusBarHeight+47+45);
const CGFloat HomeHeaderMetaViewHeight = 78;
//const CGFloat HomeHeaderTitleViewHeight = 49;
//const CGFloat HomeHeaderMenuViewHeight = 45;


@interface HomeHeaderView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *topCardView;
@property (nonatomic, strong) UIScrollView *metaView;
@property (nonatomic, strong) HomeHeaderViewPageControl *pageControl;

@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, copy) NSString *currentName;

@property (nonatomic, strong) HomeHeaderViewProgress *progressView;

@property (nonatomic, assign) CGFloat y;
@end

@implementation HomeHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentName = @"全部";
        [self addSubview:self.topCardView];
        [self addSubview:self.metaView];
        [self addSubview:self.searchButton];
        
        [self addSubview:self.pageControl];
        self.backgroundColor = [UIColor clearColor];
        
        //        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        //        [self addGestureRecognizer:panGest];
        
        
        //        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"home_create_tip"]) {
        //            CGFloat w = SCREENW / self.metaConfig.count;
        //            UIImageView *imageView = [[UIImageView alloc] init];
        //            imageView.frame = CGRectMake(w/2.0+2, 3, 40, 17);
        //            imageView.image = [UIImage imageNamed:@"home_create_product"];
        //            [_metaView addSubview:imageView];
        //
        //            UIImageView *imageView2 = [[UIImageView alloc] init];
        //            imageView2.frame = CGRectMake(w/2.0+w+2, 3, 40, 17);
        //            imageView2.image = [UIImage imageNamed:@"home_create_finance"];
        //            [_metaView addSubview:imageView2];
        //        }
        //
        //        UIView *topGrayView = [[UIView alloc] init];
        //        topGrayView.frame = CGRectMake(0, self.metaView.bottom, SCREENW, 10.0);
        //        topGrayView.backgroundColor = TABLEVIEW_COLOR;
        //        [self addSubview:topGrayView];
        //
        //        UIView *view = [[UIView alloc] init];
        //        view.frame = CGRectMake(0, self.metaView.bottom+20, SCREENW, HomeHeaderTitleViewHeight-10);
        //        view.backgroundColor = [UIColor whiteColor];
        //        [self addSubview:view];
        //        self.titleView = view;
        //
        //        UILabel *titleLabel = [[UILabel alloc] init];
        //        titleLabel.frame = CGRectMake(17, 16, 120, 18);
        //        titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        //        titleLabel.textColor = H3COLOR;
        //        titleLabel.text = @"最近发生";
        //        [view addSubview:titleLabel];
        //
        //        [self addSubview:self.menuView];
        
    }
    return self;
}
//-(void)layoutSubviews {
//    [super layoutSubviews];
//
//}

- (void)hideCreateTip {
    for (UIView *view in self.metaView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
}
- (void)pan:(UIPanGestureRecognizer *)panGest {
    UIView *view = panGest.view;
    CGPoint move = [panGest translationInView:view];
    
    if (panGest.state == UIGestureRecognizerStateBegan) {
        
    } else if (panGest.state == UIGestureRecognizerStateChanged) {
        if (self.top >= 0 && move.y > 0) {
        } else {
            CGFloat top = self.top + move.y;
            self.top = MIN(top, 0);
            if ([self.delegate respondsToSelector:@selector(homeHeaderView:didScroll:)]) {
                [self.delegate homeHeaderView:self didScroll:top];
            }
        }
    } else if (panGest.state == UIGestureRecognizerStateChanged ||
               panGest.state == UIGestureRecognizerStateFailed) {
        
    }
    
    [panGest setTranslation:CGPointMake(0, 0) inView:view];
}

- (void)searchButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(homeHeaderView:searchButtonClick:)]) {
        [self.delegate homeHeaderView:self searchButtonClick:button];
    }
}
- (void)metaButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(homeHeaderView:metaButtonClick:)]) {
        [self.delegate homeHeaderView:self metaButtonClick:button];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (scrollView.contentOffset.x + SCREENW/2.0) / SCREENW;
    //    CGFloat x = scrollView.contentOffset.x;
    //    self.progressView.progress = x / SCREENW;
}
- (void)pageControlValueChange:(UIPageControl *)page {
    self.metaView.contentOffset = CGPointMake(self.pageControl.currentPage * SCREENW, 0);
}
#pragma mark - Getter
- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[UIButton alloc] init];
        _searchButton.frame = CGRectMake(13, self.topCardView.bottom-45, SCREENW-26, 45);
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _searchButton.backgroundColor = [UIColor whiteColor];
        [_searchButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_searchButton setTitle:@"项目、机构、人物、新闻、公司、报告" forState:UIControlStateNormal];
        [_searchButton setImage:[UIImage imageNamed:@"home_search_button"] forState:UIControlStateNormal];
        _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
        _searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12+12, 0, 0);
       
        _searchButton.layer.shadowColor = HTColorFromRGB(0xDDDDDD).CGColor;//shadowColor阴影颜色
        _searchButton.layer.shadowOpacity = 0.9;//阴影透明度，默认0
        _searchButton.layer.shadowRadius = 2;//阴影半径，默认3
        _searchButton.layer.shadowOffset = CGSizeMake(0,0);
        _searchButton.layer.cornerRadius = 1;
//        _searchButton.layer.masksToBounds = YES;
        _searchButton.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        _searchButton.layer.borderWidth = 1;

        [_searchButton addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}
- (NSArray *)metaConfig {
    if (!_metaConfig) {
        _metaConfig = @[
                        @{@"title":@"极速找人", @"icon":@"home_person_lib"},
                        @{@"title":@"投资机会", @"icon":@"home_opportunity"},
                        @{@"title":@"项目库", @"icon":@"home_product"},
                        @{@"title":@"行研报告", @"icon":@"home_report"},
                        @{@"title":@"融资统计", @"icon":@"home_invest_statistics"},
                        
                        @{@"title":@"项目专辑", @"icon":@"home_album"},
                        @{@"title":@"图谱", @"icon":@"home_map"},
                        @{@"title":@"机构库", @"icon":@"home_organize_lib"},
                        @{@"title":@"招股书", @"icon":@"home_ipo_report"},
                        @{@"title":@"二级市场", @"icon":@"home_secondary_market"},
                        
                        ];
    }
    return _metaConfig;
}
- (UIScrollView *)metaView {
    if (!_metaView) {
        _metaView = [[UIScrollView alloc] init];
        _metaView.frame = CGRectMake(0, self.topCardView.bottom, SCREENW, HomeHeaderMetaViewHeight);
        _metaView.contentSize = CGSizeMake(SCREENW*2, HomeHeaderMetaViewHeight);
        _metaView.pagingEnabled = YES;
        _metaView.showsHorizontalScrollIndicator = NO;
        _metaView.backgroundColor = [UIColor whiteColor];
        _metaView.delegate = self;
        
        CGFloat w = SCREENW / 5;
        NSInteger i = 0;
        for (NSDictionary *dict in self.metaConfig) {
            UIButton *button = [self metaButtonWithTitle:dict[@"title"] image:dict[@"icon"] left:w*i width:w];
            button.tag = i;
            [button addTarget:self action:@selector(metaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_metaView addSubview:button];
            i++;
        }
        
    }
    return _metaView;
}
- (HomeHeaderViewPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[HomeHeaderViewPageControl alloc] initWithFrame: CGRectMake(0, self.metaView.top + 72, SCREENW, 5)];
        _pageControl.frame = CGRectMake((SCREENW-16)/2.0, self.metaView.bottom - 8, 16, 5);
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];//HTColorFromRGB(0x006EDA);
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];//HTColorFromRGB(0xCCCCCC);
    }
    return _pageControl;
}
- (UIButton *)metaButtonWithTitle:(NSString *)title image:(NSString *)image left:(CGFloat)left width:(CGFloat)w {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(left, 8, w, 62);
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:COLOR2D343A forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateHighlighted];
    [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    return button;
}


- (UIView *)topCardView {
    if (!_topCardView) {
        _topCardView = [[UIView alloc] init];
        _topCardView.frame = CGRectMake(0, 0, SCREENW, HomeHeaderViewBgHeight);
        _topCardView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *titleView = [[UIImageView alloc] init];
        titleView.frame = CGRectMake(13, kStatusBarHeight+11, 67, 20);
        titleView.image = [UIImage imageNamed:@"home_header_title"];
        titleView.contentMode = UIViewContentModeScaleAspectFit;
        [_topCardView addSubview:titleView];
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.frame = CGRectMake(titleView.right+8, 0, 250, 18);
        descLabel.font = [UIFont systemFontOfSize:13];
        descLabel.textColor = HTColorFromRGB(0x838CA1);
        descLabel.text = @"商业信息服务平台";
        [_topCardView addSubview:descLabel];
        descLabel.centerY = titleView.centerY;
        
//        UIImageView *msgIcon = [[UIImageView alloc] init];
//        msgIcon.frame = CGRectMake(SCREENW-41, kStatusBarHeight+11, 41, 40);
//        msgIcon.image = [UIImage imageNamed:@"nabar_msgicon"];
//        msgIcon.contentMode = UIViewContentModeCenter;
//        msgIcon.centerY = titleView.centerY;
//        [_topCardView addSubview:msgIcon];
        
    }
    return _topCardView;
}


- (HomeHeaderViewProgress *)progressView {
    if (!_progressView) {
        _progressView = [[HomeHeaderViewProgress alloc] init];
        _progressView.frame = CGRectMake((SCREENW-25)/2.0, 66+self.metaView.top, 25, 3);
        _progressView.backgroundColor = HTColorFromRGB(0xCCCCCC);
        _progressView.layer.cornerRadius = 1.5;
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}
@end

@implementation HomeHeaderViewPageControl

- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    
    [self updateDots];
}


- (void)updateDots{
    for (int i = 0; i < [self.subviews count]; i++) {
        UIImageView *dot = [self imageViewForSubview:[self.subviews objectAtIndex:i] currPage:i];
        if (i == self.currentPage){
            //            dot.image = self.currentImage;
            //            dot.size = self.currentImageSize;
            dot.backgroundColor = HTColorFromRGB(0x006EDA);//self.currentPageIndicatorTintColor;
            dot.bounds = CGRectMake(0, 0, 4, 4);
            dot.layer.cornerRadius = 2;
        }else{
            //            dot.image = self.inactiveImage;
            //            dot.size = self.inactiveImageSize;
            dot.backgroundColor = HTColorFromRGB(0xCCCCCC);//self.pageIndicatorTintColor;
            dot.bounds = CGRectMake(0, 0, 4, 4);
            dot.layer.cornerRadius = 2;
        }
    }
}
- (UIImageView *)imageViewForSubview:(UIView *)view currPage:(int)currPage{
    UIImageView *dot = nil;
    if ([view isKindOfClass:[UIView class]]) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            
            [view addSubview:dot];
        }
    }else {
        dot = (UIImageView *)view;
    }
    
    return dot;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    //计算圆点间距
    CGFloat marginX = 5 + 2;
    
    //计算整个pageControll的宽度
    CGFloat newW = (self.subviews.count - 1 ) * marginX;
    
    //设置新frame
    self.frame = CGRectMake(SCREENW/2-(newW + 5)/2, self.frame.origin.y, newW + 5, self.frame.size.height);
    
    //遍历subview,设置圆点frame
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, 4, 4)];
        }else {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, 4,4)];
        }
    }
}
@end


@implementation HomeHeaderViewProgress

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat blueW = 15;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat x = _progress * 10;
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, 0, blueW, 3) cornerRadius:1.5];
    [HTColorFromRGB(0x006EDA) set];
    [path fill];
    
    
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}
@end
