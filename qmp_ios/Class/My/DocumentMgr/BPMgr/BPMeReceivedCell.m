//
//  BPMeReceivedCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPMeReceivedCell.h"
#import "ReportModel.h"
#import "SearchCompanyModel.h"
@interface BPMeReceivedCell()
@end
@implementation BPMeReceivedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    [self.contentView addSubview:self.projectAvatarView];
    [self.contentView addSubview:self.projectNameLabel];
    [self.contentView addSubview:self.projectYeWuLabel];
    [self.contentView addSubview:self.projectHangyeLabel];
    [self.contentView addSubview:self.favorButton];
    [self.contentView addSubview:self.lookBPButton];
    [self.contentView addSubview:self.contactButton];
    [self.contentView addSubview:self.sourceUserLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.optionalView];
    [self.contentView addSubview:self.bandProjectButton];
    [self.contentView addSubview:self.redPoint];
    
    
    [self.projectAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(self.contentView.mas_left).offset(17);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
    }];
    
    [self.projectNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(57);
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50).priorityLow();
    }];
    
    [self.projectYeWuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(70);
        make.top.mas_equalTo(self.projectNameLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(18);
    }];
    
    [self.projectHangyeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.projectNameLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.projectNameLabel.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    [self.lookBPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.contentView.mas_left).offset(17);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
    }];
    
    [self.redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lookBPButton.mas_right).offset(-2);
        make.bottom.equalTo(self.lookBPButton.mas_top).offset(4);
        make.width.equalTo(@(4));
        make.height.equalTo(@(4));
    }];
    
    [self.contactButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.left.mas_equalTo(self.lookBPButton.mas_right).offset(10);
    }];
    
    [self.bandProjectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.left.mas_equalTo(self.contactButton.mas_right).offset(10);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREENW, 0.5));
        make.left.mas_equalTo(self.contentView.mas_left);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(self.contactButton.mas_centerY);
    }];
    
    [self.sourceUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-8);
        make.centerY.mas_equalTo(self.contactButton.mas_centerY);
        make.height.mas_equalTo(38);
    }];
    
    [self.favorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 38));
        make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
        make.centerY.mas_equalTo(self.projectNameLabel.mas_centerY);
    }];
    
    [self.optionalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 80));
        make.top.mas_equalTo(self.favorButton.mas_bottom).offset(0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-30);
    }];
    
    [self.projectNameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.projectNameLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
   
//    [self.lookBPButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [self.lookBPButton setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
}

