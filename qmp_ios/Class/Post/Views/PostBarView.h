//
//  PostBarView.h
//  qmp_ios
//
//  Created by QMP on 2018/8/1.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostBarView : UIView
@property (nonatomic, strong, readonly) UIButton *addRelateButton;
@property (nonatomic, strong, readonly) UIButton *addImageButton;
@property (nonatomic, strong, readonly) UIButton *addLinkButton;
@property (nonatomic, strong, readonly) UIButton *anonymousButton;

@property (nonatomic, assign) BOOL anonymous;
@property (nonatomic, copy) NSString *anonymous2;
@property (nonatomic, copy) NSString *degree2;

- (void)showAuthorIfAnonymous:(BOOL)isAnonymous; //资讯中进入强制实名
@end
