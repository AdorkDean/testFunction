//
//  EditInfoViewController.h
//  qmp_ios
//
//  Created by molly on 2017/3/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SureBtnClick)(NSString *value);
typedef void(^BackToLastpage)(void);

@protocol EditInfoViewControllerDelegate <NSObject>

- (void)updateInfoSuccess:(NSString *)value withKey:(NSString *)key;
@end

@interface EditInfoViewController : BaseViewController

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *userid;
@property (weak, nonatomic) id <EditInfoViewControllerDelegate> delegate;
@property (copy, nonatomic) SureBtnClick sureBtnClick;
@property (copy, nonatomic) BackToLastpage backToLastpage;

@end
