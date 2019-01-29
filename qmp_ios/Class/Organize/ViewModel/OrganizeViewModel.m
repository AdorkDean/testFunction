//
//  OrganizeViewModel.m
//  qmp_ios
//
//  Created by QMP on 2018/6/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OrganizeViewModel.h"
#import "JiGouDetailModel.h"
#import "OrgFaProductModel.h"
#import "OrganizeItem.h"
#import <YYText.h>
#import "RelateCompanyModel.h"
#import "JigouInvestmentsCaseModel.h"
#import "OrganizeCombineItem.h"
#import "ActivityModel.h"
#import "ActivityLayout.h"
#import "IntroduceCellLayout.h"
#import "ManagerItem.h"
#import "NewsModel.h"
#import "WinExperienceModel.h"
#import "ZhaopinModel.h"

@interface OrganizeViewModel ()

@property (nonatomic, strong) NSMutableArray *relateCompanys;
@property (nonatomic, strong) NSMutableArray *investCases;
@property (nonatomic, strong) NSMutableArray *faCases;
@property (nonatomic, strong) NSMutableArray *togetherInvestOrganizes;


@property (nonatomic, strong) NSMutableArray *hasTitleArray;

@property (nonatomic, assign) NSInteger serviceCasesCount;
@property (nonatomic, assign) NSInteger faCasesCount;
@end
@implementation OrganizeViewModel
- (void)dealloc {
    QMPLog(@"%s", __func__);
}
- (NSInteger)numberOfSections {
    return self.sectionTitles.count?:1;
}
- (NSInteger)numberOfRowInSection:(NSInteger)section {
    if (self.sectionTitles.count == 0) {
        return 1;
    }
  
    NSString *title = [self titleOfSection:section];
    if ([title hasPrefix:@"相关公司"]) {
        return MIN(3, self.relateCompanys.count);
    }
    if ([title isEqualToString:@"机构介绍"]) {
        if (self.organizeInfo.tzcount.integerValue > 0 || self.organizeInfo.score.length > 0) {
            return [PublicTool isNull:self.organizeInfo.gw_link]?2:3;
        }
        return [PublicTool isNull:self.organizeInfo.gw_link]?1:2;
    }
    if ([title isEqualToString:@"相关新闻"]) {
        return MIN(3, self.organizeNewsData.count);
    }
    if ([title isEqualToString:@"在服项目"]) {
        return MIN(3, self.serviceCases.count);
    }
    
    if ([title isEqualToString:@"获奖经历"]) {
        return MIN(3, self.organizePrizeData.count);
    }
    if ([title isEqualToString:@"合投/参投机构"]) {
        return MIN(3,self.togetherInvestOrganizes.count);
    }
    if ([title isEqualToString:@"招聘信息"]) {
        return MIN(3,self.zhaopinArr.count);
    }
    return 1;
}
- (id)modelOfIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self titleOfSection:indexPath.section];
    if ([title isEqualToString:@"用户分享"]) {
        if (self.countOfActivities == 0) {
            return 45.0;
        }
        ActivityLayout *layout = self.activityData.firstObject;
        return layout.textLayout.textBoundingSize.height+45;
        
    }else if ([title isEqualToString:@"机构介绍"]) {
        if (indexPath.row == 0) {
            if (self.organizeInfo.tzcount.integerValue > 0 || self.organizeInfo.score.length > 0) {
                return 95.0;
            }
            return self.introduceCellLayout.cellHeight;
        }else if(indexPath.row == 1){
            if (self.organizeInfo.tzcount.integerValue > 0 || self.organizeInfo.score.length > 0) {
                return self.introduceCellLayout.cellHeight;
            }
        }
        NSString *title = self.organizeInfo.gw_link;
        CGFloat width = (SCREENW-107);
        CGFloat height = [title boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height+1;
        if (height < 34) {
            return 24;
        }
        return 45.f;
    } else if ([title isEqualToString:@"相关新闻"]) {
        return 57;

    } else if ([title isEqualToString:@"投资团队"]) {
        if (self.organizeMember.count > 4) {
            return 82*3+10;
        }
        return self.organizeMember.count * 82+10;
    } else if ([title isEqualToString:@"投资案例"]) {
        if (self.investCases.count > 4) {
            return 78*3+7;
        }
        return self.investCases.count * 78+7;
    } else if ([title isEqualToString:@"FA案例"]) {
        if (self.faCases.count > 4) {
            return 78*3+7;
        }
        return self.faCases.count * 78+7;
    }else if ([title isEqualToString:@"获奖经历"]) {
        WinExperienceModel *winM = self.organizePrizeData[indexPath.row];
        CGFloat height = [PublicTool heightOfString:winM.prize_name width:SCREENW-56-17 font:[UIFont systemFontOfSize:15]];
        if (indexPath.row == 0) {
            return height+50;
        }
        return height+40;
    }else if ([title isEqualToString:@"招聘信息"]) {
        if (indexPath.row == 0) {
            return 65;
        }
        return 58;
    }
    
    NSDictionary *heightSection = @{@"在服项目":@(87),@"机构概况":@(95),@"相关公司":@(60),@"投资案例":@(105),@"FA案例":@(105),@"合投/参投机构":@(60), @"相关新闻":@(58)};
    return [heightSection[title] floatValue];
}

