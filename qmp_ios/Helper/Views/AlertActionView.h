//
//  AlertActionView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/18.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelBtnActin)(void);

typedef void(^SureBtnActin)(void);

@interface AlertActionView : UIView

+ (void)alertViewWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo sureBtnAction:(SureBtnActin)sureBtnAcion;

//投递BP
+ (void)alertViewWithMessage:(NSAttributedString*)message tipInfo:(NSAttributedString*)tipInfo sureBtnAction:(SureBtnActin)sureBtnAcion sureBtnEnabled:(BOOL)sureBtnEnabled;
//投递BP
+ (void)alertViewWithMessage:(NSAttributedString*)message tipInfo:(NSAttributedString*)tipInfo  cancelBtnAction:(CancelBtnActin)cancelBtnAction sureBtnAction:(SureBtnActin)sureBtnAcion sureBtnEnabled:(BOOL)sureBtnEnabled;


+ (void)alertViewWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo cancelTitle:(NSString*)cancelTitle sureBtnTitle:(NSString*)sureBtnTitle  sureBtnEnabled:(BOOL)sureBtnEnabled cancelBtnAction:(CancelBtnActin)cancelBtnAction sureBtnAction:(SureBtnActin)sureBtnAcion;



@end
