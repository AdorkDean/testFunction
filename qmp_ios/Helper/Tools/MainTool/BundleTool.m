//
//  BundleTool.m
//  CommonLibrary
//
//  Created by QMP on 2018/11/5.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "BundleTool.h"


@implementation BundleTool
+ (BOOL)isQMP{
    return [[[NSBundle mainBundle]bundlePath]containsString:@"qmp_ios"];
}

+ (NSBundle *)commonBundle{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CommonBundle.bundle"];
    NSBundle *bundle1 =  [NSBundle bundleWithPath: path];

    return bundle1;
}

+ (NSBundle *)qmpImgBundle{
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"QMPimgBundle.bundle"];
    NSBundle *bundle1 =  [NSBundle bundleWithPath: path];
    
    return bundle1;
}

+ (NSBundle *)xzImgBundle{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"XZimgBundle.bundle"];
    NSBundle *bundle1 =  [NSBundle bundleWithPath: path];
    
    return bundle1;
}


+ (NSString *)getBundlePath: (NSString *) assetName{
    NSBundle *myBundle = [BundleTool commonBundle];
    if (myBundle && assetName) {
        return [[myBundle resourcePath] stringByAppendingPathComponent: assetName];
    }
    return nil;
}

+ (UIImage*)imageNamed:(NSString*)imageName{
    if ([BundleTool isQMP]) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"QMPimgBundle.bundle/%@",imageName]];

    }else{
        return [UIImage imageNamed:[NSString stringWithFormat:@"XZimgBundle.bundle/%@",imageName]];
    }
    
}
@end
