//
//  UploadReportView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/25.
//  Copyright © 2018年 Molly. All rights reserved.
//上传报告封装 回调回去一个ReportModel

#import <UIKit/UIKit.h>
#import "ReportModel.h"


@interface UploadReportView : UIView

@property (copy, nonatomic)void(^uploadSuccess)(ReportModel* report);

- (UploadReportView*)initWithIsBP:(BOOL)isBP uploadSuccess:(void(^)(ReportModel* report))uplaodSuccessBlock;

@end
