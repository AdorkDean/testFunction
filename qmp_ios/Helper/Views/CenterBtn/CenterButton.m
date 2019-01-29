//
//  CenterButton.m
//  qmp_ios
//
//  Created by Molly on 2016/11/7.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CenterButton.h"
#import "GetSizeWithText.h"

@implementation CenterButton

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.centerView];
        [self.centerView addSubview:self.imgView];
        [self.centerView addSubview:self.titleLbl];
    }
    return self;
}

- (void)setToCenterWithImage:(NSString*)imgName withImgSize:(CGSize)imgSize withTitle:(NSString *)title withTitleSize:(CGSize)titleSize withFont:(CGFloat)font withTitleColor:(UIColor*)titleColor withBtnW:(CGFloat)btnW{
    
    GetSizeWithText *sizeTool = [[GetSizeWithText alloc] init];
    CGFloat titleW = ceil([sizeTool calculateSize:title withFont:self.titleLbl.font withWidth:SCREENW].width);

    CGFloat centerW = imgSize.width + titleW;
    CGFloat centerH = self.frame.size.height;
    
    self.centerView.frame = CGRectMake((btnW - centerW) / 2 , (self.frame.size.height - centerH) / 2, centerW, centerH);
    CGFloat vW = self.frame.size.width;
    CGFloat vH = self.frame.size.height;
    self.centerView.center = CGPointMake(vW/2, vH/2);
    
    self.imgView.frame = CGRectMake(0, (centerH - imgSize.height ) / 2, imgSize.width, imgSize.height);
    [self.imgView setImage:[BundleTool imageNamed:imgName]];
    self.imgView.userInteractionEnabled = YES;
    
    self.titleLbl.font = [UIFont systemFontOfSize:font];
    self.titleLbl.textColor = titleColor;
    self.titleLbl.userInteractionEnabled = YES;

    self.titleLbl.frame = CGRectMake(self.imgView.frame.origin.x + imgSize.width, (centerH - titleSize.height ) / 2, titleSize.width, titleSize.height);
    self.titleLbl.text = title;
}

- (void)setToCenterWithRightImage:(NSString*)imgName withImgSize:(CGSize)imgSize withTitle:(NSString *)title withTitleSize:(CGSize)titleSize withFont:(CGFloat)font withTitleColor:(UIColor*)titleColor withBtnW:(CGFloat)btnW{
    
    GetSizeWithText *sizeTool = [[GetSizeWithText alloc] init];
    CGFloat titleW = ceil([sizeTool calculateSize:title withFont:[UIFont systemFontOfSize:font] withWidth:SCREENW].width);
    
    CGFloat centerW = imgSize.width + titleW;
    CGFloat centerH = self.frame.size.height;
    
    self.centerView.frame = CGRectMake((btnW - centerW) / 2 , (self.frame.size.height - centerH) / 2, centerW, centerH);
    CGFloat vW = self.frame.size.width;
    CGFloat vH = self.frame.size.height;
    self.centerView.center = CGPointMake(vW/2, vH/2);
    
    self.titleLbl.frame = CGRectMake(0, (centerH - titleSize.height ) / 2, titleW, titleSize.height);
    self.titleLbl.text = title;
    self.titleLbl.font = [UIFont systemFontOfSize:font];
    self.titleLbl.textColor = titleColor;

    self.imgView.frame = CGRectMake(self.titleLbl.left + titleW, (centerH - imgSize.height ) / 2, imgSize.width, imgSize.height);
    [self.imgView setImage:[BundleTool imageNamed:imgName]];

}

- (void)changeImageWithName:(NSString *)imgName{

    [self.imgView setImage:[BundleTool imageNamed:imgName]];
}
- (UIView *)centerView{

    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor clearColor];
    }
    return _centerView;
}

- (UIImageView *)imgView{

    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
    }
    return _imgView;
}
- (UILabel *)titleLbl{

    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.backgroundColor =  [UIColor clearColor];
    }
    return _titleLbl;
}
@end
