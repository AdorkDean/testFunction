//
//  ProductTableHeadView.m
//  qmp_ios
//
//  Created by QMP on 2018/6/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductTableHeadView.h"
#import "ScrollCollectView.h"
#import "InsetsLabel.h"

@interface ProductTableHeadView()
{
    __weak IBOutlet UILabel *_iconLab;
    __weak IBOutlet UIImageView *_iconImgV;
    __weak IBOutlet UILabel *_productNameLab;
    __weak IBOutlet InsetsLabel *_lunciLab;
    __weak IBOutlet UILabel *_yewuLab;
    __weak IBOutlet UILabel *_emailLab;
    __weak IBOutlet UIImageView *_emailIcon;
    __weak IBOutlet UILabel *_addressLab;
    __weak IBOutlet UIImageView *_addressIcon;
    __weak IBOutlet UILabel *_needMoneyInfoLab;
    __weak IBOutlet NSLayoutConstraint *_emailTopEdge;
    __weak IBOutlet NSLayoutConstraint *_addressTopEdge;
    UILabel *_statusLbl;
    CGFloat basicInfoHeight;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *needMoneyViewHeight;

@property(nonatomic,strong)ScrollCollectView *menuCollecV;


@property (nonatomic, strong) NSArray *hsArr;//A股
@property (nonatomic, strong) NSArray *sbArr;//新三板
@property (nonatomic, strong) NSArray *hkArr;//港股
@property (nonatomic, strong) NSArray *usaArr;//美股

@end


@implementation ProductTableHeadView

- (instancetype)initWithCompanyDetailModel:(CompanyDetailModel*)detailM  financeNeedModel:(FinanicalNeedModel*)needModel{
    
    ProductTableHeadView *headerV = [[BundleTool commonBundle]loadNibNamed:@"ProductTableHeadView" owner:nil options:nil].lastObject;
    headerV.height = 150;
    [headerV addView];
    [headerV addCopyGesture];
    headerV.needModel = needModel; //先赋值
    
    headerV.detailM = detailM;
    
    return headerV;
}

- (void)addView{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    
    _yewuLab.font = [UIFont systemFontOfSize:13];
    
    _productNameLab.textColor = COLOR2D343A;
    _yewuLab.textColor = COLOR737782;
    _emailLab.textColor = COLOR737782;
    _addressLab.textColor = COLOR737782;
    
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.cornerRadius = 5;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconLab.layer.masksToBounds = YES;
    _iconLab.layer.cornerRadius = 5;
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImgV.height - 23, _iconImgV.width, 23)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    [_statusLbl labelWithFontSize:12 textColor:[UIColor whiteColor]];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_iconImgV addSubview:_statusLbl];
    
    [_lunciLab labelWithFontSize:11 textColor:BLUE_TITLE_COLOR cornerRadius:1.5 borderWdith:0 borderColor:nil];
    _lunciLab.backgroundColor = BLUE_LIGHT_COLOR;
    _lunciLab.edgeInsets = UIEdgeInsetsMake(3, 8, 3, 8);    
    _productNameLab.userInteractionEnabled = YES;
    _yewuLab.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [_productNameLab addGestureRecognizer:gesture];
    UILongPressGestureRecognizer *gesture1 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [_lunciLab addGestureRecognizer:gesture1];
    UILongPressGestureRecognizer *gesture2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyContent:)];
    
    [_yewuLab addGestureRecognizer:gesture2];
    
    [self.needMoneyV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(needMoneyViewClick)]];
    
}

- (void)setSelectedMenu:(NSString*)menuTitle{
    [self.menuCollecV setSelectedMenu:menuTitle];
}

- (void)needMoneyViewClick{
    if(self.tapedNeedMoneyView){
        self.tapedNeedMoneyView();
    }
}


- (void)setDetailM:(CompanyDetailModel *)detailM{
    if (!detailM) {
        UIImageView *bgImgV = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:bgImgV];
        bgImgV.tag = 3000;
        bgImgV.image = [BundleTool imageNamed:@"detail_placeholder_card"];
        bgImgV.backgroundColor = [UIColor whiteColor];
        bgImgV.contentMode = UIViewContentModeScaleToFill;
        basicInfoHeight = 150;
        self.needMoneyViewHeight.constant = 0;
        self.needMoneyV.hidden = YES;
        self.height = basicInfoHeight;
        return;
    }else{
        _detailM = detailM;
        if ([self.basicInfoV viewWithTag:3000]) {
            [[self.basicInfoV viewWithTag:3000] removeFromSuperview];
        }
        [self initialValues];
    }    
}

