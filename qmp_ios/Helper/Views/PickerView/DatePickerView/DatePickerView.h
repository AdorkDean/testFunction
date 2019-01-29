//
//  DatePickerView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView

@property(nonatomic,copy) NSString *ranksCount; //年月日  YYYY-MM-DD

- (instancetype)initDatePackerWithResponse:(void(^)(NSString*))block;
- (instancetype)initDatePackerWithNumColoum:(NSString*)ranksNum response:(void (^)(NSString *))block; //年月日
//- (instancetype)initDatePackerHaveSoFar:(BOOL)soFar withResponse:(void(^)(NSString*))block;
- (void)show;
- (void)showSoFar;
@end

@interface SLDatePickerView : UIView
- (instancetype)initDatePackerWithResponse:(void(^)(NSString*))block;
- (instancetype)initDatePackerWithNumColoum:(NSString*)ranksNum response:(void (^)(NSString *))block; //年月日
- (void)show;

@end
