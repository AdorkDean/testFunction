//
//  WMMenuItem+Font.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/6.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "WMMenuItem+Font.h"
#import <objc/runtime.h>
@implementation WMMenuItem (Font)

+ (void)load {
    SEL origSel = @selector(setSelected:withAnimation:);
    SEL swizSel = @selector(swiz_setSelected:withAnimation:);
//    [WMMenuItem swizzleMethods:[self class] originalSelector:origSel swizzledSelector:swizSel];
    Method origMethod = class_getInstanceMethod(self, origSel);
    Method swizMethod = class_getInstanceMethod(self, swizSel);
    
    BOOL didAddMethod = class_addMethod(self, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(self, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

- (void)swiz_setSelected:(BOOL)selected withAnimation:(BOOL)animation {
    if (selected) {
        if (@available(iOS 8.2, *)) {
            self.font = [UIFont systemFontOfSize:self.selectedSize weight:UIFontWeightMedium];
        }else{
            self.font = [UIFont systemFontOfSize:self.selectedSize];
        }
    } else {
        self.font = [UIFont systemFontOfSize:self.selectedSize];
    }
    [self swiz_setSelected:selected withAnimation:animation];
}
@end
