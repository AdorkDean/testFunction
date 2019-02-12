//
//  QMPActivityCellManager.m
//  qmp_ios
//
//  Created by QMP on 2018/8/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPActivityCellManager.h"

#import "QMPActivityCellModel.h"
#import "ActivityModel.h"
#import "QMPActivityCell.h"

#import "NewsWebViewController.h"
#import "QMPActivityActionView.h"
#import "ActivityShareViewController.h"
#import "ActivityDetailViewController.h"
#import "QMPThemeDetailViewController.h"
#import "PostSelectRelateViewController.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"
#import "SearchJigouModel.h"
#import "SearchPerson.h"
#import "QMPCommunityActivityCell.h"
#import "QMPActivityCellModel.h"
#import "PersonModel.h"

@interface QMPActivityCellManager () <QMPActivityCellDelegate, QMPActivityCellMenuViewDelegate>
@property (nonatomic, strong) QMPActivityCellMenuView *menuView;
@property (nonatomic, weak) UITableViewCell *currentCell;
@end
@implementation QMPActivityCellManager
+ (instancetype)manager {
    return [[self alloc] init];
}
- (BOOL)canGoNext{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return NO;
    }
    return YES;
}
- (void)activityCell:(QMPActivityCell *)cell commentButtonClickForActivity:(ActivityModel *)activity {
    if (![self canGoNext]) {
        return;
    }
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.community = self.isCommunity;
    vc.activityID = activity.ID;
    vc.activityTicket = activity.ticket;
    vc.autoShowCommentInput = activity.commentCount == 0;
    if (activity.headerRelate) {
        vc.relateModel = activity.headerRelate;
    }
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    
    vc.activityCountChanged = ^(ActivityModel *activity2) {
        [cell updateCountWithModel:activity2];
    };
}
- (void)activityCell:(QMPActivityCell *)cell shareButtonClickForActivity:(ActivityModel *)activity {
    QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc]initWithActivity:activity forCommunity:NO];
    ActivityShareViewController *vc = [[ActivityShareViewController alloc] init];
    vc.cellModel = cellModel;
    if (activity.headerRelate) {
        vc.relateModel = activity.headerRelate;
    }
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}


//点赞
- (void)activityCell:(QMPActivityCell *)cell likeButtonClick:(ActivityModel *)activity {
    if (![self canGoNext]) {
        return;
    }
    if ([PublicTool isNull:activity.ID]) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    BOOL zanStatus = !activity.digged;
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:activity.act_id forKey:@"project_id"];
    [mDict setValue:@(zanStatus) forKey:@"like"];
    
    [AppNetRequest likeOrCancelwithParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg: zanStatus == 0?@"取消点赞成功":@"点赞成功"];
            activity.digged = zanStatus;
            activity.diggCount += (zanStatus==0?-1:1);
            
            [(QMPActivityCell *)cell updateCountWithModel:activity];
            [QMPEvent event:@"activity_action_click" label:@"动态点赞"];

        }else{
            
            [PublicTool showMsg:zanStatus == 0?@"取消点赞失败":@"点赞失败"];
        }
    }];
    [QMPEvent event:@"activity_like_click"];
}


- (void)activityCell:(QMPActivityCell *)cell textExpandTap:(BOOL)currentExpandStatus {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    QMPActivityCellModel *model = cell.cellModel;
    model.expanding = !currentExpandStatus;
    [model setNeedLayout];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
- (void)activityCell:(QMPActivityCell *)cell textLinkTap:(ActivityLinkModel *)link {
    if (![self canGoNext]) {
        return;
    }
    NSArray *products = cell.cellModel.activity.relateProducts;
    
    URLModel *model = [[URLModel alloc] init];
    model.url = link.linkUrl;
    NewsWebViewController *vc = [[NewsWebViewController alloc] init];
    vc.urlModel = model;
    if (products.count > 0) {
        ActivityRelateModel *relate = [products firstObject];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        // @{@"company":newsModel.product,@"lunci":newsModel.lunci,@"icon":newsModel.icon,@"yewu":newsModel.yewu};
//        [dict setObject:relate.name forKey:@"company"];
//        [dict setObject:relate.lunci forKey:@"lunci"];
//        [dict setObject:relate.image forKey:@"icon"];
//        [dict setObject:relate.yewu forKey:@"yewu"];
//        NSString *detail = [NSString stringWithFormat:@"http://qimingpian.com/detail?ticket=%@&id=%@", relate.ticket, relate.ticketID];
        [dict setObject:relate.ticket forKey:@"ticket"];
        [dict setObject:relate.ticketID forKey:@"id"];
        vc.requestDic = dict;
    }
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"news_webpage_enter" label:@"新闻_动态"];
}
- (void)activityCell:(QMPActivityCell *)cell detailLinkTap:(NSString *)link {
    if (![self canGoNext]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToDetail:link];
}

