//
//  PostTextView.h
//  qmp_ios
//
//  Created by QMP on 2018/10/17.
//  Copyright © 2018 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^postTextHeightChangedBlock)(NSString * _Nullable text,CGFloat textHeight);
NS_ASSUME_NONNULL_BEGIN

@interface PostTextView : UITextView


@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic,strong) UIFont *placeholderFont;

@property (nonatomic, assign) NSUInteger maxNumberOfLines;

@property (nonatomic, assign) CGFloat minHeight;


@property (nonatomic, copy) postTextHeightChangedBlock textChangedBlock;

- (void)textValueDidChanged:(postTextHeightChangedBlock)block;

@end

NS_ASSUME_NONNULL_END
