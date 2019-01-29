//
//  OnePickerView.m
//  qmp_ios
//
//  Created by QMP on 2018/1/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OnePickerView.h"

@interface OnePickerView()<UIPickerViewDelegate,UIPickerViewDataSource, UIGestureRecognizerDelegate>
{
    void(^backBlock)(NSString *);
    NSArray *_dataArr;
    UIView *contentView;

    NSString *selectedStr;
}
@end


@implementation OnePickerView

- (instancetype)initDatePackerWithResponse:(void(^)(NSString*))block dataSource:(NSArray*)dataArr{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    _dataArr = dataArr;
    selectedStr = dataArr[0];
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    
    return self;
}


- (void)setViewInterface {
    
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 200)];
    [self addSubview:contentView];
    
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 0, 60, 40)];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 160)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    
    //设置pickerView默认选中当前时间
    [pickerView selectRow:0 inComponent:0 animated:YES];
    [pickerView selectRow:0 inComponent:1 animated:YES];
    
    [contentView addSubview:pickerView];
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        backBlock(selectedStr);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.3 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:{
            return _dataArr.count;
            break;
        }
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.width/3, 0, 50)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    switch (component) {
        case 0:
            label.text = _dataArr[row];
            break;
       
        default:
            break;
    }
    
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"选择%ld %ld",component,row);
    switch (component) {
        case 0:{
            selectedStr = _dataArr[row];
            break;
        }
        default:
            break;
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:contentView]) {
        return NO;
    }
    return YES;
}
@end