- (void)doActionWithItem:(NSString *)item activity:(ActivityModel *)a {
    if (![self canGoNext]) {
        return;
    }
    if ([item containsString:@"收藏"]) {
        if (!a.isCollected) {
            [QMPEvent event:@"tab_activity_more_collectclick"];
        }
        [self collectActivity:a];
    } else if ([item containsString:@"关注"]){
        [self buryActivity:a];
    } else if ([item containsString:@"举报"]){
        if (a.isReported) {
            [PublicTool showMsg:@"举报不能取消"];
            return;
        }
        [self reportActivity:a];
    }
}

- (void)collectActivity:(ActivityModel *)a {
    NSDictionary *dict = @{
                           @"action_type": @"collection",
                           @"activity_ticket": a.ticket,
                           @"action_flag": a.isCollected ? @"0": @"1"
                           };
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/setActivityUserAction" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            if ([PublicTool isNull:resultData[@"message"]]) {
                [PublicTool showMsg:@"操作失败"];
                return ;
            }
            if (![resultData[@"message"] isEqualToString:@"success"]) {
                [PublicTool showMsg:resultData[@"message"]];
                return ;
            }
            [PublicTool showMsg:a.isCollected?@"取消收藏成功":@"收藏成功"];
            if (!a.isCollected) {
                [QMPEvent event:@"activity_action_click" label:@"动态收藏成功"];
            }
            [a setCollected:!a.isCollected];
            if (self.activityDidChanged) {
                self.activityDidChanged();
            }
        }
    }];
}
- (void)buryActivity:(ActivityModel *)activity {

}
- (void)reportActivity:(ActivityModel *)a {
    if (a.isReported) {
        [PublicTool showMsg:@"举报不能取消"];
        return;
    }
    NSDictionary *dict = @{
                           @"action_type": @"report",
                           @"activity_ticket": a.ticket,
                           @"action_flag": @"1"
                           };
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/setActivityUserAction" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            if ([PublicTool isNull:resultData[@"message"]]) {
                [PublicTool showMsg:@"操作失败"];
                return ;
            }
            if (![resultData[@"message"] isEqualToString:@"success"]) {
                [PublicTool showMsg:resultData[@"message"]];
                return ;
            }
            [PublicTool showMsg:a.reported?@"取消举报成功":@"举报成功"];
            [a setReported:!a.isReported];
            if (self.activityDidChanged) {
                self.activityDidChanged();
            }
        }
    }];
}

- (void)deleteActivity:(ActivityModel *)activity cell:(UITableViewCell *)cell {
    
    __weak typeof(self) weakSelf = self;
    [PublicTool alertActionWithTitle:@"提示" message:@"你确定要删除这条动态吗？" cancleAction:^{
        
    } sureAction:^{
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:activity.act_id?:@"" forKey:@"act_id"];
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/deleteActivity" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                [PublicTool showMsg:@"删除成功"];
                
                if (weakSelf.activityDidDeleled) {
                    weakSelf.activityDidDeleled(indexPath);
                }
            }
        }];
    }];
}

