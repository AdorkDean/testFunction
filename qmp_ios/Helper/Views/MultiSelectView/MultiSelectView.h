//
//  MultiSelectView.h
//  qmp_ios
//
//  Created by QMP on 2018/5/12.
//  Copyright © 2018年 Molly. All rights reserved.
//多选view


#import <UIKit/UIKit.h>

typedef void(^ConfirmSelected)(NSString *selectedString);
@interface MultiSelectView : UIView

-(instancetype)initWithSelectionArr:(NSArray*)selectionArr  selectedArr:(NSArray*)selectedArr confirmSelect:(ConfirmSelected)confirmSelected;

@end
