//
//  MainNavViewController.m
//  QimingpianSearch
//
//  Created by Molly on 16/7/25.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "MainNavViewController.h"
#import "UIViewController+captureImg.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define TOP_VIEW  [[UIApplication sharedApplication]keyWindow].rootViewController.view

@interface MainNavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}
@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,strong) UIButton *leftBtn;

@property (nonatomic,assign) BOOL isMoving;

@end

@implementation MainNavViewController
+ (void)initialize {
    if (self == [MainNavViewController self]) {
        UINavigationBar *navBar;
        if (@available(iOS 9.0, *)) {
            navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self]];
        } else {
            navBar = [UINavigationBar appearanceWhenContainedIn:self, nil];
        }
        
        [navBar setTintColor:NV_OTHERTITLE_COLOR];
        [navBar setBarStyle:UIBarStyleBlack];
        [navBar setBarTintColor:[UIColor whiteColor]];
        if (@available(iOS 8.2, *)) {
            [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:H3COLOR,NSForegroundColorAttributeName,[UIFont systemFontOfSize:18 weight:UIFontWeightMedium],NSFontAttributeName,nil]];
        }else{
            [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:H3COLOR,NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName,nil]];
        }
        [navBar setTranslucent:NO];
    }
}
- (void)dealloc
{
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canDragBack = YES;
    
    //导航的线
    self.navigationBar.hidden = NO;
    [self.navigationBar setShadowImage:[UIImage new]];
    
    UIView *grayLine = [[UIView alloc]initWithFrame:CGRectMake(0, kNavigationBarHeight-0.5, SCREENW, 0.5)];
    grayLine.backgroundColor = HTColorFromRGB(0xeeeeee);
    [self.navigationBar addSubview:grayLine];
    self.grayLine = grayLine;
    
    UIScreenEdgePanGestureRecognizer *recognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)];
    recognizer.delegate = self;
    [recognizer setEdges:UIRectEdgeLeft];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
    
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    MainNavViewController *nav = [super initWithRootViewController:rootViewController];
    self.interactivePopGestureRecognizer.delegate = self;
    nav.delegate = self;
    return nav;
}

// 隐藏导航统一处理
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    BOOL isShowHomePage = NO;

    if ([self hideNavBarForvc:viewController]) {
        isShowHomePage = YES;
    }
    [self setNavigationBarHidden:isShowHomePage animated:NO];
}

#pragma mark - Gesture Recognizer
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
//        self.view.userInteractionEnabled = NO;

        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = TOP_VIEW.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [TOP_VIEW.superview insertSubview:self.backgroundView belowSubview:TOP_VIEW];
            self.backgroundView.backgroundColor=[UIColor blackColor];
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        UIViewController * topVC = [PublicTool topViewController];
        UIImage *lastScreenShot = topVC.captureImg;
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > SCREENW/3.0f)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:SCREENW];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = TOP_VIEW.frame;
                frame.origin.x = 0;
                TOP_VIEW.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
//        self.view.userInteractionEnabled = YES;

        return;
        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled)
    {
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
//        self.view.userInteractionEnabled = YES;

        return;
    }
    
    if (_isMoving)
    {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

- (void)moveViewWithX:(float)x
{
    x = x > SCREENW ? SCREENW:x;
    x = x<0?0:x;
    CGRect frame = TOP_VIEW.frame;
    frame.origin.x = x;
    TOP_VIEW.frame = frame;
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    if (scale>1)
    {
        scale=1;
    }
    scale=1;

    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
    
}
#pragma mark - 截图

- (UIImage *)capture
{
    UIView *view = TOP_VIEW;

    if ([UIApplication sharedApplication].windows.count) {
        view = [[[[UIApplication sharedApplication].windows firstObject] rootViewController] view];

    }
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{

    return [super popViewControllerAnimated:animated];
}



- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
   
    UIImage *capturedImage = [self capture];
    
    if (capturedImage)
    {
        viewController.captureImg = capturedImage;
    }
    
    if (self.childViewControllers.count >= 1) {
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    if (viewController.navigationItem.leftBarButtonItem == nil && [self.viewControllers count] >= 1) {

        viewController.navigationItem.leftBarButtonItems = [self createBackButton];
    }
    
    [super pushViewController:viewController animated:YES];

}

- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];
//    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.leftBtn = leftButton;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
//        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];

        return @[leftButtonItem];
    }
    return @[negativeSpacer,leftButtonItem];
}



- (void)popSelf{
    
    [self popViewControllerAnimated:YES];
}

- (BOOL)hideNavBarForvc:(UIViewController *)viewController {
    NSArray *vcs = @[@"AttentionController",
                     @"HomeViewController",
                     @"DiscoverTabController",
                     @"QMPDescoverTabController",
                     @"PersonDetailsController",
                     @"ProductDetailsController",
                     @"UnauthPeresonPageController",
                     @"OrganizeDetailViewController",
                     @"MyWalletViewController",
                     @"NewLoginController",
                     @"LoginLeaderController",
                     @"QMPThemeDetailViewController",
                     @"TabbarActivityViewController",
                     @"QMPCommunityController",
                     @"QMPDisCoverController"];
    
    NSString *classStr = NSStringFromClass([viewController class]);
    return [vcs containsObject:classStr];
}
@end
