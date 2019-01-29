//
//  FinanceEventFilterView.h
//  qmp_ios
//
//  Created by QMP on 2018/8/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FinanceEventFilterView : UIView

- (void)show;

+ (NSMutableArray *)areaDataOfLastFilter;
+ (NSMutableArray *)roundDataOfLastFilter;

@property (nonatomic, copy) void(^confirmButtonClick)(NSArray *filterSections);
@end

@interface QMPFilterItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *selected;

@property (nonatomic, strong) NSMutableArray *subItems;
@end


@interface QMPFilterSection : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSMutableArray *selectedArray2;
@property (nonatomic, strong) NSMutableArray *oldSelectedArray;
@property (nonatomic, assign) BOOL expanding;
@end
