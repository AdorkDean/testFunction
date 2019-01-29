//
//  VerticalToplabel.h
//  qmp_ios
//
//  Created by QMP on 2018/5/14.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
@interface VerticalToplabel : UILabel
@property(nonatomic,assign) BOOL copyEnabled;
@property (nonatomic) VerticalAlignment verticalAlignment;
@end
