//
//  RegisterInfoViewModel.m
//  qmp_ios
//
//  Created by QMP on 2018/6/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "RegisterInfoViewModel.h"
#import "CompanysDetailRegisterGudongModel.h"
#import "CompanysDetailRegisterPeoplesModel.h"
#import "CompanysDetailRegisterTouziModel.h"
#import "CompanyIcpModel.h"
#import "CompanysDetailRegisterChangeRecordsModel.h"
#import "PersonModel.h"
#import <ReactiveObjC.h>

@interface RegisterInfoViewModel ()
@property (nonatomic, strong) NSMutableArray *baseInfo;
@property (nonatomic, strong) NSArray *stockholders;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSArray *invests;
@property (nonatomic, strong) NSArray *contactInfo;
@property (nonatomic, strong) NSDictionary *relateProInfo;
@property (nonatomic, strong) NSArray *icpInfo;
@property (nonatomic, strong) NSArray *changeRecords;
@end
// @[@"注册信息",@"股东信息",@"主要成员",@"对外投资",@"联系方式",@"备案信息",@"变更记录"];
@implementation RegisterInfoViewModel
- (instancetype)initWithAllInfo:(NSDictionary *)info company:(NSString *)companyName {
    self = [super init];
    if (self) {
        self.info = info;
        self.companyName = companyName;
        
        [self handleRegister];
        [self handleStockHolders];
        [self handleMembers];
        [self handleInvests];
        [self handleContactInfo];
        [self handleIcpInfo];
        [self handleChangeRecords];
        [self handleRelateProInfo];
        [self handleSectionAndRows];
    }
    return self;
}
- (void)handleSectionAndRows {
    if (self.relateProInfo) {
        NSString *title = [self.relateProInfo[@"detail"] containsString:@"org"]?@"关联机构":@"关联项目";
        NSDictionary *proDic = @{@"title":title, @"data":@[self.relateProInfo], @"desc":@""};
        [self.allSection addObject:proDic];
        [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:title];
    }
    
    if (self.baseInfo.count > 0) {
        NSDictionary *dict = @{@"title":@"注册信息", @"data":self.baseInfo, @"desc":@""};
        [self.allSection addObject:dict];
        [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"注册信息"];
    }
    if (self.stockholders.count > 0) {
        NSDictionary *dict = @{@"title":@"股东信息", @"data":self.stockholders, @"desc":@"出资比例"};
        [self.allSection addObject:dict];
        if (self.stockholders.count <= 3) {
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"股东信息"];
        }else{
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_Hide) forKey:@"股东信息"];
        }
    }
    if (self.members.count > 0) {
        NSDictionary *dict = @{@"title":@"主要成员", @"data":self.members, @"desc":@""};
        [self.allSection addObject:dict];
        if (self.members.count <= 3) {
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"主要成员"];
        }else{
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_Hide) forKey:@"主要成员"];
        }
    }
    
    if (self.invests.count > 0) {
        NSDictionary *dict = @{@"title":@"对外投资", @"data":self.invests, @"desc":@""};
        [self.allSection addObject:dict];
        if (self.invests.count <= 3) {
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"对外投资"];
        }else{
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_Hide) forKey:@"对外投资"];
        }
    }
    
    if (self.contactInfo.count > 0) {
        NSDictionary *dict = @{@"title":@"联系方式", @"data":self.contactInfo, @"desc":@""};
        [self.allSection addObject:dict];
        [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"联系方式"];
    }
    
    if (self.icpInfo.count > 0) {
        NSDictionary *dict = @{@"title":@"备案信息", @"data":self.icpInfo, @"desc":@""};
        [self.allSection addObject:dict];
        if (self.icpInfo.count <= 3) {
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"备案信息"];
        }else{
            [self.sectionShowAllDic setValue:@(HeaderShowStatus_Hide) forKey:@"备案信息"];
        }
    }
    if (self.changeRecords.count > 0) {
        NSDictionary *dict = @{@"title":@"变更记录", @"data":self.changeRecords, @"desc":@""};
        [self.allSection addObject:dict];
        [self.sectionShowAllDic setValue:@(HeaderShowStatus_None) forKey:@"变更记录"];
    }

}

