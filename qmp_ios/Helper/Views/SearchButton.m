//
//  SearchButton.m
//  qmp_ios
//
//  Created by Molly on 2017/1/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "SearchButton.h"

@implementation SearchButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{

    CGFloat BtnW = 30.f;
    CGFloat allH = self.frame.size.height;
    return CGRectMake(0,( allH - BtnW ) / 2, BtnW, BtnW);

}

@end
