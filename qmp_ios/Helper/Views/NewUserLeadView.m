//
//  NewUserLeadView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NewUserLeadView.h"

@interface NewUserLeadView()
{
    NSString *_leadingKey;
}
@end

@implementation NewUserLeadView


- (instancetype)initWithshadeFrame:(CGRect)shadeFrame shadeStyle:(ShadeStyle)shadeStyle imageFrame:(CGRect)imageFrame  image:(UIImage*)image leaderKey:(NSString*)leaderKey{
    
    CGRect frame = [UIScreen mainScreen].bounds;

    if (self = [super initWithFrame:frame]) {
        // 这里创建指引在这个视图在window上
        CGRect frame = [UIScreen mainScreen].bounds;
        self.frame = frame;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sureTapClick:)];
        [self addGestureRecognizer:tap];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        _leadingKey = leaderKey;
        //create path 重点来了（**这里需要添加第一个路径）
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
        
        if (shadeStyle == ShadeStyle_rect) {
            // 这里添加第二个路径 （这个是矩形）
            [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:shadeFrame cornerRadius:5] bezierPathByReversingPath]];

        }else if(shadeStyle == ShadeStyle_circle){
            // 这里添加第二个路径 （这个是圆）
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(shadeFrame.origin.x+shadeFrame.size.width/2.0, shadeFrame.origin.y+shadeFrame.size.height/2.0) radius:shadeFrame.size.width/2.0 startAngle:0 endAngle:2*M_PI clockwise:NO]];

        }
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        //shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        [self.layer setMask:shapeLayer];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
        imageView.image = image;
        [self addSubview:imageView];
        
    }
    return self;
}



- (instancetype)initWithshadeFrame:(CGRect)shadeFrame shadeImage:(UIImage*)shadeImage arrowImageFrame:(CGRect)arrowImageFrame  arrowImage:(UIImage*)arrowImage titleArr:(NSArray*)titleArr titleFrameArr:(NSArray*)titleFrameArr clickBtnFrame:(CGRect)clickBtnFrame leaderKey:(NSString*)leaderKey{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if (self = [super initWithFrame:frame]) {
        CGRect frame = [UIScreen mainScreen].bounds;

//        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
//        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
//        effe.frame = frame;
        
        // 这里创建指引在这个视图在window上
        self.frame = frame;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];

        _leadingKey = leaderKey;
        
        //create path 重点来了（**这里需要添加第一个路径）
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
        
        CGRect circleFrame = CGRectMake(shadeFrame.origin.x, shadeFrame.origin.y+6, shadeFrame.size.width, shadeFrame.size.width-12);
        //圆
//        [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(circleFrame.origin.x+circleFrame.size.width/2.0, circleFrame.origin.y+circleFrame.size.height/2.0) radius:circleFrame.size.height/2.0 startAngle:0 endAngle:2*M_PI clockwise:NO]];
        //椭圆
        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:circleFrame ]];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd; //填充规则
//        shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
        [self.layer setMask:shapeLayer];
        
        //点击区域 图片
        UIImageView *shadowImgView = [[UIImageView alloc]initWithFrame:shadeFrame];
        shadowImgView.image = shadeImage;
        [self addSubview:shadowImgView];
        
        //箭头图片
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:arrowImageFrame];
        imageView.image = arrowImage;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
       
        //标题
        for (int i=0; i < titleArr.count; i++) {
            NSString *frameStr = titleFrameArr[i];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectFromString(frameStr)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:17];
            label.textColor = [UIColor whiteColor];
            label.text = titleArr[i];
            [self addSubview:label];
        }
        
        //btn
        UIButton *clickBtn = [[UIButton alloc]initWithFrame:clickBtnFrame];
        [clickBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        clickBtn.layer.masksToBounds = YES;
        clickBtn.layer.cornerRadius = 3.0;
        clickBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        clickBtn.layer.borderWidth = 1.0;
        [clickBtn addTarget:self action:@selector(clickBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickBtn];
        clickBtn.centerX = SCREENW/2.0;
     
    }
    return self;
}

- (instancetype)initWithimageFrame:(CGRect)imgFrame leadImage:(UIImage*)leadImage titleArr:(NSArray*)titleArr titleFrameArr:(NSArray*)titleFrameArr clickBtnFrame:(CGRect)clickBtnFrame leaderKey:(NSString*)leaderKey{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if (self = [super initWithFrame:frame]) {
        CGRect frame = [UIScreen mainScreen].bounds;
    
        self.frame = frame;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];

        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        _leadingKey = leaderKey;
        
        //图片
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:imgFrame];
        imageView.image = leadImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        
        //标题
        for (int i=0; i < titleArr.count; i++) {
            NSString *frameStr = titleFrameArr[i];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectFromString(frameStr)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:17];
            label.textColor = [UIColor whiteColor];
            label.text = titleArr[i];
            [self addSubview:label];
        }
        
        //btn
        UIButton *clickBtn = [[UIButton alloc]initWithFrame:clickBtnFrame];
        [clickBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        clickBtn.layer.masksToBounds = YES;
        clickBtn.layer.cornerRadius = 3.0;
        clickBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        clickBtn.layer.borderWidth = 1.0;
        [clickBtn addTarget:self action:@selector(clickBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickBtn];
        clickBtn.centerX = SCREENW/2.0;
        
    }
    return self;
}


- (void)clickBtnClick{
    [USER_DEFAULTS setBool:YES forKey:_leadingKey];
    [USER_DEFAULTS synchronize];
    [self removeFromSuperview];
}
/**
 *   新手指引确定
 */
- (void)sureTapClick:(UITapGestureRecognizer *)tap
{
    UIView * view = tap.view;
    [view removeFromSuperview];
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [view removeGestureRecognizer:tap];
    [USER_DEFAULTS setBool:YES forKey:_leadingKey];
    [USER_DEFAULTS synchronize];
}


@end
