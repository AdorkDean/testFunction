//
//  ActivityModel.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityModel.h"
#import "ActivityHtmlMedia.h"
@implementation ActivityUserModel
@end
@implementation ActivityLinkModel
@end
@implementation ActivityRelateModel
@end
@implementation ActivityImageModel
@end
@implementation ActivityCompanyModel
@end

@implementation ActivityModel

+ (ActivityRelateModel *)relateModelWithProjectInfo:(NSDictionary *)dict {
    ActivityRelateModel *relate = [[ActivityRelateModel alloc] init];
    relate.type = dict[@"project_type"]?:@"";
    relate.route = dict[@"detail"]?:@"";
    relate.ID = dict[@"ticket_id"]?:@"";
    relate.projectID = dict[@"project_id"]?:@"";
    
    if (![PublicTool isNull:dict[@"project_icon"]]) {
        relate.image = dict[@"project_icon"];
    } else if (![PublicTool isNull:dict[@"icon"]]) {
        relate.image = dict[@"icon"];
    }
    
    if (![PublicTool isNull:dict[@"project_ticket"]]) {
        relate.ticket = dict[@"project_ticket"];
    } else if (![PublicTool isNull:dict[@"ticket"]]) {
        relate.ticket = dict[@"ticket"];
    }
    
    if (![PublicTool isNull:dict[@"ticket_id"]]) {
        relate.ticketID = dict[@"ticket_id"];
    }
    
    
    if (![PublicTool isNull:dict[@"is_focus"]]) {
        relate.isFollowed = [dict[@"is_focus"] boolValue];
    } else if (![PublicTool isNull:dict[@"is_follow"]]) {
        relate.isFollowed = [dict[@"is_follow"] boolValue];
    }
    
    if (![PublicTool isNull:dict[@"project"]]) {
        relate.name = dict[@"project"];
    } else if (![PublicTool isNull:dict[@"name"]]) {
        relate.name = dict[@"name"];
    }
    
    if (![PublicTool isNull:dict[@"desc"]]) {
        relate.desc = dict[@"desc"];
    } else {
        relate.desc = @"";
    }
    if (![PublicTool isNull:dict[@"yewu"]]) {
        relate.yewu = dict[@"yewu"];
    } else {
        relate.yewu = @"";
    }
    if (![PublicTool isNull:dict[@"lunci"]]) {
        relate.lunci = dict[@"lunci"];
    } else {
        relate.lunci = @"";
    }
    
    // 笔记数据的处理
    if (![PublicTool isNull:dict[@"detail"]]) {
        NSDictionary *d = [PublicTool toGetDictFromStr:dict[@"detail"]];
        relate.ticket = d[@"ticket"];
        relate.ticketID = d[@"id"];
        
        NSString *detail = dict[@"detail"];
        if ([detail containsString:@"detailcom"]) {
            relate.type = @"product";
        }
    }
    
    relate.qmpIcon = @"activity_topic";
    if ([relate.type isEqualToString:@"person"]) {
        relate.qmpIcon = @"activity_user";
        relate.claim_type = dict[@"claim_type"];
    } else if ([relate.type isEqualToString:@"jigou"]) {
        relate.qmpIcon = @"activity_product";
    } else if ([relate.type isEqualToString:@"product"]) {
        relate.qmpIcon = @"activity_product";
    }
    return relate;
}
+ (BOOL)statusWithDict:(NSDictionary *)dict key:(NSString *)key {
    if (![PublicTool isNull:dict[key]]) {
        return [dict[key] boolValue];
    }
    return NO;
}
+ (NSInteger)countWithDict:(NSDictionary *)dict key:(NSString *)key {
    if (![PublicTool isNull:dict[key]]) {
        return [dict[key] integerValue];
    }
    return 0;
}
+ (CGFloat)floatWithDict:(NSDictionary *)dict key:(NSString *)key {
    if (![PublicTool isNull:dict[key]]) {
        return [dict[key] floatValue];
    }
    return 0;
}
+ (NSString *)stringWithDict:(NSDictionary *)dict key:(NSString *)key {
    if (![PublicTool isNull:dict[key]]) {
        return dict[key];
    }
    return @"";
}
+ (ActivityRelateModel *)relateModelWithUserInfo:(NSDictionary *)dict {
    ActivityRelateModel *relate = [[ActivityRelateModel alloc] init];
    
    if (![PublicTool isNull:dict[@"nickname"]]) {
        relate.name = dict[@"nickname"]?:@"";
    }
    if (![PublicTool isNull:dict[@"headimgurl"]]) {
        relate.image = dict[@"headimgurl"]?:@"";
    } else if (![PublicTool isNull:dict[@"icon"]]) {
        relate.image = dict[@"icon"]?:@"";
    }
    
    if (![PublicTool isNull:dict[@"desc"]]) {
        relate.desc = dict[@"desc"];
    } else {
        relate.desc = @"";
    }
    
    relate.ID = dict[@"person_id"]?:@"";  /// ?????????????
    relate.projectID = dict[@"person_id"]?:@"";  /// ?????????????
    
    
    if (![PublicTool isNull:dict[@"is_focus"]]) {
        relate.isFollowed = [dict[@"is_focus"] boolValue];
    }
    
    NSInteger claimType = [self countWithDict:dict key:@"claim_type"];
    if (claimType == 2) {
        relate.type = @"person";
        relate.ticket = [self stringWithDict:dict key:@"person_ticket"];
    } else {
        relate.type = @"user";
        relate.ticket = [self stringWithDict:dict key:@"unionid"];
    }
    relate.uID = [self stringWithDict:dict key:@"unionid"];
    relate.uuID = [self stringWithDict:dict key:@"uuid"];
    relate.claim_type = [self stringWithDict:dict key:@"claim_type"];
    relate.qmpIcon = @"activity_author";
    relate.isAuthor = YES;
    return relate;
}
+ (ActivityLinkModel *)activityLinkWithDict:(NSDictionary *)dict {
    ActivityLinkModel *link = [[ActivityLinkModel alloc] init];
    link.linkUrl = [self stringWithDict:dict key:@"link_url"];
    link.linkImage = [self stringWithDict:dict key:@"link_img"];
    link.linkTitle = [self stringWithDict:dict key:@"link_title"];
    return link;
}
+ (NSMutableArray<ActivityRelateModel *> *)activityRelatesWithDict:(NSDictionary *)dict {
    NSMutableArray *relates = [NSMutableArray array];
    for (NSDictionary *relateDict in dict[@"person_arr"]) {
        ActivityRelateModel *relate = [self relateModelWithProjectInfo:relateDict];
        [relates addObject:relate];
    }
    for (NSDictionary *relateDict in dict[@"product_arr"]) {
        ActivityRelateModel *relate = [self relateModelWithProjectInfo:relateDict];
        [relates addObject:relate];
    }
    for (NSDictionary *relateDict in dict[@"agency_arr"]) {
        ActivityRelateModel *relate = [self relateModelWithProjectInfo:relateDict];
        [relates addObject:relate];
    }
    for (NSDictionary *relateDict in dict[@"theme_arr"]) {
        ActivityRelateModel *relate = [self relateModelWithProjectInfo:relateDict];
        [relates addObject:relate];
    }
    return relates;
}
+ (NSMutableArray<ActivityRelateModel *> *)activityRelatesWithDict:(NSDictionary *)dict withType:(NSString *)type {
    NSMutableArray *relates = [NSMutableArray array];
    for (NSDictionary *relateDict in dict[type]) {
        ActivityRelateModel *relate = [self relateModelWithProjectInfo:relateDict];
        [relates addObject:relate];
    }
    return relates;
}
+ (ActivityUserModel *)activityUserWithDict:(NSDictionary *)dict {
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    if (![PublicTool isNull:dict[@"nickname"]]) {
        user.name = dict[@"nickname"];
    }
    
    if ([dict.allKeys containsObject:@"headimgurl"]) {
        user.avatar = dict[@"headimgurl"]?:@"";
    } else if ([dict.allKeys containsObject:@"icon"]) {
        user.avatar = dict[@"icon"]?:@"";
    }
    user.ID = dict[@"person_id"]?:@"";
    user.uID = dict[@"unionid"]?:@"";
    user.usercode = dict[@"usercode"]?:@"";
    user.company = dict[@"company"]?:@"";
    user.position = dict[@"zhiwei"]?:@"";
    user.type = dict[@"user_type"]?:@"";
    user.desc = dict[@"desc"]?:@"";
    if (![PublicTool isNull:dict[@"uuid"]]) {
        user.uuID = dict[@"uuid"];
    }
    
    //    if (![PublicTool isNull:])
    NSInteger claimType = [self countWithDict:dict key:@"claim_type"];
    if (claimType == 2) {
        user.type = @"person";
    } else {
        user.type = @"user";
    }
    
    if (![PublicTool isNull:dict[@"is_focus"]]) {
        user.isFollowed = [dict[@"is_focus"] boolValue];
    }
    return user;
}
+ (NSArray *)imagesWithDict:(NSDictionary *)dict {
    if (![dict.allKeys containsObject:@"images"]) {
        return [NSArray array];
    }
    if (![dict[@"images"] isKindOfClass:[NSArray class]]) {
        return [NSArray array];
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *imageDict in dict[@"images"]) {
        ActivityImageModel *image = [[ActivityImageModel alloc] init];
        image.width = [ActivityModel floatWithDict:imageDict key:@"width"];
        image.height = [ActivityModel floatWithDict:imageDict key:@"height"];
        image.url = [ActivityModel stringWithDict:imageDict key:@"url"];
        image.smallUrl = [ActivityModel stringWithDict:imageDict key:@"url_400"]; //放大
        image.squareUrl = [ActivityModel stringWithDict:imageDict key:@"url_200"]; // 列表
        QMPLog(@"url: %@, sq_url: %@, sm_url: %@, w:%f, h:%f", image.url, image.squareUrl, image.smallUrl, image.width, image.height);
        [arr addObject:image];
    }
    return arr;
}
- (instancetype)initWithDict:(NSDictionary *)dict isHomeFollow:(BOOL)homeFollow {
    self = [super init];
    if (self) {
        if (![PublicTool isNull:dict[@"act_id"]]) {
            _act_id = dict[@"act_id"];
        }
        if (![PublicTool isNull:dict[@"id"]]) {
            _ID = dict[@"id"];
            _ticketID = dict[@"id"];
        }
        if (![PublicTool isNull:dict[@"ticket"]]) {
            _ticket = dict[@"ticket"];
        }
        
        
        _digged = [ActivityModel statusWithDict:dict key:@"like_status"];
        _reported = [ActivityModel statusWithDict:dict key:@"report"];
        _collected = [ActivityModel statusWithDict:dict key:@"collect"];
        _buried = [ActivityModel statusWithDict:dict key:@"tread"];
        
        _diggCount = [ActivityModel countWithDict:dict key:@"like_count"];
        _commentCount = [ActivityModel countWithDict:dict key:@"comment_num"];
        _coinCount = [ActivityModel countWithDict:dict key:@"coin_num"];
        
        if (![PublicTool isNull:dict[@"anonymous"]]) {
            _anonymous = [dict[@"anonymous"] boolValue];
        } else if (![PublicTool isNull:dict[@"user_info"]]) {
            NSDictionary *dd = dict[@"user_info"];
            if (![PublicTool isNull:dd[@"anonymous"]]) {
                _anonymous = [dd[@"anonymous"] boolValue];
            }
        }
        
        _createTime = [ActivityModel stringWithDict:dict key:@"create_time"];
        
        _linkInfo = [ActivityModel activityLinkWithDict:dict];
        _images = dict[@"images"];
        _images = [ActivityModel imagesWithDict:dict];
        _comment_html = [ActivityModel stringWithDict:dict key:@"comment_html"];
        _content = [ActivityModel stringWithDict:dict key:@"content"];
        
        if ([PublicTool isNull:dict[@"comment_html"]]) {
            _htmlMedia = [ActivityHtmlMedia htmlMediaWithString:_content];
        } else {
            _htmlMedia = [ActivityHtmlMedia htmlMediaWithString:dict[@"comment_html"]];
        }
        _content = _htmlMedia.displayText; // fix
        
        _relateProducts = [ActivityModel activityRelatesWithDict:dict withType:@"product_arr"];
        _relatePersons = [ActivityModel activityRelatesWithDict:dict withType:@"person_arr"];
        _relateOrganizations = [ActivityModel activityRelatesWithDict:dict withType:@"agency_arr"];
        _relateThemes = [ActivityModel activityRelatesWithDict:dict withType:@"theme_arr"];
        
        BOOL a = NO;
        for (ActivityRelateModel *r in _relateThemes) {
            if ([r.name isEqualToString:@"创业者说"] || [r.name isEqualToString:@"投资人说"] || [r.name isEqualToString:@"大佬动态"]) {
                a = YES;
                break;
            }
        }
        NSMutableArray *arr = [NSMutableArray array];
        if (a) {
            [arr addObjectsFromArray:_relatePersons];
            [arr addObjectsFromArray:_relateProducts];
        } else {
            [arr addObjectsFromArray:_relateProducts];
            [arr addObjectsFromArray:_relatePersons];
        }
        [arr addObjectsFromArray:_relateOrganizations];
        [arr addObjectsFromArray:_relateThemes];
        
        
        
        if (![PublicTool isNull:dict[@"user_info"]]) {
            _authRelate = [ActivityModel relateModelWithUserInfo:dict[@"user_info"]];
        } else {
            _authRelate = [ActivityModel relateModelWithUserInfo:dict];
        }
        
        if (_anonymous) {
            _authRelate.name = [NSString stringWithFormat:@"%@(花名)",_authRelate.name];
        }

        if (![_authRelate.name containsString:@"机器人"]) {
            if (_authRelate.isFollowed && !_anonymous) {
                [arr insertObject:_authRelate atIndex:0]; //用户发布的动态且非匿名，如果是关注的人置前，且header显示
            } else {
                [arr addObject:_authRelate]; //用户发布的动态且匿名，跟在relate后边
            }
        }
        
        _followRelates = arr.count ? [NSArray arrayWithObject:[arr firstObject]]:@[];
        _headerRelate = arr.count ? [arr firstObject] : nil;
        
        
        NSMutableArray *arr2 = [NSMutableArray array];
        NSMutableArray *arr3 = [NSMutableArray array];
        
        for (ActivityRelateModel *m in arr) { // 关注的提到前面
            if (m.isFollowed) {
                [arr2 addObject:m];
            } else {
                [arr3 addObject:m];
            }
        }
        arr = [NSMutableArray arrayWithArray:arr2];
        [arr addObjectsFromArray:arr3];
        
        _relates = arr;
        
        if (![PublicTool isNull:dict[@"user_info"]]) {
            _user = [ActivityModel activityUserWithDict:dict[@"user_info"]];
        } else {
            _user = [ActivityModel activityUserWithDict:dict];
        }
        
        if ([dict.allKeys containsObject:@"is_mine"]) {
            _isMine = [ActivityModel statusWithDict:dict key:@"is_mine"];
        } else {
            _isMine = [_user.uID isEqualToString:[WechatUserInfo shared].unionid];
        }
        if (_isMine) {
            _headerRelate = _authRelate;
        }
        _showCompany = YES;
        ActivityCompanyModel *company = [[ActivityCompanyModel alloc] init];
        if ([dict[@"company_info"] allKeys].count) {
            NSDictionary *companyDict = dict[@"company_info"];
            company.company = [ActivityModel stringWithDict:companyDict key:@"company"];
            company.position = [ActivityModel stringWithDict:companyDict key:@"zhiwu"];
            NSString *role = [ActivityModel stringWithDict:companyDict key:@"role"];
            company.role = [PublicTool roleTextWithRequestStr:role];
            NSString *degree = [ActivityModel stringWithDict:companyDict key:@"anonymous_degree"];
            _showCompany = !(_anonymous && [degree isEqualToString:@"1"]);
            
            if (_showCompany && company.company.length <= 0) {
                _showCompany = NO;
            }
            _anonymous = [companyDict[@"anonymous"] boolValue];
            _anonymous_degree = ![PublicTool isNull:companyDict[@"anonymous_degree"]] ? companyDict[@"anonymous_degree"]:@"1";
        }
        _company = company;
        
        NSLog(@"headerRelate-----claim_type---%@",_headerRelate.claim_type);
        _homeFollow = homeFollow;
    }
    return self;
}