- (void)fixSectionTitles {
    if (self.togetherCount > 0) {
        [self.hasTitleArray addObject:@"合投/参投机构"];
    }
    
//    if (self.organizeInfo.tzcount.integerValue > 0 || self.organizeInfo.score.length > 0) {
//        [self.hasTitleArray addObject:@"机构概况"];
//    }

    NSMutableArray *indexs = [NSMutableArray array];
    NSArray *allSecctions = @[@"用户分享",@"机构概况",@"机构介绍",@"投资团队",@"在服项目",@"FA案例",@"投资案例", @"合投/参投机构", @"相关公司",@"获奖经历", @"相关新闻",@"招聘信息"];
    self.sectionTitles = [NSMutableArray arrayWithArray:allSecctions];
    NSInteger index = 0;
    for (NSString *title in allSecctions) {
        if (![self.hasTitleArray containsObject:title]) {
            [indexs addObject:title];
        }
        index++;
    }
    
    for (NSString *n in indexs) {
        [self.sectionTitles removeObject:n];
    }
}

- (JiGouDetailModel *)detailModelWithResponse:(NSDictionary *)resp {
    [self handleOrganizeDetailWithResponse:resp];
    return [JiGouDetailModel new];
}

- (void)handleOrganizeDetailWithResponse:(NSDictionary *)resp {
    self.organizeInfo = [[OrganizeItem alloc] initWithDictionary:resp[@"agency_basic"] error:nil];
    self.organizeInfo.miaoshu = [PublicTool filterSpecialString:self.organizeInfo.miaoshu];
    NSArray *contactArr = (NSArray*)resp[@"agency_contact"];
    self.lianxi = contactArr.count ? contactArr.firstObject : @{};
    
    self.introduceInfoDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"content":self.organizeInfo.miaoshu?:@"",@"spread":@(NO)}];
    self.introduceCellLayout = [[IntroduceCellLayout alloc] initWithIntroduce:self.introduceInfoDic];
    
    self.claimType = self.organizeInfo.claim_type;
    
    if (self.investCasesCount) {
        self.organizeInfo.tzcount = [NSString stringWithFormat:@"%zd",self.investCasesCount];
    }
    if (self.faCasesCount) {
        self.organizeInfo.faCasecount = [NSString stringWithFormat:@"%zd",self.faCasesCount];
    }
    
}

- (NSString *)organizeID {
    return self.organizeInfo.ticket;
}

- (NSString *)organizeTicket {
    return @"";
//    return self.organizeInfo.;
}

