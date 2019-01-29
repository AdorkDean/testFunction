//
//  CopyButton.m
//  qmp_ios
//
//  Created by qimingpian08 on 16/9/2.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CopyButton.h"

@implementation CopyButton

-(BOOL)canBecomeFirstResponder {
    
    return YES;
}

// 可以响应的方法
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    return (action == @selector(copy1:));
}

//针对于响应方法的实现
-(void)copy1:(id)sender {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
    
    NSString *info = @"复制成功";
    
    [ShowInfo showInfoOnView:self.currentV withInfo:info];
}

//UILabel默认是不接收事件的，我们需要自己添加touch事件
-(void)attachTapHandler {
    
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    touch.minimumPressDuration = 1.0;
    [self addGestureRecognizer:touch];
}

//绑定事件
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self attachTapHandler];
    }
    return self;
}

-(void)awakeFromNib {
    
    [super awakeFromNib];
    [self attachTapHandler];
}

-(void)handleTap:(UIGestureRecognizer*) recognizer {
    
//    [self becomeFirstResponder];
//    
//    //不弹出 "复制"
//    [self copy1:nil];
//    if ([recognizer state] == UIGestureRecognizerStateBegan) {
//        
//        //长按事件开始"
//        //do something
//    }
//    else if ([recognizer state] == UIGestureRecognizerStateEnded) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.superview.superview.superview.superview.superview.superview animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = NSLocalizedString(@"复制成功", @"HUD message title");
//            hud.yOffset = -150;//SCREENH / 2 - 100;
//            hud.tintColor = [UIColor whiteColor];
//            hud.labelFont = [UIFont systemFontOfSize:13];
//            hud.opacity = 0.3;
//            [hud hide:YES afterDelay:1.f];
//        });
//    }
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
    
    NSString *info = @"复制成功";
    if (self.currentV) {
        
        [ShowInfo showInfoOnView:self.currentV withInfo:info];
    }
    else{
        [ShowInfo showInfoOnView:self.superview.superview.superview.superview.superview.superview withInfo:info];
    }
}

@end