- (void)activityCell:(UITableViewCell *)cell rightButtonClick:(ActivityModel *)activity isDelete:(BOOL)isDelete {
    if (isDelete) {
        if (![self canGoNext]) {
            return;
        }
        [self deleteActivity:activity cell:cell];
    } else {
        QMPActivityActionView *view = [[QMPActivityActionView alloc] initWithActivity:activity];
        [view show];
        
        __weak typeof(self) weakSelf = self;
        view.activityActionItemTap = ^(NSString *item) {
            [weakSelf doActionWithItem:item activity:activity];
        };
        
    }
}
- (void)activityCell:(QMPActivityCell *)cell followButtonClick:(ActivityModel *)activity {
    if (![self canGoNext]) {
        return;
    }
   
    ActivityUserModel *user = activity.user;
    ActivityRelateModel *relate = activity.headerRelate;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (relate) {
        [param setValue:relate.type forKey:@"type"];
        [param setValue:@(!relate.isFollowed) forKey:@"work_flow"];
        [param setValue:relate.ticket?:@"" forKey:@"ticket"];
    } else {
        
        [param setValue:@(!user.isFollowed) forKey:@"work_flow"];
        if (![PublicTool isNull:user.ID]) {
            [param setValue:@"person" forKey:@"type"];
        } else if (![PublicTool isNull:user.uID]){
            [param setValue:@"user" forKey:@"type"];
        }
        [param setValue:user.uuID?:@"" forKey:@"ticket"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"common/commonFocus" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            if (activity.headerRelate) {
                relate.isFollowed = !relate.isFollowed;
                [PublicTool showMsg:relate.isFollowed?@"关注成功":@"取消成功"];
            } else {
                user.isFollowed = !user.isFollowed;
                [PublicTool showMsg:user.isFollowed?@"关注成功":@"取消成功"];
            }
            [cell updateFollowStatusWithModel:activity];
            if (self.activityFocusChange) {
                self.activityFocusChange(activity);
            }
        } else {
            [PublicTool showMsg:@"操作失败"];
        }
    }];
}

- (void)activityCell:(QMPActivityCell *)cell headerUserTap:(ActivityUserModel *)user {
    if (![self canGoNext]) {
        return;
    }
    
    if (![PublicTool isNull:user.ID]) {
        
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:user.uuID];

    } else if (![PublicTool isNull:user.uID]) {
        [[AppPageSkipTool shared] appPageSkipToUserDetail:user.uID];
    }
    

}
- (void)activityCell:(QMPActivityCell *)cell headerViewTap:(ActivityRelateModel *)relateItem {
    ActivityModel *model = cell.cellModel.activity;
    [self redirectDetailWithRelateItem:relateItem anonymous:model.anonymous];
}

