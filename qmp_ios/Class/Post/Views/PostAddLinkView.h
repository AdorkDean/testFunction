//
//  PostAddLinkView.h
//  qmp_ios
//
//  Created by QMP on 2018/10/17.
//  Copyright © 2018 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostAddLinkView : UIView
- (void)show;
- (void)hide;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) void (^confirmActionTap)(NSString *url);
@end

NS_ASSUME_NONNULL_END