- (void)handleStockHolders {
    NSArray *stockHolders = self.info[@"register_shareholders"];
    if (stockHolders && [stockHolders isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSDictionary *dict in stockHolders) {
            CompanysDetailRegisterGudongModel *model = [[CompanysDetailRegisterGudongModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [tempArr addObject:model];
        }
        self.stockholders = [NSArray arrayWithArray:tempArr];
    }
}
- (void)handleMembers {
    NSArray *members = self.info[@"register_peoples"];
    if (members && [members isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSDictionary *dict in members) {
            CompanysDetailRegisterPeoplesModel *model = [[CompanysDetailRegisterPeoplesModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [tempArr addObject:model];
        }
        self.members = [NSArray arrayWithArray:tempArr];
        
    }
}
- (void)handleInvests {
    NSArray *invests = self.info[@"register_investment"];
    if (invests && [invests isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSDictionary *dict in invests) {
            CompanysDetailRegisterTouziModel *model = [[CompanysDetailRegisterTouziModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [tempArr addObject:model];
        }
        self.invests = [NSArray arrayWithArray:tempArr];
    }
}
- (void)handleContactInfo {
    NSDictionary *registerInfo = self.info[@"register_info"];
    NSDictionary *needShow = @{@"phone_number":@"电话", @"email":@"邮箱"};
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSString *key in @[@"phone_number", @"email"]) {
        if ([registerInfo.allKeys containsObject:key] && ![PublicTool isNull:registerInfo[key]]) {
            NSString *title = needShow[key];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:title forKey:@"title2"];
            [dict setValue:registerInfo[key] forKey:@"value2"];
            [tempArr addObject:dict];
        }
    }
    self.contactInfo = [NSArray arrayWithArray:tempArr];
}

- (void)handleIcpInfo {
    NSArray *icpInfo = self.info[@"register_icp"];
    if (![icpInfo isKindOfClass:[NSArray class]]) {
        return;
    }
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *dict in icpInfo) {
        CompanyIcpModel *icp = [[CompanyIcpModel alloc] init];
        [icp setValuesForKeysWithDictionary:dict];
        [tempArr addObject:icp];
    }
    self.icpInfo = [NSArray arrayWithArray:tempArr];
}
- (void)handleChangeRecords {
    NSArray *changeRecords = self.info[@"register_change"];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *dic in changeRecords) {
        CompanysDetailRegisterChangeRecordsModel *model = [[CompanysDetailRegisterChangeRecordsModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        
        NSMutableString *before_str = [NSMutableString string];
        NSMutableString *after_str = [NSMutableString string];
        
        for (NSDictionary *dict in dic[@"before_arr"]) {
            [before_str appendFormat:@"%@<br>",dict[@"name"]];
        }
        if (before_str.length >= 4) {
            NSString *trail = [before_str substringWithRange:NSMakeRange(before_str.length-4, 4)];
            if ([trail isEqualToString:@"<br>"]) {
                [before_str deleteCharactersInRange:NSMakeRange(before_str.length-4, 4)];
            }
        }
        
        for (NSDictionary *dict in dic[@"after_arr"]) {
            [after_str appendFormat:@"%@<br>",dict[@"name"]];
        }
        if (after_str.length >= 4) {
            NSString *trail = [after_str substringWithRange:NSMakeRange(after_str.length-4, 4)];
            if ([trail isEqualToString:@"<br>"]) {
                [after_str deleteCharactersInRange:NSMakeRange(after_str.length-4, 4)];
            }
        }
        model.change_before = before_str;
        model.change_after = after_str;
        model.beforeAtt = [before_str htmlStringWithParagraphlineSpeace:9 textColor:H5COLOR textFont:[UIFont systemFontOfSize:13]];
        model.afterAtt = [after_str htmlStringWithParagraphlineSpeace:9 textColor:H5COLOR textFont:[UIFont systemFontOfSize:13]];
        
        [tempArr addObject:model];
    }
    self.changeRecords = [NSArray arrayWithArray:tempArr];
}

- (void)handleRelateProInfo{
    NSDictionary *relateProInfo = self.info[@"rel_project"];
    if (relateProInfo.allKeys.count) {
        self.relateProInfo = relateProInfo;
    }
}

/*
    公司名称、法人代表、注册资本、成立时间、企业类型、注册号、信用代码、经营状态、营业期限、发照时间、注册地点、登记机关
 */
- (void)handleRegister {
    NSDictionary *registerInfo = self.info[@"register_info"];
    NSDictionary *needShow = [self baseinfomatch];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"公司名称" forKey:@"title"];
    [dict setValue:registerInfo[@"company"] forKey:@"value"];
    [tempArr addObject:dict];
    
    for (NSString *key in [self baseShow]) {
        NSString *title = needShow[key];
        if ([registerInfo.allKeys containsObject:key] && ![PublicTool isNull:registerInfo[key]]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:title forKey:@"title"];
            [dict setValue:registerInfo[key] forKey:@"value"];
            [tempArr addObject:dict];
        }
    }
    
    self.baseInfo = tempArr;
}

- (NSDictionary *)baseinfomatch {
    NSDictionary *dict = @{@"faren":@"法人代表",@"qy_ziben":@"注册资本",@"open_time":@"成立时间",
                           @"qy_type":@"企业类型",@"qy_no":@"注册号",@"credit_code":@"信用代码",
                           @"qy_status":@"经营状态",@"qy_term_end":@"营业期限",@"qy_check_date":@"发照时间",
                           @"qy_reg_address":@"注册地点",@"qy_belong":@"登记机关",@"org_number":@"机构代码",
                           @"qy_fanwei":@"经营范围",@"history_names":@"曾用名"
                           };
    return dict;
}
- (NSArray *)baseShow {
    return @[@"history_names",@"faren",@"qy_ziben",@"open_time",
             @"qy_type",@"qy_no",@"org_number",@"credit_code",
             @"qy_status",@"qy_term_end",@"qy_check_date",
             @"qy_reg_address",@"qy_belong",@"qy_fanwei"];
}
- (NSMutableArray *)allSection {
    if (!_allSection) {
        _allSection = [NSMutableArray array];
    }
    return _allSection;
}

@synthesize headerShowBtnCommand = _headerShowBtnCommand;
-(RACCommand *)headerShowBtnCommand{
    if (!_headerShowBtnCommand) {
        @weakify(self);
        _headerShowBtnCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *section) {
            @strongify(self);
            [self headerShowBtnEvent:section];
            return [RACSignal empty];
        }];
    }
    return _headerShowBtnCommand;

}