- (void)initialValues{
    if (!_detailM) {
        return;
    }
    CompanyDetailLianxiModel *lianxiModel = _detailM.company_contact.firstObject;
    CompanyDetailBasicModel *basicModel = _detailM.company_basic;
    _productNameLab.text = basicModel.product.length ? basicModel.product:basicModel.company;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:basicModel.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    if(([PublicTool isNull:basicModel.icon] || [basicModel.icon containsString:@"default"]) && [PublicTool isNull:_iconLab.text]){
        _iconLab.hidden = NO;
        _iconLab.backgroundColor = RANDOM_COLORARR[arc4random() % 6];
        _iconLab.text = _productNameLab.text.length > 0 ? [_productNameLab.text substringWithRange:NSMakeRange(0, 1)] : @"企";
    }else{
        _iconLab.hidden = YES;
    }
    _statusLbl.hidden = basicModel.need_flag.integerValue == 0;
    
    if (basicModel.lunci.length) {
        _lunciLab.text = basicModel.lunci;
        _lunciLab.hidden = NO;
        
    }else{
        _lunciLab.text = @"";
        _lunciLab.hidden = YES;
    }
    
    
    _yewuLab.text = [basicModel.yewu isEqualToString:@""] ? basicModel.miaoshu : basicModel.yewu;
    _statusLbl.hidden = (basicModel.need_flag.integerValue == 0) ;
    
    _emailLab.text = [PublicTool nilStringReturn:lianxiModel.email];
    _addressLab.text = [PublicTool nilStringReturn:lianxiModel.address];
    basicInfoHeight = 83;


    if(![PublicTool isNull:lianxiModel.email]){
        CGFloat height =  [lianxiModel.email boundingRectWithSize:CGSizeMake(SCREENW-55, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.height;
        basicInfoHeight += height+8;
    }else{
        _emailLab.hidden = YES;
        _emailIcon.hidden = YES;
        _emailTopEdge.constant = - 10;
    }
    
    if(![PublicTool isNull:lianxiModel.address]){
        CGFloat height =  [_addressLab.text boundingRectWithSize:CGSizeMake(SCREENW-55, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.height;
        basicInfoHeight += height+8;

    }else{

        _addressLab.hidden = YES;
        _addressIcon.hidden = YES;
    }
    
    if ([PublicTool isNull:lianxiModel.email] && [PublicTool isNull:lianxiModel.address]) {
        basicInfoHeight = 78;
    }
    
    //融资信息
    if(self.needModel){
        
        self.needMoneyV.hidden = NO;
        NSMutableString *mStr = [NSMutableString stringWithString:@"融资需求  "];
        if (![PublicTool isNull:_needModel.need_lunci]) {
            [mStr appendString:_needModel.need_lunci];
        }
        if (![PublicTool isNull:_needModel.need_money]) {
            [mStr appendString:@" | "];
            if (![PublicTool isNull:_needModel.unit]) {
                [mStr appendString:[self fixMoneyType:_needModel.unit]];
            }
            [mStr appendString:_needModel.need_money];
        }
        if(![PublicTool isNull:_needModel.bp_file_id] && ![PublicTool isNull:_needModel.bp]){
            [mStr appendString:@" | 有BP"];
        }
        _needMoneyInfoLab.text = mStr;
        self.needMoneyViewHeight.constant = 35;
        
        self.height = basicInfoHeight + 35;

    }else{
        self.needMoneyViewHeight.constant = 0;
        self.needMoneyV.hidden = YES;
        self.height = basicInfoHeight;
    }
}

-(void)layoutSubviews{
    
    [super layoutSubviews];

    if(self.needModel){
        self.height = basicInfoHeight + 35;
    }else{
        self.height = basicInfoHeight;
    }
    if([self viewWithTag:3000]){
        [[self viewWithTag:3000] setFrame:self.basicInfoV.bounds];
    }
}


- (void)setViewModel:(ProductDetailViewModel *)viewModel{
    
    _viewModel = viewModel;
    @weakify(self);
    [RACObserve(_viewModel, needModel) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self initialValues];
    }];
}

- (void)copyContent:(UILongPressGestureRecognizer*)press{
    UILabel *label = (UILabel*)press.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [label.text stringByAppendingString:[NSString stringWithFormat:@" 来自@企名片%@",self.detailM.company_basic.short_url]];
    
    NSString *info = @"复制成功";
    
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}

- (void)claimButtonClick:(UIButton *)button {
    if (self.claimBtnClick) {
        self.claimBtnClick(button);
    }
}


- (void)addCopyGesture{
    
//    [_phoneLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyPhone)]];
    [_addressLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyAddress)]];
    [_emailLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyEmail)]];
}



- (void)copyPhone{
    CompanyDetailLianxiModel *lianxiModel = _detailM.company_contact.firstObject;

    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.detailM && ![PublicTool isNull:lianxiModel.phone]) {
        board.string = lianxiModel.phone;
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}
- (void)copyAddress{
    CompanyDetailLianxiModel *lianxiModel = _detailM.company_contact.firstObject;

    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.detailM && ![PublicTool isNull:lianxiModel.address]) {
        board.string = lianxiModel.address;
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}
- (void)copyEmail{
    CompanyDetailLianxiModel *lianxiModel = _detailM.company_contact.firstObject;
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (self.detailM && ![PublicTool isNull:lianxiModel.email]) {
        board.string = lianxiModel.email;
        [PublicTool showMsg:@"复制成功"];
        return;
    }
}



- (NSString *)fixMoneyType:(NSString *)type {
    NSDictionary *dict = @{@"人民币":@"￥",@"欧元":@"€",@"美元":@"$",@"英镑":@"£",@"日元":@"J￥",@"新台币":@"NT",@"港币":@"HKD"};
    return dict[type]?dict[type]:type;
}

- (NSArray *)hsArr{
    
    if (!_hsArr) {
        _hsArr = @[@"上证A股",@"深交所中小板",@"深交所主板",@"深交所创业板",@"上海证券交易所"];
    }
    return _hsArr;
}

- (NSArray *)sbArr{
    
    if (!_sbArr) {
        _sbArr = @[@"新三板"];
    }
    return _sbArr;
}

- (NSArray *)hkArr{
    
    if (!_hkArr) {
        _hkArr = @[@"港股",@"香港交易所主板",@"香港交易所创业板"];
    }
    return _hkArr;
}

- (NSArray *)usaArr{
    
    if (!_usaArr) {
        _usaArr = @[@"美股",@"美交所",@"纽交所",@"纳斯达克"];
    }
    return _usaArr;
}

@end