- (NSString *)titleOfSection:(NSInteger)section {
    if (self.sectionTitles.count == 0) {
        return @"";
    }
    return [self.sectionTitles objectAtIndex:section];
}
- (NSString *)rightTitleOfSection:(NSInteger)section {
    if (self.sectionTitles.count == 0) {
        return @"";
    }
    NSString *title = [self.sectionTitles objectAtIndex:section];
    if ([title isEqualToString:@"用户分享"]) {
        return self.countOfActivities > 0 ? [NSString stringWithFormat:@"全部(%zd)", self.countOfActivities] : @"";
    }
    if ([title isEqualToString:@"投资团队"]) {
        return [NSString stringWithFormat:@"全部(%zd)", self.teamCount];
    }
    if ([title isEqualToString:@"投资案例"]) {
        return self.investCasesCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.investCasesCount]:@"";
    }
    if ([title isEqualToString:@"相关公司"]) {
        return self.countOfRelatePro > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.countOfRelatePro]:@"";
    }
    if ([title isEqualToString:@"相关新闻"]) {
        return self.newsAllCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.newsAllCount]:@"";
    }
    if ([title isEqualToString:@"在服项目"]) {
        return self.serviceCasesCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.serviceCasesCount]:@"";
    }
    if ([title isEqualToString:@"FA案例"]) {
        return self.faCasesCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.faCasesCount]:@"";
    }
    if ([title isEqualToString:@"获奖经历"]) {
        return self.prizeAllCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.prizeAllCount]:@"";
    }
    if ([title isEqualToString:@"合投/参投机构"]) {
        return self.togetherCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.togetherCount]:@"";
    }
    if ([title isEqualToString:@"招聘信息"]) {
        return self.zhaopinCount > 3 ? [NSString stringWithFormat:@"全部(%zd)", self.zhaopinCount]:@"";
    }
    return @"";
}


- (NSMutableArray *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = [NSMutableArray array];
//        [_sectionTitles addObjectsFromArray:@[@"用户分享",@"机构概况",@"机构介绍",@"投资团队",@"在服项目",@"FA案例",@"投资案例", @"合投/参投机构", @"相关公司", @"相关新闻"]];
    }
    return _sectionTitles;
}
- (CGFloat)infoCellHeight {
    if (_infoCellHeight <= 0) {
        NSString *desc = self.organizeInfo.miaoshu;
        if (desc.length <= 0) {
            _infoCellHeight = 0;
            return _infoCellHeight;
        }
        desc = [desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        CGFloat totalHeight = [PublicTool heightOfString:desc width:SCREENW - 35 font:[UIFont systemFontOfSize:14]];
        int row = totalHeight / [UIFont systemFontOfSize:14].lineHeight;
        row = (row <= 5) ? row : 5;
        
        CGFloat introduceHeight = 0;
        if (row == 1) {
            introduceHeight = 18;
        } else {
            introduceHeight = 21.5*row;
        }
        
        CGFloat webHeight = 0;
        if (self.organizeInfo.gw_link.length == 0) {
            webHeight = 18;
        } else {
            webHeight = [PublicTool heightOfString:self.organizeInfo.gw_link width:SCREENW - 74 font:[UIFont systemFontOfSize:15]];
        }
        _infoCellHeight = introduceHeight + webHeight + 65;
    }
    return _infoCellHeight;
}



- (void)handleInvestCaseWithResponse:(NSDictionary *)resp {
    NSMutableArray *arr = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            JigouInvestmentsCaseModel *item = [[JigouInvestmentsCaseModel alloc] init];
            [item setValuesForKeysWithDictionary:dict];
            [arr addObject:item];
        }
    }
    self.investCases = arr;
    if (arr.count > 0) {
        [self.hasTitleArray addObject:@"投资案例"];
    }
    self.investCasesCount = [resp[@"count"] integerValue];
    if (self.organizeInfo) {
        self.organizeInfo.tzcount = [NSString stringWithFormat:@"%@",resp[@"count"]];
    }
    
}

