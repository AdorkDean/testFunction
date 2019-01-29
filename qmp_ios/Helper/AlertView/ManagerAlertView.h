//
//  ManagerAlertView.h
//  qmp_ios
//
//  Created by Molly on 16/8/20.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagsItem.h"
@class ManagerAlertView;
@protocol ManagerAlertDelegate <NSObject>

@optional
- (void)changeName:(TagsItem *)tag;

- (void)createFolder:(TagsItem *)tag inId:(NSString *)userfolderid;

- (void)pressCancleChangeName;

- (void)addAlbumToSelf:(NSString *)newName;
- (void)cancleCollectAlbumToSelf;
// new
- (void)managerAlertView:(ManagerAlertView *)view addTag:(NSString *)tagName;
@end

@interface ManagerAlertView : UIView

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UIButton *confirmBtn;

@property (strong, nonatomic) NSMutableArray *nameArr;
@property (strong, nonatomic) TagsItem *tagItem;

@property (weak, nonatomic) UIViewController *currentVC;
@property (strong, nonatomic) NSString *action;

@property (weak, nonatomic) id<ManagerAlertDelegate> delegata;

+ (instancetype)initFrame;

- (void)initViewWithTitle:(NSString *)title;

- (void)initViewWithFolder:(NSString *)folder aTitle:(NSString *)title;

- (void)initViewWithTitle:(NSString *)title withConfirmSelector:(SEL)confirmSelector;

- (void)initViewWithTitle:(NSString *)title withCancleSelector:(SEL)cancleSelector withConfirmSelector:(SEL)confirmSelector;

@property (nonatomic, strong) NSString *bpID;
@property (nonatomic, strong) NSString *oldType;
@end
