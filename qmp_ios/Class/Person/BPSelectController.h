//
//  BPSelectController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface BPSelectController : BaseViewController

@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (copy, nonatomic) NSString *personId;
@property(nonatomic,assign) BOOL isToMe;
@property (copy, nonatomic) void(^ clearSelectedReport)( );
@property (copy, nonatomic) void(^ selectedReport)(ReportModel *report);

- (void)beginSearch:(NSString*)text;
- (void)disAppear;
- (void)clearSelectedReportState;

@property (nonatomic, strong) ReportModel *sourceReport;
@end
