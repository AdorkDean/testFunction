//
//  RegisterInfoViewModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

typedef NS_ENUM(NSInteger,HeaderShowStatus){
    HeaderShowStatus_Show = 1,
    HeaderShowStatus_Hide,
    HeaderShowStatus_None //不用显示
};

#import <Foundation/Foundation.h>
// @[@"注册信息",@"股东信息",@"主要成员",@"对外投资",@"联系方式",@"备案信息",@"变更记录"];
@class PersonModel;
@interface RegisterInfoViewModel : NSObject

- (instancetype)initWithAllInfo:(NSDictionary *)info company:(NSString *)companyName;
@property (nonatomic, weak) UITableView *tableV;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, copy) NSString *companyName;
@property(nonatomic,strong) NSMutableDictionary *sectionShowAllDic;
@property (nonatomic, strong) NSMutableArray *allSection;
@property (nonatomic, strong) RACCommand *headerShowBtnCommand;


- (NSInteger)numberOfSection;
- (NSInteger)numberOfRowInSection:(NSInteger)section;

- (id)modelWithIndexPath:(NSIndexPath *)indexPath;
- (NSString *)headerTitleOfSection:(NSInteger)section;
- (NSString *)headerDescOfSection:(NSInteger)section;
- (HeaderShowStatus)headerStatusOfSection:(NSInteger)section;

- (CGFloat)heightOfRowIndexPath:(NSIndexPath *)indexPath;

- (NSDictionary *)legelPersonParam;
- (PersonModel *)legelPersonModel;

- (BOOL)hasStockHolders;

- (NSArray *)allIcpInfos;
@end