+ (ActivityModel *)activityModelWithDict:(NSDictionary *)dict {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:NO];
    
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    
    return model;
}

+ (ActivityModel *)activityModelWithDict:(NSDictionary *)dict forId:(NSString *)idd {
    
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:NO];
    //    if (model.anonymous) {
    //        model.user = [self anonymousUserModel];
    //    }
    NSMutableArray *marr = [NSMutableArray array];
    for (ActivityRelateModel *m in model.relates) {
        NSLog(@"%@", model.ticket);
        if (([m.type isEqualToString:@"product"] || [m.type isEqualToString:@"jigou"]) && [m.ticket isEqualToString:idd]) {
            model.headerRelate = m;
        }
        if (([m.type isEqualToString:@"author"]) && ([m.ID isEqualToString:idd] || [m.ticket isEqualToString:idd])) {
            [marr addObject:m];
            model.headerRelate = m;
        }
    }
    if (model.isMine) {
        model.headerRelate = model.authRelate;
    }
    
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    
    
    return model;
}

+ (ActivityModel *)homeFollowVcModelWithDict:(NSDictionary *)dict {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:YES];
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    return model;
}

+ (ActivityModel *)themeVcModelWithDict:(NSDictionary *)dict {
    ActivityModel *model = [self activityModelWithDict:dict];
    model.homeFollow = YES;
    model.authRelate = [self relateModelWithUserInfo:dict[@"user_info"]];
    return model;
}
+ (ActivityModel *)squareVCModelWithDict:(NSDictionary *)dict {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:YES];
    model.headerRelate = model.authRelate;
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    return model;
}
+ (ActivityModel *)squareVCModelWithDict:(NSDictionary *)dict anonymous:(NSInteger)anonymous {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:YES];
    if (anonymous != 2) {
        model.headerRelate = model.authRelate;
    }
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    return model;
}
+ (ActivityModel *)detailVCModelWithDict:(NSDictionary *)dict fixRealte:(ActivityRelateModel *)r {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:YES];
    model.followRelates = [NSMutableArray array];
    if (r && !model.isMine) {
        for (ActivityRelateModel *m in model.relates) {
            if ([m.type isEqualToString:r.type] && [m.ticket isEqualToString:r.ticket]) {
                model.headerRelate = m;
                break;
            }
        }
    }
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    
    return model;
}
+ (ActivityModel *)personVCactivityModelWithDict:(NSDictionary *)dict ticket:(NSString *)t {
    ActivityModel *model = [[ActivityModel alloc] initWithDict:dict isHomeFollow:YES];
    model.followRelates = [NSMutableArray array];
    if (t && !model.isMine) {
        for (ActivityRelateModel *m in model.relates) {
            if ([m.ticket isEqualToString:t]) {
                model.headerRelate = m;
                break;
            }
        }
    }
    if (model.headerRelate.isAuthor && model.anonymous && [model.headerRelate.name hasSuffix:@"(花名)"]) {
        model.headerRelate.name = [model.headerRelate.name substringToIndex:model.headerRelate.name.length -4];
    }
    return model;
}

