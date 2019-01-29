//
//  BundleTool.h
//  CommonLibrary
//
//  Created by QMP on 2018/11/5.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define BUNDLE_NAME   @"CommonBundle"


@interface BundleTool : NSObject
+ (BOOL)isQMP;
+ (NSBundle *)commonBundle;
+ (NSBundle *)qmpImgBundle;
+ (NSBundle *)xzImgBundle;

+ (UIImage*)imageNamed:(NSString*)imageName;
@end

NS_ASSUME_NONNULL_END


