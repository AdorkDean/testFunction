//
//  copyLabel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/6/12.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CopyLabel.h"


@implementation CopyLabel

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
    pboard.string = self.text;
    
    NSString *info = @"复制成功";

    [ShowInfo showInfoOnView:self.currentV withInfo:info];
}

//UILabel默认是不接收事件的，我们需要自己添加touch事件
-(void)attachTapHandler {
    
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
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

-(void)handleTap:(UIGestureRecognizer*) tap {
    
    
//    if ([tap state] == UIGestureRecognizerStateEnded){
//        
//        [self becomeFirstResponder];
//        UIMenuController *menu = [UIMenuController sharedMenuController];
//        menu.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy1:)]];
//        CGRect rect = self.bounds;
//        
//        self.currentV = self.currentV ? self.currentV : self.superview.superview.superview.superview.superview.superview;
//        [menu setTargetRect:CGRectMake(rect.origin.x + 30, rect.origin.y + 20, 60, 44) inView:self.currentV];
//        [menu setMenuVisible:YES animated:YES];
//
//    }
    
//    if ([tap state] == UIGestureRecognizerStateEnded) {
    
        //不弹出 "复制"
//        [self copy1:nil];

        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.text;
        NSString *info = @"复制成功";
        if (self.currentV) {
            
            [ShowInfo showInfoOnView:self.currentV withInfo:info];
        }
        else{
            [ShowInfo showInfoOnView:self.superview.superview.superview.superview.superview.superview withInfo:info];
        }

//    }

}

@end