- (void)setModel:(ReportModel *)model {
    _model = model;
    if (model.product_info.product.length > 0) { // 关联了项目
        self.projectAvatarView.hidden = NO;
        self.projectYeWuLabel.hidden = NO;
        self.projectHangyeLabel.hidden = NO;
        
        SearchCompanyModel *product = model.product_info;
        [self.projectAvatarView sd_setImageWithURL:[NSURL URLWithString:product.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
        
        self.projectNameLabel.text = product.product.length > 0 ? product.product : @"-";
        self.projectHangyeLabel.text = product.hangye1.length > 0 ?  product.hangye1 : @"-";
        self.projectYeWuLabel.text = product.yewu.length > 0 ?  product.yewu : @"-";
        
        [self.projectAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
        [self.projectNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(15);
            make.left.mas_equalTo(self.contentView.mas_left).offset(70);
        }];
        
    } else {
        
        self.bandProjectButton.hidden = NO;
        
        self.projectAvatarView.hidden = YES;
        self.projectYeWuLabel.hidden = YES;
        self.projectHangyeLabel.hidden = YES;

        self.projectNameLabel.text = ![PublicTool isNull:model.name] ? model.name : @"-";
        
        [self.projectAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        [self.projectNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(20);
            make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        }];
    }
    
    
    

    if (model.datetime) {
        self.timeLabel.text = [self formatDate:model.datetime];
    } else {
        self.timeLabel.text = @"";
    }


    self.sourceUserLabel.text =  [PublicTool isNull:model.send_nickname] ? @"":model.send_nickname;
    
    UIButton *topBtn = [self.optionalView viewWithTag:1000];
    UIButton *downBtn = [self.optionalView viewWithTag:1001];

    NSArray *imgArr = @[@"bp_favor",@"bp_mark",@"bp_favor_selected"];
    [self.favorButton setImage:[UIImage imageNamed:imgArr[model.interest_flag]] forState:UIControlStateNormal];

    switch (model.interest_flag) {  // 1 未标记   0 不感兴趣  2 感兴趣
        case 1:{
            [topBtn setTitle:@"感兴趣" forState:UIControlStateNormal];
            [downBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];

        }
            break;
        case 0:{
            [topBtn setTitle:@"未标记" forState:UIControlStateNormal];
            [downBtn setTitle:@"感兴趣" forState:UIControlStateNormal];
            
        }
            break;
        case 2:{
            [topBtn setTitle:@"未标记" forState:UIControlStateNormal];
            [downBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
            
        }
            break;
            
        default:
            break;
    }
    self.optionalView.hidden = !(model.showOptionView == 1);
    
    if (model.browse_status.integerValue == 2) { //未查看
        self.redPoint.hidden = NO;
    }else{
        self.redPoint.hidden = YES;
    }
}

#pragma mark - Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.optionalView.hidden = YES;
}

- (void)favorButtonClick:(UIButton *)button {
    self.optionalView.hidden = NO;

    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:favorButtonClick:)]) {
        [self.delegate bpMeReceivedCell:self favorButtonClick:button];
    }
}

- (void)contactButtonClick:(UIButton *)button {
    self.optionalView.hidden = YES;

    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:caontactButtonClick:)]) {
        [self.delegate bpMeReceivedCell:self caontactButtonClick:self.model.send_user_phone];
    }
}
- (void)lookBPButtonClick:(UIButton *)button {
    self.optionalView.hidden = YES;

    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:lookBPButtonClick:)]) {
        [self.delegate bpMeReceivedCell:self lookBPButtonClick:button];
        if (self.model.browse_status.integerValue == 2) {
            self.redPoint.hidden = YES;
        }
    }
}
- (void)projectAvatarViewTap:(UITapGestureRecognizer *)tapGest {
    self.optionalView.hidden = YES;
    if (self.model.product_info.product.length <= 0) {
        [self lookBPButtonClick:self.lookBPButton];
        return;
    }
    if (!self.model.product_info) {
        [PublicTool showMsg:@"没有关联项目"];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:projectButtonClick:)]) {
        [self.delegate bpMeReceivedCell:self projectButtonClick:self.model.product_info.detail];
    }
}
- (void)sourceUserLabelTap {
    self.optionalView.hidden = YES;

    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:sourceUserClick:)]) {
        [self.delegate bpMeReceivedCell:self sourceUserClick:self.model];
    }
}

