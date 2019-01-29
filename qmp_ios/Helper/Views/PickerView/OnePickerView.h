//
//  OnePickerView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnePickerView : UIView

- (instancetype)initDatePackerWithResponse:(void(^)(NSString*))block dataSource:(NSArray*)dataArr;

- (void)show;

@end
