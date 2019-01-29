//
//  CompanyInfoView.h
//  qmp_ios
//
//  Created by Molly on 2016/12/16.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyInfoView : UIView

@property (copy, nonatomic) void (^ finishEditClick)(NSString* text);

@property (strong, nonatomic)  UIButton *finishEditBtn;

@property (strong, nonatomic)  UITextView *infoLbl;

@property (strong, nonatomic) NSString *shortUrlStr;
@property (strong, nonatomic)  UILabel *nameLbl;
@property (strong, nonatomic)  UILabel *infoLabel;

+ (CompanyInfoView *)instanceCompanyInfoView:(CGRect)frame withInfo:(NSString *)info;

+ (CompanyInfoView *)instanceCompanyInfoView:(CGRect)frame withName:(NSString*)productName withInfo:(NSString *)info;
@end
