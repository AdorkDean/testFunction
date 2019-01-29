//
//  CardUploadTool.h
//  qmp_ios
//
//  Created by QMP on 2018/4/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardUploadTool : NSObject


+(instancetype)shared;

- (void)uploadCardsImages:(NSArray*)cardImgs finishOneImage:(void (^)(void)) finishOne;

- (void)showUploadView;

@end
