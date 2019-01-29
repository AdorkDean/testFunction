//
//  QMPIPOLibraryFilterView.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMPIPOLibraryFilterView : UIView
- (void)show;

@property (nonatomic, copy) void(^confirmButtonClick)(NSArray *filterSections);

- (NSArray *)filteBoard;
- (NSArray *)filterPlace;
- (NSArray *)filterTags;
@end
