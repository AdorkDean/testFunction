//
//  ActivityCommentModel.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityCommentModel.h"
#import "ActivityModel.h"
#import <YYText.h>
@implementation ActivityCommentModel
+ (ActivityCommentModel *)activityDetail_commentModelWithResponse:(NSDictionary *)resp {
    ActivityCommentModel *model = [[ActivityCommentModel alloc] init];
    
    ActivityUserModel *user = [[ActivityUserModel alloc] init];
    
    user.ID = resp[@"person_id"]?:@"";
    user.uID = resp[@"unionid"]?:@"";
    user.uuID = resp[@"uuid"]?:@"";
    user.name = resp[@"nickname"]?:@"";
    user.usercode = resp[@"usercode"]?:@"";

    if (![PublicTool isNull:resp[@"icon"]]) {
        user.avatar = resp[@"icon"]?:@"";
    } else if (![PublicTool isNull:resp[@"headimgurl"]]) {
        user.avatar = resp[@"headimgurl"]?:@"";
    }
    user.type = resp[@"user_type"];
    model.user = user;
    
    model.ID = resp[@"id"]?:@"";
    model.content = resp[@"comment"]?:@"";
    if (![PublicTool isNull:resp[@"anonymous"]]) {
        model.anonymous = [resp[@"anonymous"] isEqualToString:@"1"];
    }
    
    model.createAt = resp[@"create_time"]?:@"";
    model.like_status = [resp[@"like_status"] isEqualToString:@"1"];
    model.like_num = resp[@"like_num"]?:@"";
    model.likeCount = [resp[@"like_num"] integerValue];
    
    NSDictionary *companyDict = resp[@"company_info"];
    ActivityCompanyModel *company = [[ActivityCompanyModel alloc] init];
    company.company = companyDict[@"company"];
    company.role = [PublicTool roleTextWithRequestStr:companyDict[@"role"]];
    company.position = companyDict[@"zhiwu"];
    model.company = company;

    model.textLayout = [self layoutText:model.content];
    model.anonymous_degree = ![PublicTool isNull:resp[@"anonymous_degree"]] ? [resp[@"anonymous_degree"] integerValue]:1;

    if (model.anonymous && (model.anonymous_degree == 1) && [PublicTool isNull:model.company.role]) {
        model.cellHeight = 40 + model.textLayout.textBoundingSize.height + 13;
    }else{
        model.cellHeight = 55 + model.textLayout.textBoundingSize.height + 13;
    }
    return model;
}

+ (YYTextLayout *)layoutText:(NSString *)comment {
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(SCREENW-26, MAXFLOAT)];
    
    NSMutableAttributedString *mText = [[NSMutableAttributedString alloc] initWithString:comment?:@""
                                                                              attributes:@{
                                                                                           NSFontAttributeName: [UIFont systemFontOfSize:15],
                                                                                           }];
    mText.yy_lineSpacing = 6.0;
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:mText];
    return layout;
}


@end