- (void)activityCell:(QMPActivityCell *)cell relateItemTap:(ActivityRelateModel *)item {
    
    ActivityModel *activity = cell.cellModel.activity;
    if (activity.editing) {
        
    } else {
        [self redirectDetailWithRelateItem:item anonymous:activity.anonymous];
    }
}
- (void)redirectDetailWithRelateItem:(ActivityRelateModel *)relateItem anonymous:(BOOL)anonymous {
    
    if (![self canGoNext]) {
        return;
    }
    if (relateItem.isAuthor && anonymous) {
        return;
    }
    
    if ([relateItem.type isEqualToString:@"jigou"]) {
        
        NSDictionary *dict = @{@"id": relateItem.ticketID?:@"", @"ticket": relateItem.ticket?:@""};
        [[AppPageSkipTool shared] appPageSkipToJigouDetail:dict];

    } else if ([relateItem.type isEqualToString:@"product"]) {
        NSDictionary *dict = @{@"id": relateItem.ticketID?:@"", @"ticket": relateItem.ticket?:@""};
        [[AppPageSkipTool shared] appPageSkipToProductDetail:dict];
        
    } else if ([relateItem.type isEqualToString:@"person"]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:relateItem.projectID];

    } else if ([relateItem.type isEqualToString:@"theme"]) {
        QMPThemeDetailViewController *vc = [[QMPThemeDetailViewController alloc] init];
        vc.ticketID = relateItem.ticketID;;
        vc.ticket = relateItem.ticket;
        [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
        
    } else if ([relateItem.type isEqualToString:@"user"]) {
        if (anonymous) {
            return;
        }
        [[AppPageSkipTool shared] appPageSkipToUserDetail:relateItem.uID];
    }
}
#pragma mark - EditRelates
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell editRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel {
    ActivityModel *activity = cellModel.activity;
    activity.editing = YES;
    [cellModel setNeedLayout];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [QMPEvent event:@"activity_cellrelateedit_click"];
}
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell deleteRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel {
    
    ActivityModel *activity = cellModel.activity;
    [activity.relates removeObject:item];
    [cellModel setNeedLayout];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [QMPEvent event:@"activity_cellrelate_deleteclick"];
}
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell confirmRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel {
    ActivityModel *activity = cellModel.activity;
    activity.editing = NO;
    [cellModel setNeedLayout];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:activity.act_id forKey:@"id"];
    
    NSMutableArray *products = [NSMutableArray array];
    NSMutableArray *jigous = [NSMutableArray array];
    NSMutableArray *persons = [NSMutableArray array];
    NSMutableArray *themes = [NSMutableArray array];
    for (ActivityRelateModel *relate in cellModel.displayRelates) {
        if ([relate.type isEqualToString:@"jigou"]) {
            [jigous addObject:relate.ticket];
        } else if ([relate.type isEqualToString:@"product"]) {
            [products addObject:relate.ticket];
        } else if ([relate.type isEqualToString:@"theme"]) {
            [themes addObject:relate.ticket];
        } else if ([relate.type isEqualToString:@"person"]) {
            [persons addObject:relate.ticket];
        }
    }
    if (products.count) {
        [dict setObject:[products componentsJoinedByString:@"|"] forKey:@"product"];
    }
    if (jigous.count) {
        [dict setObject:[jigous componentsJoinedByString:@"|"] forKey:@"agency"];
    }
    if (persons.count) {
        [dict setObject:[persons componentsJoinedByString:@"|"] forKey:@"person"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/updateDynamicRelation" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            if (self.activityDidChanged) {
                self.activityDidChanged();
            }
        }
    }];
    [QMPEvent event:@"activity_cellrelateFinish_click"];
}
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell addRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel {
    PostSelectRelateViewController *vc = [[PostSelectRelateViewController alloc] init];
    vc.title = @"选择关联对象";
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    
    ActivityModel *activity = cellModel.activity;
    

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    __weak typeof(self) weakSelf = self;
    vc.didSelectedObject = ^(id selectedObject, NSString *type) {
        ActivityRelateModel *m = [weakSelf aaRelateObject:selectedObject type:type];
        for (ActivityRelateModel *r in activity.relates) {
            if ([r.ticket isEqualToString:m.ticket]) {
                [PublicTool showMsg:@"不能重复添加"];
                return ;
            }
        }
        [activity.relates addObject:m];
        [cellModel setNeedLayout];
        [UIView performWithoutAnimation:^{
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    };
    [QMPEvent event:@"activity_cellrelate_addclick"];
}
- (ActivityRelateModel *)aaRelateObject:(id)object type:(NSString *)type {
    ActivityRelateModel *model = [[ActivityRelateModel alloc] init];
    if ([object isKindOfClass:[SearchCompanyModel class]]) {
        SearchCompanyModel *m = (SearchCompanyModel*)object;
        model.name = m.product;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.ticket = d[@"ticket"];
        model.ticketID = d[@"id"];
        model.type = @"product";
        model.image = m.icon;
        model.qmpIcon = @"activity_product";
    } else if ([object isKindOfClass:[SearchJigouModel class]]) {
        SearchJigouModel *m = (SearchJigouModel *)object;
        model.name = m.jigou_name;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.ticket = d[@"ticket"];
        model.ticketID = d[@"id"];
        model.type = @"jigou";
        model.image = m.icon;
        model.qmpIcon = @"activity_product";
    } else if ([object isKindOfClass:[PersonModel class]]) {
        PersonModel *m = (PersonModel *)object;
        model.name = m.name;
        model.ID = m.ticket;
        model.ticket = m.ticket;
        model.projectID = m.person_id;
        model.type = @"person";
        model.image = m.icon;
        model.qmpIcon = @"activity_user";
    } else if ([object isKindOfClass:[SearchPerson class]]) {
        SearchPerson *m = (SearchPerson *)object;
        model.name = m.name;
        model.ID = m.ticket;
        model.ticket = m.ticket;
        model.projectID = m.person_id;
        model.type = @"person";
        model.image = m.icon;
        model.qmpIcon = @"activity_user";
    } else if ([object isKindOfClass:[CompanyDetailModel class]]) {
        CompanyDetailModel *m = (CompanyDetailModel *)object;
        model.ID = m.ticket;
        model.name = m.company_basic.product;
        model.type = @"product";
        model.image = m.company_basic.icon;
        model.qmpIcon = @"activity_product";
    } else if ([object isKindOfClass:[OrganizeItem class]]) {
        OrganizeItem *m = (OrganizeItem *)object;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.name = m.name;
        model.type = @"jigou";
        model.image = m.icon;
        model.qmpIcon = @"activity_product";
    }
    return model;
}

#pragma mark - 123
- (void)activityCell:(UITableViewCell *)cell userTap:(ActivityUserModel *)user {
    if (![self canGoNext]) {
        return;
    }
    
    if (![PublicTool isNull:user.ID]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:user.ID];
    } else if (![PublicTool isNull:user.uID]) {
        [[AppPageSkipTool shared] appPageSkipToUserDetail:user.uID];
    }
}
- (void)activityCell:(UITableViewCell *)cell moreButtonClick:(UIButton *)button withActivity:(ActivityModel *)activity {
    if (self.currentCell && ![self.currentCell isEqual:cell]) {
        [self.menuView removeFromSuperview];
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.frame = CGRectMake(button.left, button.centerY-17.5, 166, 35);
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.transform = CGAffineTransformMakeTranslation(-166, 0);
        }];
        [cell.contentView insertSubview:self.menuView belowSubview:button];
        self.currentCell = cell;
        self.menuView.activity = activity;
    } else {
        
        if (self.menuView.superview) {
            self.currentCell = nil;
            [UIView animateWithDuration:0.2 animations:^{
                self.menuView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self.menuView removeFromSuperview];
            }];
            
        } else {
            self.currentCell = cell;
            self.menuView.frame = CGRectMake(button.left, button.centerY-17.5, 166, 35);
            [UIView animateWithDuration:0.2 animations:^{
                self.menuView.transform = CGAffineTransformMakeTranslation(-166, 0);
            }];
            [cell.contentView insertSubview:self.menuView belowSubview:button];
            self.menuView.activity = activity;
        }
    }
}
- (void)removeMenuView {
    if (self.menuView.superview) {
        self.currentCell = nil;
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.menuView removeFromSuperview];
        }];
    }
}
- (QMPActivityCellMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[QMPActivityCellMenuView alloc] init];
        _menuView.delegate = self;
    }
    return _menuView;
}
- (void)activityCellMenuViewCollectButtonClick {
    [self removeMenuView];
    [self collectActivity:self.menuView.activity];
}
- (void)activityCellMenuViewReportButtonClick {
    [self removeMenuView];
    [self reportActivity:self.menuView.activity];
}
- (void)activityCell:(id<QMPActivityCellMethod>)cell diggButtonClick:(ActivityModel *)activity {
    if (![self canGoNext]) {
        return;
    }
    if ([PublicTool isNull:activity.ID]) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    BOOL zanStatus = !activity.digged;
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:activity.act_id forKey:@"project_id"];
    [mDict setValue:@(zanStatus) forKey:@"like"];
    
    [AppNetRequest likeOrCancelwithParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg: zanStatus == 0?@"取消点赞成功":@"点赞成功"];
            activity.digged = zanStatus;
            activity.diggCount += (zanStatus==0?-1:1);
            
            if ([cell respondsToSelector:@selector(updateCountWithModel:)]) {
                [cell updateCountWithModel:activity];
            }
            if (self.activityDidChanged) {
                self.activityDidChanged();
            }
            
            [QMPEvent event:@"activity_action_click" label:@"动态点赞"];
            
        }else{
            
            [PublicTool showMsg:zanStatus == 0?@"取消点赞失败":@"点赞失败"];
        }
    }];
    [QMPEvent event:@"activity_like_click"];
}
- (void)activityCell:(UITableViewCell *)cell textExpandTap:(BOOL)currentExpandStatus withCellModel:(QMPActivityCellModel *)model {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    model.expanding = !currentExpandStatus;
    [model setNeedLayout];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

@end
