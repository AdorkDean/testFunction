//
//  DetailFeedBackTxtCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailFeedBackTxtCell.h"
@interface DetailFeedBackTxtCell()<UITextViewDelegate>

@property(nonatomic,strong)UIView *borderView;

@end

@implementation DetailFeedBackTxtCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.borderView.layer.borderColor = [UIColor grayColor].CGColor;
    self.borderView.layer.borderWidth = 0.2;
    self.borderView.layer.cornerRadius = 4;
    self.borderView.clipsToBounds = YES;
}
+ (instancetype)initTableViewCell:(UITableView *)tableView{
    DetailFeedBackTxtCell * txtCell = [tableView dequeueReusableCellWithIdentifier:@"DetailFeedBackTxtCellID"];
    if (txtCell == nil) {
        txtCell = [[NSBundle mainBundle] loadNibNamed:@"DetailFeedBackTxtCell" owner:self options:nil].lastObject;
        [txtCell addInputTextViewOnContentView];
    }
    return txtCell;
}
- (void)addInputTextViewOnContentView{
    [self.contentView addSubview:self.borderView];
    [self.borderView addSubview:self.inputTxtVw];
}
- (HMTextView *)inputTxtVw{
    if (_inputTxtVw == nil) {
        _inputTxtVw = [[HMTextView alloc] initWithFrame:CGRectMake(5, 5, SCREENW - 34, self.contentView.bounds.size.height - 10)];
        _inputTxtVw.delegate = self;
        _inputTxtVw.placehoder = @"请在此填写问题、线索、意见";
        _inputTxtVw.placehoderColor = HCCOLOR;
        _inputTxtVw.font = [UIFont systemFontOfSize:14];
    }
    return _inputTxtVw;
}

- (UIView *)borderView{
    if (_borderView == nil) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(17, 5, SCREENW - 34, self.contentView.bounds.size.height - 10)];
    }
    return _borderView;
}
- (void)textViewDidChange:(UITextView *)textView{
    NSString * inputTxt = textView.text;
    if (inputTxt.length > 2000) {
        textView.text = [inputTxt substringToIndex:inputTxt.length - 1];
    }
    if (self.calltxtBack) {
        self.calltxtBack(textView.text);
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.borderView.frame = CGRectMake(17, 5, SCREENW - 34, self.contentView.bounds.size.height - 10);

    self.inputTxtVw.frame = CGRectMake(5, 5, self.borderView.width - 10, self.borderView.height - 10);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