#pragma mark - public
- (void)headerShowBtnEvent:(NSNumber*)section{
    NSNumber *statusNum = [self.sectionShowAllDic valueForKey:self.allSection[section.integerValue][@"title"]];
    NSInteger status = statusNum.integerValue;
    if (status == HeaderShowStatus_Show) {
        status = HeaderShowStatus_Hide;
    }else if (status == HeaderShowStatus_Hide) {
        status = HeaderShowStatus_Show;
    }
    [self.sectionShowAllDic setValue:@(status) forKey:self.allSection[section.integerValue][@"title"]];
    [self.tableV reloadData];
}


- (NSInteger)numberOfSection {
    return self.allSection.count;
}
- (NSInteger)numberOfRowInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.allSection[section];
    NSArray *data = sectionDict[@"data"];
    HeaderShowStatus headerStatus = [[self.sectionShowAllDic valueForKey:sectionDict[@"title"]] integerValue];
    if (headerStatus == HeaderShowStatus_None || headerStatus == HeaderShowStatus_Show) {
        return data.count;
    }else{
        return 3;
    }
//    if ([sectionDict[@"title"] isEqualToString:@"备案信息"]) {
//        return MIN(data.count, 3);
//    }
    return data.count;
}

- (id)modelWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.allSection.count) {
        return nil;
    }
    NSDictionary *sectionDict = self.allSection[indexPath.section];
    NSArray *data = sectionDict[@"data"];
    return data[indexPath.row];
}

- (NSString *)headerTitleOfSection:(NSInteger)section {
    NSDictionary *sectionDict = self.allSection[section];
    return sectionDict[@"title"];
}

- (NSString *)headerDescOfSection:(NSInteger)section {
    NSDictionary *sectionDict = self.allSection[section];
    return sectionDict[@"desc"];
}


- (HeaderShowStatus)headerStatusOfSection:(NSInteger)section{
    NSNumber *statusNum = [self.sectionShowAllDic valueForKey:self.allSection[section][@"title"]];
    return statusNum.integerValue;
}


- (CGFloat)heightOfRowIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *sectionDict = self.allSection[indexPath.section];
//    NSString *title = sectionDict[@"title"];
//    if ([title isEqualToString:@"备案信息"]) {
//        return 135;
//    } else if ([title isEqualToString:@"对外投资"]) {
//        return 60;
//    } else if ([title isEqualToString:@"注册信息"]) {
//        NSDictionary *model = [self modelWithIndexPath:indexPath];
//        NSString *value = model[@"value"];
//        CGFloat width = (SCREENW - 107);
//        CGFloat height = [value boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height;
//        if (height < 34) {
//            return 40;
//        }
//        return 60.f;
//    } else if ([title isEqualToString:@""]) {
//        [tableView fd_heightForCellWithIdentifier:@"CompanysDetailRegisterChangeRecordsCell" configuration:^(CompanysDetailRegisterChangeRecordsCell *cell) {
//            [cell refreshUI:dataArr[indexPath.row]];
//        }];
//    }
//
    return 44;
}
- (NSDictionary *)legelPersonParam {
    NSDictionary *registerInfo = self.info[@"register_info"];
    return @{@"uniq_hid":(registerInfo[@"legal_hid"]?:@""),@"detail":(registerInfo[@"faren_detail_link"]?:@"")};
}
- (PersonModel *)legelPersonModel {
    NSDictionary *registerInfo = self.info[@"register_info"];
    PersonModel *person = [[PersonModel alloc]init];
    person.name = registerInfo[@"faren"];
    person.uniq_hid = registerInfo[@"legal_hid"];
    return person;
}
- (BOOL)hasStockHolders {
    return self.stockholders.count > 0;
}

- (NSArray *)allIcpInfos {
    return self.icpInfo;
}
-(NSMutableDictionary *)sectionShowAllDic{
    if (!_sectionShowAllDic) {
        _sectionShowAllDic = [NSMutableDictionary dictionary];
    }
    return _sectionShowAllDic;
}
@end
