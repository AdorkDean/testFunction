//
//  UINavigationController+StatusBarStyle.m
//  qmp_ios
//
//  Created by QMP on 2017/12/6.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "UINavigationController+StatusBarStyle.h"

@implementation UINavigationController (StatusBarStyle)


-(UIViewController *)childViewControllerForStatusBarStyle{
    return self.visibleViewController;
}

-(UIViewController *)childViewControllerForStatusBarHidden{
    return self.visibleViewController;
}

@end
