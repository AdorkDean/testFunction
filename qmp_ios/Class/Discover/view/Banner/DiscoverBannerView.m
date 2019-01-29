//
//  DiscoverBannerView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DiscoverBannerView.h"
#import "GPBannerView.h"
#import "MyPageControl.h"

@interface DiscoverBannerView()<GPBannerViewDelegate>

@property(nonatomic,strong)GPBannerView *bannerV;
@property(nonatomic,strong)MyPageControl *pageControl;
@property(nonatomic,copy)void (^didSelectedIndex)(NSInteger);

@end


@implementation DiscoverBannerView

-(DiscoverBannerView *)initWithFrame:(CGRect)frame didSelectedIndex:(void (^)(NSInteger))didSelectedIndex{
    if (self = [super initWithFrame:frame]) {
        [self addView];
        self.didSelectedIndex = didSelectedIndex;
    }
    
    return self;
}


- (void)addView{
    
    [self addSubview:self.bannerV];
    [self addSubview:self.pageControl];
    self.pageControl.centerX = self.width/2.0;
}

- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    
    _pageControl.hidden = YES;
    self.pageControl.numberOfPages = dataSource.count;
    CGSize size = CGSizeMake(6 * (_pageControl.numberOfPages * 2 - 1), SCREENW*22/375);

    _pageControl.frame = CGRectMake(0, self.height - size.height, size.width, size.height);
    _pageControl.centerX = self.width/2.0;
    
    self.bannerV.dataSource = dataSource;
    
    _pageControl.hidden = NO;

}


- (void)bannerView:(GPBannerView *)bannerView didSelectedAtIndex:(NSInteger)index{
    self.didSelectedIndex(index);
}

- (void)bannerView:(GPBannerView *)bannerView didShowAtIndex:(NSInteger)index{
    
    [self.pageControl setCurrentPage:index];
}

-(MyPageControl *)pageControl{
    
    if(!_pageControl){
        
        _pageControl = [[MyPageControl alloc]initWithFrame:CGRectMake(self.width/2.0-50, CGRectGetHeight(self.bounds) - 40*ratioHeight, 100, 40)];
        [_pageControl setCurrentPage:0];
        _pageControl.currentPageIndicatorTintColor = BLUE_BG_COLOR;
        _pageControl.pageIndicatorTintColor = HTColorFromRGB(0xE3E3E3) ;
        _pageControl.pointWidth = 6;
        _pageControl.pointMargin = 6;
//        [_pageControl setValue:[UIImage imageNamed:@"hot_icon"] forKeyPath:@"_pageImage"];
//
//        [_pageControl setValue:[UIImage imageNamed:@"hot_icon"] forKeyPath:@"_currentPageImage"];
      
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

-(GPBannerView *)bannerV{
    
    if (!_bannerV) {
        
        CGRect bannerFrame = CGRectMake(0, 8, self.width, self.height - 8 - SCREENW*22/375);
        
        GPBannerView *bannerView = [GPBannerView bannerViewWithFrame:bannerFrame dataSource:@[]];
        
        bannerView.maxWidth = CGRectGetWidth(bannerFrame)-50*ratioWidth;
        bannerView.designWidth = 152;
        bannerView.designHeight = 130;
        bannerView.widthHeightScale =  33.0/14.0;

        bannerView.delegate = self;
        
        _bannerV = bannerView;
    }
    
    return _bannerV;
}


@end
