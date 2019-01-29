//
//  LoadingAnimator.m
//  qmp_ios
//
//  Created by QMP on 2018/1/24.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "LoadingAnimator.h"

#define ORIGINALFRAME CGRectMake(self.iconImg.frame.origin.x-10, self.iconImg.top, 20, 55)
#define ENDFRAME      (self.iconImg.right, self.iconImg.top, 20, 55)

@interface LoadingAnimator()
{
    CGFloat time;
}
@property(nonatomic,strong)UIImageView *iconImg;
@property(nonatomic,strong)UIImageView *sliderView;
@property(nonatomic,strong)UIImageView *sliderView1;

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSTimer *timer1;


@end
@implementation LoadingAnimator

-(void)dealloc{
  
    [self stopTimer];
}

-(instancetype)init{
    if (self = [super init]) {
        [self addView];
    }
    return self;
}

- (void)addView{
    self.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    self.backgroundColor = [UIColor whiteColor];
    
    self.iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 131, 65)];
    self.iconImg.image = [BundleTool imageNamed:@"loadingBgIcon"];
    [self addSubview:self.iconImg];
    self.iconImg.center = self.center;
    
    self.sliderView = [[UIImageView alloc]initWithFrame:ORIGINALFRAME];
    self.sliderView.image = [BundleTool imageNamed:@"loadingSlider"];
    [self addSubview:self.sliderView];
    [self.sliderView setContentMode:UIViewContentModeCenter];
    
    self.sliderView1 = [[UIImageView alloc]initWithFrame:ORIGINALFRAME];
    self.sliderView1.image = [BundleTool imageNamed:@"loadingSlider"];
    [self.sliderView1 setContentMode:UIViewContentModeCenter];

    [self addSubview:self.sliderView1];
}

- (void)showAnimatorInView:(UIView*)view{
    
    [view addSubview:self];
    self.frame = view.bounds;
    self.center = CGPointMake(view.width/2.0, view.height/2.0);
    self.iconImg.center = self.center;
    self.iconImg.top = self.height/2.0-120*ratioHeight;
    self.sliderView.frame = ORIGINALFRAME;
    self.sliderView1.frame = ORIGINALFRAME;
    time = 0.1;
    
    [self beginAnimator];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginAnimator) userInfo:nil repeats:YES];
    _timer1 = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(beginAnimator1) userInfo:nil repeats:YES];
    
}

- (void)dismissAnimatorInView:(UIView*)view{
    
    [self removeFromSuperview];
    [self stopTimer];

}

- (void)beginAnimator1{
    if (time < 0.5) {
        time = time + 0.1;
    }

}

- (void)beginAnimator{
    
    [UIView animateWithDuration:1 animations:^{
        
        self.sliderView.transform = CGAffineTransformMakeTranslation(131, 0);
       
        if (time >= 0.5) {
            [UIView animateWithDuration:1 animations:^{
    
                self.sliderView1.transform = CGAffineTransformMakeTranslation(131, 0);
    
            } completion:^(BOOL finished) {
    
                self.sliderView1.transform = CGAffineTransformIdentity;
    
            }];
            time = 0.0;
        }
        
    } completion:^(BOOL finished) {
        
        self.sliderView.transform = CGAffineTransformIdentity;
        
    }];

}

- (void)stopTimer{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    if ([_timer1 isValid]) {
        [_timer1 invalidate];
    }
    
    _timer = nil;
    _timer1 = nil;
}

@end
