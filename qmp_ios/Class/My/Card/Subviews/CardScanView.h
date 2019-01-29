//
//  CardScanView.h
//  qmp_ios
//
//  Created by QMP on 2017/12/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardScanView : UIScrollView

@property(nonatomic,strong) NSArray *imgArr;

- (void)refreshSubViews;

@end