- (void)favorateViewBtnClick:(UIButton*)btn{
    
    NSString *title = btn.titleLabel.text;
    NSInteger flag = 0;
    if ([title isEqualToString:@"感兴趣"]) {
        flag = 2;
    }else if ([title isEqualToString:@"不感兴趣"]) {
        flag = 0;
    }else if ([title isEqualToString:@"未标记"]) {
        flag = 1;
    }
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/modifyWorkBpToMeStatus" HTTPBody:@{@"id":_model.reportId,@"flag":@(flag)} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
            _model.interest_flag = flag;
            self.optionalView.hidden = YES;
            if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:refreshTableView:)]) {
                [self.delegate bpMeReceivedCell:self refreshTableView:_model];
            }
            
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
        
        _optionalView.hidden = YES;
        _model.showOptionView = 0;
        
    }];
}
- (void)bandProjectButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(bpMeReceivedCell:editBPButtonClick:)]) {
        [self.delegate bpMeReceivedCell:self editBPButtonClick:button];
    }
}
#pragma mark - Getter
- (UIView *)redPoint{
    if (!_redPoint) {
        _redPoint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 4, 4)];
        _redPoint.backgroundColor = RED_TEXTCOLOR;
        _redPoint.layer.masksToBounds = YES;
        _redPoint.layer.cornerRadius = 2;
    }
    return _redPoint;
}
- (UIImageView *)projectAvatarView {
    if (!_projectAvatarView) {
        UIImageView *view = [[UIImageView alloc] init];
//        view.frame = CGRectMake(15, 10, 44, 44);
        view.layer.cornerRadius = 4.0;
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(projectAvatarViewTap:)];
        [view addGestureRecognizer:tapGest];
        _projectAvatarView = view;
    }
    return _projectAvatarView;
}
- (UILabel *)projectNameLabel {
    if (!_projectNameLabel) {
        UILabel *label = [[UILabel alloc] init];
//        label.frame = CGRectMake(15+32+8, 10, 200, 20);
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = HTColorFromRGB(0x000000);
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(projectAvatarViewTap:)];
        [label addGestureRecognizer:tapGest];
        _projectNameLabel = label;
    }
    return _projectNameLabel;
}
- (UILabel *)projectYeWuLabel {
    if (!_projectYeWuLabel) {
        UILabel *label = [[UILabel alloc] init];
//        label.frame = CGRectMake(15+32+8, 38, 200, 20);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = HTColorFromRGB(0xA8A8A8);
        _projectYeWuLabel = label;
    }
    return _projectYeWuLabel;
}
- (UILabel *)projectHangyeLabel {
    if (!_projectHangyeLabel) {
        UILabel *label = [[UILabel alloc] init];
//        label.frame = CGRectMake(15+32+8, 38, 200, 20);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = HTColorFromRGB(0xA8A8A8);
        _projectHangyeLabel = label;
    }
    return _projectHangyeLabel;
}
- (UIButton *)lookBPButton {
    if (!_lookBPButton) {
        UIButton *button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:@"查看BP"
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                                NSUnderlineColorAttributeName: BLUE_TITLE_COLOR,
                                                                                NSUnderlineStyleAttributeName:@(0),
                                                                                NSForegroundColorAttributeName:BLUE_TITLE_COLOR
                                                                                }];
        [button setAttributedTitle:astr forState:UIControlStateNormal];
        [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [button addTarget:self action:@selector(lookBPButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _lookBPButton = button;
    }
    return _lookBPButton;
}
- (UIButton *)contactButton {
    if (!_contactButton) {
        UIButton *button = [[UIButton alloc] init];
//        button.frame = CGRectMake(15, 50, 48, 14);
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:@"联系项目"
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                                NSUnderlineColorAttributeName: BLUE_TITLE_COLOR,
                                                                                NSUnderlineStyleAttributeName:@(0),
                                                                                NSForegroundColorAttributeName:BLUE_TITLE_COLOR
                                                                                }];
        [button setAttributedTitle:astr forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [button addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _contactButton = button;
    }
    return _contactButton;
}
- (UIButton *)bandProjectButton {
    if (!_bandProjectButton) {
        _bandProjectButton = [[UIButton alloc] init];
        [_bandProjectButton setTitle:@"编辑" forState:UIControlStateNormal];
        _bandProjectButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_bandProjectButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_bandProjectButton addTarget:self action:@selector(bandProjectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bandProjectButton;
}
- (UILabel *)sourceUserLabel {
    if (!_sourceUserLabel) {
        UILabel *label = [[UILabel alloc] init];
//        label.frame = CGRectMake(200, 49, 200, 16);
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = BLUE_TITLE_COLOR;
        _sourceUserLabel = label;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceUserLabelTap)];
        [label addGestureRecognizer:tapGest];
    }
    return _sourceUserLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        UILabel *label = [[UILabel alloc] init];
//        label.frame = CGRectMake(200, 51, 200, 12);
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = HTColorFromRGB(0xA8A8A8);
        _timeLabel = label;
    }
    return _timeLabel;
}
- (UIButton *)favorButton {
    if (!_favorButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(SCREENW-40-5, 0, 40, 38);
        [button setImage:[UIImage imageNamed:@"bp_mark"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"bp_favor_selected"] forState:UIControlStateSelected];
//        [button addTarget:self action:@selector(favorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _favorButton = button;
    }

    return _favorButton;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 75.5, SCREENW, 0.5);
        _lineView.backgroundColor = LINE_COLOR;
    }
    return _lineView;
}
- (UIView *)optionalView {
    if (!_optionalView) {
        _optionalView = [[UIView alloc] initWithFrame:CGRectMake(SCREENW - 100, 50, 90, 80)];
        _optionalView.frame = CGRectMake(0, 0, 0, 0);
        _optionalView.backgroundColor = [UIColor whiteColor];
        _optionalView.layer.cornerRadius = 3;
        _optionalView.layer.borderColor = [LINE_COLOR CGColor];
        _optionalView.layer.borderWidth = 0.5;
        _optionalView.clipsToBounds = YES;
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(0, 0, 140, 40);
        button1.titleLabel.font = [UIFont systemFontOfSize:14];
        [button1 setTitle:@"感兴趣" forState:UIControlStateNormal];
        [button1 setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(favorateViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button1.tag = 1000;
        [_optionalView addSubview:button1];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(0, 40, 140, 40);
        button2.titleLabel.font = [UIFont systemFontOfSize:14];
        [button2 setTitle:@"不感兴趣" forState:UIControlStateNormal];
        [button2 setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(favorateViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button2.tag = 1001;
        [_optionalView addSubview:button2];
        
        UIImageView *view = [[UIImageView alloc] init];
        view.frame = CGRectMake(10, 40, 120, 0.5);
        view.backgroundColor = LINE_COLOR;
        [_optionalView addSubview:view];
        _optionalView.hidden = YES;
    }
    
    //每次更新数据
    if (_model) {
        UIButton *topBtn = [_optionalView viewWithTag:1000];
        UIButton *downBtn = [_optionalView viewWithTag:1001];
        
        switch (_model.interest_flag) { //1 未标记   0 不感兴趣  2 感兴趣
            case 1:{
                [topBtn setTitle:@"感兴趣" forState:UIControlStateNormal];
                [downBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
                
            }
                break;
            case 2:{
                [topBtn setTitle:@"未标记" forState:UIControlStateNormal];
                [downBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
                
            }
                break;
            case 0:{
                [topBtn setTitle:@"未标记" forState:UIControlStateNormal];
                [downBtn setTitle:@"感兴趣" forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
    }

//    _optionalView.top = self.favorButton.bottom+2;
//    _optionalView.right = self.contentView.right-15;
//    _optionalView.size = CGSizeMake(140, 80);

    return _optionalView;
}
#pragma mark - Util
- (NSString *)formatDate:(NSString *)str {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; //.S
    
    NSDate *date = [formatter dateFromString:str];
    
    if (!date) return @"";
    NSDateFormatter *formatterFullDate = [[NSDateFormatter alloc] init];
    [formatterFullDate setDateFormat:@"yyyy.MM.dd"];
    [formatterFullDate setLocale:[NSLocale currentLocale]];
    return [formatterFullDate stringFromDate:date];
}

//optionView 按钮超出父视图
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * view = [super hitTest:point withEvent:event];

    if (view == nil) {
        if (_optionalView.hidden) {
            return nil;
        }
        // 转换坐标系
        CGPoint newPoint = [_optionalView convertPoint:point fromView:self];
        // 判断触摸点是否在_optionalView上
        if (CGRectContainsPoint(_optionalView.bounds, newPoint)) {
            
            for (UIView *subView in _optionalView.subviews) {
                if (subView.tag == 1001) { //optionalView超出父视图部分
                    view = subView;
                }
            }
            
        }

        
    }
    return view;
}

@end
