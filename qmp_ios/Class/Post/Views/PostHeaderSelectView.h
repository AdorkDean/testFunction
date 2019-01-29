//
//  PostHeaderSelectView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC.h>
@class PostActivityViewModel;
FOUNDATION_EXTERN CGFloat const PostHeaderSelectViewHeight;
@interface PostHeaderSelectView : UIView
@property (nonatomic, strong) UIImageView *leftIconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *lineView;


@property (nonatomic, strong) NSMutableArray *buttons;


- (void)reloadWithSelectedObjects:(NSArray *)objects;

@property (nonatomic, copy) void(^didDeleteObject)(id selectedObject, NSInteger index);
@end
