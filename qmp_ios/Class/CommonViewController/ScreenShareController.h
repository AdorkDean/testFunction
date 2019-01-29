//
//  ScreenShareController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedPlatform)(ShareType shareType);

@interface ScreenShareController : UIViewController

@property(nonatomic,strong) UIImage *image;

+(ScreenShareController*)showShareViewWithImage:(UIImage*)shareImg didTapPlatform:(SelectedPlatform)selectPlayform;

@end
