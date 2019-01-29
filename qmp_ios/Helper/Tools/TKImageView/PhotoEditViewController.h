//
//  PhotoEditViewController.h
//  qmp_ios
//
//  Created by QMP on 2017/12/13.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FinishCropImage)(UIImage *image);
typedef void(^ReTakeImage)(BOOL isCamera); //重拍或者重新选图

@interface PhotoEditViewController : UIViewController

@property(nonatomic,strong) UIImage *img;
@property(nonatomic,assign) BOOL isCamera;
@property (copy, nonatomic)FinishCropImage finishCropImage;
@property (copy, nonatomic)ReTakeImage reTakeImg;

@end
