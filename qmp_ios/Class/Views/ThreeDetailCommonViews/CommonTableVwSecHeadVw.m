//
//  CommonTableVwSecHeadVw.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CommonTableVwSecHeadVw.h"
@interface CommonTableVwSecHeadVw()

@property (nonatomic, copy) NSString * lblText;
@property (nonatomic, copy) NSString * btnTitle;//nil or @"" 按钮会被隐藏
@property (nonatomic, copy) NSString * btnImgStr;//默认显示@"detail_left_arrow"，传@"" 可隐藏


@property (nonatomic, strong) UILabel * leftLbl;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * righBtn;

@property (nonatomic, copy) rightBtnClickBlock clickCallBack;
@property (nonatomic, copy) leftBtnClickBlock leftBtnClickEvent;

@end
@implementation CommonTableVwSecHeadVw

- (instancetype)initWithFrame:(CGRect)frame lblFrame:(CGRect)LbliFrame lblLine:(CGRect)lblLineFrame rightBtn:(CGRect)rightBtnFrame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.leftLbl];
        
        [self addSubview:self.righBtn];
    }
    return self;
}

//高度 44
- (instancetype)initSectionHeadViewFrame:(CGRect)frame clickCallBack:(rightBtnClickBlock)callBlock{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.leftLbl];
        self.leftLbl.bottom = frame.size.height;
        
        
        [self addSubview:self.righBtn];
        self.righBtn.bottom = frame.size.height;
        
        [self addSubview:self.leftBtn];
        

        _clickCallBack = callBlock;
        [self.righBtn addTarget:self action:@selector(clickRightTarget:) forControlEvents:UIControlEventTouchUpInside];
        self.leftLbl.bottom = self.height;
        self.leftBtn.centerY = self.leftLbl.centerY;
        self.righBtn.centerY = self.leftLbl.centerY;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.leftLbl.bottom = self.height - 4;
    self.leftBtn.centerY = self.leftLbl.centerY;
    self.righBtn.centerY = self.leftLbl.centerY;
}
- (void)clickRightTarget:(UIButton *)btn{
    if (_clickCallBack) {
        if (self.leftLbl.text.length > 0) {
            _clickCallBack(self.leftLbl.text);
        }else{
             _clickCallBack(@"");
        }
    }
}
- (UILabel *)leftLbl{
    if (_leftLbl == nil) {
        _leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 20)];
        _leftLbl.text = @"";
        _leftLbl.textColor = H3COLOR;
        if (@available(iOS 8.2, *)) {
            _leftLbl.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        }else{
            _leftLbl.font = [UIFont systemFontOfSize:17];
        }
            
    }
    return _leftLbl;
}



- (UIButton *)righBtn{
    if (_righBtn == nil) {
        _righBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _righBtn.frame = CGRectMake(SCREENW - 19 - 91, 0, 90, 44);
        _righBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_righBtn setTitleColor:COLOR737782 forState:UIControlStateNormal];
        [_righBtn setImage:[UIImage imageNamed:@"detail_moreArrow"] forState:UIControlStateNormal];
        [_righBtn setImage:[UIImage imageNamed:@"detail_moreArrow"] forState:UIControlStateHighlighted];
    }
    return _righBtn;
}

- (UIButton *)leftBtn{
    if (_leftBtn == nil) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(SCREENW - 100 - 19 - 100, 0, 100, 44);
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_leftBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _leftBtn;
}

- (void)leftBtnClick{
    if (_leftBtnClickEvent) {
        self.leftBtnClickEvent();
    }
    
}