- (JigouInvestmentsCaseModel *)investCaseAtRow:(NSInteger)row {
    return [self.investCases objectAtIndex:row];
}
- (CGFloat)heightForInvestCaseAtRow:(NSInteger)row {
    JigouInvestmentsCaseModel *model = [self investCaseAtRow:row];
    //添加轮次
    CGFloat rowHeight = [UIFont systemFontOfSize:14].lineHeight;
    CGFloat rowEdge = 12;
    
    CGFloat height = 0;
    if (model.lunciStringArr.count) {
        height = rowHeight * model.lunciStringArr.count + rowEdge*(model.lunciStringArr.count-1);
    }
    return 92 + height;
}


- (void)handleOrganizeActivityWithResponse:(NSDictionary *)resp {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            ActivityModel *model = [ActivityModel activityModelWithDict:dict];
            if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                model.linkInfo.linkTitle = @"新闻链接";
            }
            ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypeCompany];
            [arr addObject:layout];
        }
    }
    self.activityData = arr;
    self.countOfActivities = [resp[@"count"] integerValue];
}


- (void)handleFACaseWithResponse:(NSDictionary *)resp {
    NSMutableArray *arr = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in resp[@"list"]) {
            JigouInvestmentsCaseModel *company = [[JigouInvestmentsCaseModel alloc] init];
            [company setValuesForKeysWithDictionary:dic];
            [arr addObject:company];
        }
    }
    self.faCases = arr;
    if (arr.count > 0) {
        [self.hasTitleArray addObject:@"FA案例"];
    }
    self.faCasesCount = [resp[@"count"] integerValue];
    if (self.organizeInfo) {
        self.organizeInfo.faCasecount = [NSString stringWithFormat:@"%ld", self.faCasesCount];
    }
}

- (void)handleManagersWithResponse:(NSDictionary*)resp{
    self.organizeMember = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            ManagerItem *item = [[ManagerItem alloc] initWithDictionary:dict error:nil];
            [self.organizeMember addObject:item];
        }
    }
    if (self.organizeMember.count > 0) {
        [self.hasTitleArray addObject:@"投资团队"];
    }
    self.teamCount = [resp[@"count"] integerValue];
}

- (void)handlePrizeWithResponse:(NSDictionary*)resp{
    
    self.organizePrizeData = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            WinExperienceModel *news = [[WinExperienceModel alloc] initWithDictionary:dict error:nil];
            [self.organizePrizeData addObject:news];
        }
    }
    if (self.organizePrizeData.count > 0) {
        [self.hasTitleArray addObject:@"获奖经历"];
    }
    self.prizeAllCount = [resp[@"count"] integerValue];
}

- (void)handleNewsWithResponse:(NSDictionary*)resp{
    
    self.organizeNewsData = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            NewsModel *news = [[NewsModel alloc] initWithDictionary:dict error:nil];
            [self.organizeNewsData addObject:news];
        }
    }
    if (self.organizeNewsData.count > 0) {
        [self.hasTitleArray addObject:@"相关新闻"];
    }
    self.newsAllCount = [resp[@"count"] integerValue];
}
- (void)handleZhaopinInfoWithResponse:(NSDictionary*)resp{
    self.zhaopinArr = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            ZhaopinModel *zhaopinArr = [[ZhaopinModel alloc] initWithDictionary:dict error:nil];
            [self.zhaopinArr addObject:zhaopinArr];
        }
    }
    if (self.zhaopinArr.count > 0) {
        [self.hasTitleArray addObject:@"招聘信息"];
    }
    self.zhaopinCount = [resp[@"count"] integerValue];
}

- (NSArray *)caseArrWithTitle:(NSString *)sectionTitle {
    if ([sectionTitle isEqualToString:@"投资案例"]) {
        return self.investCases;
    }
    return self.faCases;
}

- (void)handleServiceCaseWithResponse:(NSDictionary *)resp {
    self.serviceCases = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            OrgFaProductModel *company = [[OrgFaProductModel alloc]initWithDictionary:dict error:nil];
            [self.serviceCases addObject:company];
        }
    }
    
    if (self.serviceCases.count > 0) {
        [self.hasTitleArray addObject:@"在服项目"];
    }
    self.serviceCasesCount = [resp[@"count"] integerValue];
}

