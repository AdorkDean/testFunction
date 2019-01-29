//
//  CommonDocumentController.h
//  CommonLibrary
//
//  Created by QMP on 2018/11/6.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <MuPDF/MuDocumentController.h>
#import "ReportModel.h"

NS_ASSUME_NONNULL_BEGIN

enum
{
//    BARMODE_MAIN,
//    BARMODE_SEARCH,
    BARMODE_SLIDER = 10,
    BARMODE_COLLECT,
    BARMODE_SHARE
};

@protocol backFromPDFDelegate <NSObject>

- (void)backFromPDF;

@end

@interface CommonDocumentController : MuDocumentController

@property (strong, nonatomic) ReportModel *pdfModel;


@end

NS_ASSUME_NONNULL_END