/**********************************************************************************************/


- (void)updateCountWithNew:(ActivityModel *)newActivity {
    self.commentCount = newActivity.commentCount;
    self.coinCount = newActivity.coinCount;
    
    self.collected = newActivity.isCollected;
    self.reported = newActivity.isReported;
    self.buried = newActivity.isBuried;
}

/*** basic ***/
+ (ActivityUserModel *)userModelWithDict:(NSDictionary *)dict {
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    if (![PublicTool isNull:dict[@"nickname"]]) {
        user.name = dict[@"nickname"];
    }
    
    if ([dict.allKeys containsObject:@"headimgurl"]) {
        user.avatar = dict[@"headimgurl"]?:@"";
    } else if ([dict.allKeys containsObject:@"icon"]) {
        user.avatar = dict[@"icon"]?:@"";
    }
    user.ID = dict[@"person_id"]?:@"";
    user.uID = dict[@"unionid"]?:@"";
    user.usercode = dict[@"usercode"]?:@"";
    user.company = dict[@"company"]?:@"";
    user.position = dict[@"zhiwei"]?:@"";
    user.type = dict[@"user_type"]?:@"";
    user.desc = dict[@"desc"]?:@"";
    if (![PublicTool isNull:dict[@"uuid"]]) {
        user.uuID = dict[@"uuid"];
    }
    
    if (![PublicTool isNull:@"claim_type"] && [dict[@"claim_type"] isEqualToString:@"2"]) {
        user.type = @"person";
    } else {
        user.type = @"user";
    }
    
    if (![PublicTool isNull:dict[@"is_focus"]]) {
        user.isFollowed = [dict[@"is_focus"] boolValue];
    }
    return user;
}
+ (ActivityUserModel *)userModelWithUserInfo:(NSDictionary *)dict {
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    if (![PublicTool isNull:dict[@"nickname"]]) {
        user.name = dict[@"nickname"]?:@"";
    }
    if (![PublicTool isNull:dict[@"headimgurl"]]) {
        user.avatar = dict[@"headimgurl"]?:@"";
    } else if (![PublicTool isNull:dict[@"icon"]]) {
        user.avatar = dict[@"icon"]?:@"";
    }
    
    user.ID = dict[@"person_id"]?:@"";
    user.uID = dict[@"unionid"]?:@"";
    user.usercode = dict[@"usercode"]?:@"";
    user.company = dict[@"company"]?:@"";
    user.position = dict[@"zhiwei"]?:@"";
    user.type = dict[@"user_type"]?:@"";
    user.desc = dict[@"desc"]?:@"";
    
    if (![PublicTool isNull:dict[@"desc"]]) {
        user.desc = dict[@"desc"];
    } else if (![PublicTool isNull:dict[@"company"]]) {
        NSString *desc = dict[@"company"];
        if (![PublicTool isNull:dict[@"zhiwei"]]) {
            desc = [NSString stringWithFormat:@"%@ %@", dict[@"zhiwei"],desc];
        }
        user.desc = desc;
    }
    
    if (![PublicTool isNull:@"claim_type"]) {
        NSInteger c = [dict[@"claim_type"] integerValue];
        if (c == 2) {
            user.type = @"person";
        } else {
            user.type = @"user";
        }
    } else {
        user.type = @"user";
    }
    
    return user;
}

