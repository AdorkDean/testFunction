//
//  EaseBubbleView+Share.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2017/12/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (Share)


-(void)setUpShareBubbleView;

- (void)updateShareMargin:(UIEdgeInsets)margin;

- (void)_setupShareBubbleConstraints;

@end
