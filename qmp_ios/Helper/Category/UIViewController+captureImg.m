//
//  UIViewController+captureImg.m
//  Bigbrother
//
//  Created by iii on 15/11/30.
//  Copyright © 2015年 Beijing Mobedu techology Co. Ltd. All rights reserved.
//

#import "UIViewController+captureImg.h"
#import <objc/runtime.h>
@implementation UIViewController (captureImg)
static void * CaptureImgKey = (void *)@"captureImgKey";
- (UIImage * )captureImg
{
    return objc_getAssociatedObject(self, CaptureImgKey);
}

- (void)setCaptureImg:(UIImage *)captureImg
{
    objc_setAssociatedObject(self, CaptureImgKey, captureImg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
