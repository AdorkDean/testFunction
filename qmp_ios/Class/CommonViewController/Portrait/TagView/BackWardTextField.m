//
//  BackWordTextField.m
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import "BackWardTextField.h"

@implementation BackWardTextField


-(void)deleteBackward{
    
    [super deleteBackward];
    
    self.backWardEvent();
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 6 , 0 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 6 , 0 );
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//    
//}
//
//-(void)drawRect:(CGRect)rect{
//    
//    CAShapeLayer *shapeLayer = nil;
//    for (CALayer *layer in self.layer.sublayers) {
//        if ([layer isKindOfClass:[CAShapeLayer class]]) {
//            shapeLayer = (CAShapeLayer*)layer;
//        }
//    }
//    
//    if (shapeLayer) {
//        [shapeLayer removeFromSuperlayer];
//    }
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius:2];
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.path = path.CGPath;
//    layer.lineDashPhase = 2;
//    layer.lineDashPattern = @[@(2),@(2)];
//    
//    layer.lineWidth  = 0.5;
//    layer.strokeColor = BORDER_LINE_COLOR.CGColor;
//    layer.fillColor = [UIColor whiteColor].CGColor;
//    [self.layer insertSublayer:layer atIndex:0];
//    
//}

@end
