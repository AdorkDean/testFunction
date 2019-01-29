//
//  DataHandle.h
//  qmp_ios
//
//  Created by Molly on 2017/2/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DataHandleDelegate<NSObject>
@optional
- (void)pressOKOnDataHandleAlertView;
@end
@interface DataHandle : NSObject
@property (weak, nonatomic) id <DataHandleDelegate> delegate;
- (void)handleOtherRetStatus:(NSString *)status onCurrentVC:(UIViewController *)currentVC withAction:(NSString *)actionStr withData:(NSDictionary *)dict;
@end
