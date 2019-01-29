//
//  CardScanView.m
//  qmp_ios
//
//  Created by QMP on 2017/12/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CardScanView.h"

@interface CardScanView()<UIScrollViewDelegate>
{
    UIImageView *_firstImgV;
    UIImageView *_secondImgV;
    UIScrollView *_firstScrollV;
    UIScrollView *_secondScrollV;
    CGFloat lastContentOffsetX;

}
@end

@implementation CardScanView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addView];
        self.backgroundColor = [UIColor blackColor];
        self.pagingEnabled = YES;
        self.bounces = NO;
    
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeFromSuperview)];
//        [self addGestureRecognizer:tap];
        
    }
    return self;
}


- (void)addView{
    UIScrollView *scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    scrollV.showsHorizontalScrollIndicator = NO;
    scrollV.delegate = self;
    scrollV.maximumZoomScale = 2;
    scrollV.minimumZoomScale = 1;
    [self addSubview:scrollV];
    
    UIScrollView *scrollV2 = [[UIScrollView alloc]initWithFrame:CGRectMake(SCREENW, 0, SCREENW, SCREENH)];
    scrollV2.showsHorizontalScrollIndicator = NO;
    scrollV2.maximumZoomScale = 2;
    scrollV2.minimumZoomScale = 1;
    scrollV2.delegate = self;
    [self addSubview:scrollV2];
    
    _firstImgV = [[UIImageView alloc]initWithFrame:scrollV.bounds];
    [scrollV addSubview:_firstImgV];
    _firstImgV.userInteractionEnabled = YES;
    _firstImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    _secondImgV = [[UIImageView alloc]initWithFrame:scrollV2.bounds];
    [scrollV2 addSubview:_secondImgV];
    _secondImgV.userInteractionEnabled = YES;
    _secondImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    _firstScrollV = scrollV;
    _secondScrollV = scrollV2;
    
}

- (void)setImgArr:(NSArray *)imgArr{
    
    _imgArr = imgArr;
    if (imgArr.count == 1) {
        self.contentSize = CGSizeMake(SCREENW, 0);
        _firstImgV.image = imgArr[0];
        
    }else if (imgArr.count == 2) {
        
        self.contentSize = CGSizeMake(SCREENW*2, 0);
        _firstImgV.image = imgArr[0];
        _firstScrollV.contentSize = _firstImgV.image.size;
        
        if ([imgArr[1] isKindOfClass:[NSString class]]) {
            [_secondImgV sd_setImageWithURL:[NSURL URLWithString:imgArr[1]] placeholderImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_secondImgV.size]];
        }else{
            _secondImgV.image = imgArr[1];

        }
    }
    _firstScrollV.contentSize = _firstImgV.size;
    _secondScrollV.contentSize = _secondImgV.size;
}


- (void)refreshSubViews{
    if (lastContentOffsetX == self.contentOffset.x) {
        return;
        
    }else if(self.contentOffset.x == 0 || self.contentOffset.x == SCREENW){ //滑动结束
        [_firstScrollV setZoomScale:1 animated:YES];
        [_secondScrollV setZoomScale:1 animated:YES];
    }
    lastContentOffsetX = self.contentOffset.x;
    
}

#pragma mark --UIScrollViewDelegate--

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIImageView *imgV in scrollView.subviews) {
        if ([imgV isKindOfClass:[UIImageView class]]) {
            return imgV;
        }
    }
    return nil;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
   
    if (scrollView == _firstScrollV) {
        _firstImgV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
    }else{
        _secondImgV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
    }

}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{

    [scrollView setZoomScale:scale animated:NO];
}


@end
