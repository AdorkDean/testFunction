//
//  CreateProductViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface CreateProductViewController : BaseViewController
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSMutableArray *productData;
@end
