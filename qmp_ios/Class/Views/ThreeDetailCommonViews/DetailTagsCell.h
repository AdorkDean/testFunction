//
//  DetailTagsCell.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.

//画像 标签  项目 机构 人物

#import <UIKit/UIKit.h>
#import "TagsFrame.h"


@interface DetailTagsCell : UITableViewCell

@property(nonatomic,strong)TagsFrame *tagFrame;
@property(nonatomic,assign)BOOL canNotAddTag;
@property(nonatomic,copy)void (^didClickShrinkTag)(BOOL ,TagsFrame * );
@property(nonatomic,copy)void (^didClickAddTag)(void );
@property(nonatomic,copy)void (^didClickTag)(NSString *);
//用在cell中嵌套
- (id)initWithTagString:(NSString*)tagsString clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag;

+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString*)tagsString clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag;
+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString*)tagsString isCompany:(BOOL)company clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag;
- (void)refreshTagsString:(NSString*)tagString;

//
///**
// 刷新,传入原始数据的tagArr
// */
//-(void)refreshUI:(NSArray *)tagArr andTagsFrame:(TagsFrame *)tagsFrame;
@property (nonatomic, assign) BOOL isCompany;
@end