- (void)handleTogetherOrganizeWithResponse:(NSDictionary *)resp {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if ([resp isKindOfClass:[NSDictionary class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            OrganizeCombineItem *item = [[OrganizeCombineItem alloc] init];
            [item setValuesForKeysWithDictionary:dict];
            [arr addObject:item];
        }
    }
    self.togetherInvestOrganizes = arr;
    self.togetherCount = [resp[@"count"] integerValue];
}

- (OrganizeCombineItem *)togetherInvestOrganizeAtRow:(NSInteger)row {
    return [self.togetherInvestOrganizes objectAtIndex:row];
}

- (void)handleRelateCompanyWithResponse:(NSDictionary *)resp {
    NSMutableArray *arr = [NSMutableArray array];
    if ([resp isKindOfClass:[NSDictionary class]] && [resp[@"list"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in resp[@"list"]) {
            RelateCompanyModel *company = [[RelateCompanyModel alloc] initWithDictionary:dict error:nil];
            [arr addObject:company];
        }
        self.relateCompanys = arr;
        if (arr.count > 0) {
            [self.hasTitleArray addObject:@"相关公司"];
        }
    }
    self.countOfRelatePro = [resp[@"count"] integerValue];
}

- (NSString *)relateCompanyNameAtRow:(NSInteger)row {
    RelateCompanyModel *company = [self.relateCompanys objectAtIndex:row];
    return company.company;
}
- (RelateCompanyModel *)relateCompanyAtRow:(NSInteger)row {
    return  [self.relateCompanys objectAtIndex:row];
}

- (NewsModel *)newsModelAtRow:(NSInteger)row {
    return self.organizeNewsData[row];
}
- (WinExperienceModel *)prizesModelAtRow:(NSInteger)row{
    return self.organizePrizeData[row];
}

- (ZhaopinModel *)zhaopinModelAtRow:(NSInteger)row{
    return self.zhaopinArr[row];
}

- (NSMutableArray *)hasTitleArray {
    if (!_hasTitleArray) {
        _hasTitleArray = [NSMutableArray array];
        [_hasTitleArray addObjectsFromArray:@[@"用户分享",@"机构介绍"]];
    }
    return _hasTitleArray;
}

- (void)handleCommonCountWithResponse:(NSDictionary *)resp {
    self.digged = [resp[@"like_status"] boolValue];
    self.diggCount = [resp[@"like_count"] integerValue];
    self.followed = [resp[@"focus_status"] boolValue];
}

- (CGFloat)tableHeaderViewHeight {
    CGFloat baseHeight = 83;
    
    if (![self.lianxi isKindOfClass:[NSDictionary class]] || self.lianxi.allKeys.count == 0) {
        return 78;
    }

    NSInteger infoCount = 0;
    CGFloat phoneHeight = [self heightForTableHeaderCardInfo:self.lianxi[@"phone"]];
    if (phoneHeight > 0) {
        baseHeight += phoneHeight;
        infoCount++;
    }
    
    CGFloat emailHeight = [self heightForTableHeaderCardInfo:self.lianxi[@"email"]];
    if (emailHeight > 0) {
        baseHeight += emailHeight;
        infoCount++;
    }
    
    CGFloat addressHeight = [self heightForTableHeaderCardInfo:self.lianxi[@"address"]];
    if (addressHeight > 0) {
        baseHeight += addressHeight;
        infoCount++;
    }
    if (infoCount > 0) {
        baseHeight += ((infoCount-1)*8);
    }
    
    return baseHeight + 10;
}

- (CGFloat)heightForTableHeaderCardInfo:(NSString *)info {
    if ([PublicTool isNull:info]) {
        return 0;
    }
    YYTextContainer *c = [YYTextContainer containerWithSize:CGSizeMake(SCREENW-55, MAXFLOAT)];
    c.maximumNumberOfRows = 3;
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc] initWithString:info?:@""
                                                                          attributes:@{
                                                                                       NSFontAttributeName:[UIFont systemFontOfSize:12]
                                                                                       }];
    YYTextLayout *l = [YYTextLayout layoutWithContainer:c text:t];
    return l.textBoundingSize.height;
}

@end
