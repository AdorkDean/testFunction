//
//  PostRelatesView.h
//  qmp_ios
//
//  Created by QMP on 2018/10/16.
//  Copyright © 2018 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostSelectRelateViewModel;
NS_ASSUME_NONNULL_BEGIN

@interface PostRelatesView : UIView
@property (nonatomic, strong) PostSelectRelateViewModel *viewModel;

@property (nonatomic, strong) NSArray *relates;
- (CGFloat)reloadWithSelectedObjects:(NSArray *)objects;


@property (nonatomic, copy) void(^didDeleteObject)(id selectedObject, NSInteger index);
@end

NS_ASSUME_NONNULL_END
