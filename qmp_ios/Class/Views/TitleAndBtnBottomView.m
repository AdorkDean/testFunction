//
//  TitleAndBtnBottomView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "TitleAndBtnBottomView.h"

@interface TitleAndBtnBottomView()

@property(nonatomic,copy)NSString *msgTitle;
@property(nonatomic,copy)NSString *btnTitle;

@property(nonatomic,strong)UILabel *showMessageLbl;
@property(nonatomic,strong)UIButton *createBtn;
@property(nonatomic,copy)void(^btnClickBlock)(void);

@end


@implementation TitleAndBtnBottomView

+ (TitleAndBtnBottomView*)titleAndBtnViewWithFrame:(CGRect)frame Title:(NSString *)leftTitle buttonTitle:(NSString *)btnTitle btnClick:(void (^)(void))btnClickBlock{
    
    TitleAndBtnBottomView *bottomV = [[TitleAndBtnBottomView alloc]initWithFrame:frame];
    bottomV.msgTitle = leftTitle;
    bottomV.btnTitle = btnTitle;
    bottomV.btnClickBlock = btnClickBlock;
    [bottomV addViews];
    
    return bottomV;
}


- (void)addViews{
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = H9COLOR.CGColor;//shadowColor阴影颜色
    self.layer.shadowOpacity = 0.2;//阴影透明度，默认0
    self.layer.shadowRadius = 3;//阴影半径，默认3
    self.layer.shadowOffset = CGSizeMake(0,0);
    
    [self addSubview:self.showMessageLbl];
    [self addSubview:self.createBtn];
}

- (UIButton *)createBtn{
    if (_createBtn == nil) {
        //计算宽度
        CGFloat btnTitleWidth = [PublicTool widthOfString:self.btnTitle height:CGFLOAT_MAX fontSize:16] + 30;
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _createBtn.frame = CGRectMake(SCREENW-btnTitleWidth-15, 8.5, btnTitleWidth, 32);
        _createBtn.layer.cornerRadius = _createBtn.height * 0.5;
        _createBtn.clipsToBounds = YES;
        _createBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _createBtn.backgroundColor = BLUE_BG_COLOR;
        [_createBtn setTitle:self.btnTitle forState:UIControlStateNormal];
        [_createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_createBtn addTarget:self action:@selector(createFinanceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBtn;
}
- (void)createFinanceButtonClick{
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
}

- (UILabel *)showMessageLbl{
    if (_showMessageLbl == nil) {
        _showMessageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _showMessageLbl.frame =  CGRectMake(15, 0, 200, 49);
        _showMessageLbl.font = [UIFont systemFontOfSize:14];
        _showMessageLbl.textColor = HTColorFromRGB(0x666666);
        _showMessageLbl.text = self.msgTitle;
    }
    return _showMessageLbl;
}


@end
