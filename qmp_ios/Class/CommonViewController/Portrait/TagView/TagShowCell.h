//
//  TagShowCell.h
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagShowCell : UICollectionViewCell

@property (strong, nonatomic) UIView *bgView;

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *textColor;
@property(nonatomic,assign) BOOL  selectedFlag;


@property (copy, nonatomic) void (^deleteCell)(void);


- (void)hideDeleteBtn;

- (void)showDeleteBtn;


@end
