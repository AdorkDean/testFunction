//
//  CommenNoteEditController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/16.
//  Copyright © 2018年 Molly. All rights reserved.
//评论笔记

#import "BaseViewController.h"
#import "SearchCompanyModel.h"
//#import "CommentModel.h"

@interface NoteEditController : BaseViewController
@property(nonatomic,strong)SearchCompanyModel *searchComM;
@property (copy, nonatomic) void (^publishFinish)(void);
@end