+ (ActivityUserModel *)anonymousUserModel {
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    user.name = @"匿名用户";
    user.avatar = @"http://img.798youxi.com/product/upload/5b03bcfe486e0.png";
    return user;
}

+ (ActivityRelateModel *)anonymousRelateUserModel {
    ActivityRelateModel *relate = [[ActivityRelateModel alloc] init];
    relate.name = @"匿名用户";
    relate.image = @"http://img.798youxi.com/product/upload/5b03bcfe486e0.png";
    relate.qmpIcon = @"activity_author";
    relate.desc = @"";
    relate.type = @"user";
    relate.isAuthor = YES;
    return relate;
}


@end

@implementation ActivityModel (Detail)
+ (ActivityModel *)detialVcModelWithDict:(NSDictionary *)dict {
    
    ActivityModel *model = [[ActivityModel alloc] init];
    model.user = [self userModelWithDict:dict];
    model.linkInfo = [self activityLinkWithDict:dict];
    
    if ([dict.allKeys containsObject:@"content"]) {
        model.content = dict[@"content"]?:@"";
    } else if ([dict.allKeys containsObject:@"comment"]) {
        model.content = dict[@"comment"]?:@"";
    }
    
    model.createTime = dict[@"create_time"]?:@"";
    model.ID = dict[@"id"]?:@"";
    model.ticket = dict[@"ticket"]?:@"";
    model.act_id = dict[@"act_id"]?:@"";
    //    model.uuid = dict[@"uuid"]?:@"";
    
    if (dict[@"img_url"] && [dict[@"img_url"] isKindOfClass:[NSArray class]]) {
        model.images = dict[@"img_url"]?:@[];
    }
    if (dict[@"images"] && [dict[@"images"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *imgDict in dict[@"images"]) {
            [arr addObject:imgDict[@"url"]];
        }
        model.images = arr;
    }
    
    model.digged = [dict[@"like_status"] boolValue];
    model.diggCount = [dict[@"like_count"] integerValue];
    model.commentCount = [dict[@"comment_num"] integerValue];
    model.toped = [dict[@"top_flag"] boolValue];
    model.coinCount = [dict[@"coin_num"] integerValue];
    model.collected = [dict[@"collect"] boolValue];
    model.reported = [dict[@"report"] boolValue];
    model.buried = [dict[@"tread"] boolValue];
    
    
    model.anonymous = [dict[@"anonymous"] boolValue];
    if (![PublicTool isNull:dict[@"anonymous"]]) {
        model.anonymous = [dict[@"anonymous"] boolValue];
        model.coinCount = [dict[@"coin_num"] integerValue];
    } else if (![PublicTool isNull:dict[@"user_info"]]) {
        NSDictionary *dd = dict[@"user_info"];
        if (![PublicTool isNull:dd[@"anonymous"]]) {
            model.anonymous = [dd[@"anonymous"] boolValue];
        }
    }
    
    
    if ([PublicTool isNull:dict[@"comment_html"]]) {
        model.htmlMedia = [ActivityHtmlMedia htmlMediaWithString:model.content];
    } else {
        model.htmlMedia = [ActivityHtmlMedia htmlMediaWithString:dict[@"comment_html"]];
    }
    model.content = model.htmlMedia.displayText; // fix
    
    model.relates = [self activityRelatesWithDict:dict];
    
    model.isMine = [dict[@"is_mine"] boolValue];
    
    if ([model.user.name containsString:@"机器人"] && model.relates.count > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:[model.relates firstObject]];
        model.followRelates = arr;
        
        NSMutableArray *a = [NSMutableArray arrayWithArray:model.relates];
        [a removeObjectAtIndex:0];
        [a addObject:[self relateModelWithUserInfo:dict]];
        model.relates = a;
    }
    return model;
}


+ (ActivityUserModel *)anonymousUserModel {
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    user.name = @"匿名用户";
    user.avatar = @"http://img.798youxi.com/product/upload/5b03bcfe486e0.png";
    return user;
}



@end
