//
//  QMPTagView.h
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMPTagView : UIView

@property(nonatomic,assign) BOOL actionKeyboard;
@property(nonatomic,strong)NSMutableArray *tagtitleArr;
@property(nonatomic,copy)NSString *searchString;

- (void)setEditArr:(NSMutableArray*)tagtitleArr myTagArr:(NSMutableArray*)myTagArr;
@end
