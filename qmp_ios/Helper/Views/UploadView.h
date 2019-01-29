//
//  UploadView.h
//  qmp_ios
//
//  Created by Molly on 2017/1/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UploadViewDelegate <NSObject>

@optional

- (void)pressCancleDownLoad;

@end

@interface UploadView : UIView
@property (weak, nonatomic) id<UploadViewDelegate> delegate;

+(instancetype)initFrame;
+ (instancetype)initFrameWithInfo:(NSString *)info;
- (void)initData;
- (void)changeProgressWithProgress:(CGFloat)progressNum;

@end
