//
//  BindCompanyView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindCompanyView : UIView
@property(nonatomic,assign) NSInteger companyCount;
@property(nonatomic,strong) NSMutableArray *selectedCompArr;
@property(nonatomic,strong)NSMutableArray *totalCompanyArr;
@property(nonatomic,assign) BOOL notShowDelBtn;
- (void)reloadCollectionData;
@end
