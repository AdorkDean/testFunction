//
//  XYCamreaViewController.h
//  JiaYiHui
//
//  Created by 强新宇 on 2017/7/21.
//  Copyright © 2017年 强新宇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CameraBlock)(UIImage * image);

@interface XYCameraViewController : UIViewController

@property (nonatomic, copy)CameraBlock block;

- (void)getImage:(CameraBlock)block;
@end
