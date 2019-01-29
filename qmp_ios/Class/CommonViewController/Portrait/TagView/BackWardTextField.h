//
//  BackWordTextField.h
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackWardTextField : UITextField

@property (copy, nonatomic) void(^backWardEvent)(void);
@end
