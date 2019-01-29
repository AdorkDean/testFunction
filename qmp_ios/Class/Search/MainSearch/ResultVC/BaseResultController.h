//
//  BaseResultController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger,SearchType) {
    SearchType_All = 1,
    SearchType_Product,
    SearchType_Jigou,
    SearchType_Person,
    SearchType_Company,
    SearchType_Report,
    SearchType_News
};

typedef void(^ClickAllJigou)(void);
typedef void(^ClickAllProduct)(void);
typedef void(^ClickAllPerson)(void);
typedef void(^ClickAllRegist)(void);

@interface BaseResultController : BaseViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIButton *feedbackBtn;
@property (copy, nonatomic) ClickAllJigou clickAllJigou;
@property (copy, nonatomic) ClickAllProduct clickAllProduct;
@property (copy, nonatomic) ClickAllPerson clickAllPerson;
@property (copy, nonatomic) ClickAllRegist clickAllRegist;
@property (copy, nonatomic) void(^clickAllNews)();
@property (nonatomic,strong) NSMutableArray *dataArr;

@property (copy, nonatomic) NSString *keyword;
@property(nonatomic,assign) SearchType searchType;

- (void)baiduBtnClick;
- (void)feedbackAlertView1;
- (void)kefuBtnClick:(UIButton *)button;
@end