- (void)setBtnTitle:(NSString *)btnTitle{
    _btnTitle = btnTitle;

    [self.righBtn setTitle:btnTitle forState:UIControlStateNormal];
    self.righBtn.centerY = self.leftLbl.centerY;
    if ([PublicTool isNull:_btnTitle]) {
        self.righBtn.hidden = YES;
    
    }else{
        
        self.righBtn.hidden = NO;

        if ([btnTitle containsString:@"添加"]) {
            _righBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [_righBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            [_righBtn setImage:[UIImage imageNamed:@"company_addTag"] forState:UIControlStateNormal];
            [_righBtn setImage:[UIImage imageNamed:@"company_addTag"] forState:UIControlStateHighlighted];
            [self.righBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:4];
            [_righBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        }else if([btnTitle containsString:@"编辑"]){
            _righBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [_righBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            [_righBtn setImage:nil forState:UIControlStateNormal];
            [_righBtn setImage:nil forState:UIControlStateHighlighted];
            [self.righBtn setTitle:btnTitle forState:UIControlStateNormal];
            [self.righBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:0];
            [_righBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        }else{
            
            _righBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [_righBtn setTitleColor:COLOR737782 forState:UIControlStateNormal];
            [_righBtn setImage:[UIImage imageNamed:@"detail_moreArrow"] forState:UIControlStateNormal];
            [_righBtn setImage:[UIImage imageNamed:@"detail_moreArrow"] forState:UIControlStateHighlighted];
            [_righBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
            [_righBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        }
        
        CGFloat width = [PublicTool widthOfString:btnTitle height:CGFLOAT_MAX fontSize:14];
        self.leftBtn.right = SCREENW - 17 - width - 24;
    }
}

- (void)setBtnImgStr:(NSString *)btnImgStr{
    
    _btnImgStr = btnImgStr;
    
    [self.righBtn setImage:[UIImage imageNamed:_btnImgStr] forState:UIControlStateNormal];
    [self.righBtn setImage:[UIImage imageNamed:_btnImgStr] forState:UIControlStateHighlighted];
    if ([PublicTool isNull:_btnImgStr]) {
        [self.righBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:0];
    }else{
        [self.righBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:8];
    }
}

- (instancetype)initlbltitle:(NSString *)title btnTitle:(NSString *)btnTitle callBack:(rightBtnClickBlock)callBlock{
    CommonTableVwSecHeadVw * sectionHeadVw = [[CommonTableVwSecHeadVw alloc] initSectionHeadViewFrame:CGRectMake(0, 0, SCREENW, HEADERHEIGHT) clickCallBack:^(NSString *sectionTitle) {
        callBlock(sectionTitle);
    }];
    sectionHeadVw.leftLbl.text = title;
    sectionHeadVw.leftBtn.hidden = YES;
    sectionHeadVw.btnImgStr = @"detail_moreArrow";
    sectionHeadVw.btnTitle = btnTitle;
    return sectionHeadVw;
}

- (instancetype)initlbltitle:(NSString *)title leftBtnTitle:(NSString *)leftBtnTitle  btnTitle:(NSString *)btnTitle callBack:(rightBtnClickBlock)callBlock leftBtnClick:(leftBtnClickBlock)leftBtnClickEvent{
    
    CommonTableVwSecHeadVw * sectionHeadVw = [[CommonTableVwSecHeadVw alloc] initSectionHeadViewFrame:CGRectMake(0, 0, SCREENW, HEADERHEIGHT) clickCallBack:^(NSString *sectionTitle) {
        callBlock(sectionTitle);
    }];
    sectionHeadVw.leftBtnClickEvent = leftBtnClickEvent;
    sectionHeadVw.leftLbl.text = title;
    sectionHeadVw.leftBtn.hidden = NO;
    [sectionHeadVw.leftBtn setTitle:leftBtnTitle forState:UIControlStateNormal];
    sectionHeadVw.btnImgStr = @"detail_moreArrow";
    sectionHeadVw.btnTitle = btnTitle;
    return sectionHeadVw;
}

- (instancetype)initlbltitle:(NSString *)title btnTitle:(NSString *)btnTitle height:(CGFloat)height callBack:(rightBtnClickBlock)callBlock{
   
    CommonTableVwSecHeadVw * sectionHeadVw = [[CommonTableVwSecHeadVw alloc] initSectionHeadViewFrame:CGRectMake(0, 0, SCREENW, height) clickCallBack:^(NSString *sectionTitle) {
        callBlock(sectionTitle);
    }];
    sectionHeadVw.leftLbl.text = title;
    sectionHeadVw.leftBtn.hidden = YES;
    sectionHeadVw.btnImgStr = @"detail_moreArrow";
    sectionHeadVw.btnTitle = btnTitle;

    return sectionHeadVw;
}

- (instancetype)initlbltitle:(NSString *)title leftBtnTitle:(NSString *)leftBtnTitle btnTitle:(NSString *)btnTitle height:(CGFloat)height callBack:(rightBtnClickBlock)callBlock leftBtnClick:(leftBtnClickBlock)leftBtnClickEvent{
    CommonTableVwSecHeadVw * sectionHeadVw = [[CommonTableVwSecHeadVw alloc] initSectionHeadViewFrame:CGRectMake(0, 0, SCREENW, height) clickCallBack:^(NSString *sectionTitle) {
        callBlock(sectionTitle);
    }];
    sectionHeadVw.leftBtnClickEvent = leftBtnClickEvent;
    sectionHeadVw.leftLbl.text = title;
    sectionHeadVw.leftBtn.hidden = YES;
    sectionHeadVw.btnImgStr = @"detail_moreArrow";
    sectionHeadVw.btnTitle = btnTitle;
    
    return sectionHeadVw;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
