//
//  PickPhotosView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PickPhotosView;
@protocol PickPhotosViewDelegate <NSObject>
@optional
- (void)pickPhotosView:(PickPhotosView *)view deleteButtonClick:(NSInteger)index;
- (void)pickPhotosView:(PickPhotosView *)view photoViewClick:(NSInteger)index;
@end

@interface PickPhotosView : UIView
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, weak) id<PickPhotosViewDelegate> delegate;
@end
